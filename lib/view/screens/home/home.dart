import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/friends_controller.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/friends_service.dart';
import 'package:sohba/view/widgets/text_field.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserSearchPage(),
            ),
          );
        },
        child: Column(children: [
          const SizedBox(
            height: 100,
          ),
          ref.watch(getFriendsProvider).when(
                data: (users) => Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(users[index].name!),
                        )),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
        ]),
      ),
    );
  }
}

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  _UserSearchPageState createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 40.h,
          ),
          SizedBox(
            height: 50.h,
            child: MyTextField(
              hintText: "ابحث عن صديق",
              labelText: "بحث برقم الهاتف",
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
                if (phoneNumber.length == 10) {
                  ref.read(searchUsersProvider(phoneNumber));
                }
              },
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          ref.watch(searchUsersProvider(phoneNumber)).when(
                data: (users) => Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: UserCard(
                        user: users[index],
                      ),
                    ),
                  ),
                ),
                loading: () => phoneNumber.length == 10 ? const CircularProgressIndicator() : const SizedBox(),
                error: (error, stack) => Text('Error: $error'),
              ),
        ],
      ),
    );
  }
}

class UserCard extends ConsumerWidget {
  final FriendModel user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.white,
      elevation: 15.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: ListTile(
        title: Text(user.name!),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        leading: CircleAvatar(
          backgroundColor: AppColors.black,
          backgroundImage: NetworkImage(user.avatar ??
              'https://th.bing.com/th/id/R.3cc84035a9f175d38139b718c5c60e73?rik=1hEla21le%2f2Zhw&riu=http%3a%2f%2fwww.pngall.com%2fwp-content%2fuploads%2f5%2fProfile-PNG-Free-Download.png&ehk=KTE%2bcnU8tbMRQTVE9RJUoH59ReP%2bgFtzIpw%2bNRRXN1s%3d&risl=&pid=ImgRaw&r=0'),
        ),
        trailing: IconButton(
          onPressed: () {
            ref.read(friendsServiceProvider).addFriend(user.id);
            ref.read(getFriendsProvider);
            Navigator.pop(context);
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح')));
          },
          icon: Icon(
            Icons.person_add_alt_1,
            color: AppColors.primary,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
}
