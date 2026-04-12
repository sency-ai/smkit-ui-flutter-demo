import 'package:flutter/material.dart';

class WorkoutResultScreen extends StatelessWidget {
  final String workoutResult;

  const WorkoutResultScreen({super.key, required this.workoutResult});

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
