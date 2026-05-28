/// Subject codes included per exam stream.
const gateCsSubjectCodes = {
  'algo',
  'ds',
  'os',
  'dbms',
  'cn',
  'toc',
  'math',
  'apt',
};

const gateDaSubjectCodes = {
  'math',
  'apt',
  'prog-da',
  'stats',
  'ml',
  'ds',
  'algo',
};

const gateCsOnlyCodes = {'algo', 'ds', 'os', 'dbms', 'cn', 'toc'};

const gateDaOnlyCodes = {'prog-da', 'stats', 'ml'};

bool subjectMatchesExam(String subjectCode, String exam) {
  if (exam == 'GATE DA') {
    return gateDaSubjectCodes.contains(subjectCode);
  }
  return gateCsSubjectCodes.contains(subjectCode);
}

bool weekMatchesExam(List<String> subjectCodes, String exam) {
  return subjectCodes.any((code) => subjectMatchesExam(code, exam));
}

bool mockMatchesExam(String stream, String exam) {
  if (stream == 'Mixed') return true;
  return stream == exam;
}
