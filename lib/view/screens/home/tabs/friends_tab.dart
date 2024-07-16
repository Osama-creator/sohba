import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/friends_controller.dart';
import 'package:sohba/view/screens/friends/add_friend.dart';

class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  @override
  void initState() {
    super.initState();
    ref.read(friendsNotifierProvider.notifier).loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsNotifierProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 30.h),
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
          friendsState.when(
            data: (users) => Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.black,
                        backgroundImage: NetworkImage(users[index].avatar),
                      ),
                      title: Text(users[index].name),
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
            ref.read(friendsNotifierProvider.notifier).loadFriends(forceRefresh: true);
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
            SizedBox(width: 5.w),
            const Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}
