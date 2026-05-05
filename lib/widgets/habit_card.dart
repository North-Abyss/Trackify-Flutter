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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        // Instead of a hardcoded color, ask the Global Theme for its primary container color!
        color: isCompleted 
          ? Theme.of(context).colorScheme.primary // The main theme color (e.g., solid blue)
          : Theme.of(context).colorScheme.surfaceContainerHighest, // A nice neutral grey/tinted background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          //Dynamic Text Colors!
          color: isCompleted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          //decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}