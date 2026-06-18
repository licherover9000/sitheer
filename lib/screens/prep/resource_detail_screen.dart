import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/question_bank.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/mock_attempt_screen.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/screens/prep/practice_runner_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({
    super.key,
    required this.resource,
    required this.chapterId,
    required this.subjectTitle,
  });

  final PrepResource resource;
  final String chapterId;
  final String subjectTitle;

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    final done = prep.isResourceDone(resource.id);

    return Scaffold(
      appBar: AppBar(title: Text(resource.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          ResourceTypeBadge(type: resource.type),
          const SizedBox(height: 12),
          Text(
            resource.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '$subjectTitle - ${resource.source}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(resource.description),
          const SizedBox(height: 8),
          Chip(label: Text(resource.timeLabel)),
          if (resource.isPremium) ...[
            const SizedBox(height: 8),
            const Chip(
              avatar: Icon(Icons.star_outline, size: 16),
              label: Text('Premium practice map'),
            ),
          ],
          const SizedBox(height: AppSizes.paddingL),
          if (resource.type == PrepResourceType.pyq)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PracticeRunnerScreen.chapter(chapterId),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start PYQ drill'),
            ),
          if (resource.type == PrepResourceType.mock)
            FilledButton.icon(
              onPressed: () {
                final mocks = prep.mocks;
                if (mocks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No mock papers available for this exam.'),
                    ),
                  );
                  return;
                }
                final paper = mocks.firstWhere(
                  (m) => m.title.toLowerCase().contains('sprint'),
                  orElse: () => mocks.first,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MockAttemptScreen(paper: paper),
                  ),
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Start timed practice'),
            ),
          if (resource.url != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openUrl(context, resource.url!),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open resource link'),
            ),
          ],
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () async {
              await prep.markResourceComplete(
                chapterId,
                resource.id,
                done: !done,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      done ? 'Marked incomplete' : 'Marked complete',
                    ),
                  ),
                );
              }
            },
            icon: Icon(done ? Icons.undo : Icons.check_circle_outline),
            label: Text(done ? 'Undo complete' : 'Mark complete'),
          ),
          const SizedBox(height: AppSizes.paddingL),
          SectionTitle(
            title: 'Preview questions',
            subtitle:
                '${questionsForChapter(chapterId).length} sample items in app',
          ),
          const SizedBox(height: 8),
          ...questionsForChapter(chapterId)
              .take(2)
              .map(
                (q) => Card(
                  child: ListTile(
                    title: Text(q.prompt, maxLines: 2),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PracticeRunnerScreen.chapter(chapterId),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
