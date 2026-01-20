// Assign faculty to subject/year/branch based on expertise and ensure one free period per day
void assignFacultyToSubjects({
  required int daysPerWeek,
  required int periodsPerDay,
}) {
  // Map: day -> teacherId -> periods assigned
  Map<int, Map<String, int>> dailyAssignments = {};
  for (int day = 0; day < daysPerWeek; day++) {
    dailyAssignments[day] = {};
    for (final teacher in CollegeData.teachers) {
      dailyAssignments[day]![teacher.id] = 0;
    }
  }

  // For each subject, year, branch, assign a teacher who knows it and has a free slot
  for (final subject in CollegeData.subjects) {
    for (final branch in CollegeData.branchesSections.keys) {
      for (final year in ['1st', '2nd', '3rd', '4th']) {
        // Find eligible teachers
        final eligibleTeachers = CollegeData.teachers.where((t) =>
          t.subjects.contains(subject.code) &&
          t.branches.contains(branch) &&
          t.years.contains(year)
        ).toList();
        if (eligibleTeachers.isEmpty) continue;

        // Assign classes for the week
        int classesLeft = subject.classesPerWeek;
        for (int day = 0; day < daysPerWeek && classesLeft > 0; day++) {
          for (final teacher in eligibleTeachers) {
            // Ensure teacher has at least one free period per day
            if (dailyAssignments[day]![teacher.id]! < periodsPerDay - 1) {
              // Assign a period (find a free period)
              int assignedPeriods = dailyAssignments[day]![teacher.id]!;
              int period = assignedPeriods; // naive: assign next available
              // Add to timetable
              CollegeData.timetable.add(TimetableEntry(
                subjectCode: subject.code,
                teacherId: teacher.id,
                section: CollegeData.branchesSections[branch]!.isNotEmpty ? CollegeData.branchesSections[branch]!.first : '',
                branch: branch,
                year: year,
                day: day,
                period: period,
                isLab: subject.isLab,
                mentorId: '',
              ));
              dailyAssignments[day]![teacher.id] = assignedPeriods + 1;
              classesLeft--;
              if (classesLeft == 0) break;
            }
          }
        }
      }
    }
  }
}

import '../models/teacher.dart';
import '../models/subject.dart';
import '../models/timetable_entry.dart';

class CollegeData {
  static List<Teacher> teachers = [];
  static List<Subject> subjects = [];
  static List<Map<String, dynamic>> blocks = [];
  static Map<String, List<String>> branchesSections = {};
  static List<TimetableEntry> timetable = [];
}
