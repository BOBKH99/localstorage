import 'package:flutter/material.dart';
import 'ScoresDatabase.dart';



class StudentScoresScreen extends StatefulWidget {
  @override
  _StudentScoresScreenState createState() => _StudentScoresScreenState();
}

class _StudentScoresScreenState extends State<StudentScoresScreen> {
  final ScoresDatabase db = ScoresDatabase.instance;

  final TextEditingController _homeworkScoreController = TextEditingController();
  final TextEditingController _answerScoreController = TextEditingController();

  List<Map<String, dynamic>> _scoresList = [];

  Future<void> _addScore(int studentId, int? homeworkScore, int? answerScore) async {
    try {
      await db.insertScore(studentId, homeworkScore, answerScore);
      _fetchScores(studentId);
      _homeworkScoreController.clear();
      _answerScoreController.clear();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _fetchScores(int studentId) async {
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = scores;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchScores(1);  // Fetch scores for student ID 1 on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Scores')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _homeworkScoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Homework Score (Optional)',
              ),
            ),
            TextField(
              controller: _answerScoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Answer Question Score (Optional)',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final homeworkScore = int.tryParse(_homeworkScoreController.text);
                final answerScore = int.tryParse(_answerScoreController.text);

                await _addScore(1, homeworkScore, answerScore);
              },
              child: Text('Add Score'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scoresList.length,
                itemBuilder: (context, index) {
                  final score = _scoresList[index];
                  return ListTile(
                    title: Text('Date: ${score['date']}'),
                    subtitle: Text(
                      'Homework: ${score['homework_score']?.toString() ?? "N/A"}, Answer: ${score['answer_score']?.toString() ?? "N/A"}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}