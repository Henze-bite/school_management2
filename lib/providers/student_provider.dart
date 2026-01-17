import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Student> get students =>
      _filteredStudents.isEmpty ? _students : _filteredStudents;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalStudents => _students.length;

  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _students = await _dbService.getAllStudents();
      _filteredStudents = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load students: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      final newStudent = Student(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: student.name,
        rollNumber: student.rollNumber,
        classId: student.classId,
        email: student.email,
        phone: student.phone,
        profileImagePath: student.profileImagePath,
        dateOfBirth: student.dateOfBirth,
        address: student.address,
        parentName: student.parentName,
        parentPhone: student.parentPhone,
      );

      await _dbService.insertStudent(newStudent);
      _students.add(newStudent);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add student: $e';
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _dbService.updateStudent(student);
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update student: $e';
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _dbService.deleteStudent(id);
      _students.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete student: $e';
      notifyListeners();
    }
  }

  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = [];
    } else {
      _filteredStudents = _students
          .where(
            (student) =>
                student.name.toLowerCase().contains(query.toLowerCase()) ||
                student.rollNumber.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                student.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void sortStudentsByName() {
    _students.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void sortStudentsByClass() {
    _students.sort((a, b) => a.classId.compareTo(b.classId));
    notifyListeners();
  }

  void sortStudentsByRollNumber() {
    _students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
    notifyListeners();
  }

  Future<List<Student>> getStudentsByClass(String classId) async {
    return await _dbService.getStudentsByClass(classId);
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
