import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/auth_controller.dart';
import 'package:sohba/view/screens/auth/sign_up_page.dart';
import 'package:sohba/view/widgets/text_field.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(signUpControllerProvider);
    final signUpController = ref.read(signUpControllerProvider.notifier);

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        Gap(50.h),
        Center(
          child: Text(
            'تسجيل الدخول',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Gap(200.h),
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
        Gap(50.h),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
                onPressed: () {
                  signUpController.login(context);
                },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 3,
                      )
                    : const Text('تسجيل الدخول'))),
        Gap(50.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ليس لديك حساب؟ ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                },
                child: Text(
                  'انشاء حساب',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.primary),
                ))
          ],
        ),
      ]),
    ));
  }
}
