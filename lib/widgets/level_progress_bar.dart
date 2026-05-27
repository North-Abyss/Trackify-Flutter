//level_progress_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the UserProvider for EXP updates
    final userProvider = context.watch<UserProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
      padding: const EdgeInsets.all(20.0),
      
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Use the theme's surface color for the card background
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: colorScheme.primary, 
          width: 1.5, // Make the border slightly thicker so the global theme pops
        ),
        // Add a subtle shadow to lift it off the background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row containing Level and EXP numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Level ${userProvider.level}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${userProvider.exp % 100} / 100 EXP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // The visual progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: userProvider.currentLevelProgress, // 0.0 to 1.0
              minHeight: 12,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}