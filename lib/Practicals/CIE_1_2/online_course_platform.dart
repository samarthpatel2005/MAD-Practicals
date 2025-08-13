import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

class Student {
  final String studentId;
  final String name;
  final List<Course> courses = [];

  Student({required this.studentId, required this.name});

  @override
  String toString() => '$name ($studentId)';
}

class Assignment {
  final String title;
  final DateTime dueDate;
  final Map<Student, double> grades = HashMap();

  Assignment({required this.title, required this.dueDate});

  @override
  String toString() => '$title (Due: ${dueDate.toLocal().toString().split(' ')[0]})';
}

class Course {
  final String courseName;
  final String courseId;
  final List<Assignment> assignments = [];
  final List<Student> students = [];

  Course({required this.courseName, required this.courseId});

  void enrollStudent(Student student) {
    if (!students.contains(student)) {
      students.add(student);
      student.courses.add(this);
    }
  }

  void addAssignment(Assignment assignment) {
    assignments.add(assignment);
  }

  void submitAssignment(Student student, Assignment assignment) {
    if (!students.contains(student)) {
      print('${student.name} is not enrolled in $courseName.');
      return;
    }
    print('${student.name} submitted "${assignment.title}"');
  }

  void assignGrade(Student student, Assignment assignment, double grade) {
    if (!students.contains(student)) {
      print('${student.name} is not enrolled in $courseName.');
      return;
    }
    assignment.grades[student] = grade;
    print('Grade $grade assigned to ${student.name} for "${assignment.title}"');
  }

  double? calculateAverageGrade(Student student) {
    final grades = assignments
        .map((a) => a.grades[student])
        .where((g) => g != null)
        .cast<double>()
        .toList();
    if (grades.isEmpty) return null;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  String generateCourseSummary() {
    final buffer = StringBuffer();
    buffer.writeln('--- Course Summary for $courseName ($courseId) ---');
    buffer.writeln('Number of students: ${students.length}');
    buffer.writeln('Number of assignments: ${assignments.length}');

    // Calculate course average
    final allGrades = <double>[];
    for (var student in students) {
      final avg = calculateAverageGrade(student);
      if (avg != null) allGrades.add(avg);
    }

    final courseAvg = allGrades.isEmpty
        ? 0.0
        : allGrades.reduce((a, b) => a + b) / allGrades.length;
    buffer.writeln('Average grade of the course: ${courseAvg.toStringAsFixed(2)}');

    // Get top 3 performers
    final studentAverages = <MapEntry<Student, double>>[];
    for (var student in students) {
      final avg = calculateAverageGrade(student);
      if (avg != null) {
        studentAverages.add(MapEntry(student, avg));
      }
    }
    studentAverages.sort((a, b) => b.value.compareTo(a.value));

    buffer.writeln('Top 3 performers:');
    for (var i = 0; i < min(3, studentAverages.length); i++) {
      final entry = studentAverages[i];
      buffer.writeln(
          '${i + 1}. ${entry.key.name} (${entry.key.studentId}) - ${entry.value.toStringAsFixed(2)}');
    }
    buffer.writeln('----------------------------------------------');
    return buffer.toString();
  }
}

class OnlineCoursePlatformScreen extends StatefulWidget {
  const OnlineCoursePlatformScreen({Key? key}) : super(key: key);

