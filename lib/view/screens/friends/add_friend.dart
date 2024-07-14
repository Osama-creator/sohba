import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/controller/friends_controller.dart';
import 'package:sohba/service/friends_service.dart';
import 'package:sohba/view/widgets/text_field.dart';
import 'package:sohba/view/widgets/user_card.dart';

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
          Text(
            "ابحث عن صديق",
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          SizedBox(
            height: 50.h,
            child: MyTextField(
              hintText: "ابحث عن صديق",
              labelText: "بحث برقم الهاتف",
              keyboardType: TextInputType.number,
              maxLength: 11,
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
                        onAddFriend: () {
                          ref.read(friendsServiceProvider).addFriend(users[index].id);
                          Navigator.of(context).pop(true);
                        },
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
