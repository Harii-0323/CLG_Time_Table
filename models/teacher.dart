class Teacher {
  final String id;
  final String name;
  final List<String> subjects; // List of subject codes/names
  final List<String> years;    // e.g., ['1st', '2nd']
  final List<String> branches; // e.g., ['CSE', 'ECE']

  Teacher({
    required this.id,
    required this.name,
    required this.subjects,
    required this.years,
    required this.branches,
  });
}
