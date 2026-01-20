import 'package:flutter/material.dart';

import '../data/college_data.dart';
import '../models/timetable_entry.dart';
import '../models/subject.dart';
import '../models/teacher.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}


  String? subjectCode, teacherId, mentorId, section, branch, year;
  int? day, period;
  bool isLab = false;
  int labLength = 2; // default lab length

  void addEntry() {
        // Validate branch
        if (branch == null || !CollegeData.branchesSections.containsKey(branch)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Invalid branch")));
          return;
        }

        // Validate section
        if (section == null || !CollegeData.branchesSections[branch]!.contains(section)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Invalid section for branch")));
          return;
        }

        // Validate block (if block info is required, e.g., section/block mapping)
        // Example: if you want to check if a block exists, add a block field and validate here
        // if (block == null || !CollegeData.blocks.any((b) => b["name"] == block)) {
        //   ScaffoldMessenger.of(context)
        //       .showSnackBar(const SnackBar(content: Text("Invalid block")));
        //   return;
        // }
    // Find subject and teacher
    final subject = CollegeData.subjects.firstWhere((s) => s.code == subjectCode, orElse: () => Subject(code: '', name: '', isLab: false, classesPerWeek: 0));
    final teacher = CollegeData.teachers.firstWhere((t) => t.id == teacherId, orElse: () => Teacher(id: '', name: '', subjects: [], years: [], branches: []));

    // Check for teacher timing collision
    final clash = CollegeData.timetable.any((e) =>
        e.teacherId == teacherId &&
        e.day == day &&
        e.period == period);

    if (clash) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Teacher timing collision detected")));
      return;
    }

    // Lab period continuity check
    if (subject.isLab) {
      for (int i = 0; i < labLength; i++) {
        final labClash = CollegeData.timetable.any((e) =>
            e.teacherId == teacherId &&
            e.day == day &&
            e.period == (period ?? 0) + i);
        if (labClash) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Lab period collision detected")));
          return;
        }
      }
    }

    // Mentor assignment: no two classes at same time with same mentor
    if (mentorId != null) {
      final mentorClash = CollegeData.timetable.any((e) =>
          e.mentorId == mentorId &&
          e.day == day &&
          e.period == period);
      if (mentorClash) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Mentor already assigned at this time")));
        return;
      }
    }

    // Add entry (lab: add multiple periods)
    if (subject.isLab) {
      for (int i = 0; i < labLength; i++) {
        CollegeData.timetable.add(TimetableEntry(
          subjectCode: subjectCode ?? '',
          teacherId: teacherId ?? '',
          section: section ?? '',
          branch: branch ?? '',
          year: year ?? '',
          day: day ?? 0,
          period: (period ?? 0) + i,
          isLab: true,
          mentorId: mentorId ?? '',
        ));
      }
    } else {
      CollegeData.timetable.add(TimetableEntry(
        subjectCode: subjectCode ?? '',
        teacherId: teacherId ?? '',
        section: section ?? '',
        branch: branch ?? '',
        year: year ?? '',
        day: day ?? 0,
        period: period ?? 0,
        isLab: false,
        mentorId: mentorId ?? '',
      ));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timetable")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              hint: const Text("Subject"),
              items: CollegeData.subjects
                  .map((s) => DropdownMenuItem(value: s.code, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => subjectCode = v),
            ),
            DropdownButtonFormField<String>(
              hint: const Text("Teacher"),
              items: CollegeData.teachers
                  .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => setState(() => teacherId = v),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Mentor ID"),
              onChanged: (v) => mentorId = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Section"),
              onChanged: (v) => section = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Branch"),
              onChanged: (v) => branch = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Year"),
              onChanged: (v) => year = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Day (0=Mon)"),
              keyboardType: TextInputType.number,
              onChanged: (v) => day = int.tryParse(v),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Period"),
              keyboardType: TextInputType.number,
              onChanged: (v) => period = int.tryParse(v),
            ),
            Row(
              children: [
                Checkbox(
                  value: isLab,
                  onChanged: (v) => setState(() => isLab = v ?? false),
                ),
                const Text("Is Lab"),
                if (isLab)
                  SizedBox(
                    width: 100,
                    child: TextField(
                      decoration: const InputDecoration(labelText: "Lab Length"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => labLength = int.tryParse(v) ?? 2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: addEntry, child: const Text("Add")),
            const Divider(),
            Expanded(
              child: ListView(
                children: CollegeData.timetable
                    .map((e) => ListTile(
                          title: Text(
                              "${e.subjectCode} - ${e.teacherId} (${e.day} P${e.period}) [${e.isLab ? 'Lab' : 'Theory'}] Mentor: ${e.mentorId}"),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
