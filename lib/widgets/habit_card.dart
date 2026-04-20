// habit_card.dart
import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final bool isCompleted;

  const HabitCard({
    super.key, 
    required this.title, 
    required this.isCompleted
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.blueGrey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}