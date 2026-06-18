import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/question_bank.dart';
import 'package:sitheer/model/mock_question.dart';
import 'package:sitheer/model/prep_question.dart';
import 'package:sitheer/model/prep_content.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/practice_review_screen.dart';

/// Full 65-question GATE-style mock exam with:
/// - Colour-coded question palette (not-visited / answered / marked / marked+answered)
/// - Mark for review toggle
/// - Clear response
/// - Countdown timer turning red in final 10 min, auto-submits at 0
/// - GATE scoring: +1 correct MCQ, -1/3 wrong MCQ, 0 skipped
/// - Submit confirmation dialog with unanswered count
class MockAttemptScreen extends StatefulWidget {
  const MockAttemptScreen({super.key, required this.paper});

  final MockPaper paper;

  @override
  State<MockAttemptScreen> createState() => _MockAttemptScreenState();
}

class _MockAttemptScreenState extends State<MockAttemptScreen> {
  final Map<int, int> _answers = {};
  final Set<int> _visited = {};
  final Set<int> _markedForReview = {};
  int _current = 0;
  late final List<MockQuestion> _questions;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
    _secondsLeft = _parseDurationMinutes(widget.paper.duration) * 60;
    _visited.add(0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished || !mounted) return;
      if (_secondsLeft <= 0) {
        _submit(autoSubmit: true);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  int _parseDurationMinutes(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '180') ?? 180;
  }

  List<MockQuestion> _buildQuestions() {
    // Shuffle so each attempt draws a different set/order, then cycle if the
    // pool is smaller than the paper size. Order is fixed for this attempt.
    // The mock interface is single-correct MCQ only; exclude NAT/MSQ.
    final pool =
        QuestionBank.instance.allQuestions
            .where((q) => q.type == QuestionType.mcq && q.options.isNotEmpty)
            .toList()
          ..shuffle();
    if (pool.isEmpty) return const [];
    final count = widget.paper.questions.clamp(10, 65);
    return List.generate(count, (i) {
      final q = pool[i % pool.length];
      return MockQuestion(
        questionId: q.id,
        prompt: q.prompt,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation,
        chapterId: q.chapterId,
      );
    });
  }

  void _navigateTo(int index) {
    setState(() {
      _current = index;
      _visited.add(index);
    });
  }

  void _toggleMark() {
    setState(() {
      if (_markedForReview.contains(_current)) {
        _markedForReview.remove(_current);
      } else {
        _markedForReview.add(_current);
      }
    });
  }

  void _clearResponse() {
    setState(() => _answers.remove(_current));
  }

  Future<void> _submit({bool autoSubmit = false}) async {
    if (_finished) return;

    // Stop the countdown immediately so it can't tick (or auto-submit again)
    // while the confirm dialog is open.
    _timer?.cancel();

    final unanswered = _questions.length - _answers.length;

    if (!autoSubmit && unanswered > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit mock?'),
          content: Text(
            '$unanswered question${unanswered == 1 ? '' : 's'} unanswered.\n'
            'Unanswered questions score 0 marks.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Review'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit anyway'),
            ),
          ],
        ),
      );
      // User chose to keep reviewing: resume the countdown from where it left.
      if (confirmed != true) {
        if (mounted && !_finished) _startTimer();
        return;
      }
    }

    int correct = 0;
    int incorrect = 0;
    int skipped = 0;

    for (var i = 0; i < _questions.length; i++) {
      final answered = _answers.containsKey(i);
      if (!answered) {
        skipped++;
      } else if (_answers[i] == _questions[i].correctIndex) {
        correct++;
      } else {
        incorrect++;
      }
    }

    setState(() => _finished = true);

    if (!mounted) return;

    final now = DateTime.now();
    final attempts = _questions.asMap().entries.map((e) {
      final q = e.value;
      return QuestionAttempt(
        questionId: q.questionId,
        chapterId: q.chapterId,
        prompt: q.prompt,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation,
        selectedIndex: _answers[e.key],
        markedForReview: _markedForReview.contains(e.key),
        attemptedAt: now,
      );
    }).toList();

    final session = PracticeSession(
      id: 'mock-${widget.paper.id}-${now.millisecondsSinceEpoch}',
      source: 'mock',
      refId: widget.paper.id,
      title: widget.paper.title,
      attempts: attempts,
      completedAt: now,
    );

    final prep = context.read<PrepProvider>();
    await prep.recordMockAttempt(widget.paper, correct, incorrect, skipped);
    await prep.recordPracticeSession(session);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PracticeReviewScreen(session: session)),
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

  bool get _isLowTime => _secondsLeft <= 600;

  Color _paletteColor(int i) {
    final answered = _answers.containsKey(i);
    final marked = _markedForReview.contains(i);
    final visited = _visited.contains(i);
    if (marked && answered) return AppColors.warning;
    if (marked) return Colors.purple;
    if (answered) return AppColors.mint;
    if (visited) return AppColors.danger;
    return AppColors.bgSoft;
  }

  Color _paletteTextColor(Color bg) {
    if (bg == AppColors.bgSoft) return AppColors.textMuted;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _questions[_current];
    final answered = _answers.containsKey(_current);
    final marked = _markedForReview.contains(_current);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paper.title, overflow: TextOverflow.ellipsis),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isLowTime
                  ? AppColors.danger.withValues(alpha: 0.12)
                  : AppColors.bgSoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: _isLowTime ? AppColors.danger : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _isLowTime ? AppColors.danger : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _timeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _isLowTime ? AppColors.danger : null,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _submit(),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Submit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // ── Question palette sidebar ──
          SizedBox(
            width: 220,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_questions.length} Questions',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      _PaletteLegend(),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemCount: _questions.length,
                    itemBuilder: (_, i) {
                      final isActive = i == _current;
                      final bg = _paletteColor(i);
                      return GestureDetector(
                        onTap: () => _navigateTo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _paletteTextColor(bg),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // ── Question area ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text('Q${_current + 1} of ${_questions.length}'),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(label: Text(q.chapterId)),
                      const Spacer(),
                      if (marked)
                        const Chip(
                          avatar: Icon(Icons.bookmark, size: 14),
                          label: Text('Marked for review'),
                          backgroundColor: Color(0x1A9C27B0),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    q.prompt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(q.options.length, (i) {
                    final label = String.fromCharCode(65 + i);
                    final isSelected = _answers[_current] == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _answers[_current] = i),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                          backgroundColor: isSelected
                              ? AppColors.primary.withValues(alpha: 0.07)
                              : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.bgSoft,
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : AppColors.textMuted,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(q.options[i])),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _toggleMark,
                        icon: Icon(
                          marked ? Icons.bookmark : Icons.bookmark_outline,
                          size: 18,
                        ),
                        label: Text(marked ? 'Unmark' : 'Mark & Next'),
                      ),
                      const SizedBox(width: 8),
                      if (answered)
                        OutlinedButton.icon(
                          onPressed: _clearResponse,
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear'),
                        ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _current > 0
                            ? () => _navigateTo(_current - 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (_current < _questions.length - 1) {
                            _navigateTo(_current + 1);
                          } else {
                            _submit();
                          }
                        },
                        child: Text(
                          _current < _questions.length - 1
                              ? 'Save & Next'
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

class _PaletteLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (AppColors.bgSoft, 'Not visited', AppColors.textMuted),
      (AppColors.danger, 'Visited, not answered', Colors.white),
      (AppColors.mint, 'Answered', Colors.white),
      (Colors.purple, 'Marked for review', Colors.white),
      (AppColors.warning, 'Marked + answered', Colors.white),
    ];
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: item.$1,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
