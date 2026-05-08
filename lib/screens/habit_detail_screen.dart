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
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    
    // Convert target duration to hours, minutes, seconds
    int totalSeconds = widget.habit.targetDurationSeconds;
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;

    _hoursController = TextEditingController(text: h > 0 ? h.toString() : '');
    _minutesController = TextEditingController(text: m > 0 ? m.toString() : '');
    _secondsController = TextEditingController(text: s > 0 ? s.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name', 
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Target Duration (Manual Input)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Hours', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutes', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seconds', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  int h = int.tryParse(_hoursController.text) ?? 0;
                  int m = int.tryParse(_minutesController.text) ?? 0;
                  int s = int.tryParse(_secondsController.text) ?? 0;
                  
                  int totalSeconds = (h * 3600) + (m * 60) + s;

                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'seconds': totalSeconds,
                  });
                },
                child: const Text('Save Changes'),
              ),
            )
          ],
        ),
      ),
    );
  }
}