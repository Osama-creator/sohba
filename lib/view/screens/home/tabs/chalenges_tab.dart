import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/service/challenge_service.dart';
import 'package:sohba/view/screens/challenge/add_new_challenge.dart';
import 'package:sohba/view/screens/challenge/challenge_page.dart';

class ChalengesTab extends ConsumerWidget {
  const ChalengesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsyncValue = ref.watch(challengesStreamProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.h),
            Center(
              child: Text(
                "التحديات",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            challengesAsyncValue.when(
              data: (challenges) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) => ChallengeCard(
                      challenge: challenges[index],
                    ),
                  ),
                );
              },
              error: (error, stackTrace) {
                return Text(error.toString());
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddChallengeScreen(
                isPrivate: true,
              ),
            ),
          );
          if (result == true) {
            ref.refresh(challengesStreamProvider);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        label: Row(
          children: [
            Text(
              "اضافة تحدي",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.white,
                  ),
            ),
            SizedBox(
              width: 5.w,
            ),
            const Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}

class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  final bool isPrivate;
  const ChallengeCard({
    super.key,
    required this.challenge,
    this.isPrivate = true,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  List<String> usersImages = [];

  @override
  void initState() {
    super.initState();
    fetchUserAvatars();
  }

  Future<void> fetchUserAvatars() async {
    List<String> fetchedUsersImages = [];
    for (var friendId in widget.challenge.friendsId) {
      final user = await getUserById(friendId);
      fetchedUsersImages.add(user.avatar);
    }
    setState(() {
      usersImages = fetchedUsersImages;
    });
  }

  Future<FriendModel> getUserById(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return FriendModel.fromJson(userDoc.data() as Map<String, dynamic>, userId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      width: 300.w,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengeDetails(
                challenge: widget.challenge,
                collectionKey: widget.isPrivate ? 'challenges' : 'main_challenges',
              ),
            ),
          );
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: widget.isPrivate ? AppColors.primary : const Color.fromARGB(255, 103, 189, 107))),
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(widget.challenge.name,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.fade),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: widget.isPrivate ? AppColors.primary : const Color.fromARGB(255, 103, 189, 107)),
                        child: Text(
                          'المهام: ${widget.challenge.tasks.length}',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.white,
                                fontSize: 12.sp,
                              ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: widget.isPrivate ? AppColors.primary : const Color.fromARGB(255, 103, 189, 107),
                            size: 15.sp,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'اليوم ${widget.challenge.dayNumber}',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColors.black,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                !widget.isPrivate
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(left: 10.w, top: 50.h),
                        width: 80.w,
                        child: Stack(
                          children: [
                            ...usersImages.take(2).map((image) {
                              int index = usersImages.indexOf(image);
                              return Positioned(
                                left: index * 20.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(image),
                                  radius: 15,
                                  backgroundColor: AppColors.grey,
                                ),
                              );
                            }),
                            if (usersImages.length > 2)
                              Positioned(
                                left: 40.0,
                                child: CircleAvatar(
                                  backgroundColor: AppColors.white,
                                  radius: 15,
                                  child: Text(
                                    '+${usersImages.length - 2}',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
