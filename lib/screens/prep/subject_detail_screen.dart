import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key, required this.subject});

  final PrepSubject subject;

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    final progress = prep.subjectProgress(subject);

    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: subject.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: subject.accent,
                  foregroundColor: Colors.white,
                  child: Icon(subject.icon, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(subject.subtitle),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: subject.accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).round()}% chapter mastery',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          SectionTitle(
            title: 'Chapters',
            subtitle: '${subject.chapters.length} modules with resources',
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...subject.chapters.map((chapter) {
            final accuracy = prep.chapterAccuracy(
              chapter.id,
              fallback: chapter.accuracy,
            );
            return Card(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: subject.accent.withValues(alpha: 0.12),
                  foregroundColor: subject.accent,
                  child: Text('${(accuracy * 100).round()}%'),
                ),
                title: Text(
                  chapter.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${chapter.pyqCount} PYQs - ${chapter.weightage} weight - ${chapter.difficulty}',
                ),
                children: chapter.resources
                    .map(
                      (resource) => Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: ResourceCard(
                          resource: resource,
                          chapterId: chapter.id,
                          subjectTitle: subject.title,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
