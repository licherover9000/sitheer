import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _subjectCode = 'all';
  PrepResourceType? _type;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    final subjects = _subjectCode == 'all'
        ? prep.subjects
        : prep.subjects
              .where((subject) => subject.code == _subjectCode)
              .toList();

    final filtered = subjects
        .map(
          (subject) => _SubjectResourceView(
            subject: subject,
            chapters: subject.chapters
                .map(
                  (chapter) => _ChapterResourceView(
                    chapter: chapter,
                    resources: chapter.resources
                        .where(_matchesResource)
                        .toList(),
                  ),
                )
                .where((view) => view.resources.isNotEmpty)
                .toList(),
          ),
        )
        .where((view) => view.chapters.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          const PrepHeader(
            eyebrow: 'Resource library',
            title: 'Every chapter has a material stack.',
            subtitle:
                'PYQ packs, notes, formula cards, playlist imports, and timed drills are grouped by subject so the structure stays searchable.',
          ),
          const SizedBox(height: AppSizes.paddingL),
          TextField(
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search chapters, PYQs, notes, formulas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All subjects'),
                    selected: _subjectCode == 'all',
                    onSelected: (_) => setState(() => _subjectCode = 'all'),
                  ),
                ),
                ...prep.subjects.map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        subject.icon,
                        size: 16,
                        color: subject.accent,
                      ),
                      label: Text(subject.title),
                      selected: _subjectCode == subject.code,
                      onSelected: (_) =>
                          setState(() => _subjectCode = subject.code),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All material'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              for (final type in PrepResourceType.values)
                FilterChip(
                  avatar: Icon(_iconForType(type), size: 16),
                  label: Text(_labelForType(type)),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.search_off_outlined,
              title: 'No resources found',
              message: 'Try another subject, material type, or search term.',
            )
          else
            ...filtered.map((view) => _SubjectSection(view: view)),
        ],
      ),
    );
  }

  bool _matchesResource(PrepResource resource) {
    if (_type != null && resource.type != _type) return false;
    if (_query.isEmpty) return true;
    final haystack = [
      resource.title,
      resource.description,
      resource.source,
      _labelForType(resource.type),
    ].join(' ').toLowerCase();
    return haystack.contains(_query);
  }
}

class _SubjectSection extends StatelessWidget {
  const _SubjectSection({required this.view});

  final _SubjectResourceView view;

  @override
  Widget build(BuildContext context) {
    final prep = context.watch<PrepProvider>();
    final subject = view.subject;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: subject.title,
            subtitle: subject.subtitle,
            action: CircleAvatar(
              backgroundColor: subject.accent.withValues(alpha: 0.12),
              foregroundColor: subject.accent,
              child: Icon(subject.icon),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...view.chapters.map((chapterView) {
            final chapter = chapterView.chapter;
            return Card(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          chapter.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Chip(label: Text('${chapter.pyqCount} PYQs')),
                        Chip(label: Text('${chapter.weightage} weight')),
                        Chip(label: Text(chapter.difficulty)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: prep.chapterAccuracy(
                          chapter.id,
                          fallback: chapter.accuracy,
                        ),
                        minHeight: 7,
                        color: subject.accent,
                        backgroundColor: subject.accent.withValues(alpha: 0.12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current accuracy ${(prep.chapterAccuracy(chapter.id, fallback: chapter.accuracy) * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 780;
                        if (!isWide) {
                          return Column(
                            children: chapterView.resources
                                .map(
                                  (resource) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ResourceCard(
                                      resource: resource,
                                      chapterId: chapter.id,
                                      subjectTitle: subject.title,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }
                        return GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: chapterView.resources
                              .map(
                                (resource) => ResourceCard(
                                  resource: resource,
                                  chapterId: chapter.id,
                                  subjectTitle: subject.title,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SubjectResourceView {
  const _SubjectResourceView({required this.subject, required this.chapters});

  final PrepSubject subject;
  final List<_ChapterResourceView> chapters;
}

class _ChapterResourceView {
  const _ChapterResourceView({required this.chapter, required this.resources});

  final PrepChapter chapter;
  final List<PrepResource> resources;
}

String _labelForType(PrepResourceType type) {
  return switch (type) {
    PrepResourceType.pyq => 'PYQs',
    PrepResourceType.notes => 'Notes',
    PrepResourceType.formula => 'Formula',
    PrepResourceType.lecture => 'Playlists',
    PrepResourceType.mock => 'Mocks',
    PrepResourceType.article => 'Guides',
  };
}

IconData _iconForType(PrepResourceType type) {
  return switch (type) {
    PrepResourceType.pyq => Icons.quiz_outlined,
    PrepResourceType.notes => Icons.notes_outlined,
    PrepResourceType.formula => Icons.functions,
    PrepResourceType.lecture => Icons.play_circle_outline,
    PrepResourceType.mock => Icons.timer_outlined,
    PrepResourceType.article => Icons.article_outlined,
  };
}
