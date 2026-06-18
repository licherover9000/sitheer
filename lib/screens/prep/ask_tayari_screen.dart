import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/providers/mentor_keys_provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/flagged_questions_screen.dart';
import 'package:sitheer/screens/prep/mentor_reply_sheet.dart';
import 'package:sitheer/screens/prep/prep_widgets.dart';
import 'package:sitheer/screens/prep/subject_detail_screen.dart';
import 'package:sitheer/screens/settings/settings_screen.dart';
import 'package:sitheer/services/mentor_service.dart';

class AskTayariScreen extends StatelessWidget {
  const AskTayariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepProvider>(
      builder: (context, prep, _) {
        final nextWeek =
            prep.currentRoadmapWeek ??
            (prep.weeks.isNotEmpty ? prep.weeks.first : null);
        final weakestSubjects = [...prep.subjects]
          ..sort(
            (a, b) =>
                prep.subjectProgress(a).compareTo(prep.subjectProgress(b)),
          );

        return Scaffold(
          appBar: AppBar(
            title: const Text('myTayari'),
            actions: [
              IconButton(
                tooltip: 'Flagged to revise',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FlaggedQuestionsScreen(),
                    ),
                  );
                },
                icon: Badge(
                  isLabelVisible: prep.flaggedQuestions.isNotEmpty,
                  label: Text('${prep.flaggedQuestions.length}'),
                  child: const Icon(Icons.flag_outlined),
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                tooltip: 'Planner',
                onPressed: () => context.read<MainNavProvider>().setIndex(5),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            children: [
              PrepHeader(
                eyebrow: 'Exam prep cockpit',
                title: 'Ask, practice, review, repeat.',
                subtitle:
                    'Structured ${prep.selectedExam} workspace with roadmap, PYQs, mocks, notes, and college shortlisting.',
                trailing: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supportedExams
                    .map(
                      (exam) => ChoiceChip(
                        label: Text(exam),
                        selected: exam == prep.selectedExam,
                        onSelected: (_) => prep.setExam(exam),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSizes.paddingM),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 960 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSizes.paddingM,
                    mainAxisSpacing: AppSizes.paddingM,
                    childAspectRatio: columns == 4 ? 1.35 : 1.0,
                    children: [
                      MetricCard(
                        label: 'PYQs mapped',
                        value: '${prep.totalPyqs}+',
                        icon: Icons.quiz_outlined,
                        color: AppColors.primary,
                        footer: 'By subject and chapter',
                      ),
                      MetricCard(
                        label: 'Chapters',
                        value: '${prep.totalChapters}',
                        icon: Icons.view_module_outlined,
                        color: AppColors.mint,
                        footer: 'With resource stacks',
                      ),
                      MetricCard(
                        label: 'Roadmap',
                        value: '${prep.weeks.length} wk',
                        icon: Icons.map_outlined,
                        color: AppColors.warning,
                        footer: 'Week ${prep.currentWeek} active',
                      ),
                      MetricCard(
                        label: 'Progress',
                        value: '${(prep.overallProgress * 100).round()}%',
                        icon: Icons.trending_up_outlined,
                        color: AppColors.cyan,
                        footer: 'Synced locally & Firebase',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingL),
              SectionTitle(
                title: 'Ask Tayari',
                subtitle: prep.contentReady
                    ? 'Gemini + OpenAI mentor with your live progress.'
                    : 'Loading catalog from device...',
              ),
              const SizedBox(height: AppSizes.paddingM),
              _AskMentorPanel(prep: prep),
              if (nextWeek != null) ...[
                const SizedBox(height: AppSizes.paddingL),
                SectionTitle(
                  title: 'Next on your roadmap',
                  subtitle: nextWeek.focus,
                  action: TextButton.icon(
                    onPressed: () =>
                        context.read<MainNavProvider>().setIndex(1),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Open'),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.warning.withValues(
                                alpha: 0.12,
                              ),
                              foregroundColor: AppColors.warning,
                              child: Text('${nextWeek.week}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextWeek.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '${nextWeek.phase} - ${nextWeek.hours} study hours',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: nextWeek.checkpoints
                              .map(
                                (item) => FilterChip(
                                  avatar: Icon(
                                    prep.isCheckpointDone(item)
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  label: Text(item),
                                  selected: prep.isCheckpointDone(item),
                                  onSelected: (_) =>
                                      prep.toggleCheckpoint(item),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Weak spots first',
                subtitle:
                    'Ranked by your saved chapter accuracy and completions.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              ...weakestSubjects
                  .take(3)
                  .map(
                    (subject) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SubjectProgressTile(
                        subject: subject,
                        progress: prep.subjectProgress(subject),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SubjectDetailScreen(subject: subject),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              const SizedBox(height: AppSizes.paddingL),
              const SectionTitle(
                title: 'Toolkit',
                subtitle: 'Fast paths into the main prep workflows.',
              ),
              const SizedBox(height: AppSizes.paddingM),
              const _ToolkitGrid(),
            ],
          ),
        );
      },
    );
  }
}

class _ToolkitGrid extends StatelessWidget {
  const _ToolkitGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _ToolkitItem(
        title: 'Resource vault',
        subtitle: 'PYQs, notes, formulas, playlists',
        icon: Icons.inventory_2_outlined,
        color: AppColors.primary,
        index: 2,
      ),
      _ToolkitItem(
        title: 'Mock tests',
        subtitle: 'Full papers and section sprints',
        icon: Icons.timer_outlined,
        color: AppColors.danger,
        index: 3,
      ),
      _ToolkitItem(
        title: 'Analytics',
        subtitle: 'Accuracy, leaks, trends',
        icon: Icons.analytics_outlined,
        color: AppColors.mint,
        index: 4,
      ),
      _ToolkitItem(
        title: 'Planner',
        subtitle: 'Tasks, focus timer, schedule',
        icon: Icons.calendar_month_outlined,
        color: AppColors.warning,
        index: 5,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 960 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSizes.paddingM,
          mainAxisSpacing: AppSizes.paddingM,
          childAspectRatio: columns == 4 ? 1.35 : 1.0,
          children: items
              .map(
                (item) => Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    onTap: () =>
                        context.read<MainNavProvider>().setIndex(item.index),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: item.color.withValues(alpha: 0.12),
                            foregroundColor: item.color,
                            child: Icon(item.icon),
                          ),
                          const Spacer(),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AskMentorPanel extends StatefulWidget {
  const _AskMentorPanel({required this.prep});

  final PrepProvider prep;

  @override
  State<_AskMentorPanel> createState() => _AskMentorPanelState();
}

class _AskMentorPanelState extends State<_AskMentorPanel> {
  final _controller = TextEditingController();
  final _mentor = MentorService();
  bool _loading = false;
  static const _maxQuestionLength = 2000;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _loading) return;
    if (trimmed.length > _maxQuestionLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keep questions under $_maxQuestionLength characters.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final keys = context.read<MentorKeysProvider>();

    try {
      final result = await _mentor.replyAsync(
        question: trimmed,
        prep: widget.prep,
        geminiKey: keys.geminiApiKey,
        openaiKey: keys.openaiApiKey,
        useCloud: keys.useCloudMentor,
      );
      if (!mounted) return;
      await MentorReplySheet.show(
        context,
        question: trimmed,
        answer: result.answer,
        sources: result.sources,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mentor error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = context.watch<MentorKeysProvider>();
    final modeLabel = keys.useCloudMentor
        ? 'Secure cloud mentor (Firebase Functions)'
        : keys.hasGemini && keys.hasOpenai
        ? 'Gemini + OpenAI on device'
        : keys.hasGemini
        ? 'Gemini on device'
        : keys.hasOpenai
        ? 'OpenAI on device'
        : 'Offline rules (enable cloud or add API keys)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              modeLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 3,
              maxLength: _maxQuestionLength,
              enabled: !_loading,
              textInputAction: TextInputAction.send,
              onSubmitted: _loading ? null : _ask,
              decoration: InputDecoration(
                hintText:
                    'Ask for a concept fix, PYQ set, mock review, or weekly plan...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 42),
                  child: Icon(Icons.auto_awesome_outlined),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _loading
                  ? null
                  : () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      _ask(text);
                    },
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_loading ? 'Thinking...' : 'Ask'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mentorPrompts
                  .map(
                    (prompt) => ActionChip(
                      avatar: const Icon(Icons.bolt_outlined, size: 16),
                      label: Text(prompt),
                      onPressed: () {
                        _controller.text = prompt;
                        _ask(prompt);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolkitItem {
  const _ToolkitItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.index,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int index;
}
