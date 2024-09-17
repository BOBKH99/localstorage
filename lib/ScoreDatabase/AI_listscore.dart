import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:storedatalocal/dashboard/home_admin/home_screen.dart';
import '../StudentDatabase.dart';
import '../attentden/database_attandance.dart';
import '../model.dart';
import 'ScoresDatabase.dart';

class StudentGrid extends StatefulWidget {
  const StudentGrid();

  @override
  _StudentGridState createState() => _StudentGridState();
}

class _StudentGridState extends State<StudentGrid> {
  TextStyle textStyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black12,
  );
  List<StudentScore> studentScores = [];
  List<Map<String, dynamic>> Attendance = [];
  List<bool> buttonAbsent = [];
  List<bool> buttonPresent = [];
  List<bool> buttonLate = [];// Track button states for each student

  late int isClick = 1 ;
  int? homework_Score;
  int? answer_Score;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadData();
  }

  final AttendanceDatabase db = AttendanceDatabase.instance;

  Future<void> _loadData() async {
    final studentsDatabasePath = join(await getDatabasesPath(), 'students.db');
    final studentsDatabase = await openDatabase(studentsDatabasePath);
    final List<Map<String, dynamic>> students =
    await studentsDatabase.query('students');

    final scoresDatabase = await ScoresDatabase.instance.database;
    final List<Map<String, dynamic>> scores =
    await scoresDatabase.query('scores');

    final attendanceDatabase = await AttendanceDatabase.instance.database;
    List<Map<String, dynamic>> attendance =
    await attendanceDatabase.query('Attendance');

    List<StudentScore> tempList = [];
    for (var student in students) {
      List<Map<String, dynamic>> studentScores = scores
          .where((score) => score['student_id'] == student['id'])
          .toList();

      tempList.add(StudentScore(
        id: student['id'],
        name: student['name'],
        image: student['imagePath'],
        studentClass: student['studentClass'],
        scores: studentScores,
      ));
    }

    setState(() {
      attendance = Attendance;
      studentScores = tempList;
      buttonAbsent = List.filled(studentScores.length, false);
      buttonPresent = List.filled(studentScores.length, false);
      buttonLate = List.filled(studentScores.length, false);
      _isLoading = false;
    });
  }
  final StudentsDatabase dbS = StudentsDatabase();

  List<Student> _students = [];
  List<String> _classes = [];
  String? _selectedClass;

  void _loadClasses() async {
    final classes = await dbS.getAllClasses();
    setState(() {
      _classes = classes;
      if (_classes.isNotEmpty) {
        _selectedClass = _classes[0];
        _loadStudents(_selectedClass!);
      }
    });
  }

  void _loadStudents(String studentClass) async {
    final students = await dbS.getStudentsByClass(studentClass);
    setState(() {
      _students = students;
    });
  }

  Future<void> _addAttendance_absent(int studentId, int absent, int present, int late, int index) async {
    await db.insertAttendance(studentId, absent, present, late);
    setState(() {
      // buttonLate[index] = false;
      // buttonPresent[index] = false;
      buttonAbsent[index] = true;
    });
  }
  Future<void> _addAttendance_present(int studentId, int absent, int present, int late, int index) async {
    await db.insertAttendance(studentId, absent, present, late);
    setState(() {
      // buttonLate[index] = false;
      // buttonAbsent[index] = false;
      buttonPresent[index] = true;
    });
  }
  Future<void> _addAttendance_late(int studentId, int absent, int present, int late, int index) async {
    await db.insertAttendance(studentId, absent, present, late);
    setState(() {
      // buttonAbsent[index] = false;
      // buttonPresent[index] = false;
      buttonLate[index] = true;// Disable button after click
    });
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
      return {'total_absent': 0, 'total_late': 0};
    }
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

  final List<String> screen = ['Attendance', 'Score input', 'Edit attendance'];
  final ScoresDatabase dbScore = ScoresDatabase.instance;
  late int studentID;

  Future<void> _addScore(int studentId, int? homeworkScore, int? answerScore) async {
    homeworkScore ??= 0;
    answerScore ??= 0;
    await dbScore.insertScore(studentId, homeworkScore, answerScore);
    setState(() {

    });
  }

  Future<void> _updateAttendance_late( int studentId, int? newAbsent, int? newPresent, int? newLate, int index) async{
    await db.updateAttendanceByid(studentId, newAbsent, newPresent, newLate);
    setState(() {
      buttonPresent[index] = false;
      buttonAbsent[index] = false;
      buttonLate[index] = true;
    });
  }
  Future<void> _updateAttendance_absent( int studentId, int? newAbsent, int? newPresent, int? newLate, int index) async{
    await db.updateAttendanceByid(studentId, newAbsent, newPresent, newLate);
    setState(() {
      buttonPresent[index] = false;
      buttonLate[index] = false;
      buttonAbsent[index] = true;
    });
  }
  Future<void> _updateAttendance_present( int studentId, int? newAbsent, int? newPresent, int? newLate, int index) async{
    await db.updateAttendanceByid(studentId, newAbsent, newPresent, newLate);
    setState(() {
      buttonLate[index] = false;
      buttonAbsent[index] = false;
      buttonPresent[index] = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        title: const Text('Student Scores'),
        backgroundColor: Colors.white54,
        actions: [
          const Text('Class: '),
          if (_classes.isNotEmpty)
            Container(
              width: 100, // Set your desired width
              height: 40, // Set your desired height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),// Set your desired background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 2, // Spread radius (controls the size of the shadow)
                    blurRadius: 5, // Blur radius (controls the softness of the shadow)
                    offset: const Offset(0, 3), // Offset (controls the position of the shadow)
                  ),
                ],
              ),
              child: Center(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClass = newValue!;
                      _loadStudents(_selectedClass!);
                      buttonAbsent = List.filled(studentScores.length, false);
                      buttonPresent = List.filled(studentScores.length, false);
                      buttonLate = List.filled(studentScores.length, false);
                      homework_Score;
                      answer_Score;
                    });
                  },
                  items: _classes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(width: 200,),
          InkWell(
            onTap: () {
                setState(() {
                  isClick = 2;
                });
            },
              child: SizedBox( height: 70, child: Column(
                children: [
                  Image.asset('assets/golf.png',height: 30,),
                  const SizedBox(height: 10,),
                  const Text('Score input',style: TextStyle(fontSize: 10))
                ],
              ))),
          const SizedBox(width: 50,),
          InkWell(
            onTap: () {
                setState(() {
                  isClick = 1;
                });
            },
              child: SizedBox( height: 70, child: Column(
                children: [
                  Image.asset('assets/attendance.png',height: 40,),
                  const SizedBox(height: 0,),
                  const Text('Attendane input',style: TextStyle(fontSize: 10))
                ],
              ))),
          const SizedBox(width: 20,),
          InkWell(
              onTap: () {
                setState(() {
                  isClick = 3;
                });
              },
              child: SizedBox( height: 70, child: Column(
                children: [
                  Image.asset('assets/edit.png',height: 40,),
                  const Text('Edit Attendance',style: TextStyle(fontSize: 10),)
                ],
              ))),
          const SizedBox(width: 50,)
        ],
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
                  const SizedBox(width: 15),
                  Text('Profile', style: textStyle),
                  const SizedBox(width: 50),
                  Text('Name', style: textStyle),
                  const SizedBox(width: 150),
                  Text('Homework Score', style: textStyle),
                  const SizedBox(width: 50),
                  Text('Answer Score', style: textStyle),
                  const SizedBox(width: 50),
                  Text('Student Presence', style: textStyle),
                  const SizedBox(width: 100,),
                  if(isClick == 1)
                    Text(screen[0],style: const TextStyle(fontSize: 18, color: Colors.blueGrey),),
                  if(isClick == 2)
                    Text(screen[1],style: const TextStyle(fontSize: 18, color: Colors.blueGrey),),
                  if(isClick == 3)
                    Text(screen[2],style: const TextStyle(fontSize: 18, color: Colors.blueGrey),),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.86,
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  // final studentScore = studentScores[index];
                   final bool isButtonClicked = buttonAbsent[index];
                   final bool presentClicked = buttonPresent[index];
                   final bool lateClicked = buttonLate[index];
                  final student = _students[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: InkWell(
                      onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => HomeAdmin(id: student.id!),)),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isButtonClicked || presentClicked || lateClicked ? Colors.grey : Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 4, bottom: 4, right: 5, left: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: FileImage(File(student.imagePath)),
                                radius: 40,
                              ),
                              const SizedBox(width: 10.0),
                              SizedBox(
                                width: 200,
                                child: AutoSizeText(
                                  student.name,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 10.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              const SizedBox(width: 60),
                              Center(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: fetchTotalScores(student.id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
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
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 75,
                                            padding: const EdgeInsets.all(8.0),
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
                                          const SizedBox(width: 120),
                                          Container(
                                            height: 50,
                                            width: 75,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                '$answerScore',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: answerColor),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 100),
                                        ],
                                      );
                                    } else {
                                      return const Text('No data available');
                                    }
                                  },
                                ),
                              ),
                              Row(
                                children: [
                                  Center(
                                    child: FutureBuilder<Map<String, dynamic>>(
                                      future: fetchTotalAbsent(student.id!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          final totalAbsent = snapshot.data!;
                                          print('this is the total late is : ${totalAbsent['total_late']}');
                                          int? totalLate = (totalAbsent['total_late'] ?? 0) ~/ 2;
                                          final int absent =
                                              (totalAbsent['total_absent'] ?? 0) + totalLate;
                                          return Container(
                                            height: 50,
                                            width: 75,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                '$absent',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const Text('No data available');
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  if(isClick == 1)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                          onPressed: lateClicked
                                              ? null
                                              : () => _addAttendance_late(
                                              student.id!, 0, 0, 1, index),
                                          child: const Text('Permission'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          onPressed: presentClicked
                                              ? null
                                              : () => _addAttendance_present(
                                              student.id!, 0, 1, 0, index),
                                          child: const Text('Checked'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: isButtonClicked
                                              ? null
                                              : () => _addAttendance_absent(
                                              student.id!, 1, 0, 0, index),
                                          child: const Text('Absent'),
                                        ),
                                      ],
                                    ),
                                  if(isClick == 2)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 120, // Set a fixed width to avoid unbounded constraints
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                homework_Score = int.tryParse(value);
                                              });
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: 'Homework',
                                              labelStyle: const TextStyle(fontSize: 12),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(color: CupertinoColors.activeBlue, width: 2, ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                            ),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 120, // Set a fixed width to avoid unbounded constraints
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                answer_Score = int.tryParse(value);
                                              });
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: 'Answer',
                                              labelStyle: const TextStyle(fontSize: 12),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(color: CupertinoColors.activeBlue, width: 2, ),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                            ),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            print('homework_sore: $homework_Score, answer_score: $answer_Score');
                                            print('suuuuuuuuuuuuuuu:::::  ${student.id}');
                                            await _addScore(student.id!, homework_Score, answer_Score);
                                          },
                                          child: const Text('Add Score'),
                                        ),
                                      ],
                                    ),
                                  if(isClick == 3)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                          onPressed: lateClicked
                                              ? null
                                              : () => _updateAttendance_late(student.id!,0,0,1,index),
                                          child: const Text('Late'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          onPressed: presentClicked
                                              ? null
                                              : () => _updateAttendance_present(student.id!,0,1,0,index),
                                          child: const Text('Checked'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: isButtonClicked
                                              ? null
                                              : () => _updateAttendance_absent(student.id!,1,0,0,index),
                                          child: const Text('Absent'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
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
    required this.scores, required studentClass,
  });
}
