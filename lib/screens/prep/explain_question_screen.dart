import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/mentor_keys_provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/services/mentor_service.dart';

/// Dedicated "flag a problem and learn it with AI" screen.
///
/// Shows the question, the correct answer, the user's answer, then lets the
/// student get an AI explanation (and an "Explain differently" follow-up).
/// Reuses [MentorService] - no new AI plumbing.
class ExplainQuestionScreen extends StatefulWidget {
  const ExplainQuestionScreen({super.key, required this.attempt});

  final QuestionAttempt attempt;

  @override
  State<ExplainQuestionScreen> createState() => _ExplainQuestionScreenState();
}

class _ExplainQuestionScreenState extends State<ExplainQuestionScreen> {
  final _mentor = MentorService();
  bool _loading = false;
  String? _answer;
  List<String> _sources = const [];

  QuestionAttempt get _q => widget.attempt;

  Future<void> _explain({bool simpler = false}) async {
    if (_loading) return;
    final keys = context.read<MentorKeysProvider>();
    final prep = context.read<PrepProvider>();

    // No AI available: surface the stored explanation instead of a generic
    // offline tip.
    if (!keys.useCloudMentor && !keys.hasAnyKey) {
      setState(() {
        _answer = (_q.explanation != null && _q.explanation!.trim().isNotEmpty)
            ? _q.explanation!.trim()
            : 'Add a Gemini/OpenAI key or enable the cloud mentor in Settings '
                  'to get an AI explanation for this question.';
        _sources = const ['offline'];
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final reply = await _mentor.explainQuestion(
        question: _q,
        prep: prep,
        simpler: simpler,
        geminiKey: keys.geminiApiKey,
        openaiKey: keys.openaiApiKey,
        useCloud: keys.useCloudMentor,
      );
      if (!mounted) return;
      setState(() {
        _answer = reply.answer;
        _sources = reply.sources;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mentor error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    final flagged = prep.isFlagged(_q.questionId);
    final chapterTitle =
        findChapterContext(_q.chapterId)?.$2.title ?? _q.chapterId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn this problem'),
        actions: [
          IconButton(
            tooltip: flagged ? 'Remove flag' : 'Flag to revise',
            icon: Icon(flagged ? Icons.flag : Icons.flag_outlined),
            color: flagged ? AppColors.warning : null,
            onPressed: () => prep.toggleFlag(_q),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          Chip(label: Text(chapterTitle), visualDensity: VisualDensity.compact),
          const SizedBox(height: 12),
          Text(
            _q.prompt,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...List.generate(_q.options.length, (i) {
            final isCorrect = i == _q.correctIndex;
            final isPicked = i == _q.selectedIndex;
            Color? border;
            if (isCorrect) {
              border = AppColors.mint;
            } else if (isPicked) {
              border = AppColors.danger;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: border ?? AppColors.border,
                  width: border != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(_q.options[i])),
                  if (isCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.mint,
                      size: 18,
                    )
                  else if (isPicked)
                    const Icon(Icons.cancel, color: AppColors.danger, size: 18),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSizes.paddingM),
          if (_answer == null)
            FilledButton.icon(
              onPressed: _loading ? null : () => _explain(),
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Thinking...' : 'Explain with AI'),
            )
          else ...[
            Card(
              color: AppColors.bgSoft,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI explanation',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        if (_sources.isNotEmpty)
                          Text(
                            _sources.join(', '),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_answer!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _explain(simpler: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Explain differently'),
            ),
          ],
          const SizedBox(height: AppSizes.paddingL),
          StudyTopicSection(chapterId: _q.chapterId),
        ],
      ),
    );
  }
}
