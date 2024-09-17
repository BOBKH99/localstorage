import 'package:flutter/material.dart';
import '../model.dart';
import 'ScoresDatabase.dart';



class StudentScoresScreen extends StatefulWidget {
  final Student student;

  const StudentScoresScreen({ required this.student});

  @override
  State<StudentScoresScreen> createState() => _StudentScoresScreenState();
}

class _StudentScoresScreenState extends State<StudentScoresScreen> {
  final ScoresDatabase db = ScoresDatabase.instance;

  final TextEditingController _homeworkScoreController = TextEditingController();
  final TextEditingController _answerScoreController = TextEditingController();

  List<Map<String, dynamic>> _scoresList = [];
  late int studentID;

  Future<void> _addScore(int studentId, int? homeworkScore, int? answerScore) async {
    await db.insertScore(studentId, homeworkScore, answerScore);
    _fetchScores(studentId);
    _homeworkScoreController.clear();
    _answerScoreController.clear();
  }

  Future<void> _fetchScores(int studentId) async {
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = scores;
    });
  }
  Future<void> _deleteScore(int id, int studentId) async {
    await db.deleteScore(id, studentId);
    final scores = await db.fetchScores(studentId);
    setState(() {
      _scoresList = scores;
    });

  }

  @override
  void initState() {
    super.initState();
    studentID = widget.student.id!;
    _fetchScores(studentID);  // Fetch scores for student ID 1 on startup
  }

  @override
  Widget build(BuildContext context) {
    print('Hello');
    return Scaffold(
      appBar: AppBar(title: const Text('Student Scores')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _homeworkScoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Homework Score (Optional)',
              ),
            ),
            TextField(
              controller: _answerScoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Answer Question Score (Optional)',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final homeworkScore = int.tryParse(_homeworkScoreController.text);
                final answerScore = int.tryParse(_answerScoreController.text);

                await _addScore(studentID, homeworkScore, answerScore);
              },
              child: const Text('Add Score'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scoresList.length,
                itemBuilder: (context, index) {
                  final score = _scoresList[index];
                  print('this is Index : $index');
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: SizedBox(
                                height: 100,
                                child: Column(
                                  children: [
                                    const Text('Are you sure you want delete this score?',style: TextStyle(color: Colors.red),),
                                    ListTile(
                                      title: Text('Date: ${score['date']}'),
                                      subtitle: Text(
                                        'Homework: ${score['homework_score']?.toString() ?? "N/A"}, Answer: ${score['answer_score']?.toString() ?? "N/A"}',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No')),
                                TextButton(
                                    onPressed: () {
                                      _deleteScore(score['id'], studentID);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Yes')),
                              ],
                            );
                          },);
                    },
                    child: ListTile(
                      title: Text('Date: ${score['date']}'),
                      subtitle: Text(
                        'Homework: ${score['homework_score']?.toString() ?? "N/A"}, Answer: ${score['answer_score']?.toString() ?? "N/A"}',
                      ),
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
