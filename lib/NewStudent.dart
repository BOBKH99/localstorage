import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'StudentDatabase.dart';
import 'model.dart';

class CustomTextFieldDemo extends StatefulWidget {
  @override
  _CustomTextFieldDemoState createState() => _CustomTextFieldDemoState();
}

class _CustomTextFieldDemoState extends State<CustomTextFieldDemo>  {
  final StudentsDatabase _dbHelper = StudentsDatabase();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController= TextEditingController();

  String? _nameError;
  String? _scoreError;
  String? _classError;
  String? _birthdayError;
  String? _ageError;
  String? _imagePath;



  Future<void> _addStudent() async {
    //_onFloatingActionButtonPressed();
    setState(() {
          _isButtonClicked = true;
        });
    _validateInputs();
      final student = Student(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        score: int.parse(_scoreController.text),
        birthday: DateTime.parse(_birthdayController.text),
        studentClass: _classController.text,
        phone: _phoneController.text,
        imagePath: _imagePath!,
      );
      await _dbHelper.insertStudent(student);
      Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // late AnimationController _lottieController;
  bool _isButtonClicked = false;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // _lottieController = AnimationController(
  //   //   vsync: this,
  //   // );
  //   _lottieController.addStatusListener((status) {
  //     if (status == AnimationStatus.completed) {
  //
  //     }
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   _lottieController.dispose();
  //   super.dispose();
  // }
  //
  // // void _onFloatingActionButtonPressed() {
  // //   setState(() {
  // //     _isButtonClicked = true;
  // //   });
  // //   _lottieController.forward(from: 0.0);
  // // }
  //
  //


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Custom Text Fields'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        widthFactor: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 820,

            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(5)
            ),
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  errorText: _nameError,
                ),
                SizedBox(height: 5),
                _buildTextField(
                  controller: _scoreController,
                  labelText: 'Score',
                  errorText: _scoreError,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _classController,
                        labelText: 'Grade or Class',
                        errorText: _classError,
                      ),
                    ),
                    SizedBox(width: 15),
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
                SizedBox(height: 5),
                _buildDatePickerField(
                  controller: _birthdayController,
                  labelText: 'Birthday (YYYY-MM-DD)',
                  errorText: _birthdayError,
                ),
                SizedBox(height: 5,),
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                ),
                SizedBox(height: 5),
                // _imagePath == null
                //     ? Text('No image selected')
                //     : Image.file(File(_imagePath!),width: 100,height: 100,),
                Container(
                  width: 250,
                  height: 300,
                  color: Colors.white,
                  child: _imagePath == null
                      ? Text('No image selected')
                      : Image.file(File(_imagePath!),width: 100,height: 100,),
                ),
                SizedBox(height: 8,),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: _addStudent,
                  child: _isButtonClicked
                      ? Lottie.asset(
                    'assets/lottie/Animation - 1723633408861.json',
                    // controller: _lottieController,
                    width: 56.0,  // Adjust the size to fit within the FAB
                    height: 56.0, // Adjust the size to fit within the FAB
                    // onLoaded: (composition) {
                    //   _lottieController.duration = composition.duration;
                    // },
                  )
                      : Text('New student'),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _onFloatingActionButtonPressed,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   child: _isButtonClicked
      //       ? Lottie.asset(
      //     'assets/lottie/Animation - 1723633408861.json',
      //     controller: _lottieController,
      //     width: 56.0,  // Adjust the size to fit within the FAB
      //     height: 56.0, // Adjust the size to fit within the FAB
      //     onLoaded: (composition) {
      //       _lottieController.duration = composition.duration;
      //     },
      //   )
      //       : Icon(Icons.check),
      // ),
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