import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storedatalocal/ScoreDatabase/ScoresDatabase.dart';
import 'package:storedatalocal/attentden/database_attandance.dart';
import 'StudentDatabase.dart';
import 'model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditStudentPage extends StatefulWidget {
  final Student student;

  const EditStudentPage({ required this.student});

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final StudentsDatabase _dbHelper = StudentsDatabase();
  final ImagePicker _picker = ImagePicker();
  final ScoresDatabase db = ScoresDatabase.instance;
  final AttendanceDatabase dbAtt = AttendanceDatabase.instance;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _scoreController;
  late TextEditingController _classController;
  late TextEditingController _birthdayController;
  late TextEditingController _phoneController;

  String? _nameError;
  String? _scoreError;
  String? _classError;
  String? _birthdayError;
  String? _ageError;
  String? _imagePath;
  late int id;
  List<Map<String, dynamic>> _scoresList = [];
  List<Map<String, dynamic>> _attendance = [];


  int late = 0;
  int present = 0;
  int absent = 0;

  @override
  void initState() {
    super.initState();
    print('helllllllllllloooo');
    id = widget.student.id!;
    _nameController = TextEditingController(text: widget.student.name);
    _ageController = TextEditingController(text: widget.student.age.toString());
    _scoreController = TextEditingController(text: widget.student.score.toString());
    _classController = TextEditingController(text: widget.student.studentClass);
    _birthdayController = TextEditingController(text: widget.student.birthday.toIso8601String().substring(0, 10));
    _phoneController = TextEditingController(text: widget.student.phone.toString());
    _imagePath = widget.student.imagePath;
    _initializeData();
  }
  Future<void> _initializeData() async {
    await _fetchScores(id);
    await _fetchAttendance(id);
    _sortScoresByDate();
    _sortAttendanceByDate();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _updateStudent() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _scoreController.text.isEmpty ||
        _classController.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _phoneController.text.isEmpty||
        _imagePath == null) {
      // Show error message
      return;
    }

    final updatedStudent = Student(
      id: widget.student.id,
      name: _nameController.text,
      age: int.parse(_ageController.text),
      score: int.parse(_scoreController.text),
      birthday: DateTime.parse(_birthdayController.text),
      studentClass: _classController.text,
      phone: _phoneController.text,
      imagePath: _imagePath!,
    );
    await _dbHelper.updateStudent(updatedStudent);
    Navigator.pop(context);
  }

  Future<void> _deleteStudent(int studentId) async {
    await _dbHelper.deleteStudent(studentId);
    await db.deleteScoreAll(studentId);
    await dbAtt.deleteAttendanceAll(studentId);
    Navigator.pop(context);
  }

  Future<void> _fetchScores(int studentId) async {
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = List<Map<String, dynamic>>.from(scores);
    });
  }

  Future<void> _fetchAttendance(int studentId) async {
    final attendance = await dbAtt.fetchAbsent(studentId);
    setState(() {
      _attendance = List<Map<String, dynamic>>.from(attendance);
    });
  }

  bool isHovering = false;

  void _sortScoresByDate() {
    _scoresList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA); // Sort in descending order
    });
  }

  void _sortAttendanceByDate() {
    _attendance.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA); // Sort in descending order
    });
  }

  bool isFirstButtonClicked = false;

  void _onButtonPressed(bool isFirstButton) {
    setState(() {
      isFirstButtonClicked = isFirstButton;
    });
  }

  void _showDialog(int id, int studentId, int late, int present, int absent, String date, ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                const Text('Update Attendance', style: TextStyle(fontSize: 20, color: CupertinoColors.activeBlue)),
                Row(
                  children: [
                    const Text('Late: '),
                    Text('$late', style: const TextStyle(color: Colors.orange, fontSize: 18)),
                    const Text(', Present: '),
                    Text('$present', style: const TextStyle(color: Colors.blue, fontSize: 18)),
                    const Text(', Absent: '),
                    Text('$absent', style: const TextStyle(color: Colors.red, fontSize: 18)),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(height: 8),
                    const Text('Date: ', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    Text(date, style: TextStyle(color: Colors.deepOrangeAccent.shade200, fontSize: 14)),
                  ],
                ),
              ],
            ),
            content: SizedBox(
              height: 70,
              child: Column(
                children: [
                  const Text('Choose new attendance', style: TextStyle(fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () => _updateAttendance(id, studentId, 0, 0, 1),
                        child: const Text('Late', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => _updateAttendance(id, studentId, 0, 1, 0),
                        child: const Text('Checked', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _updateAttendance(id, studentId, 1, 0, 0),
                        child: const Text('Absent', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Delete"),
                onPressed: () {
                  _deleteAttendance(id, studentId);
                  // Delete attendance logic here
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
      },
    ).then((_) {
      // This callback is called when the dialog is closed
      setState(() {}); // Trigger a rebuild of the main widget
    });
  }

  void _showDialogAtt(int id, int studentId, int homework, int answer, String date) {
    final TextEditingController homeworkScoreController = TextEditingController(text: homework.toString());
    final TextEditingController answerScoreController = TextEditingController(text: answer.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              const Text('Update Scores', style: TextStyle(fontSize: 20, color: CupertinoColors.activeBlue)),
              Column(
                children: [
                  TextField(
                    controller: homeworkScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Homework Score (Optional)',
                    ),
                  ),
                  TextField(
                    controller: answerScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Answer Question Score (Optional)',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(height: 8),
                  const Text('Date: ', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  Text(date, style: TextStyle(color: Colors.deepOrangeAccent.shade200, fontSize: 14)),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await _deleteScore(id, studentId);
                Navigator.of(context).pop(); // Close the dialog after deleting the score
              },
              child: const Text('Delete Score', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                final homeworkScore = int.tryParse(homeworkScoreController.text);
                final answerScore = int.tryParse(answerScoreController.text);

                await _updateScore(id, studentId, homeworkScore, answerScore);
                Navigator.of(context).pop(); // Close the dialog after updating the score
              },
              child: const Text('Update Score'),
            ),
          ],
        );
      },
    ).then((_) {
      // This callback is called when the dialog is closed
      setState(() {}); // Trigger a rebuild of the main widget
    });
  }

  Future<void> _updateScore(int id, int studentId, int? newHomeworkScore, int? newAnswerScore) async{
    await db.updateScore(id,studentId, newHomeworkScore, newAnswerScore);
    setState(() {
      _initializeData();
    });
  }
  Future<void> _deleteScore(int id, int studentId) async {
    await db.deleteScore(id, studentId);
    setState(() {
      _initializeData();
    });
  }

  Future<void> _updateAttendance(int id, int studentId, int? newAbsent, int? newPresent, int? newLate) async{
    await dbAtt.updateAttendance(id,studentId, newAbsent, newPresent, newLate);
    setState(() {
      _initializeData();
    });
    Navigator.pop(context);
  }
  Future<void> _deleteAttendance(int id, int studentId) async {
    await dbAtt.deleteAttendance(id, studentId);
    setState(() {
      _initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: _updateStudent,
            child:  Image.asset('assets/update.png',height: 80,),
          ),
          const SizedBox(width: 30,),
          InkWell(
            onTap: () =>  _deleteStudent(id),
            child:  Image.asset('assets/trash.png',height: 80,),
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white30,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _imagePath == null
                    ? const Text('No image selected')
                    : Stack(
                      children:[
                        Positioned(
                        child: InkWell(
                          onTap: _pickImage,
                          onHover: (value) {
                            setState(() {
                              isHovering = value;
                            });
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: CircleAvatar(
                                        backgroundImage: FileImage(File(_imagePath!)),
                                        radius: 100,),
                        ),
                      ),
                          if(isHovering == true)
                            Positioned(
                              bottom: 0,
                              left: 80,
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white30
                                  ),
                                  child: Image.asset('assets/generative-image.png',width: 50,)))

                                    ]
                    ),
                const SizedBox(height: 20,),
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _scoreController,
                  labelText: 'Score',
                  errorText: _scoreError,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _classController,
                        labelText: 'Grade or Class',
                        errorText: _classError,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _ageController,
                        labelText: 'Age',
                        errorText: _ageError,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDatePickerField(
                  controller: _birthdayController,
                  labelText: 'Birthday (YYYY-MM-DD)',
                  errorText: _birthdayError,
                ),
                const SizedBox(height: 16,),
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Phone number',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _onButtonPressed(true),
                      child: Text(
                        'All scores',
                        style: TextStyle(
                          color: isFirstButtonClicked ? Colors.blue : Colors.black,
                          fontSize: isFirstButtonClicked ? 18 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => _onButtonPressed(false),
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          color: !isFirstButtonClicked ? Colors.blue : Colors.black,
                          fontSize: !isFirstButtonClicked ? 18 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                if(isFirstButtonClicked)
                  Container(
                  width: double.infinity,
                  height: 400,

                  decoration: const BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,crossAxisSpacing: 0.2,
                      mainAxisSpacing: 0.1,
                      childAspectRatio: 1 / 0.2,),
                    itemCount: _scoresList.length,
                    itemBuilder: (context, index) {
                      final score = _scoresList[index];
                      return InkWell(
                        onLongPress:  () {
                          _showDialogAtt(score['id'], id, score['homework_score'] ?? 0, score['answer_score'] ?? 0, score['date']);
                        },
                        child: Container(

                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1,color: Colors.grey)
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                const Text('Homework: '),
                                Text('${score['homework_score']}',style: const TextStyle(color: Colors.blue,fontSize: 18),),
                                const Text(', Answer: '),
                                Text('${score['answer_score']}',style: const TextStyle(color: Colors.blue,fontSize: 18),)
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                const Text('Date: ',style: TextStyle(color: Colors.black54),),
                                Text('${score['date']}',style: TextStyle(color: Colors.deepOrangeAccent.shade200))
                              ],
                            ),

                        )
                        ),
                      );
                    },),
                )else
                  Container(
                    width: double.infinity,
                    height: 400,

                    decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),

                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,crossAxisSpacing: 0.2,
                        mainAxisSpacing: 0.1,
                        childAspectRatio: 1 / 0.2,),
                      itemCount: _attendance.length,
                      itemBuilder: (context, index) {
                        final attendance = _attendance[index];
                        return InkWell(
                          onLongPress:  () {
                            _showDialog(attendance['id'], id, attendance['late'], attendance['present'], attendance['absent'], attendance['date']);
                          },
                          child: Container(

                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1,color: Colors.grey)
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    const Text('Late: '),
                                    Text(attendance['late']?.toString() ?? "0",style: const TextStyle(color: Colors.orange,fontSize: 18),),
                                    const Text(', Present: '),
                                    Text(attendance['present']?.toString() ?? "0",style: const TextStyle(color: Colors.blue,fontSize: 18),),
                                    const Text(', Absent: '),
                                    Text(attendance['absent']?.toString() ?? "0",style: const TextStyle(color: Colors.red,fontSize: 18),),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    const Text('Date: ',style: TextStyle(color: Colors.black54),),
                                    Text('${attendance['date']}',style: TextStyle(color: Colors.deepOrangeAccent.shade200))
                                  ],
                                ),

                              )
                          ),
                        );
                      },),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: errorText != null ? const Icon(Icons.error, color: Colors.red) : null,

      ),
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String labelText,
    String? errorText,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        setState(() {
          controller.text = pickedDate!.toIso8601String().split('T').first;
          _birthdayError = null;
        });
            },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.grey),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: errorText != null ? const Icon(Icons.error, color: Colors.red) : null,
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  void _validateInputs() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name cannot be empty' : null;
      _scoreError = _scoreController.text.isEmpty || !isNumeric(_scoreController.text)
          ? 'Score must be a number'
          : null;
      _classError = _classController.text.isEmpty ? 'Grade or Class cannot be empty' : null;
      _birthdayError = _birthdayController.text.isEmpty || !isValidDate(_birthdayController.text)
          ? 'Enter a valid date (YYYY-MM-DD)'
          : null;
      _ageError = _ageController.text.isEmpty || !isNumeric(_ageController.text)
          ? 'Age must be a number'
          : null;
    });
  }

  bool isNumeric(String str) {
    if (str.isEmpty) return false;
    final number = num.tryParse(str);
    return number != null;
  }

  bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

}