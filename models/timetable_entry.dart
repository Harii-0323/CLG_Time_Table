class TimetableEntry {
  final String subjectCode;
  final String teacherId;
  final String section;
  final String branch;
  final String year;
  final int day; // 0=Monday, 1=Tuesday, etc.
  final int period; // 0=first period, etc.
  final bool isLab;
  final String mentorId;

  TimetableEntry({
    required this.subjectCode,
    required this.teacherId,
    required this.section,
    required this.branch,
    required this.year,
    required this.day,
    required this.period,
    required this.isLab,
    required this.mentorId,
  });
}
