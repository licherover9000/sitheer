import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/providers/settings_provider.dart';
import 'package:sitheer/screens/settings/mentor_api_keys_section.dart';
import 'package:sitheer/providers/timer_providers.dart';
import 'package:sitheer/core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timer = context.watch<TimerProviders>();
    final prep = context.watch<PrepProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          Text(
            'Appearance',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode, size: 18),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode, size: 18),
                  ),
                ],
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                selected: {settings.themeMode},
                onSelectionChanged: (next) {
                  if (next.isEmpty) return;
                  unawaited(settings.setThemeMode(next.first));
                },
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          const MentorApiKeysSection(),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'Prep content',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    prep.contentReady
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    color: prep.contentReady
                        ? AppColors.mint
                        : AppColors.warning,
                  ),
                  title: Text(
                    prep.contentReady
                        ? 'Catalog synced'
                        : 'Using offline catalog',
                  ),
                  subtitle: Text(
                    prep.contentError ??
                        'Firestore path: content/exams/items/{gate-cs|gate-da}',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh from cloud'),
                  onTap: () => unawaited(prep.refreshContent()),
                ),
                const Divider(height: 1),
                _UploadCatalogTile(prep: prep),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'Timer (minutes)',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _DurationTile(
                  label: 'Focus',
                  value: timer.focusedMinutes,
                  onChanged: (v) {
                    if (v != null) {
                      unawaited(
                        context.read<TimerProviders>().updateDurations(
                          focus: v,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                _DurationTile(
                  label: 'Short break',
                  value: timer.shortBreakMinutes,
                  onChanged: (v) {
                    if (v != null) {
                      unawaited(
                        context.read<TimerProviders>().updateDurations(
                          shortBreak: v,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                _DurationTile(
                  label: 'Long break',
                  value: timer.longBreakMinutes,
                  onChanged: (v) {
                    if (v != null) {
                      unawaited(
                        context.read<TimerProviders>().updateDurations(
                          longBreak: v,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final void Function(int?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: DropdownButton<int>(
        value: value,
        onChanged: onChanged,
        items: [5, 10, 15, 20, 25, 30, 45, 50, 60]
            .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
            .toList(),
      ),
    );
  }
}

class _UploadCatalogTile extends StatefulWidget {
  const _UploadCatalogTile({required this.prep});

  final PrepProvider prep;

  @override
  State<_UploadCatalogTile> createState() => _UploadCatalogTileState();
}

class _UploadCatalogTileState extends State<_UploadCatalogTile> {
  bool _uploading = false;

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      await widget.prep.refreshContent(forceUpload: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catalog uploaded to Firestore successfully.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _uploading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload_outlined),
      title: const Text('Upload built-in catalog to Firestore'),
      subtitle: const Text(
        'Writes content/exams/items/{gate-cs|gate-da} — requires write permission.',
      ),
      onTap: _uploading ? null : _upload,
    );
  }
}

