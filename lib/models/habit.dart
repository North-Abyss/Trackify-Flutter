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
  });

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
    );
  }
}