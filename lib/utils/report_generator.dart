import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/class_model.dart';

class ReportGenerator {
  static Map<String, dynamic> generateStudentPerformanceReport(
    Student student,
    List<dynamic> grades,
    List<Attendance> attendance,
    double gpa,
  ) {
    final presentCount = attendance.where((a) => a.status == 'present').length;
    final attendancePercentage = attendance.isEmpty
        ? 0.0
        : (presentCount / attendance.length) * 100;

    return {
      'studentId': student.id,
      'studentName': student.name,
      'rollNumber': student.rollNumber,
      'email': student.email,
      'phone': student.phone,
      'classId': student.classId,
      'gpa': gpa,
      'attendancePercentage': attendancePercentage,
      'totalClasses': attendance.length,
      'presentDays': presentCount,
      'absentDays': attendance.length - presentCount,
      'totalGrades': grades.length,
      'generatedDate': DateTime.now().toString(),
    };
  }

  static Map<String, dynamic> generateClassReport(
    String className,
    List<Student> students,
    Map<String, double> gpas,
    Map<String, double> attendances,
  ) {
    final totalStudents = students.length;
    final averageGPA = gpas.isNotEmpty
        ? gpas.values.reduce((a, b) => a + b) / totalStudents
        : 0.0;
    final averageAttendance = attendances.isNotEmpty
        ? attendances.values.reduce((a, b) => a + b) / totalStudents
        : 0.0;

    final excellentStudents = students
        .where((s) => gpas[s.id] != null && gpas[s.id]! >= 3.5)
        .map((s) => s.name)
        .toList();

    final needsHelpStudents = students
        .where((s) => gpas[s.id] != null && gpas[s.id]! < 2.0)
        .map((s) => s.name)
        .toList();

    return {
      'className': className,
      'totalStudents': totalStudents,
      'averageGPA': averageGPA,
      'averageAttendance': averageAttendance,
      'excellentStudents': excellentStudents,
      'needsHelpStudents': needsHelpStudents,
      'generatedDate': DateTime.now().toString(),
    };
  }

  static String formatReportAsString(Map<String, dynamic> report) {
    StringBuffer buffer = StringBuffer();
    report.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  static Future<void> generateStudentReportPDF(
    Student student,
    List<Grade> grades,
    List<Attendance> attendance,
    double gpa,
  ) async {
    final pdf = pw.Document();
    final presentCount = attendance.where((a) => a.status == 'present').length;
    final attendancePercentage = attendance.isEmpty
        ? 0.0
        : (presentCount / attendance.length) * 100;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Student Report Card',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${DateTime.now().toString().split(' ')[0]}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Student Information
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Student Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildInfoRow('Name', student.name),
                  _buildInfoRow('Roll Number', student.rollNumber),
                  _buildInfoRow('Email', student.email),
                  _buildInfoRow('Phone', student.phone),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Performance Summary
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatBox('GPA', gpa.toStringAsFixed(2)),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox(
                    'Attendance',
                    '${attendancePercentage.toStringAsFixed(1)}%',
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox('Total Grades', grades.length.toString()),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Grades Table
            if (grades.isNotEmpty) ...[
              pw.Text(
                'Grades',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Subject', isHeader: true),
                      _buildTableCell('Marks', isHeader: true),
                      _buildTableCell('Percentage', isHeader: true),
                      _buildTableCell('Grade', isHeader: true),
                    ],
                  ),
                  ...grades.map((grade) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(grade.subject),
                        _buildTableCell(grade.marks.toString()),
                        _buildTableCell('${grade.percentage.toStringAsFixed(1)}%'),
                        _buildTableCell(grade.grade),
                      ],
                    );
                  }),
                ],
              ),
            ],

            // Attendance Summary
            if (attendance.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Attendance Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBox('Present', presentCount.toString()),
                  _buildStatBox(
                    'Absent',
                    (attendance.length - presentCount).toString(),
                  ),
                  _buildStatBox('Total Days', attendance.length.toString()),
                ],
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateClassReportPDF(
    SchoolClass schoolClass,
    List<Student> students,
    Map<String, double> gpas,
    Map<String, double> attendances,
  ) async {
    final pdf = pw.Document();
    final totalStudents = students.length;
    final averageGPA = gpas.isNotEmpty
        ? gpas.values.reduce((a, b) => a + b) / totalStudents
        : 0.0;
    final averageAttendance = attendances.isNotEmpty
        ? attendances.values.reduce((a, b) => a + b) / totalStudents
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Class Performance Report - ${schoolClass.name} ${schoolClass.section}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Stats
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatBox('Total Students', totalStudents.toString()),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox('Avg GPA', averageGPA.toStringAsFixed(2)),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox(
                    'Avg Attendance',
                    '${averageAttendance.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Students Table
            pw.Text(
              'Student Performance',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCell('Name', isHeader: true),
                    _buildTableCell('Roll Number', isHeader: true),
                    _buildTableCell('GPA', isHeader: true),
                    _buildTableCell('Attendance', isHeader: true),
                  ],
                ),
                ...students.map((student) {
                  final gpa = gpas[student.id] ?? 0.0;
                  final attendance = attendances[student.id] ?? 0.0;
                  return pw.TableRow(
                    children: [
                      _buildTableCell(student.name),
                      _buildTableCell(student.rollNumber),
                      _buildTableCell(gpa.toStringAsFixed(2)),
                      _buildTableCell('${attendance.toStringAsFixed(1)}%'),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateAttendanceReportPDF(
    List<Attendance> attendance,
    String? className,
  ) async {
    final pdf = pw.Document();
    final presentCount = attendance.where((a) => a.status == 'present').length;
    final absentCount = attendance.where((a) => a.status == 'absent').length;
    final leaveCount = attendance.where((a) => a.status == 'leave').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Attendance Report${className != null ? ' - $className' : ''}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatBox('Present', presentCount.toString()),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox('Absent', absentCount.toString()),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox('Leave', leaveCount.toString()),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildStatBox('Total', attendance.length.toString()),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Attendance Table
            pw.Text(
              'Attendance Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Student ID', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                    _buildTableCell('Remarks', isHeader: true),
                  ],
                ),
                ...attendance.take(50).map((att) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(att.date),
                      _buildTableCell(att.studentId),
                      _buildTableCell(att.status),
                      _buildTableCell(att.remarks ?? '-'),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
