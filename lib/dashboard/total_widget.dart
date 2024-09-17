import 'package:storedatalocal/ScoreDatabase/ScoresDatabase.dart';
import 'package:storedatalocal/attentden/database_attandance.dart';

import '../../utils/media_query_values.dart';
import 'package:flutter/material.dart';

class TotalWidget extends StatefulWidget {
  int id;
  TotalWidget({
    required this.id
  });

  @override
  State<TotalWidget> createState() => _TotalWidgetState();
}

class _TotalWidgetState extends State<TotalWidget> {

  late int id;
  Map<String, dynamic>? lastScores;
  Map<String, dynamic>? totalScores;
  Map<String, dynamic>? totalAbsent;
  Map<String, dynamic>? totalPermission;
  Map<String, dynamic>? totalPresents;
  bool isLoading = true;
  late bool Hcolor = true;
  late bool Acolor = true;
  late bool Abcolor = true;
  late bool Lcolor = true;


  @override
  void initState() {
    super.initState();
    id = widget.id;
    fetchScores();
  }

  Future<void> fetchScores() async {
    setState(() {
      isLoading = true;
    });

    // Fetch both last and total scores
    final lastS = await ScoresDatabase.instance.fetchLastScores(id);
    final totalS = await ScoresDatabase.instance.fetchTotalScores(id);
    final totalA = await AttendanceDatabase.instance.fetchTotalAbsent(id);
    final totalP = await AttendanceDatabase.instance.fetchTotalPresent(id);

      setState(() {
        lastScores = lastS;
        totalScores = totalS;
        totalAbsent = totalA;
        totalPresents = totalP;
        //totalPermission = totalA['total_late'];
        isLoading = false;
      });
  }
  @override
  Widget build(BuildContext context) {
    // Assign default values if null
    final homeworkScore = lastScores?['homework_score'] ?? 0;
    final answerScore = lastScores?['answer_score'] ?? 0;

    final totalHomeworkScore = totalScores?['total_homework_score'] ?? 0;
    final totalAnswerScore = totalScores?['total_answer_score'] ?? 0;

    final totalAbsents = totalAbsent?['total_absent'] ?? 0;
    final totalLate = totalAbsent?['total_late'] ?? 0;
    final totalPresent = totalPresents?['total_present'] ?? 0;

    // Adjust color based on homeworkScore
    if (homeworkScore <= 4) {
      Hcolor = false;
    } else {
      Hcolor = true;
    }
    if (answerScore <= 49) {
      Acolor = false;
    } else {
      Acolor = true;
    }
    if (totalAbsents > 0) {
      Abcolor = false;
    } else {
      Abcolor = true;
    }
    if (totalLate > 1) {
      Lcolor = false;
    } else {
      Lcolor = true;
    }

    print(totalPresent);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
      width: context.width * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ពិន្ទុកិច្ចការផ្ទះ',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (homeworkScore >= 5)
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.green,
                          size: 15.0,
                        ),
                      if (homeworkScore <= 4)
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.red,
                          size: 15.0,
                        ),
                      SizedBox(
                        width: context.width * 0.001,
                      ),
                      Text(
                        '$homeworkScore',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Hcolor ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: context.height * 0.02,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'សរុប',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                  SizedBox(
                    width: context.width * 0.001,
                  ),
                  Text(
                    '$totalHomeworkScore',
                    style: const TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ពិន្ទុកប្រលង',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (answerScore >= 50)
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.green,
                          size: 15.0,
                        ),
                      if (answerScore <= 49)
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.red,
                          size: 15.0,
                        ),
                      SizedBox(
                        width: context.width * 0.001,
                      ),
                      Text(
                        '$answerScore',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Acolor ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: context.height * 0.02,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'សរុប',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                  SizedBox(
                    width: context.width * 0.001,
                  ),
                  Text(
                    '$totalAnswerScore',
                    style: const TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'អវត្តមានច្បាប់',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                  SizedBox(
                    width: context.width * 0.008,
                  ),
                  Text(
                    '$totalLate',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Lcolor ? Colors.green : Colors.orange),
                  ),
                ],
              ),
              SizedBox(
                height: context.height * 0.02,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'អវត្តមាន',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey,fontFamily: 'khmer'),
                  ),
                  SizedBox(
                    width: context.width * 0.001,
                  ),
                  Text(
                    '$totalAbsents',
                    style: TextStyle(
                      fontSize: 26.0,
                      color: Abcolor ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'វត្តមាន',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey, fontFamily: 'khmer'),
                  ),
                ],
              ),
              SizedBox(
                height: context.height * 0.02,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: context.width * 0.001,
                  ),
                  Text(
                    '$totalPresent',
                    style: const TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
