import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storedatalocal/NewStudent.dart';
import 'package:storedatalocal/ScoreDatabase/AI_listscore.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'black'
      ),
      home: const StudentPage(),
      navigatorObservers: [routeObserver],
    );
  }
}


class StudentPage extends StatefulWidget {
  const StudentPage();

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with RouteAware {
  final StudentsDatabase db = StudentsDatabase();

  List<Student> _students = [];
  List<String> _classes = [];
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    //_loadStudents(_selectedClass!);
  }

  void _loadClasses() async {
    final classes = await db.getAllClasses();
    setState(() {
      _classes = classes;
      if (_classes.isNotEmpty) {
        _selectedClass = _classes[0];
        _loadStudents(_selectedClass!);
      }
    });
  }

  void _loadStudents(String studentClass) async {
    final students = await db.getStudentsByClass(studentClass);
    setState(() {
      _students = students;
    });
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
    // This method is called when this screen becomes visible again
    if (_selectedClass != null) {
      _loadStudents(_selectedClass!);
      _loadClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        toolbarHeight: 80,
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomTextFieldDemo()),
            ),
            child: SizedBox(
              width: 80,
              child: Image.asset('assets/id-card.png', width: 80),
            ),
          ),
          const SizedBox(width: 100),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentGrid()),
            ),
            child: Image.asset('assets/work-order.png',height: 80,)
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 0.2,
            mainAxisSpacing: 0.1,
            childAspectRatio: 1 / 0.3,
          ),
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStudentPage(student: student),
                ),
              ),
              highlightColor: Colors.blueGrey,
              hoverColor: Colors.blue,
              child: Container(
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey, width: 0.05),
                ),
                child: Row(
                  children: [
                    SizedBox(
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
                            Text(student.name, style: const TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                const Text('Score: ', style: TextStyle(fontSize: 14)),
                                Text(
                                  '${student.score}',
                                  style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue),
                                ),
                                Text(
                                  ', Class: ${student.studentClass}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Text(
                              student.phone!,
                              style: const TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
