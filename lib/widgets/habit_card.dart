// lib/widgets/habit_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit; 

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<HabitProvider>(); 
    
    // Check if this specific habit is cooling down
    final isCoolingDown = habit.cooldownEndTime != null;

    String formatSeconds(int seconds) {
      final d = Duration(seconds: seconds);
      String two(int n) => n.toString().padLeft(2, '0');
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      final s = d.inSeconds.remainder(60);
      if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
      return '${two(m)}:${two(s)}';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: habit.completed ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              habit.name,
              style: TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.w600,
                color: habit.completed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (habit.targetDurationSeconds > 0) ...[
                Text(
                  // Show live countdown if cooling down, otherwise show target time!
                  isCoolingDown 
                      ? formatSeconds(provider.getRemainingSeconds(habit)) 
                      : formatSeconds(habit.targetDurationSeconds),
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