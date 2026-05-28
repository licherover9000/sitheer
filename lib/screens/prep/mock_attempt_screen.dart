import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_questions.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/providers/prep_provider.dart';

class MockAttemptScreen extends StatefulWidget {
  const MockAttemptScreen({super.key, required this.paper});

  final MockPaper paper;

  @override
  State<MockAttemptScreen> createState() => _MockAttemptScreenState();
}

class _MockAttemptScreenState extends State<MockAttemptScreen> {
  final Map<int, int> _answers = {};
  int _current = 0;
  late final List<_MockQuestion> _questions;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
    _secondsLeft = _parseDurationMinutes(widget.paper.duration) * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished) return;
      if (_secondsLeft <= 0) {
        _finish();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  int _parseDurationMinutes(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '90') ?? 90;
  }

  List<_MockQuestion> _buildQuestions() {
    final pool = prepQuestionsByChapter.values.expand((q) => q).toList();
    final count = widget.paper.questions.clamp(3, 8);
    return List.generate(count, (i) {
      final q = pool[i % pool.length];
      return _MockQuestion(
        prompt: q.prompt,
        options: q.options,
        correctIndex: q.correctIndex,
      );
    });
  }

  void _finish() {
    _timer?.cancel();
    var score = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) score++;
    }
    context.read<PrepProvider>().recordMockAttempt(widget.paper, score);
    setState(() => _finished = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Mock submitted'),
        content: Text(
          '${widget.paper.title}\n'
          'Score: $score / ${_questions.length}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paper.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _timeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFeatures: [],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 88,
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (_, i) {
                final answered = _answers.containsKey(i);
                final active = i == _current;
                return ListTile(
                  dense: true,
                  selected: active,
                  title: Text('${i + 1}'),
                  trailing: Icon(
                    answered ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: answered ? AppColors.mint : AppColors.textMuted,
                  ),
                  onTap: () => setState(() => _current = i),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Q${_current + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q.prompt,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _answers[_current] = i),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: _answers[_current] == i
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Text(q.options[i]),
                      ),
                    );
                  }),
                  const Spacer(),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _current > 0
                            ? () => setState(() => _current--)
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (_current < _questions.length - 1) {
                            setState(() => _current++);
                          } else {
                            _finish();
                          }
                        },
                        child: Text(
                          _current < _questions.length - 1
                              ? 'Next'
                              : 'Submit mock',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockQuestion {
  const _MockQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}
