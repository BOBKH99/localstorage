// import 'package:flutter/material.dart';
//
// class CustomTextFieldDemo extends StatefulWidget {
//   @override
//   _CustomTextFieldDemoState createState() => _CustomTextFieldDemoState();
// }
//
// class _CustomTextFieldDemoState extends State<CustomTextFieldDemo> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _scoreController = TextEditingController();
//   final TextEditingController _classController = TextEditingController();
//   final TextEditingController _birthdayController = TextEditingController();
//
//   String? _nameError;
//   String? _scoreError;
//   String? _classError;
//   String? _birthdayError;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey,
//       appBar: AppBar(
//         title: Text('Custom Text Fields'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildTextField(
//               controller: _nameController,
//               labelText: 'Name',
//               errorText: _nameError,
//             ),
//             SizedBox(height: 16),
//             _buildTextField(
//               controller: _scoreController,
//               labelText: 'Score',
//               errorText: _scoreError,
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             _buildTextField(
//               controller: _classController,
//               labelText: 'Grade or Class',
//               errorText: _classError,
//             ),
//             SizedBox(height: 16),
//             _buildDatePickerField(
//               controller: _birthdayController,
//               labelText: 'Birthday (YYYY-MM-DD)',
//               errorText: _birthdayError,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _validateInputs,
//         child: Icon(Icons.check),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     String? errorText,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(color: Colors.black),
//         errorText: errorText,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: Colors.white),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: Colors.white),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.0),
//           borderSide: BorderSide(color: Colors.white),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         suffixIcon: errorText != null ? Icon(Icons.error, color: Colors.red) : null,
//       ),
//       keyboardType: keyboardType,
//       style: TextStyle(color: Colors.black),
//     );
//   }
//
//   Widget _buildDatePickerField({
//     required TextEditingController controller,
//     required String labelText,
//     String? errorText,
//   }) {
//     return GestureDetector(
//       onTap: () async {
//         DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(1900),
//           lastDate: DateTime(2100),
//         );
//         if (pickedDate != null) {
//           setState(() {
//             controller.text = pickedDate.toIso8601String().split('T').first;
//             _birthdayError = null;
//           });
//         }
//       },
//       child: AbsorbPointer(
//         child: TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             labelText: labelText,
//             labelStyle: TextStyle(color: Colors.black),
//             errorText: errorText,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.white),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.white),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide(color: Colors.white),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             suffixIcon: errorText != null ? Icon(Icons.error, color: Colors.red) : null,
//           ),
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }
//
//   void _validateInputs() {
//     setState(() {
//       _nameError = _nameController.text.isEmpty ? 'Name cannot be empty' : null;
//       _scoreError = _scoreController.text.isEmpty || !isNumeric(_scoreController.text)
//           ? 'Score must be a number'
//           : null;
//       _classError = _classController.text.isEmpty ? 'Grade or Class cannot be empty' : null;
//       _birthdayError = _birthdayController.text.isEmpty || !isValidDate(_birthdayController.text)
//           ? 'Enter a valid date (YYYY-MM-DD)'
//           : null;
//     });
//   }
//
//   bool isNumeric(String str) {
//     if (str.isEmpty) return false;
//     final number = num.tryParse(str);
//     return number != null;
//   }
//
//   bool isValidDate(String date) {
//     try {
//       DateTime.parse(date);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }