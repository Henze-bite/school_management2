import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/database_service.dart';

class ClassProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<SchoolClass> _classes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SchoolClass> get classes => _classes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalClasses => _classes.length;

  Future<void> loadClasses() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _classes = await _dbService.getAllClasses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load classes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    try {
      final newClass = SchoolClass(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: schoolClass.name,
        section: schoolClass.section,
        capacity: schoolClass.capacity,
        teacherId: schoolClass.teacherId,
      );

      await _dbService.insertClass(newClass);
      _classes.add(newClass);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add class: $e';
      notifyListeners();
    }
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    try {
      await _dbService.updateClass(schoolClass);
      final index = _classes.indexWhere((c) => c.id == schoolClass.id);
      if (index != -1) {
        _classes[index] = schoolClass;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update class: $e';
      notifyListeners();
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _dbService.deleteClass(id);
      _classes.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete class: $e';
      notifyListeners();
    }
  }

  SchoolClass? getClassById(String id) {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
