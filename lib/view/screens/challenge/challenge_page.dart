// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/model/task.dart';
import 'package:sohba/view/screens/challenge/add_friends_to_challenge.dart';

class ChallengeDetails extends ConsumerStatefulWidget {
  const ChallengeDetails({super.key, required this.challenge});
  final Challenge challenge;

  @override
  _ChallengeDetailsState createState() => _ChallengeDetailsState();
}

class _ChallengeDetailsState extends ConsumerState<ChallengeDetails> {
  late Stream<DocumentSnapshot> _challengeStream;
  // late Challenge _currentChallenge;
  final String _challengeName = '';

  @override
  void initState() {
    super.initState();
    _challengeStream = FirebaseFirestore.instance.collection('challenges').doc(widget.challenge.id).snapshots();
    // Call updateChallengeDay when the screen is first opened
    updateChallengeDay(widget.challenge.id);
  }

  Future<void> updateChallengeDay(String challengeId) async {
    await ref.read(challengeNotifierProvider.notifier).updateChallengeDay(challengeId);
  }

  void _showCompletedUsersBottomSheet(BuildContext context, List<String> completedUserIds) async {
    final userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: completedUserIds)
        .get();

    final userNames = userDocs.docs.map((doc) => doc.data()['name']).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300.h,
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: userNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(userNames[index]),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: taskNameController,
            decoration: const InputDecoration(hintText: "Task Name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                var task = Task(
                  id: DateTime.now().toIso8601String(),
                  name: taskNameController.text,
                  friendsId: [],
                  friendsCountList: [],
                );
                await ref.read(challengeNotifierProvider.notifier).addTaskToChallenge(widget.challenge.id, task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTaskConfirmation(
    BuildContext context,
    Task task,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد حذف المهمة'),
          content: Text('هل أنت متأكد من حذف المهمة  ${task.name}؟'),
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
                await ref.read(challengeNotifierProvider.notifier).deleteTask(widget.challenge.id, task.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addFriends(BuildContext context) async {
    final selectedFriends = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectFriendsScreen(
          preSelectedFriendIds: widget.challenge.friendsId,
        ),
      ),
    );

    if (selectedFriends != null) {
      for (var friendId in selectedFriends) {
        ref.read(challengeNotifierProvider.notifier).addMemberToChallenge(widget.challenge.id, friendId);
      }
    }
  }

  void _handleMenuOption(String option) {
    if (option == 'إضافة صديق') {
      addFriends(context);
    } else if (option == 'إضافة مهمة') {
      _showAddTaskDialog(context);
    } else if (option == 'حذف التحدي') {
      ref.read(challengeNotifierProvider.notifier).removeChallengeFromAll(widget.challenge.id);
      Navigator.of(context).pop();
    } else if (option == 'الخروج من التحدي') {
      ref.read(challengeNotifierProvider.notifier).leaveChallenge(widget.challenge.id);
      Navigator.of(context).pop();
    }
  }

  void _showFirstUsersBottomSheet(
    BuildContext context,
    List<FriendsCount> friends,
  ) async {
    List<Map<String, dynamic>> users = [];

    for (var friend in friends) {
      final user = await getUserById(friend.id);
      users.add({
        'user': user,
        'taskCount': friend.count,
      });
    }

    // Sort users by task count in descending order
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

              return ListTile(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _challengeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Challenge not found'));
          }

          final currentChallenge = Challenge.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          final isAdmin = currentChallenge.adminId == FirebaseAuth.instance.currentUser?.uid;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80.h,
                decoration: const BoxDecoration(color: AppColors.primary),
                padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      currentChallenge.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold, color: AppColors.white, fontSize: 16.sp),
                    ),
                    PopupMenuButton<String>(
                      onSelected: _handleMenuOption,
                      iconSize: 25.sp,
                      iconColor: AppColors.white,
                      itemBuilder: (BuildContext context) {
                        return <String>[
                          if (isAdmin) 'إضافة صديق',
                          if (isAdmin) 'إضافة مهمة',
                          if (isAdmin) 'حذف التحدي',
                          if (!isAdmin) 'الخروج من التحدي'
                        ].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'اليوم ${currentChallenge.dayNumber} من التحدي',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'اليوم: ${DateFormat.yMd().format(currentChallenge.today)}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: currentChallenge.tasks.length,
                  itemBuilder: (context, index) {
                    final task = currentChallenge.tasks[index];
                    bool isChecked = task.friendsId.contains(FirebaseAuth.instance.currentUser?.uid);
                    final friendsCompleted = task.friendsId.length;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0.h,
                        horizontal: 8.0.w,
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.primary)),
                        color: AppColors.white,
                        child: ListTile(
                          leading: Checkbox(
                            value: isChecked,
                            activeColor: AppColors.primary,
                            onChanged: (bool? value) async {
                              if (value != null) {
                                await ref
                                    .read(challengeNotifierProvider.notifier)
                                    .checkTask(currentChallenge.id, task.id);
                              }
                            },
                          ),
                          title: Text(
                            task.name,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showFirstUsersBottomSheet(context, task.friendsCountList),
                                icon: const Icon(Icons.leaderboard_rounded, color: AppColors.black),
                              ),
                              if (isAdmin)
                                IconButton(
                                  onPressed: () async {
                                    _deleteTaskConfirmation(context, task);
                                  },
                                  icon: const Icon(Icons.delete, color: AppColors.red),
                                )
                            ],
                          ),
                          subtitle: GestureDetector(
                            onTap: () => _showCompletedUsersBottomSheet(context, task.friendsId),
                            child: Text(
                              'أنهى المهمه   :  $friendsCompleted ',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(color: Colors.grey, fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
