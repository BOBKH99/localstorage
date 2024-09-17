import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:storedatalocal/ScoreDatabase/ScoresDatabase.dart';


class AdminDashboard extends StatefulWidget {
  final int id;

  const AdminDashboard({ required this.id});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ScoresDatabase db = ScoresDatabase.instance;

  List<Map<String, dynamic>> _scoresList = [];
  List<double> _homework = [];
  List<double> _answer = [];
  bool _isLoading = true;

  Future<void> _fetchScores(int studentId) async {
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = List<Map<String, dynamic>>.from(scores);

      _homework = _scoresList
          .map((score) => (score['homework_score'] as num).toDouble())
          .toList();
      _answer = _scoresList
          .map((score) => (score['answer_score'] as num).toDouble())
          .toList();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchScores(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        // Dynamically calculate the width based on the number of data points
        width: _calculateChartWidth(),
        height: 500,
        color: Colors.black,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    if (value % 10 == 0) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                            color: Colors.green, fontSize: 10),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < _scoresList.length) {
                      String dateTimeString = _scoresList[index]['date'];
                      DateTime dateTime =
                      DateTime.parse(dateTimeString);
                      String formattedDate =
                      DateFormat('MM-dd').format(dateTime);
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: getHomeworkSpots(),
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.purple, Colors.pink],
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                      Colors.pink.withOpacity(0.3)
                    ],
                  ),
                ),
              ),
              LineChartBarData(
                spots: getAnswerSpots(),
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green, Colors.cyan],
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.green.withOpacity(0.3),
                      Colors.cyan.withOpacity(0.3)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate width based on the number of data points
  double _calculateChartWidth() {
    const double pointWidth = 50.0; // Adjust this value for the spacing
    return _scoresList.length * pointWidth;
  }

  List<FlSpot> getHomeworkSpots() {
    List<FlSpot> spots = [];
    for (var i = 0; i < _homework.length; i++) {
      spots.add(FlSpot(i.toDouble(), _homework[i]));
    }
    return spots;
  }

  List<FlSpot> getAnswerSpots() {
    List<FlSpot> spots = [];
    for (var i = 0; i < _answer.length; i++) {
      spots.add(FlSpot(i.toDouble(), _answer[i]));
    }
    return spots;
  }
}
