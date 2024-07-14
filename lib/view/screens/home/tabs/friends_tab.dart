import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/friends_controller.dart';
import 'package:sohba/view/screens/friends/add_friend.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30.h,
          ),
          Center(
            child: Text(
              "الأصدقاء",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
          ref.watch(getFriendsProvider).when(
                data: (users) => Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.black,
                            backgroundImage: NetworkImage(users[index].avatar ??
                                'https://www.google.com/imgres?q=profile%20image&imgurl=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F005%2F544%2F718%2Fnon_2x%2Fprofile-icon-design-free-vector.jpg&imgrefurl=https%3A%2F%2Fwww.vecteezy.com%2Ffree-vector%2Fprofile-icon&docid=RBpRIqik_jZCqM&tbnid=_5mhIFxchtSFMM&vet=12ahUKEwj3_6bUoaeHAxWkUaQEHbPUAU8QM3oECBwQAA..i&w=980&h=980&hcb=2&ved=2ahUKEwj3_6bUoaeHAxWkUaQEHbPUAU8QM3oECBwQAA'),
                          ),
                          title: Text(users[index].name!),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserSearchPage(),
            ),
          );
          if (result == true) {
            ref.refresh(getFriendsProvider);
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        label: Row(
          children: [
            Text(
              "اضافة صديق",
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
