import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedClassId;
  final Map<String, String> _attendanceMap = {}; // studentId -> status

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StudentProvider>().loadStudents();
        context.read<ClassProvider>().loadClasses();
      }
    });
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _attendanceMap.clear();
      });
    }
  }

  void _submitAttendance() async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    final attendanceProvider = context.read<AttendanceProvider>();
    final formatter = DateFormat('yyyy-MM-dd');

    for (var entry in _attendanceMap.entries) {
      final attendance = Attendance(
        id: '',
        studentId: entry.key,
        classId: _selectedClassId!,
        date: formatter.format(_selectedDate),
        status: entry.value,
      );
      await attendanceProvider.markAttendance(attendance);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<StudentProvider>().loadStudents();
          await context.read<ClassProvider>().loadClasses();
          if (_selectedClassId != null) {
            final formatter = DateFormat('yyyy-MM-dd');
            await context.read<AttendanceProvider>().loadAttendanceByDate(
                  formatter.format(_selectedDate),
                );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),

              // Class Selection
              const Text(
                'Select Class',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<ClassProvider>(
                builder: (context, classProvider, _) {
                  return DropdownButton(
                    value: _selectedClassId,
                    isExpanded: true,
                    hint: const Text('Select a class'),
                    items: classProvider.classes
                        .map(
                          (cls) => DropdownMenuItem(
                            value: cls.id,
                            child: Text('${cls.name} - ${cls.section}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        _attendanceMap.clear();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Student List
              if (_selectedClassId != null)
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, _) {
                    final classStudents = studentProvider.students
                        .where((s) => s.classId == _selectedClassId)
                        .toList();

                    if (classStudents.isEmpty) {
                      return const Center(
                        child: Text('No students in this class'),
                      );
                    }

                    return Column(
                      children: [
                        const Text(
                          'Mark Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...classStudents.map((student) {
                          final status = _attendanceMap[student.id] ?? 'absent';
                          return _buildAttendanceCard(student, status);
                        }),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitAttendance,
                            child: const Text('Submit Attendance'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic student, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Roll: ${student.rollNumber}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildStatusButton('Present', 'present', status),
                const SizedBox(width: 4),
                _buildStatusButton('Absent', 'absent', status),
                const SizedBox(width: 4),
                _buildStatusButton('Leave', 'leave', status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String value, String currentStatus) {
    final isSelected = currentStatus == value;
    return SizedBox(
      width: 60,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _attendanceMap[_getCurrentStudentId()] = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF1E88E5)
              : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }

  String _getCurrentStudentId() => '';
}
