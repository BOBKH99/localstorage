// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// import 'model.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   static Database? _database;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'students.db');
//     return await openDatabase(path);
//   }
//
//   Future<List<Student>> getStudentsByClass(String studentClass) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'students',
//       where: 'class = ?',
//       whereArgs: [studentClass],
//       orderBy: 'name ASC',
//     );
//
//     return List.generate(maps.length, (i) {
//       return Student.fromMap(maps[i]);
//     });
//   }
//
//   Future<List<String>> getAllClasses() async {
//     final db = await database;
//     var result = await db.rawQuery('SELECT DISTINCT class FROM students ORDER BY class ASC');
//     List<String> classes = result.map((c) => c['class'] as String).toList();
//     return classes;
//   }
// }
//
//
