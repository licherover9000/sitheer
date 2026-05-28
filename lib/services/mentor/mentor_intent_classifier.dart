import 'package:sitheer/model/mentor_reply.dart';

MentorIntent classifyMentorIntent(String question) {
  final q = question.toLowerCase();
  if (q.contains('plan') ||
      q.contains('week') ||
      q.contains('roadmap') ||
      q.contains('schedule')) {
    return MentorIntent.plan;
  }
  if (q.contains('mock') || q.contains('score') || q.contains('rank')) {
    return MentorIntent.mock;
  }
  if (q.contains('pyq') || q.contains('previous year')) {
    return MentorIntent.pyq;
  }
  if (q.contains('explain') ||
      q.contains('why') ||
      q.contains('wrong') ||
      q.contains('concept') ||
      q.contains('normalize') ||
      q.contains('algorithm')) {
    return MentorIntent.concept;
  }
  return MentorIntent.general;
}

bool shouldUseBothModels(MentorIntent intent) =>
    intent == MentorIntent.general || intent == MentorIntent.plan;
