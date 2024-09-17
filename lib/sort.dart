// import 'package:flutter/material.dart';
//
// import 'StudentDatabase.dart';
// import 'model.dart';
//
// class StudentsList extends StatefulWidget {
//   @override
//   _StudentsListState createState() => _StudentsListState();
// }
//
// class _StudentsListState extends State<StudentsList> {
//
//   final StudentsDatabase db = StudentsDatabase();
//
//   List<Student> _students = [];
//   List<String> _classes = [];
//   String? _selectedClass;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadClasses();
//   }
//
//   void _loadClasses() async {
//     final classes = await db.getAllClasses();
//     setState(() {
//       _classes = classes;
//       if (_classes.isNotEmpty) {
//         _selectedClass = _classes[0];
//         _loadStudents(_selectedClass!);
//       }
//     });
//   }
//
//   void _loadStudents(String studentClass) async {
//     final students = await db.getStudentsByClass(studentClass);
//     setState(() {
//       _students = students;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Students List'),
//       ),
//       body: Column(
//         children: [
//           if (_classes.isNotEmpty)
//             DropdownButton<String>(
//               value: _selectedClass,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedClass = newValue!;
//                   _loadStudents(_selectedClass!);
//                 });
//               },
//               items: _classes.map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _students.length,
//               itemBuilder: (context, index) {
//                 final student = _students[index];
//                 return ListTile(
//                   title: Text(student['name']),
//                   subtitle: Text('Class: ${student['studentClass']}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: StudentsList(),
//   ));
// }