  @override
  State<OnlineCoursePlatformScreen> createState() =>
      _OnlineCoursePlatformScreenState();
}

class _OnlineCoursePlatformScreenState
    extends State<OnlineCoursePlatformScreen> {
  late Course course;
  late List<Assignment> assignments;
  late List<Student> students;

  @override
  void initState() {
    super.initState();
    
    // Initialize course
    course = Course(courseName: 'Course App', courseId: 'C-101');
    
    // Create students
    students = [
      Student(studentId: 'S001', name: 'Aman Patel'),
      Student(studentId: 'S002', name: 'Jaimin Raval'),
      Student(studentId: 'S003', name: 'Ayush Patel'),
      Student(studentId: 'S004', name: 'Rohit sharma'),
      Student(studentId: 'S005', name: 'Shubh Patel'),
    ];
    
    // Enroll students in the course
    for (var student in students) {
      course.enrollStudent(student);
    }

    // Create assignments
    assignments = [
      Assignment(title: 'UI Design Basics', dueDate: DateTime(2024, 6, 15)),
      Assignment(title: 'State Management', dueDate: DateTime(2024, 6, 25)),
      Assignment(title: 'API Integration', dueDate: DateTime(2024, 7, 5)),
      Assignment(title: 'Final Project', dueDate: DateTime(2024, 7, 20)),
    ];
    
    // Add assignments to course
    for (var assignment in assignments) {
      course.addAssignment(assignment);
    }

    // Simulate some submissions and grades
    _simulateSubmissionsAndGrades();
  }

  void _simulateSubmissionsAndGrades() {
    // Assignment 1 submissions and grades
    course.submitAssignment(students[0], assignments[0]);
    course.submitAssignment(students[1], assignments[0]);
    course.submitAssignment(students[2], assignments[0]);
    course.submitAssignment(students[3], assignments[0]);
    
    course.assignGrade(students[0], assignments[0], 92);
    course.assignGrade(students[1], assignments[0], 87);
    course.assignGrade(students[2], assignments[0], 95);
    course.assignGrade(students[3], assignments[0], 83);

    // Assignment 2 submissions and grades
    course.submitAssignment(students[0], assignments[1]);
    course.submitAssignment(students[1], assignments[1]);
    course.submitAssignment(students[2], assignments[1]);
    course.submitAssignment(students[3], assignments[1]);
    course.submitAssignment(students[4], assignments[1]);
    
    course.assignGrade(students[0], assignments[1], 88);
    course.assignGrade(students[1], assignments[1], 91);
    course.assignGrade(students[2], assignments[1], 93);
    course.assignGrade(students[3], assignments[1], 85);
    course.assignGrade(students[4], assignments[1], 79);

    // Assignment 3 submissions and grades
    course.submitAssignment(students[0], assignments[2]);
    course.submitAssignment(students[1], assignments[2]);
    course.submitAssignment(students[2], assignments[2]);
    course.submitAssignment(students[4], assignments[2]);
    
    course.assignGrade(students[0], assignments[2], 94);
    course.assignGrade(students[1], assignments[2], 89);
    course.assignGrade(students[2], assignments[2], 96);
    course.assignGrade(students[4], assignments[2], 82);
  }

  void _showCourseSummaryDialog() {
    final summary = course.generateCourseSummary();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Course Summary'),
        content: SingleChildScrollView(
          child: Text(
            summary,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${course.courseName} (${course.courseId})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Show Course Summary',
            onPressed: _showCourseSummaryDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Course: ${course.courseName}'),
                    Text('Course ID: ${course.courseId}'),
                    Text('Total Students: ${course.students.length}'),
                    Text('Total Assignments: ${course.assignments.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Students Section
            Text(
              'Enrolled Students',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...students.map(
              (student) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student.name} (${student.studentId})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Assignment Grades:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      ...assignments.map((assignment) {
                        final grade = assignment.grades[student];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  assignment.title,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: grade != null
                                      ? (grade >= 90
                                          ? Colors.green.shade100
                                          : grade >= 80
                                              ? Colors.orange.shade100
                                              : Colors.red.shade100)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  grade != null
                                      ? grade.toStringAsFixed(1)
                                      : 'Not graded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: grade != null
                                        ? (grade >= 90
                                            ? Colors.green.shade800
                                            : grade >= 80
                                                ? Colors.orange.shade800
                                                : Colors.red.shade800)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Course Average: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              course.calculateAverageGrade(student)?.toStringAsFixed(2) ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Assignments Section
            Text(
              'Assignments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...assignments.map(
              (assignment) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due Date: ${assignment.dueDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submissions: ${assignment.grades.length}/${students.length}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCourseSummaryDialog,
        tooltip: 'View Course Summary',
        child: const Icon(Icons.assessment),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Online Course Platform',
    home: OnlineCoursePlatformScreen(),
    debugShowCheckedModeBanner: false,
  ));
}