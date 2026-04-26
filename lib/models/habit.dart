// lib/models/habit.dart

class Habit {
  final String id;
  final String name;
  bool completed;

  Habit({
    required this.id,
    required this.name,
    this.completed = false, // Defaults to false if not provided!
  });

  // Pack into a Map (to be turned into JSON)
  Map<String, dynamic> toMap(){
    return{
      'id':id, 'name':name, 'completed':completed
    };
  }

  // Unpack from a Map (coming from JSON)
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id:json['id'], name:json['name'], completed:json['completed'],
    );
  } 
  
}






