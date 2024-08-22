import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        absent_count INTEGER NOT NULL DEFAULT 0,
        total_absent_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (student_id) REFERENCES students(student_id)
      )
    ''');
  }

  // Method to record attendance
  Future<int> recordAttendance(int studentId, bool isAbsent) async {
    final db = await instance.database;

    if (isAbsent) {
      final data = {
        'student_id': studentId,
        'date': DateTime.now().toIso8601String(),
        'absent_count': 1,
      };

      await db.insert('attendance', data);

      await db.rawUpdate('''
        UPDATE attendance
        SET total_absent_count = total_absent_count + 1
        WHERE student_id = ?
      ''', [studentId]);
    }

    return 1;
  }
  // Method to fetch all attendance records
  Future<List<Map<String, dynamic>>> fetchAllAttendance() async {
    final db = await instance.database;

    return await db.query('attendance');
  }

  // Corrected method to fetch attendance records for a specific student
  Future<List<Map<String, dynamic>>> fetchAttendance(int studentId) async {
    final db = await AttendanceDatabase.instance.database;

    return await db.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
