import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/challenge_details_controller.dart';
import 'package:sohba/controller/friends_in_challenge_controller.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

class ChallengeDetails extends ConsumerStatefulWidget {
  const ChallengeDetails({
    super.key,
    required this.challenge,
    required this.collectionKey,
  });
  final Challenge challenge;
  final String collectionKey;

  @override
  _ChallengeDetailsState createState() => _ChallengeDetailsState();
}

class _ChallengeDetailsState extends ConsumerState<ChallengeDetails> {
  late Stream<DocumentSnapshot> _challengeStream;
  final ChallengeDetailsController _challengeService = ChallengeDetailsController();
  final FriendInChallengeController _friendService = FriendInChallengeController();

  @override
  void initState() {
    super.initState();
    _challengeStream = _challengeService.getChallengeStream(widget.collectionKey, widget.challenge.id);
    _challengeService.updateChallengeDay(widget.challenge.id, widget.collectionKey, ref);
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
              _buildHeader(context, currentChallenge, isAdmin),
              const SizedBox(height: 10),
              _buildChallengeInfo(context, currentChallenge),
              const SizedBox(height: 20),
              _buildTaskList(context, currentChallenge, isAdmin),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Challenge currentChallenge, bool isAdmin) {
    return Container(
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
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 16.sp,
                ),
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
                if (!isAdmin || widget.collectionKey != 'main_challenges') 'الخروج من التحدي',
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
    );
  }

  Widget _buildChallengeInfo(BuildContext context, Challenge currentChallenge) {
    return Column(
      children: [
        Text(
          'اليوم ${currentChallenge.dayNumber} من التحدي',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'اليوم: ${DateFormat.yMd().format(currentChallenge.today)}',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, Challenge currentChallenge, bool isAdmin) {
    return Expanded(
      child: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          setState(() {
            final item = currentChallenge.tasks.removeAt(oldIndex);
            currentChallenge.tasks.insert(newIndex, item);
          });
        },
        children: [
          for (int index = 0; index < currentChallenge.tasks.length; index++)
            _buildTaskItem(context, currentChallenge, currentChallenge.tasks[index], index, isAdmin),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Challenge currentChallenge, Task task, int index, bool isAdmin) {
    final isChecked = task.friendsId.contains(FirebaseAuth.instance.currentUser?.uid);
    final friendsCompleted = task.friendsId.length;

    return Padding(
      key: ValueKey(task.id),
      padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 8.0.w),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.primary),
        ),
        color: AppColors.white,
        child: ListTile(
          leading: Checkbox(
            value: isChecked,
            activeColor: AppColors.primary,
            onChanged: (bool? value) async {
              if (value != null) {
                await _challengeService.checkTask(
                  ref,
                  currentChallenge.id,
                  task.id,
                  widget.collectionKey,
                );
              }
            },
          ),
          title: Text(
            task.name,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _friendService.showFirstUsersBottomSheet(context, task.friendsCountList),
                icon: const Icon(Icons.leaderboard_rounded, color: AppColors.black),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    _handleMenuOptionForTasks(value, task);
                  },
                  iconSize: 25.sp,
                  iconColor: AppColors.black,
                  itemBuilder: (BuildContext context) {
                    return <String>[
                      'تعديل',
                      'حذف',
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
          subtitle: GestureDetector(
            onTap: () => _friendService.showCompletedUsersBottomSheet(context, task.friendsId),
            child: Text(
              'أنهى المهمه  :  $friendsCompleted ',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: friendsCompleted == 0 ? Colors.grey : AppColors.black,
                    fontSize: 12.sp,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuOption(String option) {
    if (option == 'إضافة صديق') {
      _challengeService.addFriends(context, ref, widget.challenge, widget.collectionKey);
    } else if (option == 'إضافة مهمة') {
      _challengeService.showAddAndUpdateTaskDialog(
          context, ref, widget.challenge.id, false, null, widget.collectionKey);
    } else if (option == 'حذف التحدي') {
      _challengeService.removeChallenge(context, ref, widget.challenge.id, widget.collectionKey);
    } else if (option == 'الخروج من التحدي') {
      _challengeService.leaveChallenge(context, ref, widget.challenge.id);
    }
  }

  void _handleMenuOptionForTasks(String option, Task task) {
    if (option == 'حذف') {
      _challengeService.deleteTaskConfirmation(context, ref, widget.challenge.id, task.id, widget.collectionKey);
    } else {
      _challengeService.showAddAndUpdateTaskDialog(context, ref, widget.challenge.id, true, task, widget.collectionKey);
    }
  }
}
