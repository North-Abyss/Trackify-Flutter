// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:dynamic_color/dynamic_color.dart'; // THE NEW MATERIAL YOU ENGINE!

import 'providers/habit_provider.dart'; 
import 'providers/theme_provider.dart'; 
import 'providers/user_provider.dart'; 
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize the notification engine
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  
  // 2. Schedule the daily 8 PM reminder
  await NotificationService.scheduleDailyReminder();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), 
        ChangeNotifierProvider(create: (_) => UserProvider()), 
      ],
      // We use Consumer here so we have direct access to the theme state
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          
          // Wrap the app in the Dynamic Color engine
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              
              ThemeData activeLight;
              ThemeData activeDark;

              // Check if the user specifically requested the System's dynamic color
              // AND ensure the system actually provided one (lightDynamic != null)
              if (themeProvider.activeThemeName == 'Dynamic' && lightDynamic != null && darkDynamic != null) {
                // ACTIVATE MATERIAL YOU (Matches User's Wallpaper)
                activeLight = ThemeData(colorScheme: lightDynamic.harmonized(), useMaterial3: true);
                activeDark = ThemeData(colorScheme: darkDynamic.harmonized(), useMaterial3: true);
              } else {
                // USE TRACKIFY'S CUSTOM COLORS (Ocean Blue, Amber, etc.)
                activeLight = themeProvider.lightTheme;
                activeDark = themeProvider.darkTheme;
              }

              return MaterialApp(
                debugShowCheckedModeBanner: false, // Remove the debug banner
                title: 'Trackify', 
                
                theme: activeLight, 
                darkTheme: activeDark,
                themeMode: themeProvider.themeMode,
                
                home: const DashboardScreen(), 
              );
            },
          );
        },
      )
    );
  }
}