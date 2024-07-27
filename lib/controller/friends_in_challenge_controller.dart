import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/model/task.dart';

class FriendInChallengeController {
  Future<void> showCompletedUsersBottomSheet(BuildContext context, List<String> completedUserIds) async {
    final userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: completedUserIds)
        .get();
    final users = userDocs.docs.map((doc) => FriendModel.fromJson(doc.data(), doc.id)).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300.h,
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: users[index].avatar != null ? NetworkImage(users[index].avatar) : null,
                      child: users[index].avatar == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(users[index].name),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showFirstUsersBottomSheet(BuildContext context, List<FriendsCount> friends) async {
    List<Map<String, dynamic>> users = [];
    for (var friend in friends) {
      final user = await getUserById(friend.id);
      users.add({
        'user': user,
        'taskCount': friend.count,
      });
    }

    users.sort((a, b) => b['taskCount'].compareTo(a['taskCount']));

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300.h,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index]['user'];
              final taskCount = users[index]['taskCount'];

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatar ?? ''),
                    ),
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.black),
                    ),
                    trailing: Text(
                      'النقاط : ${taskCount.toString()}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<FriendModel> getUserById(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return FriendModel.fromJson(userDoc.data() as Map<String, dynamic>, userId);
  }
}
