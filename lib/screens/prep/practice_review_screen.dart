import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/explain_question_screen.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/screens/prep/pyq_quiz_screen.dart';

/// Shared post-attempt review used by both mocks and PYQ drills.
///
/// Shows a score summary, accuracy by chapter, a retake CTA for the weakest
/// chapter, and a filterable list (All / Wrong / Flagged) of question cards
/// with the user's answer vs the correct answer and explanation.
enum _ReviewFilter { all, wrong, flagged }

class PracticeReviewScreen extends StatefulWidget {
  const PracticeReviewScreen({super.key, required this.session});

  final PracticeSession session;

  @override
  State<PracticeReviewScreen> createState() => _PracticeReviewScreenState();
}

class _PracticeReviewScreenState extends State<PracticeReviewScreen> {
  _ReviewFilter _filter = _ReviewFilter.wrong;

  PracticeSession get _session => widget.session;

  List<QuestionAttempt> get _filtered {
    switch (_filter) {
      case _ReviewFilter.all:
        return _session.attempts;
      case _ReviewFilter.wrong:
        return _session.attempts.where((a) => a.isWrong).toList();
      case _ReviewFilter.flagged:
        return _session.attempts.where((a) => a.markedForReview).toList();
    }
  }

  String _chapterTitle(String chapterId) =>
      findChapterContext(chapterId)?.$2.title ?? chapterId;

  @override
  Widget build(BuildContext context) {
    final s = _session;

    // Accuracy by chapter.
    final byChapter = <String, (int correct, int total)>{};
    for (final a in s.attempts) {
      final cur = byChapter[a.chapterId] ?? (0, 0);
      byChapter[a.chapterId] = (cur.$1 + (a.isCorrect ? 1 : 0), cur.$2 + 1);
    }

    // Weakest chapter for the retake CTA.
    String? weakest;
    var weakestAcc = double.infinity;
    byChapter.forEach((ch, t) {
      final acc = t.$2 == 0 ? 0.0 : t.$1 / t.$2;
      if (acc < weakestAcc) {
        weakestAcc = acc;
        weakest = ch;
      }
    });

    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          _SummaryCard(session: s),
          const SizedBox(height: AppSizes.paddingM),
          if (byChapter.isNotEmpty) ...[
            Text(
              'Accuracy by chapter',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  children: byChapter.entries.map((e) {
                    final acc = e.value.$2 == 0 ? 0.0 : e.value.$1 / e.value.$2;
                    final color = acc >= 0.7
                        ? AppColors.mint
                        : acc >= 0.4
                        ? AppColors.warning
                        : AppColors.danger;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              _chapterTitle(e.key),
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: acc,
                                minHeight: 10,
                                color: color,
                                backgroundColor: color.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(acc * 100).round()}%',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
          ],
          if (weakest != null) ...[
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PyqQuizScreen(chapterId: weakest!),
                ),
              ),
              icon: const Icon(Icons.replay_outlined),
              label: Text('Retake weak topic: ${_chapterTitle(weakest!)}'),
            ),
            const SizedBox(height: AppSizes.paddingM),
            StudyTopicSection(chapterId: weakest!, limit: 3),
          ],
          const SizedBox(height: AppSizes.paddingL),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('All (${s.total})', _ReviewFilter.all),
              _filterChip('Wrong (${s.incorrectCount})', _ReviewFilter.wrong),
              _filterChip(
                'Flagged (${s.attempts.where((a) => a.markedForReview).length})',
                _ReviewFilter.flagged,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          if (filtered.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.mint,
                ),
                title: Text(
                  _filter == _ReviewFilter.wrong
                      ? 'No wrong answers here.'
                      : 'Nothing to show for this filter.',
                ),
              ),
            )
          else
            ...filtered.map(
              (a) => _ReviewCard(
                attempt: a,
                chapterTitle: _chapterTitle(a.chapterId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _ReviewFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[
      _StatChip(
        label: 'Marks',
        value: session.marks.toStringAsFixed(2),
        color: AppColors.primary,
      ),
      _StatChip(
        label: 'Accuracy',
        value: '${(session.accuracy * 100).round()}%',
        color: AppColors.mint,
      ),
      _StatChip(
        label: 'Correct',
        value: '${session.correctCount}',
        color: AppColors.mint,
      ),
      _StatChip(
        label: 'Wrong',
        value: '${session.incorrectCount}',
        color: AppColors.danger,
      ),
      _StatChip(
        label: 'Skipped',
        value: '${session.skippedCount}',
        color: AppColors.textMuted,
      ),
    ];
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Wrap(spacing: 8, runSpacing: 8, children: stats),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.attempt, required this.chapterTitle});

  final QuestionAttempt attempt;
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
    final a = attempt;
    final statusIcon = a.isCorrect
        ? Icons.check_circle_outline
        : a.isSkipped
        ? Icons.remove_circle_outline
        : Icons.cancel_outlined;
    final statusColor = a.isCorrect
        ? AppColors.mint
        : a.isSkipped
        ? AppColors.textMuted
        : AppColors.danger;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 6),
                Chip(
                  label: Text(chapterTitle),
                  visualDensity: VisualDensity.compact,
                ),
                if (a.markedForReview) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.flag, color: AppColors.warning, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              a.prompt,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (a.selectedIndex != null && !a.isCorrect)
              _AnswerRow(
                label: 'Your answer',
                text: a.options[a.selectedIndex!],
                color: AppColors.danger,
                icon: Icons.close,
              ),
            if (a.isSkipped)
              const _AnswerRow(
                label: 'Your answer',
                text: 'Skipped',
                color: AppColors.textMuted,
                icon: Icons.remove,
              ),
            _AnswerRow(
              label: 'Correct answer',
              text: a.options[a.correctIndex],
              color: AppColors.mint,
              icon: Icons.check,
            ),
            if (a.explanation != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  a.explanation!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExplainQuestionScreen(attempt: a),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Explain with AI'),
                ),
                const Spacer(),
                Builder(
                  builder: (context) {
                    final flagged = context.select<PrepProvider, bool>(
                      (p) => p.isFlagged(a.questionId),
                    );
                    return IconButton(
                      tooltip: flagged ? 'Remove flag' : 'Flag to revise',
                      icon: Icon(
                        flagged ? Icons.flag : Icons.flag_outlined,
                        color: flagged ? AppColors.warning : null,
                      ),
                      onPressed: () =>
                          context.read<PrepProvider>().toggleFlag(a),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    required this.text,
    required this.color,
    required this.icon,
  });

  final String label;
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
