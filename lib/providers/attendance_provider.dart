import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  List<Attendance> _attendances = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> markAttendance(Attendance attendance) async {
    try {
      final newAttendance = Attendance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: attendance.studentId,
        classId: attendance.classId,
        date: attendance.date,
        status: attendance.status,
        remarks: attendance.remarks,
      );

      await _dbService.insertAttendance(newAttendance);
      _attendances.add(newAttendance);
      
      // Schedule reminder for next day
      final nextDay = DateTime.now().add(const Duration(days: 1));
      await _notificationService.scheduleAttendanceReminder(nextDay);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark attendance: $e';
      notifyListeners();
    }
  }

  Future<void> loadAttendanceByDate(String date) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _attendances = await _dbService.getAttendanceByDate(date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load attendance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceByStudent(String studentId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _attendances = await _dbService.getAttendanceByStudent(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load attendance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceByClass(String classId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _attendances = await _dbService.getAttendanceByClass(classId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load attendance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllAttendance() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _attendances = await _dbService.getAllAttendance();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load attendance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAttendance(Attendance attendance) async {
    try {
      await _dbService.updateAttendance(attendance);
      final index = _attendances.indexWhere((a) => a.id == attendance.id);
      if (index != -1) {
        _attendances[index] = attendance;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update attendance: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAttendance(String id) async {
    try {
      await _dbService.deleteAttendance(id);
      _attendances.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete attendance: $e';
      notifyListeners();
    }
  }

  int getAttendanceCount(String studentId, String status) {
    return _attendances
        .where((a) => a.studentId == studentId && a.status == status)
        .length;
  }

  double getAttendancePercentage(String studentId, int totalDays) {
    if (totalDays == 0) return 0;
    final presentCount = getAttendanceCount(studentId, 'present');
    return (presentCount / totalDays) * 100;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
