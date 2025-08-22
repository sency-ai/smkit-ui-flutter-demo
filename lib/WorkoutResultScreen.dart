import 'package:flutter/material.dart';

class WorkoutResultScreen extends StatelessWidget {
  final String workoutResult;

  const WorkoutResultScreen({Key? key, required this.workoutResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Result'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            workoutResult,
            style: const TextStyle(fontSize: 20.0),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}
