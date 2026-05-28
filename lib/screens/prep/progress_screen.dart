import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/screens/prep/subject_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepProvider>(
      builder: (context, prep, _) {
        final weakest = [...prep.subjects]
          ..sort(
            (a, b) =>
                prep.subjectProgress(a).compareTo(prep.subjectProgress(b)),
          );
        final strong = [...prep.subjects]
          ..sort(
            (a, b) =>
                prep.subjectProgress(b).compareTo(prep.subjectProgress(a)),
          );

        final mockTrend = prep.mocks
            .map((m) => prep.mockAttempt(m.id)?.score ?? m.score)
            .toList();
        final trendDelta = mockTrend.length >= 2
            ? mockTrend.last - mockTrend.first
            : 0;

        return Scaffold(
          appBar: AppBar(title: const Text('Progress')),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            children: [
              PrepHeader(
                eyebrow: 'Analytics',
                title: 'Know where marks are leaking.',
                subtitle:
                    '${prep.selectedExam} accuracy, mock history, mistake buckets, and admission options in one view.',
                trailing: SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: prep.overallProgress,
                        strokeWidth: 8,
                        color: AppColors.mint,
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                      ),
                      Text(
                        '${(prep.overallProgress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    childAspectRatio: columns == 1 ? 2.35 : 1.2,
                    children: [
                      MetricCard(
                        label: 'Strongest subject',
                        value: strong.first.title,
                        icon: strong.first.icon,
                        color: strong.first.accent,
                        footer:
                            '${(prep.subjectProgress(strong.first) * 100).round()}% complete',
                      ),
                      MetricCard(
                        label: 'Repair queue',
                        value: weakest.first.title,
                        icon: Icons.priority_high_outlined,
                        color: AppColors.danger,
                        footer:
                            '${(prep.subjectProgress(weakest.first) * 100).round()}% complete',
                      ),
                      MetricCard(
                        label: 'Mock trend',
                        value: trendDelta >= 0 ? '+$trendDelta' : '$trendDelta',
                        icon: Icons.show_chart_outlined,
                        color: AppColors.mint,
                        footer: 'Score change across saved attempts',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Subject accuracy',
                subtitle: 'Tap a subject for chapters and resources.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              ...prep.subjects.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SubjectProgressTile(
                    subject: subject,
                    progress: prep.subjectProgress(subject),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailScreen(subject: subject),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Mistake tracker',
                subtitle:
                    'The buckets below turn wrong answers into revision loops.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              const _MistakeTracker(),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'College predictor',
                subtitle:
                    'Use score bands to maintain reach, target, and backup routes.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              ...predictorColleges.map(
                (college) => _PredictorCard(college: college),
              ),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Community and top picks',
                subtitle: 'Discussion prompts and recommended next actions.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              const _CommunityPanel(),
            ],
          ),
        );
      },
    );
  }
}

class _MistakeTracker extends StatelessWidget {
  const _MistakeTracker();

  @override
  Widget build(BuildContext context) {
    final buckets = [
      ('Concept gap', 42, AppColors.danger, Icons.psychology_outlined),
      ('Calculation slip', 31, AppColors.warning, Icons.calculate_outlined),
      ('Time pressure', 27, AppColors.primary, Icons.timer_outlined),
      ('Question trap', 19, AppColors.mint, Icons.warning_amber_outlined),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: buckets
              .map(
                (bucket) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: bucket.$3.withValues(alpha: 0.12),
                        foregroundColor: bucket.$3,
                        child: Icon(bucket.$4, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    bucket.$1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Text('${bucket.$2} tagged'),
                              ],
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: bucket.$2 / 50,
                                minHeight: 7,
                                color: bucket.$3,
                                backgroundColor: bucket.$3.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PredictorCard extends StatelessWidget {
  const _PredictorCard({required this.college});

  final PredictorCollege college;

  @override
  Widget build(BuildContext context) {
    final color = switch (college.fit) {
      'Reach' => AppColors.warning,
      'Target' => AppColors.mint,
      _ => AppColors.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: const Icon(Icons.school_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    college.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${college.program} - ${college.route}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(college.fit),
                  backgroundColor: color.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
                Text(
                  college.rankBand,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPanel extends StatelessWidget {
  const _CommunityPanel();

  @override
  Widget build(BuildContext context) {
    final prompts = [
      'Post your mock analysis and ask for a 7 day recovery plan.',
      'Compare your DBMS normalization approach with top answers.',
      'Share a college shortlist for COAP and CCMT feedback.',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Discussion queue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...prompts.map(
              (prompt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.forum_outlined),
                title: Text(prompt),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
