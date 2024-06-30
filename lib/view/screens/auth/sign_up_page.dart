import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sohba/controller/auth_controller.dart';
import 'package:sohba/view/widgets/text_field.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(signUpControllerProvider);
    final signUpController = ref.read(signUpControllerProvider.notifier);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(80.h),
            Center(
              child: Text(
                'إنشاء حساب جديد',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Gap(150.h),
            Column(
              children: [
                SizedBox(
                  height: 50.h,
                  child: MyTextField(
                    controller: signUpController.nameC,
                    labelText: 'الاسم',
                    hintText: "ادخل اسمك",
                  ),
                ),
                Gap(20.h),
                SizedBox(
                  height: 50.h,
                  child: MyTextField(
                    controller: signUpController.phoneC,
                    labelText: ' رقم الهاتف',
                    hintText: "ادخل  رقم الهاتف",
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Gap(20.h),
                SizedBox(
                  height: 50.h,
                  child: MyTextField(
                    controller: signUpController.passwordC,
                    labelText: 'كلمة المرور',
                    hintText: "ادخل كلمة المرور",
                    obscureText: true,
                  ),
                ),
                Gap(150.h),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                        onPressed: () {
                          signUpController.signUp(context);
                        },
                        child: isLoading ? const CircularProgressIndicator() : const Text('انشاء حساب')))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
