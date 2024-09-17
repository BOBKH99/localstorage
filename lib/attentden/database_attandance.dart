import 'dart:async';


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class AttendanceDatabase {
  static final AttendanceDatabase instance = AttendanceDatabase._init();

  static Database? _database;

  AttendanceDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      // onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Attendance (
      id INTEGER NOT NULL,
      student_id INTEGER NOT NULL,
      date TEXT ,
      absent INTEGER DEFAULT 0,
      present INTEGER DEFAULT 0,
      late INTEGER DEFAULT 0,
      total_absent INTEGER DEFAULT 0,
      total_present INTEGER DEFAULT 0,
      total_late INTEGER DEFAULT 0,
      PRIMARY KEY (id, student_id)
    )
    ''');
  }
  // Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     await db.execute('''
  //     ALTER TABLE Attendance ADD COLUMN present INTEGER DEFAULT 0
  //     ''');
  //     await db.execute('''
  //     ALTER TABLE Attendance ADD COLUMN total_present INTEGER DEFAULT 0
  //     ''');
  //   }
  // }

  Future<void> insertAttendance(int studentId, int? absent, int? present, int? late) async {
    final db = await AttendanceDatabase.instance.database;
    String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Get the max current id for the student_id
    final List<Map<String, dynamic>> maxIdResult = await db.rawQuery(
        'SELECT MAX(id) as max_id, SUM(absent) as total_absent, SUM(present) as total_present, SUM(late) as total_late FROM Attendance WHERE student_id = ?',
        [studentId]
    );

    int newId = (maxIdResult.first['max_id'] ?? 0) + 1;

    int totalAbsent = (maxIdResult.first['total_absent'] ?? 0) + (absent ?? 0);
    int totalPresent = (maxIdResult.first['total_present'] ?? 0) + (present ?? 0);
    int totalLate = (maxIdResult.first['total_late'] ?? 0) + (late ?? 0);


    await db.insert(
      'Attendance',
      {
        'id': newId,
        'student_id': studentId,
        'date': currentDate,
        'absent': absent,
        'present': present,
        'late': late,
        'total_absent': totalAbsent,
        'total_present': totalPresent,
        'total_late': totalLate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  // Fetch scores for a specific student
  Future<List<Map<String, dynamic>>> fetchAbsent(int studentId) async {
    final db = await instance.database;
    return await db.query('Attendance', where: 'student_id = ?', whereArgs: [studentId]);
  }

  Future<Map<String, dynamic>> fetchTotalAbsent(int studentId) async {
    final db = await AttendanceDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        SUM(absent) as total_absent,
        SUM(late) as total_late    
      FROM Attendance 
      WHERE student_id = ?
    ''', [studentId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {'total_absent': 0, 'total_late' : 0};
    }
  }

  Future<Map<String, dynamic>> fetchTotalPresent(int studentId) async {
    final db = await AttendanceDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        SUM(present) as total_present
      FROM Attendance 
      WHERE student_id = ?
    ''', [studentId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {'total_present': 0};
    }
  }

  Future<void> updateAttendance(int id, int studentId, int? newAbsent, int? newPresent, int? newLate) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> previousAttendanceResult = await db.query(
      'Attendance',
      columns: ['absent', 'present', 'late'],
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );
    int oldAbsent = previousAttendanceResult.first['absent'] ?? 0;
    int oldPresent = previousAttendanceResult.first['present'] ?? 0;
    int oldLate = previousAttendanceResult.first['late'] ?? 0;

    int absentDifference = (newAbsent ?? 0) - oldAbsent;
    int presentDifference = (newPresent ?? 0) - oldPresent;
    int lateDifference = (newLate ?? 0) - oldLate;

    await db.rawUpdate('''
      UPDATE Attendance SET
        absent = ?,
        present = ?,
        late = ?,
        total_absent = total_absent + ?,
        total_present = total_present + ?,
        total_late = total_late + ?
      WHERE id = ? AND student_id = ?
    ''', [newAbsent, newPresent, newLate, absentDifference, presentDifference, lateDifference, id, studentId]);
  }
  Future<void> deleteAttendanceAll(int studentId) async {
    final db = await instance.database;

    await db.delete(
      'Attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }
  Future<void> deleteAttendance(int id, int studentId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> previousAttendanceResult = await db.query(
      'Attendance',
      columns: ['absent', 'present', 'late'],
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );
    int oldAbsent = previousAttendanceResult.first['absent'] ?? 0;
    int oldPresent = previousAttendanceResult.first['present'] ?? 0;
    int oldLate = previousAttendanceResult.first['late'] ?? 0;

    await db.rawUpdate('''
      UPDATE Attendance SET
        total_absent = total_absent - ?,
        total_present = total_present - ?,
        total_late = total_late - ?
      WHERE student_id = ?
    ''', [oldAbsent, oldPresent, oldLate, studentId]);

    await db.delete(
      'Attendance',
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId]
    );
  }


  Future<void> updateAttendanceByid(int studentId, int? newAbsent, int? newPresent, int? newLate) async {
    final db = await instance.database;

    // Query to get the maximum id for the given student_id
    final List<Map<String, dynamic>> maxIdResult = await db.rawQuery('''
    SELECT MAX(id) as max_id FROM Attendance WHERE student_id = ?
  ''', [studentId]);

    if (maxIdResult.isEmpty || maxIdResult.first['max_id'] == null) {
      print('No attendance records found for student_id: $studentId');
      return; // No records found, return early
    }

    int maxId = maxIdResult.first['max_id'];

    final List<Map<String, dynamic>> previousAttendanceResult = await db.query(
      'Attendance',
      columns: ['absent', 'present', 'late'],
      where: 'id = ? AND student_id = ?',
      whereArgs: [maxId, studentId],
    );

    if (previousAttendanceResult.isEmpty) {
      print('No previous attendance record found for id: $maxId and student_id: $studentId');
      return; // No previous record found, return early
    }

    int oldAbsent = previousAttendanceResult.first['absent'] ?? 0;
    int oldPresent = previousAttendanceResult.first['present'] ?? 0;
    int oldLate = previousAttendanceResult.first['late'] ?? 0;

    int absentDifference = (newAbsent ?? 0) - oldAbsent;
    int presentDifference = (newPresent ?? 0) - oldPresent;
    int lateDifference = (newLate ?? 0) - oldLate;

    await db.rawUpdate('''
    UPDATE Attendance SET
      absent = ?,
      present = ?,
      late = ?,
      total_absent = total_absent + ?,
      total_present = total_present + ?,
      total_late = total_late + ?
    WHERE id = ? AND student_id = ?
  ''', [newAbsent, newPresent, newLate, absentDifference, presentDifference, lateDifference, maxId, studentId]);
  }




  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
