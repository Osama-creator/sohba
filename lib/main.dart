import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sohba/config/theme/light_theme.dart';
import 'package:sohba/helpers/get_it.dart';
import 'package:sohba/view/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setup();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // final sStorage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: "صحبة",
          locale: const Locale('ar'),
          theme: getThemDataLight(),
          debugShowCheckedModeBanner: false,
          home: const SplashPage(),
        );
      },
    );
  }
}
