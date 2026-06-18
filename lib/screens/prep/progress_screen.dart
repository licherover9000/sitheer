import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/practice_review_screen.dart';
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
                title: 'Wrong answers to review',
                subtitle:
                    'Revisit the questions you missed across drills and mocks.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              _ReviewWrongPanel(prep: prep),
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

class _ReviewWrongPanel extends StatelessWidget {
  const _ReviewWrongPanel({required this.prep});

  final PrepProvider prep;

  @override
  Widget build(BuildContext context) {
    final sessions = prep.recentSessions;
    final wrong = prep.allWrongAttempts;

    if (wrong.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.task_alt_outlined, color: AppColors.mint),
          title: Text('No wrong answers tracked yet.'),
          subtitle: Text(
            'Finish a PYQ drill or a mock to build your review list.',
          ),
        ),
      );
    }

    // Wrong count by chapter (top 5).
    final byChapter = <String, int>{};
    for (final a in wrong) {
      byChapter[a.chapterId] = (byChapter[a.chapterId] ?? 0) + 1;
    }
    final top = byChapter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = top.first.value;

    String title(String chapterId) =>
        findChapterContext(chapterId)?.$2.title ?? chapterId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${wrong.length} wrong across ${sessions.length} recent '
              'session${sessions.length == 1 ? '' : 's'}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...top
                .take(5)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            title(e.key),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: e.value / maxCount,
                              minHeight: 7,
                              color: AppColors.danger,
                              backgroundColor: AppColors.danger.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.value}'),
                      ],
                    ),
                  ),
                ),
            const Divider(height: 24),
            Text(
              'Recent sessions',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            ...sessions
                .take(5)
                .map(
                  (s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      s.source == 'mock'
                          ? Icons.assignment_outlined
                          : Icons.menu_book_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${s.incorrectCount} wrong · ${(s.accuracy * 100).round()}% '
                      'accuracy',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeReviewScreen(session: s),
                      ),
                    ),
                  ),
                ),
          ],
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
