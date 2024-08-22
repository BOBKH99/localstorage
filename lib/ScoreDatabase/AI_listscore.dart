import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../attentden/attendance_database.dart';
import 'ScoresDatabase.dart';

class StudentGrid extends StatefulWidget {
  @override
  _StudentGridState createState() => _StudentGridState();
}

class _StudentGridState extends State<StudentGrid> {
  TextStyle textStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black12,
  );
  List<StudentScore> studentScores = [];
  List<Map<String, dynamic>> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

    // Load data from students.db
    final studentsDatabasePath = join(await getDatabasesPath(), 'students.db');
    final studentsDatabase = await openDatabase(studentsDatabasePath);
    final List<Map<String, dynamic>> students =
    await studentsDatabase.query('students');

    final scoresDatabase = await ScoresDatabase.instance.database;
    final List<Map<String, dynamic>> scores =
    await scoresDatabase.query('scores');

    List<StudentScore> tempList = [];
    for (var student in students) {
      List<Map<String, dynamic>> studentScores = scores
          .where((score) => score['student_id'] == student['id'])
          .toList();

      tempList.add(StudentScore(
        id: student['id'],
        name: student['name'],
        image: student['imagePath'],
        scores: studentScores,
      ));





    }
    // Load data from attendance.db
    final attendanceDatabasePath = join(await getDatabasesPath(), 'attendance.db');
    final attendanceDatabase = await openDatabase(attendanceDatabasePath);

    // Query to fetch all attendance records
    final List<Map<String, dynamic>> records = await attendanceDatabase.query('attendance');

    setState(() {
      _attendanceRecords = records;
      studentScores = tempList;
    });
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

  Future<List<Map<String, dynamic>>> fetchAttendance(int studentId) async {
    final db = await AttendanceDatabase.instance.database;

    return await db.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  @override
  Widget build(BuildContext context) {
    void _recordAttendance(int studentId, bool isAbsent) async {
      final AttendanceDatabase _attendanceDb = AttendanceDatabase.instance;

      await _attendanceDb.recordAttendance(studentId, isAbsent);

      // Optionally, refresh UI or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAbsent ? 'Recorded Absent' : 'Recorded Present')),
      );
      print('this is student ID : $studentId');
      setState(() {

      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Scores'),
        backgroundColor: Colors.white54,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.03,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 15),
                  Text('Profile', style: textStyle),
                  SizedBox(width: 50),
                  Text('Name', style: textStyle),
                  SizedBox(width: 150),
                  Text('Homework Score', style: textStyle),
                  SizedBox(width: 50),
                  Text('Answer Score', style: textStyle),
                  SizedBox(width: 50),
                  Text('Student Presence', style: textStyle),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.86,
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: studentScores.length,
                itemBuilder: (context, index) {
                  final studentScore = studentScores[index];
                  // Safely access attendance records with a fallback for empty or mismatched length

                  // Default to 0 if no record

                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4, bottom: 4, right: 5, left: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                              FileImage(File(studentScore.image)),
                              radius: 40,
                            ),
                            SizedBox(width: 10.0),
                            Container(
                              width: 200,
                              child: AutoSizeText(
                                studentScore.name,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                minFontSize: 10.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            SizedBox(
                              width: 60,
                            ),
                            Center(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: fetchTotalScores(studentScore.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      final totalScores = snapshot.data!;
                                      final int homeworkScore =
                                          totalScores['total_homework_score'] ?? 0;
                                      final int answerScore =
                                          totalScores['total_answer_score'] ?? 0;

                                      final Color homeworkColor = homeworkScore > 0
                                          ? Colors.blueAccent
                                          : Colors.red;
                                      final Color answerColor = answerScore > 0
                                          ? Colors.blueAccent
                                          : Colors.red;
                                      final record = _attendanceRecords[index];
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 75,
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                '$homeworkScore',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: homeworkColor),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 120),
                                          Container(
                                            height: 50,
                                            width: 75,
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                '$answerScore',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: homeworkColor),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 100),
                                          Container(
                                            height: 50,
                                            width: 75,
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                '${record['total_absent_count']}',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: homeworkColor),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 100),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => _recordAttendance(
                                                    studentScore.id, false),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue),
                                                child: Text('Checked'),
                                              ),
                                              SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () => _recordAttendance(
                                                    studentScore.id, true),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red),
                                                child: Text('Absent'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Text('No data available');
                                    }
                                  },
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }

}

class StudentScore {
  final int id;
  final String name;
  final String image;
  final List<Map<String, dynamic>> scores;

  StudentScore({
    required this.id,
    required this.name,
    required this.image,
    required this.scores,
  });
}
