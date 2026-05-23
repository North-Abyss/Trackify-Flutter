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
    final isCoolingDown = habit.cooldownEndTime != null;

    // --- GRAB THE CUSTOM COLOR ---
    final customColor = Color(habit.colorValue);

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
        // Use the custom color! If completed, solid color. If not, a very faint tinted version of it!
        color: habit.completed 
          ? customColor 
          : customColor.withValues( alpha:0.1),
        borderRadius: BorderRadius.circular(8.0),
        // Add a subtle border matching the color
        border: Border.all(color: habit.completed ? Colors.transparent : customColor.withValues( alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600,
                    // White text if solid background, otherwise match theme
                    color: habit.completed ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (habit.targetDurationSeconds > 0) ...[
                    Text(
                      isCoolingDown 
                          ? formatSeconds(provider.getRemainingSeconds(habit)) 
                          : formatSeconds(habit.targetDurationSeconds),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: habit.completed ? Colors.white : customColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (habit.completed && habit.targetDurationSeconds == 0)
                    const Icon(Icons.check_circle, color: Colors.white),
                ],
              ),
            ],
          ),
          
          // --- SHOW THE TAG IF IT EXISTS ---
          if (habit.tag.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: habit.completed ? Colors.white.withValues( alpha:0.2) : customColor.withValues( alpha:0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                habit.tag.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: habit.completed ? Colors.white : customColor,
                ),
              ),
            ),
          ]
        ],
      )
    );
  }

}