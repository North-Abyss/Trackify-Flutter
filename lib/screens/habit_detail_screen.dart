// lib/screens/habit_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/habit.dart';


// Upgraded to StatefulWidget to hold a TextField!
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the current habit name
    _editController = TextEditingController(text: widget.habit.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _editController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Return the updated text back to the previous screen!
                Navigator.pop(context, _editController.text);
              },
              child: const Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }
}