import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart'; // Import your model class

class StudentsDatabase {
  static final StudentsDatabase _instance = StudentsDatabase._internal();
  factory StudentsDatabase() => _instance;
  static Database? _database;

  StudentsDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'students.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        score INTEGER,
        birthday TEXT,
        studentClass TEXT,
        phone TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrade if needed
  }

  Future<int> insertStudent(Student student) async {
    try {
      Database db = await database;
      return await db.insert('students', student.toMap());
    } catch (e) {
      print('Insert student error: $e');
      return -1; // Indicate failure
    }
  }

  Future<List<Student>> getStudents() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('students');
      return List.generate(maps.length, (i) {
        return Student.fromMap(maps[i]);
      });
    } catch (e) {
      print('Get students error: $e');
      return [];
    }
  }

  Future<int> updateStudent(Student student) async {
    try {
      Database db = await database;
      return await db.update(
        'students',
        student.toMap(),
        where: 'id = ?',
        whereArgs: [student.id],
      );
    } catch (e) {
      print('Update student error: $e');
      return -1;
    }
  }

  Future<int> deleteStudent(int id) async {
    try {
      Database db = await database;
      return await db.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Delete student error: $e');
      return -1;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
