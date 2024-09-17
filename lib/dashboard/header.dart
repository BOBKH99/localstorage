import 'package:flutter/material.dart';
import 'package:storedatalocal/StudentDatabase.dart';

import '../../utils/media_query_values.dart';
import 'package:intl/intl.dart';


class Header extends StatefulWidget {
  var id;

  Header({
    required this.id
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  final StudentsDatabase dbS = StudentsDatabase();

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> Attendance = [];

  void _loadStudents(int id) async {
    final students = await dbS.fetchStudent(id);
    setState(() {
      _students = students;
    });
  }
  late int id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    _loadStudents(id);
  }


  @override
  Widget build(BuildContext context) {
    String formattedTime12Hour = DateFormat("hh:mm:ss a").format(DateTime.now());
    print(formattedTime12Hour); // Output: 07:38:57 PM

    final currentTime = DateTime.now();
    final isDaytime = currentTime.hour >= 6 && currentTime.hour < 18;

    return Container(
      height: context.height * 0.28,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.medium,
          opacity: 0.5,
          image: AssetImage(
            'assets/images/header_image.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios,size: 26,color: Colors.white,shadows: [BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),],),
              ),
              const SizedBox(width: 20,),
              Icon(
                isDaytime ? Icons.wb_sunny : Icons.nights_stay,
                size: 40,
                color: Colors.amber, // Customize the color as needed
              ),
              SizedBox(
                width: context.width * 0.01,
              ),
              Text(
                formattedTime12Hour,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.grey[200],fontSize: 16),
              ),
            ],
          ),
          // SizedBox(width: 400,),
          Text('ផ្ទាំងបង្ហាញទិន្ន័យ', style: TextStyle(fontSize: 30, color: Colors.white,fontFamily: 'khmer',shadows: [BoxShadow(
          color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),],),),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${_students[0]['studentClass']}',style: const TextStyle(fontFamily: 'khmer', fontSize: 24, color: Colors.white),),
                      Text('${_students[0]['phone']}',style: const TextStyle(fontFamily: 'khmer', fontSize: 24, color: Colors.white),),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
