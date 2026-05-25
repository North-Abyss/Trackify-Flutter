// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // Default to today!

  // --- THE DATA BRIDGE ---
  // This helper function asks the Provider: "Did we complete any habits on this specific day?"
  List<Habit> _getHabitsForDay(DateTime day, List<Habit> allHabits) {
    return allHabits.where((habit) {
      // isSameDay is a handy utility from the table_calendar package
      return habit.completedDates.any((completedDate) => isSameDay(completedDate, day));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the habits so the calendar redraws instantly when you complete a task!
    final allHabits = context.watch<HabitProvider>().habits;
    final habitsForSelectedDay = _selectedDay != null ? _getHabitsForDay(_selectedDay!, allHabits) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Matrix'),
      ),
      body: Column(
        children: [
          // THE CALENDAR WIDGET
          TableCalendar<Habit>(
            firstDay: DateTime.utc(2023, 1, 1), 
            lastDay: DateTime.utc(2030, 12, 31), 
            focusedDay: _focusedDay,
            
            // 🚀 INJECT THE DATA HERE!
            eventLoader: (day) => _getHabitsForDay(day, allHabits),

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; 
              });
            },
            
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, 
              titleCentered: true,
            ),
            
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              // Pushes the dots slightly lower so they don't cover the number
              markersMaxCount: 4, 
            ),

            // 🎨 CUSTOM DOT PAINTER
            // This replaces the default gray dots with our custom colored dots!
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox();
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Take up to 4 habits to show as dots so it doesn't get cluttered
                  children: events.take(4).map((habit) {
                    return Container(
                      margin: const EdgeInsets.only(top: 38.0, right: 1.5, left: 1.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(habit.colorValue), // The exact custom color!
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          
          const Divider(thickness: 2),
          
          // THE DAILY HISTORY LIST
          Expanded(
            child: habitsForSelectedDay.isEmpty
                ? const Center(
                    child: Text(
                      'No habits completed on this day.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: habitsForSelectedDay.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      final habit = habitsForSelectedDay[index];
                      return Card(
                        elevation: 0,
                        color: Color(habit.colorValue).withValues(alpha: 0.15),
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle, 
                            color: Color(habit.colorValue)
                          ),
                          title: Text(
                            habit.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: habit.tag.isNotEmpty 
                            ? Text(habit.tag.toUpperCase(), style: const TextStyle(fontSize: 12))
                            : null,
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}