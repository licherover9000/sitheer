import 'package:flutter/material.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/mock_question.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/screens/prep/pyq_quiz_screen.dart';

/// Post-mock analysis screen showing:
/// - Overall score, marks, accuracy
/// - Subject area accuracy bar chart
/// - List of wrong answers with explanations
/// - "Retake weak topics" CTA
class MockAnalysisScreen extends StatelessWidget {
  const MockAnalysisScreen({
    super.key,
    required this.paper,
    required this.results,
    required this.correct,
    required this.incorrect,
    required this.skipped,
  });

  final MockPaper paper;
  final List<MockQuestionResult> results;
  final int correct;
  final int incorrect;
  final int skipped;

  double get _marks => correct - (incorrect / 3);
  double get _accuracy => results.isEmpty ? 0 : correct / results.length;

  @override
  Widget build(BuildContext context) {
    final wrongResults = results
        .where(
          (r) =>
              r.selectedIndex != null &&
              r.selectedIndex != r.question.correctIndex,
        )
        .toList();

    // Subject breakdown
    final subjectMap = <String, (int correct, int total)>{};
    for (final r in results) {
      final ch = r.question.chapterId;
      final existing = subjectMap[ch] ?? (0, 0);
      final isCorrect = r.selectedIndex == r.question.correctIndex ? 1 : 0;
      subjectMap[ch] = (existing.$1 + isCorrect, existing.$2 + 1);
    }

    // Weakest chapter for retake CTA
    String? weakestChapter;
    double weakestAccuracy = double.infinity;
    subjectMap.forEach((ch, tuple) {
      final acc = tuple.$2 == 0 ? 0.0 : tuple.$1 / tuple.$2;
      if (acc < weakestAccuracy) {
        weakestAccuracy = acc;
        weakestChapter = ch;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
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
          // ── Header card ──
          Card(
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${paper.stream} · ${paper.year} · ${paper.duration}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      final stats = [
                        _StatChip(
                          label: 'Marks',
                          value: _marks.toStringAsFixed(2),
                          color: AppColors.primary,
                        ),
                        _StatChip(
                          label: 'Accuracy',
                          value: '${(_accuracy * 100).round()}%',
                          color: AppColors.mint,
                        ),
                        _StatChip(
                          label: 'Correct',
                          value: '$correct',
                          color: AppColors.mint,
                        ),
                        _StatChip(
                          label: 'Wrong',
                          value: '$incorrect',
                          color: AppColors.danger,
                        ),
                        _StatChip(
                          label: 'Skipped',
                          value: '$skipped',
                          color: AppColors.textMuted,
                        ),
                      ];
                      return isWide
                          ? Row(
                              children: stats
                                  .map((s) => Expanded(child: s))
                                  .toList(),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: stats,
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // ── Subject breakdown ──
          if (subjectMap.isNotEmpty) ...[
            Text(
              'Accuracy by subject',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  children: subjectMap.entries.map((entry) {
                    final ch = entry.key;
                    final acc = entry.value.$2 == 0
                        ? 0.0
                        : entry.value.$1 / entry.value.$2;
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
                              ch,
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
                                backgroundColor:
                                    color.withValues(alpha: 0.12),
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

          // ── Retake CTA ──
          if (weakestChapter != null)
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PyqQuizScreen(chapterId: weakestChapter!),
                ),
              ),
              icon: const Icon(Icons.replay_outlined),
              label: Text('Retake weak topic: $weakestChapter'),
            ),
          const SizedBox(height: AppSizes.paddingM),

          // ── Wrong answers list ──
          if (wrongResults.isNotEmpty) ...[
            Text(
              'Wrong answers (${wrongResults.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            ...wrongResults.map((r) {
              final q = r.question;
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Chip(
                            label: Text(q.chapterId),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q.prompt,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (r.selectedIndex != null)
                        _AnswerRow(
                          label: 'Your answer',
                          text: q.options[r.selectedIndex!],
                          color: AppColors.danger,
                          icon: Icons.close,
                        ),
                      _AnswerRow(
                        label: 'Correct answer',
                        text: q.options[q.correctIndex],
                        color: AppColors.mint,
                        icon: Icons.check,
                      ),
                      if (q.explanation != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.bgSoft,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            q.explanation!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ] else
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.mint,
                ),
                title: const Text('No wrong answers!'),
                subtitle: const Text(
                  'Perfect score. Great work on this mock.',
                ),
              ),
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
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
