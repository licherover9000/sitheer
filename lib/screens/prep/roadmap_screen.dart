import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/utils/prep_task_helper.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepProvider>(
      builder: (context, prep, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Roadmap'),
            actions: [
              PopupMenuButton<int>(
                tooltip: 'Jump to week',
                onSelected: prep.setCurrentWeek,
                itemBuilder: (_) => prep.weeks
                    .map(
                      (w) => PopupMenuItem<int>(
                        value: w.week,
                        child: Text('Week ${w.week}: ${w.title}'),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            children: [
              PrepHeader(
                eyebrow: 'Study map',
                title: 'A week-by-week route through the syllabus.',
                subtitle:
                    '${prep.selectedExam} roadmap keeps high-weight chapters early, repair loops for weak areas, and measurable checkpoints each week.',
              ),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Preparation flow',
                subtitle:
                    'The same map drives tasks, PYQs, mocks, and revision.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              _PhaseRail(currentWeek: prep.currentWeek),
              const SizedBox(height: AppSizes.paddingL),
              SectionTitle(
                title: 'Weekly plan',
                subtitle:
                    'Week ${prep.currentWeek} is active - ${prep.completedCheckpoints.length} checkpoints done',
              ),
              const SizedBox(height: AppSizes.paddingM),
              ...prep.weeks.map(
                (week) => _RoadmapWeekCard(
                  week: week,
                  isActive: week.week == prep.currentWeek,
                  prep: prep,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhaseRail extends StatelessWidget {
  const _PhaseRail({required this.currentWeek});

  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final activePhaseIndex = ((currentWeek - 1) / 2).floor().clamp(0, 6);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 680;
            if (isWide) {
              return Row(
                children: [
                  for (var i = 0; i < studyMapPhases.length; i++) ...[
                    Expanded(
                      child: _PhaseNode(
                        index: i + 1,
                        label: studyMapPhases[i],
                        active: i <= activePhaseIndex,
                      ),
                    ),
                    if (i != studyMapPhases.length - 1)
                      Container(width: 22, height: 2, color: AppColors.border),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (var i = 0; i < studyMapPhases.length; i++) ...[
                  _PhaseNode(
                    index: i + 1,
                    label: studyMapPhases[i],
                    active: i <= activePhaseIndex,
                  ),
                  if (i != studyMapPhases.length - 1)
                    Container(width: 2, height: 18, color: AppColors.border),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhaseNode extends StatelessWidget {
  const _PhaseNode({
    required this.index,
    required this.label,
    required this.active,
  });

  final int index;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: active ? AppColors.primary : AppColors.bgSoft,
          foregroundColor: active ? Colors.white : AppColors.textMuted,
          child: Text('$index'),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: active ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _RoadmapWeekCard extends StatelessWidget {
  const _RoadmapWeekCard({
    required this.week,
    required this.isActive,
    required this.prep,
  });

  final RoadmapWeek week;
  final bool isActive;
  final PrepProvider prep;

  @override
  Widget build(BuildContext context) {
    final subjects = prep.subjects
        .where((subject) => week.subjectCodes.contains(subject.code))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      shape: isActive
          ? RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            )
          : null,
      child: ExpansionTile(
        initiallyExpanded: isActive,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: 6,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSizes.paddingM,
          0,
          AppSizes.paddingM,
          AppSizes.paddingM,
        ),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.12),
          foregroundColor: isActive ? Colors.white : AppColors.primary,
          child: Text('${week.week}'),
        ),
        title: Text(
          week.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${week.phase} - ${week.hours} hours'),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              week.focus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => prep.setCurrentWeek(week.week),
                icon: const Icon(Icons.flag_outlined),
                label: Text(isActive ? 'Current week' : 'Set as current week'),
              ),
              TextButton.icon(
                onPressed: () => context.read<MainNavProvider>().setIndex(2),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Open vault'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ListBlock(
            title: 'Outcomes',
            icon: Icons.flag_outlined,
            items: week.outcomes,
          ),
          const SizedBox(height: 12),
          _ListBlock(
            title: 'Checkpoints',
            icon: Icons.checklist_outlined,
            items: week.checkpoints,
            trailing: (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Add to planner',
                  icon: const Icon(Icons.add_task_outlined, size: 20),
                  onPressed: () => addRoadmapTask(context, item),
                ),
                Checkbox(
                  value: prep.isCheckpointDone(item),
                  onChanged: (_) => prep.toggleCheckpoint(item),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects
                  .map(
                    (subject) => ActionChip(
                      avatar: Icon(
                        subject.icon,
                        size: 16,
                        color: subject.accent,
                      ),
                      label: Text(subject.title),
                      onPressed: () =>
                          context.read<MainNavProvider>().setIndex(2),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({
    required this.title,
    required this.icon,
    required this.items,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Widget Function(String item)? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.done, size: 16, color: AppColors.mint),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                  if (trailing != null) trailing!(item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
