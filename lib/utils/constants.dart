import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);

  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF64748B);
}

class AppPadding {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 100.0;
}

class AppStrings {
  static const String appName = 'School Management';
  static const String dashboard = 'Dashboard';
  static const String students = 'Students';
  static const String classes = 'Classes';
  static const String attendance = 'Attendance';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String logout = 'Logout';

  static const String studentName = 'Student Name';
  static const String rollNumber = 'Roll Number';
  static const String email = 'Email';
  static const String phone = 'Phone Number';
  static const String dateOfBirth = 'Date of Birth';
  static const String address = 'Address';
  static const String parentName = 'Parent Name';
  static const String parentPhone = 'Parent Phone';

  static const String className = 'Class Name';
  static const String classTeacher = 'Class Teacher';
  static const String totalStudents = 'Total Students';

  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';

  static const String noData = 'No data available';
  static const String loading = 'Loading...';
  static const String error = 'Error occurred';
  static const String success = 'Success';
}

class AnimationDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
