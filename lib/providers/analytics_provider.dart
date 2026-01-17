import 'package:flutter/material.dart';
import '../models/grade_model.dart';
import '../models/performance_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';

class AnalyticsProvider extends ChangeNotifier {
  final Map<String, List<Grade>> _grades = {};
  final Map<String, StudentPerformance> _performances = {};

  List<Grade> getStudentGrades(String studentId) {
    return _grades[studentId] ?? [];
  }

  StudentPerformance? getStudentPerformance(String studentId) {
    return _performances[studentId];
  }

  void addGrade(Grade grade) {
    if (_grades[grade.studentId] == null) {
      _grades[grade.studentId] = [];
    }
    _grades[grade.studentId]!.add(grade);
    _updatePerformance(grade.studentId);
    notifyListeners();
  }

  void updateGrade(String studentId, String gradeId, Grade updatedGrade) {
    final grades = _grades[studentId];
    if (grades != null) {
      final index = grades.indexWhere((g) => g.id == gradeId);
      if (index != -1) {
        grades[index] = updatedGrade;
        _updatePerformance(studentId);
        notifyListeners();
      }
    }
  }

  void deleteGrade(String studentId, String gradeId) {
    _grades[studentId]?.removeWhere((g) => g.id == gradeId);
    _updatePerformance(studentId);
    notifyListeners();
  }

  double calculateGPA(String studentId) {
    final grades = _grades[studentId] ?? [];
    if (grades.isEmpty) return 0.0;

    final totalGradePoints = grades.fold<double>(0, (sum, grade) {
      final gp = _getGradePoint(grade.percentage);
      return sum + gp;
    });

    return totalGradePoints / grades.length;
  }

