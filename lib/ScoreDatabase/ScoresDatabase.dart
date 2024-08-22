import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ScoresDatabase {
  static final ScoresDatabase instance = ScoresDatabase._init();

  static Database? _database;

  ScoresDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('scores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Set the version to 2
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Include the upgrade logic
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE scores (
      id INTEGER NOT NULL,
      student_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      homework_score INTEGER,
      answer_score INTEGER,
      total_homework_score INTEGER,
      total_answer_score INTEGER,
      PRIMARY KEY (id, student_id)
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new columns for the total scores
      await db.execute('ALTER TABLE scores ADD COLUMN total_homework_score INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE scores ADD COLUMN total_answer_score INTEGER DEFAULT 0');
    }
  }

  // Insert a new score with custom id logic
  Future<void> insertScore(int studentId, int? homeworkScore, int? answerScore) async {
    final db = await instance.database;
    String currentDate = DateTime.now().toIso8601String();

    // Get the max current id for the student_id
    final List<Map<String, dynamic>> maxIdResult = await db.rawQuery(
        'SELECT MAX(id) as max_id, SUM(homework_score) as total_homework, SUM(answer_score) as total_answer FROM scores WHERE student_id = ?',
        [studentId]
    );

    int newId = (maxIdResult.first['max_id'] ?? 0) + 1;

    int totalHomeworkScore = (maxIdResult.first['total_homework'] ?? 0) + (homeworkScore ?? 0);
    int totalAnswerScore = (maxIdResult.first['total_answer'] ?? 0) + (answerScore ?? 0);

    await db.insert('scores', {
      'id': newId,
      'student_id': studentId,
      'date': currentDate,
      'homework_score': homeworkScore,
      'answer_score': answerScore,
      'total_homework_score': totalHomeworkScore,
      'total_answer_score': totalAnswerScore,
    });
  }

  // Fetch scores for a specific student
  Future<List<Map<String, dynamic>>> fetchScores(int studentId) async {
    final db = await instance.database;
    return await db.query('scores', where: 'student_id = ?', whereArgs: [studentId]);
  }

  // Update a score
  Future<void> updateScore(int id, int studentId, int? newHomeworkScore, int? newAnswerScore) async {
    final db = await instance.database;

    // Calculate the difference in scores to adjust totals
    final List<Map<String, dynamic>> previousScoreResult = await db.query(
      'scores',
      columns: ['homework_score', 'answer_score'],
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );

    int oldHomeworkScore = previousScoreResult.first['homework_score'] ?? 0;
    int oldAnswerScore = previousScoreResult.first['answer_score'] ?? 0;

    int homeworkDifference = (newHomeworkScore ?? 0) - oldHomeworkScore;
    int answerDifference = (newAnswerScore ?? 0) - oldAnswerScore;

    await db.rawUpdate('''
      UPDATE scores SET
        homework_score = ?,
        answer_score = ?,
        total_homework_score = total_homework_score + ?,
        total_answer_score = total_answer_score + ?
      WHERE id = ? AND student_id = ?
    ''', [newHomeworkScore, newAnswerScore, homeworkDifference, answerDifference, id, studentId]);
  }

  // Delete a score
  Future<void> deleteScore(int id, int studentId) async {
    final db = await instance.database;

    // Adjust totals before deleting
    final List<Map<String, dynamic>> previousScoreResult = await db.query(
      'scores',
      columns: ['homework_score', 'answer_score'],
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );

    int oldHomeworkScore = previousScoreResult.first['homework_score'] ?? 0;
    int oldAnswerScore = previousScoreResult.first['answer_score'] ?? 0;

    await db.rawUpdate('''
      UPDATE scores SET
        total_homework_score = total_homework_score - ?,
        total_answer_score = total_answer_score - ?
      WHERE student_id = ?
    ''', [oldHomeworkScore, oldAnswerScore, studentId]);

    await db.delete(
      'scores',
      where: 'id = ? AND student_id = ?',
      whereArgs: [id, studentId],
    );
  }
  Future<Map<String, dynamic>> fetchTotalScores(int studentId) async {
    final db = await ScoresDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        SUM(homework_score) as total_homework_score, 
        SUM(answer_score) as total_answer_score 
      FROM scores 
      WHERE student_id = ?
    ''', [studentId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {'total_homework_score': 0, 'total_answer_score': 0};
    }
  }


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

