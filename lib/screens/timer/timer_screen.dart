import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/timer_providers.dart';
import '../../core/constants.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimerProviders>();

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Mode Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeButton(
                  title: 'Focus',
                  mode: TimerMode.focus,
                  currentMode: provider.mode,
                ),
                _ModeButton(
                  title: 'Short Break',
                  mode: TimerMode.shortBreak,
                  currentMode: provider.mode,
                ),
                _ModeButton(
                  title: 'Long Break',
                  mode: TimerMode.longBreak,
                  currentMode: provider.mode,
                ),
              ],
            ),
            const SizedBox(height: 50),

            // 2. The Progress Ring (from the manual)
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    color: Colors.grey.shade200,
                  ),
                  CircularProgressIndicator(
                    value: provider.progress,
                    strokeWidth: 12,
                    color: AppColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.timeString,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.bgDark,
                            ),
                      ),
                      Text(
                        provider.mode.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // 3. Play / Pause / Reset Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (provider.state == TimerState.idle ||
                    provider.state == TimerState.paused)
                  FloatingActionButton.large(
                    onPressed: provider.start,
                    child: const Icon(Icons.play_arrow),
                  )
                else if (provider.state == TimerState.running)
                  FloatingActionButton.large(
                    onPressed: provider.pause,
                    child: const Icon(Icons.pause),
                  ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: provider.reset,
                  icon: const Icon(Icons.refresh, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the mode buttons
class _ModeButton extends StatelessWidget {
  final String title;
  final TimerMode mode;
  final TimerMode currentMode;

  const _ModeButton({
    required this.title,
    required this.mode,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    return TextButton(
      onPressed: () => context.read<TimerProviders>().setMode(mode),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? AppColors.primary : Colors.grey,
        textStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      child: Text(title),
    );
  }
}
