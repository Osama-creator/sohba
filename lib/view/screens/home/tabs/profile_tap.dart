import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/auth_controller.dart';
import 'package:sohba/service/auth_service.dart';
import 'package:sohba/view/screens/auth/sign_in_page.dart';
import 'package:sohba/view/screens/friends/friends_tab.dart';

class SettingTab extends ConsumerWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 40.h,
              ),
              userAsyncValue.when(
                data: (user) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 5.w,
                      ),
                      CircleAvatar(
                        radius: 40.h,
                        backgroundImage: NetworkImage(user.avatar),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 22.0.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.phone,
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text(error.toString()),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                child: const Divider(
                  thickness: 1,
                ),
              ),
              const SettingListTile(
                title: "تعديل الحساب",
                icon: Icons.account_circle,
              ),
              SizedBox(
                height: 15.h,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FriendsTab(),
                    ),
                  );
                },
                child: const SettingListTile(
                  title: "الأصدقاء",
                  icon: Icons.people,
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              GestureDetector(
                onTap: () {
                  ref.read(authServiceProvider).logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                },
                child: const SettingListTile(
                  title: "تسجيل الخروج",
                  icon: Icons.logout,
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              const SettingListTile(
                title: "اللغة",
                icon: Icons.language,
              ),
              SizedBox(
                height: 15.h,
              ),
              const SettingListTile(
                title: "الوضع",
                icon: Icons.dark_mode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const SettingListTile({
    super.key,
    required this.icon,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 10.w,
        ),
        Icon(
          icon,
          //
          size: 30.w,
          color: AppColors.primary,
        ),
        SizedBox(
          width: 15.w,
        ),
        Text(
          title,
          //
        ),
      ],
    );
  }
}
