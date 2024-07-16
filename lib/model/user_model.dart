class UserModel {
  String? phone;
  String? name;
  String? avatar;
  String? password;

  UserModel({this.phone, this.name, this.avatar, this.password});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phone: json['phone'],
      name: json['name'],
      avatar: json['avatar'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'name': name, 'avatar': avatar, 'password': password};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          name == other.name &&
          avatar == other.avatar &&
          password == other.password;

  @override
  int get hashCode => phone.hashCode ^ name.hashCode ^ avatar.hashCode ^ password.hashCode;
}

// class FriendModel extends UserModel {
//   final String id;

//   FriendModel({
//     required this.id,
//     super.phone,
//     super.name,
//     super.avatar,
//     super.password,
//   }) : super();

//   factory FriendModel.fromJson(Map<String, dynamic> json, String id) {
//     return FriendModel(
//       id: id,
//       phone: json['phone'],
//       name: json['name'],
//       avatar: json['avatar'],
//       password: json['password'],
//     );
//   }

//   @override
//   int get hashCode => id.hashCode ^ super.hashCode;
// }
