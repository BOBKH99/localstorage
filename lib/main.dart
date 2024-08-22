import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storedatalocal/NewStudent.dart';
import 'package:storedatalocal/ScoreDatabase/AI_listscore.dart';
import 'package:storedatalocal/ScoreDatabase/ScoreScreen.dart';
import 'ScoreDatabase/ListScore.dart';
import 'ScoreDatabase/ScoresDatabase.dart';
import 'TextField.dart';
import 'StudentDatabase.dart';
import 'editstudent.dart';
import 'model.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  // Initialize sqflite for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'black'
      ),
      home: StudentPage(),
      navigatorObservers: [routeObserver],
    );
  }
}


class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with RouteAware {
  final StudentsDatabase _dbHelper = StudentsDatabase();

  List<Student> _students = [];


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

  
  
  



  void _navigateToEditStudent(Student student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditStudentPage(student: student)),
    );
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    print(_students.length);
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentGrid(),)),
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
            crossAxisCount: 4,crossAxisSpacing: 0.2,
            mainAxisSpacing: 0.1,
            childAspectRatio: 1 / 0.3,),
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];
            return InkWell(
              onTap: () => _navigateToEditStudent(student),
              highlightColor: Colors.blueGrey,
              hoverColor: Colors.blue,
              
              child: Container(
                width: 200,
                height: 80,
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text('Score: ', style: TextStyle(fontSize: 14)),
                                Text('${student.score}', style: TextStyle(fontSize: 14,color: CupertinoColors.activeBlue)),
                                Text(', Class: ${student.studentClass}', style: TextStyle(fontSize: 14)),
                               ],
                            ),
                            Text(student.phone!, style: TextStyle(fontSize: 14),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },),
      )
    );
  }
}