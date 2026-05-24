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

    // 1. Grab the raw custom color
    final customColor = Color(habit.colorValue);

    // 2. THE DARK ACCENT GENERATOR!
    // Mix the custom color with 40% black to make it rich and deep.
    final darkAccentColor = Color.lerp(customColor, Colors.black, 0.2)!;

    // 3. Determine the solid color: 
    // Light Mode = Use the deep Dark Accent
    // Dark Mode = Use the original bright color so it pops against the dark UI
    final solidColor = isDark ? customColor : darkAccentColor;

    // Background color mapping
    final bgColor = habit.completed
        ? solidColor
        : (isDark ? customColor.withValues(alpha: 0.15) : customColor.withValues(alpha: 0.1));

    // Text color mapping (White text looks incredible on dark accents!)
    final textColor = habit.completed
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);

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
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0), 
        border: Border.all(
          color: habit.completed ? solidColor : customColor, 
          //width: 2,
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
                // The tag background adapts beautifully based on state and theme
                color: habit.completed 
                    ? (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.3))
                    : customColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                habit.tag.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor, 
                ),
              ),
            ),
          ]
        ],
      )
    );
  }
}