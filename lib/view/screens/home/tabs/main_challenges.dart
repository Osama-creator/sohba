import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/service/challenge_service.dart';
import 'package:sohba/view/screens/challenge/add_new_challenge.dart';
import 'package:sohba/view/screens/home/tabs/chalenges_tab.dart';

class MainChalengesTab extends ConsumerWidget {
  const MainChalengesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool canAddChallenge = currentUserId == 'wpLUf9jBs7SgyaFDhGAxQExVD4A2';
    final challengesAsyncValue = ref.watch(mainchallengesStreamProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.h),
            Center(
              child: Text(
                "التحديات الكبرى",
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
                      isPrivate: false,
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
      floatingActionButton: canAddChallenge
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddChallengeScreen(
                      isPrivate: false,
                    ),
                  ),
                );
                if (result == true) {
                  ref.refresh(mainchallengesStreamProvider);
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
            )
          : null,
    );
  }
}
