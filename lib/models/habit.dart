// lib/models/habit.dart
class Habit {
  final String id;
  String name;
  bool completed;
  DateTime? lastCompletedDate;
  int currentStreak;
  int targetDurationSeconds;
  DateTime? cooldownEndTime;
  // --- NEW: THE META DATA ---
  String description;
  String link;
  String tag;
  int colorValue;
  // The Historical Tracker! A list of every day this habit was finished.
  List<DateTime> completedDates; 

  Habit({
    required this.id,
    required this.name,
    this.completed = false,
    this.lastCompletedDate,
    this.currentStreak = 0,
    this.targetDurationSeconds = 0,
    this.cooldownEndTime,
    // Default values for the new fields
    this.description = '',
    this.link = '',
    this.tag = '',
    this.colorValue = 0xFF4CAF50, // Default to Material Green
    List<DateTime>? completedDates,
  }): completedDates = completedDates ?? []; // Initialize as empty list if none exist


  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'completed': completed,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'targetDurationSeconds': targetDurationSeconds,
      'cooldownEndTime': cooldownEndTime?.toIso8601String(), // Save it!
      // Save the new fields
      'description': description,
      'link': link,
      'tag': tag,
      'colorValue': colorValue,
      // Save the historical dates to the hard drive as strings
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Habit.fromjson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'], name: json['name'], completed: json['completed'],
      lastCompletedDate: json['lastCompletedDate'] != null ? DateTime.parse(json['lastCompletedDate']) : null,
      currentStreak: json['currentStreak'] ?? 0,
      targetDurationSeconds: json['targetDurationSeconds'] ?? 0,
      cooldownEndTime: json['cooldownEndTime'] != null ? DateTime.parse(json['cooldownEndTime']) : null, // Load it!
      // Load the new fields safely
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      tag: json['tag'] ?? '',
      colorValue: json['colorValue'] ?? 0xFF4CAF50,
      // Safely load the history, even if it's an older save file!
      completedDates: (json['completedDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ?? [],
    );
  }
}
