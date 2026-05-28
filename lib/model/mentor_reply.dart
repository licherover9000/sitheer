class MentorReply {
  const MentorReply({
    required this.answer,
    required this.sources,
    this.intent = MentorIntent.general,
  });

  final String answer;
  final List<String> sources;
  final MentorIntent intent;
}

enum MentorIntent { plan, concept, mock, pyq, general }
