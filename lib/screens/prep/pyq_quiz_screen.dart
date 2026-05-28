import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/prep_questions.dart';
import 'package:sitheer/model/prep_question.dart';
import 'package:sitheer/providers/prep_provider.dart';

class PyqQuizScreen extends StatefulWidget {
  const PyqQuizScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  State<PyqQuizScreen> createState() => _PyqQuizScreenState();
}

class _PyqQuizScreenState extends State<PyqQuizScreen> {
  late final List<PrepQuestion> _questions;
  int _index = 0;
  int? _selected;
  int _correct = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = questionsForChapter(widget.chapterId);
  }

  PrepQuestion get _current => _questions[_index];

  void _submit() {
    if (_selected == null) return;
    setState(() {
      _answered = true;
      if (_selected == _current.correctIndex) _correct++;
    });
  }

  void _next() async {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
      return;
    }

    final accuracy = _correct / _questions.length;
    await context.read<PrepProvider>().recordQuizResult(
      widget.chapterId,
      accuracy,
      _questions.length,
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drill complete'),
        content: Text(
          'Score: $_correct / ${_questions.length} '
          '(${(accuracy * 100).round()}% accuracy)',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = findChapterContext(widget.chapterId);
    final chapterTitle = ctx?.$2.title ?? widget.chapterId;

    return Scaffold(
      appBar: AppBar(
        title: Text('PYQ - $chapterTitle'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_index + 1} of ${_questions.length}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              _current.prompt,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            ...List.generate(_current.options.length, (i) {
              final selected = _selected == i;
              final isCorrect = i == _current.correctIndex;
              Color? border;
              if (_answered && isCorrect) {
                border = AppColors.mint;
              } else if (_answered && selected && !isCorrect) {
                border = AppColors.danger;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: _answered
                      ? null
                      : () => setState(() => _selected = i),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    side: BorderSide(
                      color: border ?? AppColors.border,
                      width: border != null ? 2 : 1,
                    ),
                    backgroundColor: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Text(_current.options[i]),
                ),
              );
            }),
            if (_answered && _current.explanation != null) ...[
              const SizedBox(height: 12),
              Card(
                color: AppColors.bgSoft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Text(_current.explanation!),
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _answered
                  ? _next
                  : (_selected == null ? null : _submit),
              child: Text(
                _answered
                    ? (_index < _questions.length - 1 ? 'Next' : 'Finish')
                    : 'Check answer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
