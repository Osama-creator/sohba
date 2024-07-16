import 'package:sohba/model/task.dart';

class Challenge {
  String id;
  String adminId;
  String name;
  DateTime endDate;
  DateTime today;
  List<Task> tasks;
  List<String> friendsId;

  Challenge({
    required this.name,
    required this.id,
    required this.adminId,
    required this.endDate,
    required this.today,
    required this.tasks,
    required this.friendsId,
  });

  // From JSON
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      name: json['name'],
      id: json['id'],
      adminId: json['adminId'],
      endDate: DateTime.parse(json['endDate']),
      today: DateTime.parse(json['today']),
      tasks: (json['tasks'] as List).map((taskJson) => Task.fromJson(taskJson)).toList(),
      friendsId: List<String>.from(json['friendsId']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'adminId': adminId,
      'endDate': endDate.toIso8601String(),
      'today': today.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'friendsId': friendsId,
    };
  }
}
