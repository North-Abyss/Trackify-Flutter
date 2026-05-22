class Habit {
  final String id;
  String name;
  bool completed;
  DateTime? lastCompletedDate;
  int currentStreak;
  int targetDurationSeconds;
  
  // NEW: Each habit tracks its own cooldown!
  DateTime? cooldownEndTime;

  Habit({
    required this.id,
    required this.name,
    this.completed = false,
    this.lastCompletedDate,
    this.currentStreak = 0,
    this.targetDurationSeconds = 0,
    this.cooldownEndTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'completed': completed,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'targetDurationSeconds': targetDurationSeconds,
      'cooldownEndTime': cooldownEndTime?.toIso8601String(), // Save it!
    };
  }

  factory Habit.fromjson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'], name: json['name'], completed: json['completed'],
      lastCompletedDate: json['lastCompletedDate'] != null ? DateTime.parse(json['lastCompletedDate']) : null,
      currentStreak: json['currentStreak'] ?? 0,
      targetDurationSeconds: json['targetDurationSeconds'] ?? 0,
      cooldownEndTime: json['cooldownEndTime'] != null ? DateTime.parse(json['cooldownEndTime']) : null, // Load it!
    );
  }
}