// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/habit_provider.dart'; // Import your new manager
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override 
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: const MaterialApp(
      debugShowCheckedModeBanner: false, // Bonus: removes the 'Debug' banner!
      title: 'Trackify', home: DashboardScreen(), 
      ),
    );
    
  }
}