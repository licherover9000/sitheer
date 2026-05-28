import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/providers/mentor_keys_provider.dart';

class MentorApiKeysSection extends StatefulWidget {
  const MentorApiKeysSection({super.key});

  @override
  State<MentorApiKeysSection> createState() => _MentorApiKeysSectionState();
}

class _MentorApiKeysSectionState extends State<MentorApiKeysSection> {
  final _geminiController = TextEditingController();
  final _openaiController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keys = context.read<MentorKeysProvider>();
      _geminiController.text = keys.geminiApiKey;
      _openaiController.text = keys.openaiApiKey;
    });
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _openaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys = context.watch<MentorKeysProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI mentor (Gemini + OpenAI)',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Recommended: enable cloud mentor (keys stored in Firebase '
                  'secrets, not in the app). Device keys are dev-only fallback.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use secure cloud mentor'),
                  subtitle: const Text(
                    'Requires deploying functions/mentorChat',
                  ),
                  value: keys.useCloudMentor,
                  onChanged: keys.setUseCloudMentor,
                ),
                const Divider(),
                Text(
                  'Device fallback: plans -> Gemini, concepts -> OpenAI.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _geminiController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Gemini API key',
                    hintText: 'AIza...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _openaiController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'OpenAI API key',
                    hintText: 'sk-...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: !_obscure,
                      onChanged: (v) =>
                          setState(() => _obscure = !(v ?? false)),
                    ),
                    const Text('Show keys'),
                  ],
                ),
                FilledButton(
                  onPressed: () async {
                    await keys.setGeminiKey(_geminiController.text);
                    await keys.setOpenaiKey(_openaiController.text);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API keys saved')),
                      );
                    }
                  },
                  child: const Text('Save keys'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    await keys.clearKeys();
                    _geminiController.clear();
                    _openaiController.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API keys cleared')),
                      );
                    }
                  },
                  child: const Text('Clear keys'),
                ),
                const SizedBox(height: 8),
                Text(
                  keys.hasAnyKey
                      ? 'Active: ${keys.hasGemini ? 'Gemini ' : ''}${keys.hasOpenai ? 'OpenAI' : ''}'
                      : 'No keys - mentor uses offline rules',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
