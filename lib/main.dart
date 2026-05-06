// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/habit_provider.dart'; // Import your new manager
import 'providers/theme_provider.dart'; // Import your new ThemeProvider!
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override 
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Inject it here!
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Bonus: removes the 'Debug' banner!
            title: 'Trackify', 
            
            // Flutter natively handles the switching now!
            theme: context.watch<ThemeProvider>().lightTheme, 
            darkTheme: context.watch<ThemeProvider>().darkTheme,
            themeMode: context.watch<ThemeProvider>().themeMode,
            
            home: DashboardScreen(), 
          );
        },
      )
    );
    
  }
}