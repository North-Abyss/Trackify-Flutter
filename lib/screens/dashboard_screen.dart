//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert'; // For JSON encoding/decoding
//import '../models/habit.dart';
import '../providers/theme_provider.dart'; // Import the ThemeProvider to access the palette
import '../providers/user_provider.dart'; // Import the UserProvider
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';
import '../widgets/habit_card.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/habit_provider.dart'; // Import your new manager
//import 'habit_detail_screen.dart';
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

  // --- THE ULTIMATE CREATE & EDIT DIALOG ---
  void _showHabitDialog(BuildContext context, {Habit? existingHabit}) {
    final isEditing = existingHabit != null;

    // Text Controllers
    final nameController = TextEditingController(text: existingHabit?.name ?? '');
    final descController = TextEditingController(text: existingHabit?.description ?? '');
    final linkController = TextEditingController(text: existingHabit?.link ?? '');
    final tagController = TextEditingController(text: existingHabit?.tag ?? '');
    
    // --- FETCH THE DYNAMIC PALETTE FROM THEME PROVIDER ---
    // Make sure you import '../providers/theme_provider.dart'; at the top of the file!
    // We get the list of predefined seed colors from your ThemeProvider
    final List<Color> themePalette = context.read<ThemeProvider>().availableThemes.map((name) => context.read<ThemeProvider>().getThemeColor(name)).toList();
    
    // If the habit has a color, use it. Otherwise, default to the currently active Theme color!
    final activeThemeColor = Theme.of(context).colorScheme.primary;
    int selectedColor = existingHabit?.colorValue ?? activeThemeColor.toARGB32();
    
    // Timer
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
      builder: (context) => StatefulBuilder( 
        builder: (context, setState) {
          // Wrap in a Dialog to control exact padding and width
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500), // Max width for Desktop!
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Habit' : 'Create New Habit',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Habit Name', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    
                    // Meta Data Fields
                    TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: tagController, decoration: const InputDecoration(labelText: 'Tag (e.g., Health)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.sell, size: 18)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: linkController, decoration: const InputDecoration(labelText: 'Link URL', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link, size: 18)))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Color Picker
                    const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: themePalette.map((color) {
                        final colorValue = color.toARGB32();// update from color value
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = colorValue),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 18, // Slightly bigger
                            child: selectedColor == colorValue ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Cooldown Timer
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
                    const SizedBox(height: 24),

                    // Action Buttons aligned to the right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              int hrs = int.tryParse(hCtrl.text) ?? 0;
                              int mins = int.tryParse(mCtrl.text) ?? 0;
                              int secs = int.tryParse(sCtrl.text) ?? 0;
                              
                              context.read<HabitProvider>().saveOrUpdateHabit(
                                id: existingHabit?.id, 
                                name: nameController.text,
                                durationSeconds: (hrs * 3600) + (mins * 60) + secs,
                                description: descController.text,
                                link: linkController.text,
                                tag: tagController.text,
                                colorValue: selectedColor, 
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
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
            title: const Text('Trackify Dashboard', style: TextStyle(fontSize: 28.0)),
            actions: [
              // 0. Calendar Button
              IconButton(
                iconSize: 32.0, 
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarScreen()),
                  );
                },
              ),
              // 1. Profile Button
              IconButton(
                iconSize: 32.0,
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
                iconSize: 32.0,
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

                          onLongPress: () {
                              _showHabitDialog(context, existingHabit: habit);
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