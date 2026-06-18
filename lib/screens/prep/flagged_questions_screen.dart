import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/explain_question_screen.dart';

/// Lists every question the user flagged to revise, with a tap-through to the
/// AI explain flow.
class FlaggedQuestionsScreen extends StatelessWidget {
  const FlaggedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flagged = context.watch<PrepProvider>().flaggedQuestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Flagged to revise')),
      body: flagged.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No flagged problems yet.\n'
                      'Tap the flag icon on any question to save it here, '
                      'then learn it with AI.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: flagged.length,
              itemBuilder: (context, i) {
                final q = flagged[i];
                final chapterTitle =
                    findChapterContext(q.chapterId)?.$2.title ?? q.chapterId;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                  child: ListTile(
                    leading: const Icon(Icons.flag, color: AppColors.warning),
                    title: Text(
                      q.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(chapterTitle),
                    trailing: IconButton(
                      tooltip: 'Remove flag',
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          context.read<PrepProvider>().unflag(q.questionId),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExplainQuestionScreen(attempt: q),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
