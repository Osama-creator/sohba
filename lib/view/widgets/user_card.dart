import 'package:flutter/material.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/model/friend_model.dart';

class UserCard extends StatelessWidget {
  final FriendModel user;
  final VoidCallback onAddFriend;

  const UserCard({required this.user, required this.onAddFriend, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 10,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
        ),
        title: Text(user.name),
        trailing: IconButton(
          icon: const Icon(Icons.person_add, color: AppColors.primary),
          onPressed: onAddFriend,
        ),
      ),
    );
  }
}
