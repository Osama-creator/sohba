import 'package:hive/hive.dart';

part 'friend_model.g.dart';

@HiveType(typeId: 0)
class FriendModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;
  @HiveField(3)
  String avatar;
  FriendModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatar,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json, String id) {
    return FriendModel(
      id: id,
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'name': name,
      'phone': phone,
    };
  }
}
