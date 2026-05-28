import 'package:flutter/material.dart';
import 'package:sitheer/core/constants.dart';

class MentorReplySheet extends StatelessWidget {
  const MentorReplySheet({
    super.key,
    required this.question,
    required this.answer,
    this.sources = const [],
  });

  final String question;
  final String answer;
  final List<String> sources;

  static Future<void> show(
    BuildContext context, {
    required String question,
    required String answer,
    List<String> sources = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => MentorReplySheet(
        question: question,
        answer: answer,
        sources: sources,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingM,
        0,
        AppSizes.paddingM,
        MediaQuery.paddingOf(context).bottom + AppSizes.paddingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tayari mentor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (sources.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: sources
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'You asked',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(question),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              child: Text(
                answer,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
