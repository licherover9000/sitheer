import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/data/prep_catalog_accessors.dart';
import 'package:sitheer/data/question_bank.dart';
import 'package:sitheer/model/prep_question.dart';
import 'package:sitheer/model/question_attempt.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/screens/prep/practice_review_screen.dart';

/// One question runner for every practice surface (per-chapter drills and
/// PYQ-by-year). Renders MCQ (single), MSQ (multi-select), and NAT (numeric),
/// gives immediate feedback, then records a [PracticeSession] and offers the
/// shared wrong-answer review.
class PracticeRunnerScreen extends StatefulWidget {
  const PracticeRunnerScreen({
    super.key,
    required this.questions,
    required this.title,
    required this.source,
    required this.refId,
  });

  /// Builds a per-chapter drill from the question bank.
  factory PracticeRunnerScreen.chapter(String chapterId) {
    final title = findChapterContext(chapterId)?.$2.title ?? chapterId;
    return PracticeRunnerScreen(
      questions: questionsForChapter(chapterId),
      title: 'PYQ - $title',
      source: 'pyq',
      refId: chapterId,
    );
  }

  final List<PrepQuestion> questions;
  final String title;
  final String source;
  final String refId;

  @override
  State<PracticeRunnerScreen> createState() => _PracticeRunnerScreenState();
}

class _PracticeRunnerScreenState extends State<PracticeRunnerScreen> {
  int _index = 0;
  bool _answered = false;
  final _natController = TextEditingController();

  // Recorded responses per question index.
  final Map<int, int> _mcq = {};
  final Map<int, Set<int>> _msq = {};
  final Map<int, double> _nat = {};

  // In-progress selection for the current question (before "Check").
  int? _pendingMcq;
  final Set<int> _pendingMsq = {};

  PrepQuestion get _q => widget.questions[_index];
  bool get _isLast => _index >= widget.questions.length - 1;

  @override
  void dispose() {
    _natController.dispose();
    super.dispose();
  }

  bool get _hasResponse {
    switch (_q.type) {
      case QuestionType.mcq:
        return _pendingMcq != null;
      case QuestionType.msq:
        return _pendingMsq.isNotEmpty;
      case QuestionType.nat:
        return double.tryParse(_natController.text.trim()) != null;
    }
  }

  void _check() {
    if (!_hasResponse) return;
    setState(() {
      _answered = true;
      switch (_q.type) {
        case QuestionType.mcq:
          _mcq[_index] = _pendingMcq!;
        case QuestionType.msq:
          _msq[_index] = {..._pendingMsq};
        case QuestionType.nat:
          _nat[_index] = double.parse(_natController.text.trim());
      }
    });
  }

  QuestionAttempt _attemptAt(int i) {
    final q = widget.questions[i];
    return QuestionAttempt.fromQuestion(
      q,
      attemptedAt: DateTime.now(),
      selectedIndex: _mcq[i],
      selectedIndexes: (_msq[i] ?? const <int>{}).toList(),
      numericResponse: _nat[i],
    );
  }

  QuestionAttempt _currentAttemptForFlag() => QuestionAttempt.fromQuestion(
    _q,
    attemptedAt: DateTime.now(),
    selectedIndex: _pendingMcq,
    selectedIndexes: _pendingMsq.toList(),
    numericResponse: double.tryParse(_natController.text.trim()),
    markedForReview: true,
  );

  Future<void> _next() async {
    if (!_isLast) {
      setState(() {
        _index++;
        _answered = false;
        _pendingMcq = null;
        _pendingMsq.clear();
        _natController.clear();
      });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final now = DateTime.now();
    final attempts = [
      for (var i = 0; i < widget.questions.length; i++) _attemptAt(i),
    ];
    final correct = attempts.where((a) => a.isCorrect).length;
    final session = PracticeSession(
      id: '${widget.source}-${widget.refId}-${now.millisecondsSinceEpoch}',
      source: widget.source,
      refId: widget.refId,
      title: widget.title,
      attempts: attempts,
      completedAt: now,
    );

    final prep = context.read<PrepProvider>();
    // Update chapter accuracy for per-chapter drills.
    if (widget.source == 'pyq' && widget.questions.isNotEmpty) {
      await prep.recordQuizResult(
        widget.refId,
        correct / widget.questions.length,
        widget.questions.length,
        incorrectCount: widget.questions.length - correct,
      );
    }
    await prep.recordPracticeSession(session);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Practice complete'),
        content: Text(
          'Score: $correct / ${widget.questions.length} '
          '(${(session.accuracy * 100).round()}% accuracy)\n'
          'Marks: ${session.marks.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeReviewScreen(session: session),
                ),
              );
            },
            child: const Text('Review answers'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No questions available yet.')),
      );
    }

    final prep = context.watch<PrepProvider>();
    final flagged = prep.isFlagged(_q.id);
    final total = widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: flagged ? 'Remove flag' : 'Flag to revise',
            icon: Icon(flagged ? Icons.flag : Icons.flag_outlined),
            color: flagged ? AppColors.warning : null,
            onPressed: () => prep.toggleFlag(_currentAttemptForFlag()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / total),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Question ${_index + 1} of $total',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
                ),
                const Spacer(),
                _TypeChip(type: _q.type, marks: _q.marks, year: _q.year),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    _q.prompt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._buildAnswerArea(),
                  if (_answered && _q.explanation != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: AppColors.bgSoft,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        child: Text(_q.explanation!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            FilledButton(
              onPressed: _answered ? _next : (_hasResponse ? _check : null),
              child: Text(
                _answered ? (_isLast ? 'Finish' : 'Next') : 'Check answer',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerArea() {
    switch (_q.type) {
      case QuestionType.mcq:
        return _optionTiles(multi: false);
      case QuestionType.msq:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Select all that apply',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
            ),
          ),
          ..._optionTiles(multi: true),
        ];
      case QuestionType.nat:
        return _natField();
    }
  }

  List<Widget> _optionTiles({required bool multi}) {
    return List.generate(_q.options.length, (i) {
      final isCorrect = multi
          ? _q.correctIndexes.contains(i)
          : i == _q.correctIndex;
      final selected = multi ? _pendingMsq.contains(i) : _pendingMcq == i;
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
              : () => setState(() {
                  if (multi) {
                    selected ? _pendingMsq.remove(i) : _pendingMsq.add(i);
                  } else {
                    _pendingMcq = i;
                  }
                }),
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
          child: Row(
            children: [
              Icon(
                multi
                    ? (selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                    : (selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(_q.options[i])),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _natField() {
    final correct = _answered && _q.isNumericCorrect(_nat[_index]);
    return [
      TextField(
        controller: _natController,
        enabled: !_answered,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
        ],
        decoration: const InputDecoration(
          labelText: 'Your answer (numerical)',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      if (_answered) ...[
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              color: correct ? AppColors.mint : AppColors.danger,
            ),
            const SizedBox(width: 8),
            Text('Correct answer: ${_q.correctAnswerText}'),
          ],
        ),
      ],
    ];
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.marks, this.year});

  final QuestionType type;
  final int marks;
  final int? year;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      QuestionType.mcq => 'MCQ',
      QuestionType.msq => 'MSQ',
      QuestionType.nat => 'NAT',
    };
    final text = [
      label,
      '$marks mark${marks == 1 ? '' : 's'}',
      if (year != null) '$year',
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
