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
    final provider = context.watch<HabitProvider>(); 
    final isCoolingDown = habit.cooldownEndTime != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Grab the raw custom color for this specific habit
    final seedColor = Color(habit.colorValue);

    // 2. Generate a local Material 3 ColorScheme JUST for this card!
    final cardScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    // 3. Apply the Level Card Aesthetic to the Uncompleted State
    final bgColor = habit.completed
        ? cardScheme.primaryContainer
        // Match the level card's subtle background
        : cardScheme.surfaceContainerHighest.withValues(alpha: 0.5); 

    // Text automatically adjusts for perfect contrast
    final textColor = habit.completed
        ? cardScheme.onPrimaryContainer
        : cardScheme.onSurface;

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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Match level card margins
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          // MATCH THE LEVEL CARD BORDER! 
          // Solid primary border for uncompleted, transparent for completed.
          color: habit.completed ? Colors.transparent : cardScheme.primary, 
          width: habit.completed ? 0 : 1, // Optional: slightly thicker border if you want
        ),
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
                    fontSize: 18.0, 
                    fontWeight: FontWeight.w600,
                    color: textColor, 
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
                        color: textColor, 
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (habit.completed && habit.targetDurationSeconds == 0)
                    Icon(Icons.check_circle, color: textColor),
                ],
              ),
            ],
          ),
          
          if (habit.tag.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: habit.completed 
                    ? cardScheme.secondary.withValues(alpha: 0.2)
                    : cardScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                habit.tag.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: habit.completed ? textColor : cardScheme.onSecondaryContainer, 
                ),
              ),
            ),
          ]
        ],
      )
    );
  }
  
}