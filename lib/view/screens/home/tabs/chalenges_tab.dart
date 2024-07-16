import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/view/screens/challenge/add_new_challenge.dart';

class ChalengesTab extends ConsumerWidget {
  const ChalengesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final challengesController = ref.watch(challengeNotifierProvider);
    final data = ref.watch(getChallengesProvider);
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
            data.when(
              data: (data) {
                return Expanded(
                    child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => ChallengeCard(
                    challenge: data[index],
                  ),
                ));
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
              builder: (context) => const AddChallengeScreen(),
            ),
          );
          if (result == true) {
            ref.refresh(getChallengesProvider);
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

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  const ChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 300.w,
      child: Card(
        elevation: 10,
        color: AppColors.primary,
        child: Column(
          children: [
            Text(
              challenge.name,
              style:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              challenge.friendsId.length.toString(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.white, fontSize: 16.sp),
            ),
            Text(
              ' يوم 40',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.white, fontSize: 16.sp),
            )
          ],
        ),
      ),
    );
  }
}
