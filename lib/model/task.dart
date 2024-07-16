class Task {
  String id; // Added id field
  String name;
  List<String> friendsId;
  List<FriendsCount> friendsCountList;

  Task({
    required this.id, // Added id parameter to constructor
    required this.name,
    required this.friendsId,
    required this.friendsCountList,
  });

  // From JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'], // Assign id from JSON
      name: json['name'],
      friendsId: List<String>.from(json['friendsId']),
      friendsCountList: (json['friendsCountList'] as List).map((item) => FriendsCount.fromJson(item)).toList(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in JSON
      'name': name,
      'friendsId': friendsId,
      'friendsCountList': friendsCountList.map((item) => item.toJson()).toList(),
    };
  }
}

class FriendsCount {
  String id;
  int count;

  FriendsCount({
    required this.id,
    required this.count,
  });

  // From JSON
  factory FriendsCount.fromJson(Map<String, dynamic> json) {
    return FriendsCount(
      id: json['id'],
      count: json['count'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
    };
  }
}
