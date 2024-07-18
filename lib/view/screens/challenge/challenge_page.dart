import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/model/challenge.dart';

class ChallengeDetails extends ConsumerStatefulWidget {
  const ChallengeDetails({super.key, required this.challengeId});
  final String challengeId;

  @override
  _ChallengeDetailsState createState() => _ChallengeDetailsState();
}

class _ChallengeDetailsState extends ConsumerState<ChallengeDetails> {
  late Stream<DocumentSnapshot> _challengeStream;
  late Challenge _currentChallenge;

  @override
  void initState() {
    super.initState();
    _challengeStream = FirebaseFirestore.instance.collection('challenges').doc(widget.challengeId).snapshots();

    // Call updateChallengeDay when the screen is first opened
    updateChallengeDay(widget.challengeId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _challengeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Challenge not found'));
            }

            _currentChallenge = Challenge.fromJson(snapshot.data!.data() as Map<String, dynamic>);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text(
                  _currentChallenge.name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'اليوم ${_currentChallenge.dayNumber} من التحدي',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'اليوم: ${DateFormat.yMMMd().format(_currentChallenge.today)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _currentChallenge.tasks.length,
                    itemBuilder: (context, index) {
                      final task = _currentChallenge.tasks[index];
                      bool isChecked = task.friendsId.contains(FirebaseAuth.instance.currentUser?.uid);
                      final friendsCompleted = task.friendsId.length;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0.h),
                        child: Card(
                          color: AppColors.white,
                          elevation: 10,
                          child: ListTile(
                            leading: Checkbox(
                              value: isChecked,
                              activeColor: AppColors.primary,
                              onChanged: (bool? value) async {
                                if (value != null) {
                                  await ref
                                      .read(challengeNotifierProvider.notifier)
                                      .checkTask(_currentChallenge.id, task.id);
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
      ),
    );
  }
}
