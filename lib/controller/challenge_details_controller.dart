import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/view/screens/challenge/add_friends_to_challenge.dart';

class ChallengeDetailsController {
  Stream<DocumentSnapshot> getChallengeStream(String collectionKey, String challengeId) {
    return FirebaseFirestore.instance.collection(collectionKey).doc(challengeId).snapshots();
  }

  Future<void> updateChallengeDay(String challengeId, String collectionKey, WidgetRef ref) async {
    await ref.read(challengeNotifierProvider.notifier).updateChallengeDay(challengeId, collectionKey);
  }

  Future<void> checkTask(WidgetRef ref, String challengeId, String taskId, String collectionKey) async {
    await ref.read(challengeNotifierProvider.notifier).checkTask(challengeId, taskId, collectionKey);
  }

  Future<void> showAddAndUpdateTaskDialog(
      BuildContext context, WidgetRef ref, String challengeId, bool isUpdated, Task? task, String collectionKey) async {
    final taskNameController = TextEditingController();
    if (isUpdated) {
      taskNameController.text = task!.name;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isUpdated ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
          content: TextField(
            controller: taskNameController,
            decoration: const InputDecoration(hintText: "إسم المهمة"),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('تم'),
              onPressed: () async {
                var newTask = Task(
                  id: isUpdated ? task!.id : DateTime.now().toIso8601String(),
                  name: taskNameController.text,
                  friendsId: isUpdated ? task!.friendsId : [],
                  friendsCountList: isUpdated ? task!.friendsCountList : [],
                );
                if (isUpdated) {
                  await ref.read(challengeNotifierProvider.notifier).updateTask(challengeId, newTask, collectionKey);
                } else {
                  await ref
                      .read(challengeNotifierProvider.notifier)
                      .addTaskToChallenge(challengeId, newTask, collectionKey);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTaskConfirmation(
      BuildContext context, WidgetRef ref, String challengeId, String taskId, String collectionKey) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد حذف المهمة'),
          content: const Text('هل أنت متأكد من حذف المهمة؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () async {
                await ref.read(challengeNotifierProvider.notifier).deleteTask(challengeId, taskId, collectionKey);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addFriends(BuildContext context, WidgetRef ref, Challenge challenge, String collectionKey) async {
    final selectedFriends = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectFriendsScreen(
          preSelectedFriendIds: challenge.friendsId,
        ),
      ),
    );

    if (selectedFriends != null) {
      for (var friendId in selectedFriends) {
        ref.read(challengeNotifierProvider.notifier).addMemberToChallenge(challenge.id, friendId);
      }
    }
  }

  Future<void> removeChallenge(BuildContext context, WidgetRef ref, String challengeId, String collectionKey) async {
    await ref.read(challengeNotifierProvider.notifier).removeChallengeFromAll(challengeId, collectionKey);
    Navigator.of(context).pop();
  }

  Future<void> leaveChallenge(BuildContext context, WidgetRef ref, String challengeId) async {
    await ref.read(challengeNotifierProvider.notifier).leaveChallenge(challengeId);
    Navigator.of(context).pop();
  }
}