  double _getGradePoint(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 80) return 3.7;
    if (percentage >= 70) return 3.3;
    if (percentage >= 60) return 3.0;
    if (percentage >= 50) return 2.0;
    return 0.0;
  }

  Map<String, double> getSubjectAverages(String studentId) {
    final grades = _grades[studentId] ?? [];
    final subjects = <String, List<double>>{};

    for (final grade in grades) {
      if (subjects[grade.subject] == null) {
        subjects[grade.subject] = [];
      }
      subjects[grade.subject]!.add(grade.percentage);
    }

    final averages = <String, double>{};
    subjects.forEach((subject, percentages) {
      averages[subject] =
          percentages.reduce((a, b) => a + b) / percentages.length;
    });

    return averages;
  }

  List<Grade> getTopPerformers(int limit) {
    final allGrades = _grades.values.expand((list) => list).toList();
    allGrades.sort((a, b) => b.percentage.compareTo(a.percentage));
    return allGrades.take(limit).toList();
  }

  void _updatePerformance(String studentId) {
    final gpa = calculateGPA(studentId);
    _performances[studentId] = StudentPerformance(
      studentId: studentId,
      gpa: gpa,
      attendancePercentage: 85.0,
      totalPresent: 42,
      totalAbsent: 8,
      strengths: _identifyStrengths(studentId),
      areasForImprovement: _identifyAreasForImprovement(studentId),
      lastUpdated: DateTime.now(),
    );
  }

  List<String> _identifyStrengths(String studentId) {
    final averages = getSubjectAverages(studentId);
    return averages.entries
        .where((e) => e.value >= 75)
        .map((e) => e.key)
        .toList();
  }

  List<String> _identifyAreasForImprovement(String studentId) {
    final averages = getSubjectAverages(studentId);
    return averages.entries
        .where((e) => e.value < 60)
        .map((e) => e.key)
        .toList();
  }

  Map<String, dynamic> getClassAnalytics(List<Student> students) {
    if (students.isEmpty) {
      return {
        'averageGPA': 0.0,
        'topStudent': null,
        'totalStudents': 0,
        'excellentCount': 0,
        'averageAttendance': 0.0,
      };
    }

    final gpas = students
        .map((s) => calculateGPA(s.id))
        .where((gpa) => gpa > 0)
        .toList();

    final topStudent = students.reduce((a, b) {
      final gpaA = calculateGPA(a.id);
      final gpaB = calculateGPA(b.id);
      return gpaA > gpaB ? a : b;
    });

    final excellentCount = students
        .where((s) => calculateGPA(s.id) >= 3.5)
        .length;

    return {
      'averageGPA': gpas.isEmpty
          ? 0.0
          : gpas.reduce((a, b) => a + b) / gpas.length,
      'topStudent': topStudent.name,
      'totalStudents': students.length,
      'excellentCount': excellentCount,
      'performancePercentage': excellentCount > 0
          ? (excellentCount / students.length) * 100
          : 0.0,
    };
  }

  Map<String, dynamic> generateStudentReport(
    Student student,
    List<Attendance> attendances,
  ) {
    final performance = _performances[student.id];
    final grades = _grades[student.id] ?? [];
    final attendancePercentage = attendances.isNotEmpty
        ? (attendances.where((a) => a.status == 'present').length /
                  attendances.length) *
              100
        : 0.0;

    return {
      'studentName': student.name,
      'rollNumber': student.rollNumber,
      'gpa': calculateGPA(student.id),
      'attendance': attendancePercentage,
      'totalGrades': grades.length,
      'averageMarks': grades.isEmpty
          ? 0.0
          : grades.map((g) => g.percentage).reduce((a, b) => a + b) /
                grades.length,
      'performance': performance?.performanceStatus ?? 'No Data',
      'strengths': performance?.strengths ?? [],
      'improvements': performance?.areasForImprovement ?? [],
      'generatedDate': DateTime.now().toString(),
    };
  }

  List<Map<String, dynamic>> getAttendanceTrend(
    List<Attendance> attendances,
    int days,
  ) {
    final now = DateTime.now();
    final trendData = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toString().split(' ')[0];
      final dayAttendances = attendances.where((a) => a.date == dateStr).toList();
      
      double percentage = 0.0;
      if (dayAttendances.isNotEmpty) {
        final presentCount = dayAttendances.where((a) => a.status == 'present').length;
        percentage = (presentCount / dayAttendances.length) * 100;
      }

      trendData.add({
        'label': '${date.day}/${date.month}',
        'percentage': percentage,
      });
    }

    return trendData;
  }

  Map<String, int> getGPADistribution(List<Student> students) {
    final distribution = <String, int>{
      '0.0-1.0': 0,
      '1.0-2.0': 0,
      '2.0-2.5': 0,
      '2.5-3.0': 0,
      '3.0-3.5': 0,
      '3.5-4.0': 0,
    };

    for (final student in students) {
      final gpa = calculateGPA(student.id);
      if (gpa >= 3.5) {
        distribution['3.5-4.0'] = (distribution['3.5-4.0'] ?? 0) + 1;
      } else if (gpa >= 3.0) {
        distribution['3.0-3.5'] = (distribution['3.0-3.5'] ?? 0) + 1;
      } else if (gpa >= 2.5) {
        distribution['2.5-3.0'] = (distribution['2.5-3.0'] ?? 0) + 1;
      } else if (gpa >= 2.0) {
        distribution['2.0-2.5'] = (distribution['2.0-2.5'] ?? 0) + 1;
      } else if (gpa >= 1.0) {
        distribution['1.0-2.0'] = (distribution['1.0-2.0'] ?? 0) + 1;
      } else {
        distribution['0.0-1.0'] = (distribution['0.0-1.0'] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Map<String, int> getPerformanceDistribution(List<Student> students) {
    int excellent = 0;
    int good = 0;
    int average = 0;
    int needsImprovement = 0;

    for (final student in students) {
      final gpa = calculateGPA(student.id);
      if (gpa >= 3.5) {
        excellent++;
      } else if (gpa >= 3.0) {
        good++;
      } else if (gpa >= 2.0) {
        average++;
      } else {
        needsImprovement++;
      }
    }

    return {
      'Excellent': excellent,
      'Good': good,
      'Average': average,
      'Needs Improvement': needsImprovement,
    };
  }

  Map<String, double> getClassSubjectAverages(List<Student> students) {
    final subjectTotals = <String, List<double>>{};
    final subjectCounts = <String, int>{};

    for (final student in students) {
      final subjectAverages = getSubjectAverages(student.id);
      subjectAverages.forEach((subject, average) {
        if (subjectTotals[subject] == null) {
          subjectTotals[subject] = [];
          subjectCounts[subject] = 0;
        }
        subjectTotals[subject]!.add(average);
        subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
      });
    }

    final classAverages = <String, double>{};
    subjectTotals.forEach((subject, values) {
      if (values.isNotEmpty) {
        classAverages[subject] = values.reduce((a, b) => a + b) / values.length;
      }
    });

    return classAverages;
  }
}
