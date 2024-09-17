import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../ScoreDatabase/ScoresDatabase.dart';

class PieChartWidget extends StatefulWidget {
  final int id;  // 'final' ensures this is initialized by the constructor

  PieChartWidget({required this.id});

  @override
  State<PieChartWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartWidget> {
  int touchedIndex = -1;
  Map<String, dynamic>? totalScore;
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    print('Init state called');
    _fetchAttendanceData();  // Fetch the attendance data in initState
  }

  Future<void> _fetchAttendanceData() async {
    print('Fetching attendance data...'); // Debugging print

    try {
      final totalS = await ScoresDatabase.instance.fetchTotalScores(widget.id);

      setState(() {
        totalScore = totalS;
        _isloading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');  // Log any errors
    }
  }


  @override
  Widget build(BuildContext context) {

    return _isloading
        ? const Center(child: CircularProgressIndicator())
        : AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 80,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 30.0 : 20.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: promiscuousPink,
            value: (totalScore?['total_homework_score'] ?? 0).toDouble(),
            radius: radius,
            showTitle: false,
            borderSide: const BorderSide(width: 4, color: lightBlack),
          );
        case 1:
          return PieChartSectionData(
            color: blue,
            value: (totalScore?['total_answer_score'] ?? 0).toDouble(),
            radius: radius,
            showTitle: false,
            borderSide: const BorderSide(width: 4, color: lightBlack),
          );
        default:
          throw Error();
      }
    });
  }
}
