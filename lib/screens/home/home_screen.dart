import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/event.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/providers/schedule_providers.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/providers/timer_providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String _modeLabel(TimerMode m) {
    return switch (m) {
      TimerMode.focus => 'Focus',
      TimerMode.shortBreak => 'Short break',
      TimerMode.longBreak => 'Long break',
    };
  }

  static String? _etaLabel(AppEvent? e) {
    if (e == null) return null;
    final start = DateTime(
      e.date.year,
      e.date.month,
      e.date.day,
      e.startTime.hour,
      e.startTime.minute,
    );
    final from = DateTime.now();
    if (start.isBefore(from)) return null;
    final diff = start.difference(from);
    if (diff.inMinutes < 60) {
      return 'in ${diff.inMinutes} min';
    }
    return 'in ${diff.inHours} h ${diff.inMinutes.remainder(60)} m';
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProviders>();
    final timer = context.watch<TimerProviders>();
    final schedule = context.watch<ScheduleProviders>();
    final next = schedule.nextUpcomingEvent;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          _SummaryCard(
            title: "Today's tasks",
            subtitle:
                '${tasks.pendingTasks.length} pending · ${tasks.completedTasks.length} done',
            icon: Icons.check_circle_outline,
            onTap: () =>
                context.read<MainNavProvider>().setIndex(1),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _SummaryCard(
            title: 'Focus',
            subtitle: timer.state == TimerState.running
                ? '${_modeLabel(timer.mode)} running · ${timer.sessions} completed'
                : '${timer.sessions} focus session(s) completed',
            icon: Icons.timer_outlined,
            onTap: () =>
                context.read<MainNavProvider>().setIndex(2),
          ),
          const SizedBox(height: AppSizes.paddingM),
          _SummaryCard(
            title: 'Next event',
            subtitle: next == null
                ? 'Nothing coming up'
                : '${next.title} · ${_etaLabel(next) ?? "Schedule"}',
            icon: Icons.event,
            onTap: () =>
                context.read<MainNavProvider>().setIndex(3),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
