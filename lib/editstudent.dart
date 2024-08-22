import 'package:flutter/material.dart';
import 'StudentDatabase.dart';
import 'model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditStudentPage extends StatefulWidget {
  final Student student;

  EditStudentPage({required this.student});

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final StudentsDatabase _dbHelper = StudentsDatabase();
  final ImagePicker _picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _ageController = TextEditingController(text: widget.student.age.toString());
    _scoreController = TextEditingController(text: widget.student.score.toString());
    _classController = TextEditingController(text: widget.student.studentClass);
    _birthdayController = TextEditingController(text: widget.student.birthday.toIso8601String().substring(0, 10));
    _phoneController = TextEditingController(text: widget.student.phone.toString());
    _imagePath = widget.student.imagePath;
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

  Future<void> _deleteStudent() async {
    await _dbHelper.deleteStudent(widget.student.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
        actions: [
          IconButton(
            icon: Image.asset('assets/trash.png',width: 80,height: 80,),
            onPressed: _deleteStudent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
              errorText: _nameError,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _scoreController,
              labelText: 'Score',
              errorText: _scoreError,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _classController,
                    labelText: 'Grade or Class',
                    errorText: _classError,
                  ),
                ),
                SizedBox(width: 16),
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
            SizedBox(height: 16),
            _buildDatePickerField(
              controller: _birthdayController,
              labelText: 'Birthday (YYYY-MM-DD)',
              errorText: _birthdayError,
            ),
            SizedBox(height: 10),
            _imagePath == null
                ? Text('No image selected')
                : Image.file(File(_imagePath!),width: 200,height: 300,),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _updateStudent,
              child: Text('Update'),
            ),
          ],
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
        labelStyle: TextStyle(color: Colors.black),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: errorText != null ? Icon(Icons.error, color: Colors.red) : null,
      ),
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
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
        if (pickedDate != null) {
          setState(() {
            controller.text = pickedDate.toIso8601String().split('T').first;
            _birthdayError = null;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.black),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: errorText != null ? Icon(Icons.error, color: Colors.red) : null,
          ),
          style: TextStyle(color: Colors.black),
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