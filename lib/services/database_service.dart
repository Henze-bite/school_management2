import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'school_management.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        profileImagePath TEXT
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        section TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        teacherId TEXT NOT NULL
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rollNumber TEXT NOT NULL,
        classId TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        profileImagePath TEXT,
        dateOfBirth TEXT NOT NULL,
        address TEXT NOT NULL,
        parentName TEXT NOT NULL,
        parentPhone TEXT NOT NULL
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        classId TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT
      )
    ''');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Student operations
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final result = await db.query('students');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<List<Student>> getStudentsByClass(String classId) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudent(String id) async {
    final db = await database;
    final result = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Student.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(String id) async {
    final db = await database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'name LIKE ? OR rollNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  // Class operations
  Future<void> insertClass(SchoolClass schoolClass) async {
    final db = await database;
    await db.insert(
      'classes',
      schoolClass.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SchoolClass>> getAllClasses() async {
    final db = await database;
    final result = await db.query('classes');
    return result.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<SchoolClass?> getClass(String id) async {
    final db = await database;
    final result = await db.query('classes', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return SchoolClass.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    final db = await database;
    await db.update(
      'classes',
      schoolClass.toMap(),
      where: 'id = ?',
      whereArgs: [schoolClass.id],
    );
  }

  Future<void> deleteClass(String id) async {
    final db = await database;
    await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // Attendance operations
  Future<void> insertAttendance(Attendance attendance) async {
    final db = await database;
    await db.insert(
      'attendance',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<List<Attendance>> getAttendanceByStudent(String studentId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<List<Attendance>> getAttendanceByClass(String classId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<List<Attendance>> getAllAttendance() async {
    final db = await database;
    final result = await db.query('attendance', orderBy: 'date DESC');
    return result.map((map) => Attendance.fromMap(map)).toList();
  }

  Future<void> updateAttendance(Attendance attendance) async {
    final db = await database;
    await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<void> deleteAttendance(String id) async {
    final db = await database;
    await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('attendance');
    await db.delete('students');
    await db.delete('classes');
    await db.delete('users');
  }
}
