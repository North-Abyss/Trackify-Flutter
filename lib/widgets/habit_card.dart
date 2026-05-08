// habit_card.dart
import 'package:flutter/material.dart';
import '../models/habit.dart'; // Import the model
//import 'package:provider/provider.dart';
//import '../providers/habit_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit; 

  const HabitCard({
    super.key, 
    required this.habit,
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
        color: habit.completed 
          ? Theme.of(context).colorScheme.primary // The main theme color (e.g., solid blue)
          : Theme.of(context).colorScheme.surfaceContainerHighest, // A nice neutral grey/tinted background
        borderRadius: BorderRadius.circular(8.0),
      ),
      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The Text (Wrapped in Expanded so it doesn't push the timer off screen)
          Expanded(
            child: Text(
              habit.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: habit.completed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // THE NEW TIMER UI
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (habit.targetDurationSeconds > 0) ...[
                Text(
                  habit.formattedTimer,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: habit.completed ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (habit.completed && habit.targetDurationSeconds == 0)
                Icon(Icons.check_circle, color: colorScheme.onPrimary),
            ],
          ),
        ],
      )

    );
  }
}