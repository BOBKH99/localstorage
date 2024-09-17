import 'package:storedatalocal/StudentDatabase.dart';
import 'package:storedatalocal/model.dart';

import '../../utils/colors.dart';
import '../../utils/media_query_values.dart';
import 'package:flutter/material.dart';
import 'total_widget.dart';

class OverallPortfolioCard extends StatefulWidget {
  int id;
  OverallPortfolioCard({
    required this.id
  });

  @override
  State<OverallPortfolioCard> createState() => _OverallPortfolioCardState();
}

class _OverallPortfolioCardState extends State<OverallPortfolioCard> {

  late int id;
  late List<Student> student;


  final StudentsDatabase db = StudentsDatabase();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    loading();
  }
  void loading() async {
    // Fetch student data as List<Map<String, Object?>>
    final studentData = await db.fetchStudent(id);

    // Map the List<Map<String, Object?>> to List<Student>
    setState(() {
      student = studentData.map((data) => Student.fromMap(data)).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -90, 0),
      width: context.width * 0.65,
      height: context.height * 0.24,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 22.0),
      decoration: BoxDecoration(
        color: lightBlack.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'ទិន្ន័យសង្ខេប',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'khmer'
                ),
              ),
              const Spacer(),
              // CustomOutlineButton(
              //     width: context.width * 0.08, title: 'កែទិន្ន័យ',),
              SizedBox(
                width: context.width * 0.015,
              ),
              // GestureDetector(
              //   onTap: () {
              //     print(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Getstudent(id: id)),
              //     );
              //   },
              //   child: Container(
              //     width: context.width * 0.08,
              //     height: context.height * 0.05,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12.0),
              //       gradient: const LinearGradient(
              //         begin: Alignment.bottomRight,
              //         end: Alignment.topLeft,
              //         colors: [
              //           primaryColor,
              //           secondPrimaryColor,
              //         ],
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Text(
              //           'កែទិន្ន័យ',
              //           style: TextStyle(fontSize: 15.0, fontFamily: 'khmer'),
              //         ),
              //         SizedBox(
              //           width: context.width * 0.005,
              //         ),
              //         const Icon(
              //           Icons.edit,
              //           size: 20.0,
              //         ),
              //       ],
              //     ),
              //   ),
              // )

            ],
          ),
          TotalWidget(id: id,),
        ],
      ),
    );
  }
}
