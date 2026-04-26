// lib/screens/habit_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitDetailScreen extends StatelessWidget {

  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // Use the habit's name dynamically in the AppBar!
      appBar: AppBar(
        title: Text('${habit.name} Details'), backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Habit: ${habit.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${habit.completed ? "Completed ✅" : "Pending ⏳"}', style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text('Future statistics will go here!'),
          ],
        ),
      ),
    );
  }
}