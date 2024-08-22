import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storedatalocal/ScoreDatabase/StudentscoreScreen1.dart';

import '../NewStudent.dart';
import '../StudentDatabase.dart';
import '../model.dart';
import 'ScoresDatabase.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class Listscore extends StatefulWidget {


  @override
  State<Listscore> createState() => _ListscoreState();

}

class _ListscoreState extends State<Listscore> with RouteAware {
  final StudentsDatabase _dbHelper = StudentsDatabase();
  final ScoresDatabase db = ScoresDatabase.instance;

  final TextEditingController _homeworkScoreController = TextEditingController();
  final TextEditingController _answerScoreController = TextEditingController();


  List<Student> _students = [];
  List<Map<String, dynamic>> _scoresList = [];


  Future<void> _addScore(int studentId, int? homeworkScore, int? answerScore) async {
    try {
      await db.insertScore(studentId, homeworkScore, answerScore);
      _fetchScores(studentId);
      _homeworkScoreController.clear();
      _answerScoreController.clear();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _fetchScores(int studentId) async {
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = scores;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the current route
    // shows up again.
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    List<Student> students = await _dbHelper.getStudents();
    setState(() {
      _students = students;
    });
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Student List'),
          toolbarHeight: 80,
          actions: [
            InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => CustomTextFieldDemo(),)),
                child: Container(
                    width: 80,
                    child: Image.asset('assets/id-card.png',width: 80,))),
            SizedBox(width: 100,),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentScoresScreen(),)),
              child: Icon(Icons.score,weight: 50,),
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,crossAxisSpacing: 0.2,
              mainAxisSpacing: 0.1,
              childAspectRatio: 1 / 0.3,),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final score = _scoresList[index];
              return InkWell(
                onTap: () {},
                highlightColor: Colors.blueGrey,
                hoverColor: Colors.blue,

                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey,width: 0.05),
                    //borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: CircleAvatar(
                          backgroundImage: FileImage(File(student.imagePath)),
                          radius: 40, // Adjust the radius as needed
                        ),
                      ),
                      Text(student.name, style: TextStyle(fontSize: 16)),
                      ListView.builder(
                        itemCount: score.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('Date: ${score['date']}'),
                            subtitle: Text(
                              'Homework: ${score['homework_score']?.toString() ?? "0"}, Answer: ${score['answer_score']?.toString() ?? "0"}',
                            ),
                          );
                        },
                      ),
                      Text(student.phone!, style: TextStyle(fontSize: 14),),
                    ],
                  ),
                ),
              );
            },),
        )
    );
  }
}
