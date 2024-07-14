import 'package:flutter/material.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/model/user_model.dart';

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
          backgroundImage: NetworkImage(user.avatar ??
              'https://www.google.com/imgres?q=profile%20image&imgurl=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F005%2F544%2F718%2Fnon_2x%2Fprofile-icon-design-free-vector.jpg&imgrefurl=https%3A%2F%2Fwww.vecteezy.com%2Ffree-vector%2Fprofile-icon&docid=RBpRIqik_jZCqM&tbnid=_5mhIFxchtSFMM&vet=12ahUKEwj3_6bUoaeHAxWkUaQEHbPUAU8QM3oECBwQAA..i&w=980&h=980&hcb=2&ved=2ahUKEwj3_6bUoaeHAxWkUaQEHbPUAU8QM3oECBwQAA'),
        ),
        title: Text(user.name!),
        trailing: IconButton(
          icon: const Icon(Icons.person_add, color: AppColors.primary),
          onPressed: onAddFriend,
        ),
      ),
    );
  }
}
