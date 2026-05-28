import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/mock_attempt_screen.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';

class MockTestsScreen extends StatelessWidget {
  const MockTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mocks')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          const PrepHeader(
            eyebrow: 'Exam mode',
            title: 'Practice in the same rhythm as the real test.',
            subtitle:
                'Full papers, previous-year mocks, and focused sprints feed the same analysis system so retakes are based on evidence.',
          ),
          const SizedBox(height: AppSizes.paddingL),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 720 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSizes.paddingM,
                mainAxisSpacing: AppSizes.paddingM,
                childAspectRatio: columns == 1 ? 2.25 : 1.25,
                children: const [
                  MetricCard(
                    label: 'Real interface',
                    value: '65 Q',
                    icon: Icons.desktop_windows_outlined,
                    color: AppColors.primary,
                    footer: 'Question palette and timer',
                  ),
                  MetricCard(
                    label: 'Retake loop',
                    value: '48 h',
                    icon: Icons.replay_outlined,
                    color: AppColors.mint,
                    footer: 'Wrong answers return later',
                  ),
                  MetricCard(
                    label: 'Score leaks',
                    value: '5',
                    icon: Icons.leak_remove_outlined,
                    color: AppColors.warning,
                    footer: 'Tracked by topic and speed',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingL),
          const SectionTitle(
            title: 'Mock catalog',
            subtitle:
                'Start a paper, review it, then retake only what matters.',
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...prep.mocks.map(
            (paper) => _MockPaperCard(paper: paper, prep: prep),
          ),
          const SizedBox(height: AppSizes.paddingL),
          const SectionTitle(
            title: 'Exam interface map',
            subtitle: 'The mock screen is structured around the real workflow.',
          ),
          const SizedBox(height: AppSizes.paddingM),
          const _InterfaceMap(),
        ],
      ),
    );
  }
}

class _MockPaperCard extends StatelessWidget {
  const _MockPaperCard({required this.paper, required this.prep});

  final MockPaper paper;
  final PrepProvider prep;

  @override
  Widget build(BuildContext context) {
    final saved = prep.mockAttempt(paper.id);
    final displayScore = saved?.score ?? paper.score;
    final displayAccuracy = saved?.accuracy ?? paper.accuracy;
    final statusColor = switch (paper.status) {
      'New' => AppColors.primary,
      'Analysis ready' => AppColors.mint,
      'Retake suggested' => AppColors.warning,
      _ => AppColors.textMuted,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  foregroundColor: statusColor,
                  child: const Icon(Icons.assignment_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${paper.stream} - ${paper.year} - ${paper.duration}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(paper.status),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final stats = [
                  _MiniStat(label: 'Questions', value: '${paper.questions}'),
                  _MiniStat(label: 'Score', value: '$displayScore'),
                  _MiniStat(
                    label: 'Accuracy',
                    value: '${(displayAccuracy * 100).round()}%',
                  ),
                ];
                return isWide
                    ? Row(
                        children: stats.map((s) => Expanded(child: s)).toList(),
                      )
                    : Column(children: stats);
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paper.focusAreas
                  .map(
                    (area) => Chip(
                      avatar: const Icon(
                        Icons.track_changes_outlined,
                        size: 16,
                      ),
                      label: Text(area),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MockAttemptScreen(paper: paper),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analysis'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InterfaceMap extends StatelessWidget {
  const _InterfaceMap();

  @override
  Widget build(BuildContext context) {
    final blocks = [
      ('Timer', Icons.timer_outlined, 'Fixed 180 minute rhythm'),
      ('Question area', Icons.subject_outlined, 'Clear prompt and options'),
      ('Palette', Icons.grid_view_outlined, 'Answered, marked, skipped'),
      ('Review', Icons.rate_review_outlined, 'Topic, time, trap, solution'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 720 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.45 : 1.2,
              children: blocks
                  .map(
                    (block) => Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.bgSoft,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(block.$2, color: AppColors.primary),
                          const Spacer(),
                          Text(
                            block.$1,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            block.$3,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
