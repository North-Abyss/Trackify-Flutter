//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert'; // For JSON encoding/decoding
//import '../models/habit.dart';
import '../providers/user_provider.dart'; // Import the UserProvider
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/habit_card.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/habit_provider.dart'; // Import your new manager
import 'habit_detail_screen.dart';
import '../widgets/level_progress_bar.dart';
import '../models/habit.dart'; 
import 'package:flutter/services.dart'; // REQUIRED for keyboard keys!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

const uuid = Uuid();
class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _habitController = TextEditingController();

  // --- THE UNIFIED CREATE & EDIT DIALOG ---
  void _showHabitDialog(BuildContext context, {Habit? existingHabit}) {
    final isEditing = existingHabit != null;
    final nameController = TextEditingController(text: existingHabit?.name ?? '');
    
    // If editing, extract the saved time back into hours/mins/secs
    int h = 0, m = 0, s = 0;
    if (isEditing && existingHabit.targetDurationSeconds > 0) {
      h = existingHabit.targetDurationSeconds ~/ 3600;
      m = (existingHabit.targetDurationSeconds % 3600) ~/ 60;
      s = existingHabit.targetDurationSeconds % 60;
    }
    
    final hCtrl = TextEditingController(text: h > 0 ? h.toString() : '');
    final mCtrl = TextEditingController(text: m > 0 ? m.toString() : '');
    final sCtrl = TextEditingController(text: s > 0 ? s.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(isEditing ? 'Edit Habit' : 'Create New Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Habit Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text('Cooldown Timer (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: hCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hrs'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: mCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: sCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sec'))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Convert inputs back to total seconds
                int hrs = int.tryParse(hCtrl.text) ?? 0;
                int mins = int.tryParse(mCtrl.text) ?? 0;
                int secs = int.tryParse(sCtrl.text) ?? 0;
                int totalSecs = (hrs * 3600) + (mins * 60) + secs;

                // Call our new consolidated Provider method!
                context.read<HabitProvider>().saveOrUpdateHabit(
                  id: existingHabit?.id, // Passes null if creating new
                  name: nameController.text,
                  durationSeconds: totalSecs,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WATCH THE STATE: This tells the UI to rebuild anytime notifyListeners() is called!
    final habitProvider = context.watch<HabitProvider>();
    final myHabits = habitProvider.habits; // Grab the list from the provider

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyN): NewHabitIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): NewHabitIntent(), // For Mac
      },
      child: Actions(
        // 2. THE TRIGGER: What happens when NewHabitIntent fires?
        actions: <Type, Action<Intent>>{
          NewHabitIntent: CallbackAction<NewHabitIntent>(
            onInvoke: (NewHabitIntent intent) {
              _showHabitDialog(context); // Call our helper function!
              return null;
            },
          ),
        },

        child: Focus(
          autofocus: true,
        child: Scaffold(
          //backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text('Trackify Dashboard'),
            actions: [
              // 1. Profile Button
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              // 2. Settings Button
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),

          body: Center(

            child: ConstrainedBox(
              
              constraints: const BoxConstraints(maxWidth: 600),
              
              // NEW: Wrapping everything in a Column so we can stack the progress bar and list

              child:Column( 
                children: [ 
                  
                  const LevelProgressBar(), // THE PROGRESS BAR UI
                  
                  Expanded(
                  child: ListView.builder(
                    itemCount: myHabits.length,
                    itemBuilder: (context, index) {
                        final habit = myHabits[index];

                        return Dismissible(
                          key: Key(habit.id),

                          direction: DismissDirection.startToEnd,
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.5,
                          },

                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20.0),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),

                          // The logic to execute when swiped off screen
                          onDismissed: (direction) {
                            context.read<HabitProvider>().deleteHabit(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${habit.name} deleted')),
                            );
                          },

                          child: GestureDetector(
                            onTap: () {
                              context.read<HabitProvider>().toggleHabit(habit.id);
                              context.read<UserProvider>().addExp(10);
                            },

                            onLongPress: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HabitDetailScreen(habit: habit),
                                ),
                              );

                              // If the widget was destroyed while we were waiting, stop executing!
                              if (!context.mounted) return;

                              // Handle the result which is now a Map with 'name' and 'seconds'
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                final String? updatedName = result['name'];
                                final int? updatedSeconds = result['seconds'];
                                if ((updatedName != null && updatedName.isNotEmpty) ||
                                    updatedSeconds != null) {
                                  context.read<HabitProvider>().saveOrUpdateHabit(
                                    id: habit.id,
                                    name: updatedName ?? habit.name,
                                    durationSeconds: updatedSeconds ?? habit.targetDurationSeconds,
                                  );
                                }
                              }
                            },

                            child: HabitCard(
                              habit: habit,
                            ), // Pass the whole habit object to the card!
                          ),
                        );
                      },
                    ),
                  ),
                ]
              ),
            ),
          ),
          
          floatingActionButton: FloatingActionButton(
            //backgroundColor: Theme.of(context).colorScheme.primary, // Use the theme's primary color
            child: const Icon(Icons.add),
            onPressed: () {
              _habitController.clear();
              _showHabitDialog(context); // Call our helper function!
            },
          ),
      
        )
        ),
      ),      
    );
  }
}

// shortcut keys
class NewHabitIntent extends Intent {
  
}