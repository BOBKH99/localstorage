import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storedatalocal/StudentDatabase.dart';
import 'package:storedatalocal/utils/media_query_values.dart';
import '../../utils/colors.dart';
import '../ScoreDatabase/ScoresDatabase.dart';
import '../attentden/database_attandance.dart';
import 'outline_button.dart';
import 'pie_chart.dart';

class StockWidget extends StatefulWidget {
  int id;
  StockWidget({
    required this.id
  });

  @override
  State<StockWidget> createState() => _StockWidgetState();
}

class _StockWidgetState extends State<StockWidget> {
  final StudentsDatabase db = StudentsDatabase();

  late int id = widget.id;
  Map<String, dynamic>? totalAbsent;
  Map<String, dynamic>? totalPresent;
  List<Map<String, dynamic>>? student = [];
   late double average = 0.0;
   late double answer = 0.0;
   late double homework = 0.0;
  bool isloading = true;

  void loading()async {

    final students = await db.fetchStudent(id);
    final totalA = await AttendanceDatabase.instance.fetchTotalAbsent(id);
    final totalP = await AttendanceDatabase.instance.fetchTotalPresent(id);
    final averages = await ScoresDatabase.instance.calculateAveragePercentage(id);
    final answerPercentage = averages['average_answer_percentage'] ?? 0;
    final homeworkPercentage = averages['average_homework_percentage'] ?? 0;
    print('Average Answer Score Percentage: ${averages['average_answer_percentage']}%');
    print('Average Homework Score Percentage: ${averages['average_homework_percentage']}%');
     final _average = (answerPercentage + homeworkPercentage) / 2;
    setState(() {
      student = students;
      totalAbsent = totalA;
      totalPresent = totalP;
      average = _average;
      answer = answerPercentage;
      homework = homeworkPercentage;
      isloading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading();
  }


  @override
  Widget build(BuildContext context) {
    print(':::::::::::::::: $average');
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            width: context.width * 0.22,
            // height: context.height,
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 22.0,
            ),
            transform: Matrix4.translationValues(0, -75, 0),
            decoration: BoxDecoration(
              color: lightBlack,
              borderRadius: BorderRadius.circular(25.0),
            ),
          child: Column(
            children: [
              Container(
                height: 100,
                width: 300,
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 22.0,
                ),
                transform: Matrix4.translationValues(0, -80, 0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: OverflowBox(
                    maxHeight: 400,  // Control how much the image overflows out
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: CircleAvatar(
                        backgroundImage: FileImage(File(student?[0]['imagePath'])),
                      ),
                    ),
                  ),
                ),
              ),
              Text(student?[0]['name'], style: TextStyle(fontFamily: 'khmer', fontSize: 18, color: Colors.white60),),
              Text('${student?[0]['age']}', style: TextStyle(fontFamily: 'khmer', fontSize: 18, color: Colors.white60),),
              Text(student?[0]['birthday'], style: TextStyle(fontFamily: 'khmer', fontSize: 18, color: Colors.white60),),
              Stack(
                alignment: Alignment.center,
                children: [
                  PieChartWidget(id: id,),
                  Container(
                    width: context.width * 0.235,
                    height: context.height * 0.235,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.0,
                        color: darkGrey.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ស្ថិតិពិន្ទុ',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: darkGrey, fontFamily: 'khmer',fontSize: 16),
                        ),
                        SizedBox(
                          height: context.height * 0.02,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${average.toStringAsFixed(2)}', // Format to two decimal places
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrangeAccent
                              ),
                            ),
                            SizedBox(
                              width: context.width * 0.001,
                            ),
                            Text(
                              '%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: darkGrey, fontSize: 15.0),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: context.height * 0.02,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          Container(
            width: context.width * 0.15,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: darkBlack,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 10.0,
                  color: darkGrey,
                ),
                SizedBox(
                  width: context.width * 0.015,
                ),
                Text(
                  'OB Nov - 17 Nov',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(
                  width: context.width * 0.008,
                ),
                const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 13.0,
                  color: darkGrey,
                ),
              ],
            ),
          ),
            SizedBox(
              height: context.height * 0.015,
            ),
            accountsWidget(context, 'ស្ថិតិពិន្ទុក កិច្ចការផ្ទះ', '${homework.toStringAsFixed(2)}', isPercentage: true),
              accountsWidget(context, 'ស្ថិតិពិន្ទុក ប្រលង', '${answer.toStringAsFixed(2)}', isPercentage: true),
            SizedBox(
              height: context.height * 0.02,
            ),
            CustomOutlineButton(width: context.width * 0.15, title: 'Null'),
            SizedBox(
              height: context.height * 0.02,
            ),
        ],
      ),
    );
  }

  Padding accountsWidget(BuildContext context, String title, String value,
      {bool isPercentage = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: context.width * 0.15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: darkGrey, fontFamily: 'khmer'),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: isPercentage ? Colors.green : darkGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
