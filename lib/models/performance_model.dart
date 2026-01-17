class StudentPerformance {
  final String studentId;
  final double gpa;
  final double attendancePercentage;
  final int totalPresent;
  final int totalAbsent;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final DateTime lastUpdated;

  StudentPerformance({
    required this.studentId,
    required this.gpa,
    required this.attendancePercentage,
    required this.totalPresent,
    required this.totalAbsent,
    required this.strengths,
    required this.areasForImprovement,
    required this.lastUpdated,
  });

  int get totalClasses => totalPresent + totalAbsent;

  String get performanceStatus {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Very Good';
    if (gpa >= 2.5) return 'Good';
    if (gpa >= 2.0) return 'Average';
    return 'Needs Improvement';
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'gpa': gpa,
      'attendancePercentage': attendancePercentage,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'strengths': strengths.join(','),
      'areasForImprovement': areasForImprovement.join(','),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StudentPerformance.fromMap(Map<String, dynamic> map) {
    return StudentPerformance(
      studentId: map['studentId'] ?? '',
      gpa: (map['gpa'] ?? 0.0).toDouble(),
      attendancePercentage: (map['attendancePercentage'] ?? 0.0).toDouble(),
      totalPresent: map['totalPresent'] ?? 0,
      totalAbsent: map['totalAbsent'] ?? 0,
      strengths:
          (map['strengths'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      areasForImprovement:
          (map['areasForImprovement'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      lastUpdated: DateTime.parse(
        map['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
