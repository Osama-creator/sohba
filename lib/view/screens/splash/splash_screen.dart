import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/helpers/get_it.dart';
import 'package:sohba/service/local_service.dart';
import 'package:sohba/view/screens/auth/sign_in_page.dart';
import 'package:sohba/view/screens/auth/sign_up_page.dart';
import 'package:sohba/view/screens/home/main_screen.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), checkUserStatus);
  }

  Future<void> checkUserStatus() async {
    final token = await getIt.call<UserDataService>.call().getToken();
    if (token != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/logo.png",
          scale: 1,
        ),
      ),
    );
  }
}
