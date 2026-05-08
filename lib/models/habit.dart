// lib/models/habit.dart

class Habit {
  final String id;
  String name;
  bool completed;

  // NEW: Time and Gamification tracking
  DateTime? lastCompletedDate;
  int currentStreak;

  int targetDurationSeconds; // Timer

  // NEW LIVE TIMER VARIABLES
  int remainingSeconds; 

  Habit({
    required this.id,
    required this.name,
    this.completed = false, // Defaults to false if not provided!
    this.lastCompletedDate,
    this.currentStreak = 0,
    this.targetDurationSeconds = 0, // Defaults to 0 (no timer) if not provided!
    int? remainingSeconds = 0,
  }):remainingSeconds = remainingSeconds ?? targetDurationSeconds;

  // --- THE 45-MINUTE FORMATTING MAGIC ---
  String get formattedTimer {
    if (targetDurationSeconds == 0) return ""; // Don't show if no timer is set

    // USE REMAINING SECONDS INSTEAD OF TARGET!
    int hours = remainingSeconds ~/ 3600;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int seconds = remainingSeconds % 60;

    if (targetDurationSeconds < 45 * 60) {
      // Less than 45 mins -> Format as MM:SS (e.g., 15:30)
      String m = minutes.toString().padLeft(2, '0');
      String s = seconds.toString().padLeft(2, '0');
      return "$m:$s";
    } else {
      // 45 mins or more -> Format as HH:MM (e.g., 1h 15m or 1:15)
      String h = hours.toString();
      String m = minutes.toString().padLeft(2, '0');
      return "${h}h ${m}m"; 
    }
  }

  // Pack into a Map (to be turned into JSON)
  Map<String, dynamic> toMap(){
    return{
      'id':id, 'name':name, 'completed':completed,

      // Save Date as an ISO string, or null if never completed
      'lastCompletedDate': lastCompletedDate?.toIso8601String(), 
      'currentStreak': currentStreak,
      'targetDurationSeconds': targetDurationSeconds, // timer
      'remainingSeconds': remainingSeconds, // <--- Save remaining time!
    };
  }

  // Unpack from a Map (coming from JSON)
  factory Habit.fromjson(Map<String, dynamic> json) {
    return Habit(
      id:json['id'], name:json['name'], completed:json['completed'],

      // Parse the String back into a DateTime object safely
      lastCompletedDate: json['lastCompletedDate'] != null 
          ? DateTime.parse(json['lastCompletedDate']) 
          : null,
      currentStreak: json['currentStreak'] ?? 0,

      targetDurationSeconds: json['targetDurationSeconds'] ?? 0,

      remainingSeconds: json['remainingSeconds'], // <--- Load remaining time!
    );
  } 
  
}






