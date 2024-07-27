import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/auth_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:developer';

import 'package:sohba/view/screens/home/main_screen.dart';

final userProvider = FutureProvider<FriendModel>(
  (
    ref,
  ) =>
      ref.read(authServiceProvider).getUserData(),
);

class SignUpController extends StateNotifier<bool> {
  final AuthServiceInterface authService;
  SignUpController(this.authService) : super(false);

  TextEditingController nameC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  File? profileImage;

  Future<String?> uploadProfileImage(File image) async {
    try {
      final cloudinary = CloudinaryPublic('dbljrmkwy', 'eiv574ou', cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      log(e.message.toString());
      log(e.request.toString());
    }
    return null;
  }

  Future<void> signUp(BuildContext context) async {
    if (!_validateInputs(context)) return;

    try {
      state = true; // isLoading
      String? prfImage;
      if (profileImage != null) {
        prfImage = await uploadProfileImage(profileImage!);
      }

      UserModel user = UserModel(
        name: nameC.text.trim(),
        phone: phoneC.text.trim(),
        password: passwordC.text.trim(),
        avatar: prfImage ??
            'https://th.bing.com/th/id/R.6e78774c2c47f39ff8d382296ba995b6?rik=ZstKOqQ1vskzBw&pid=ImgRaw&r=0',
      );

      await authService.signUp(user);
      state = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      state = false; // isLoading
      _handleFirebaseAuthException(e, context);
    } catch (e) {
      state = false; // isLoading
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ : ${e.toString()}')));
    }
  }

  Future<void> login(BuildContext context) async {
    if (!_validateInputsLogin(context)) return;

    try {
      state = true; // isLoading

      await authService.signInWithEmailAndPassword(phoneC.text.trim(), passwordC.text.trim());
      state = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } catch (e) {
      state = false; // isLoading
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ : ${e.toString()}')));
    }
  }

  bool _validateInputs(BuildContext context) {
    if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty || passwordC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return false;
    } else if (passwordC.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمه السر ضعيفه')));
      return false;
      // } else if (phoneC.text[0] != '0' || phoneC.text[1] != '1' || phoneC.text.length != 11) {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير صحيح')));
      //   return false;
    }
    return true;
  }

  bool _validateInputsLogin(BuildContext context) {
    if (phoneC.text.trim().isEmpty || passwordC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return false;
    }
    return true;
  }

  void _handleFirebaseAuthException(FirebaseAuthException e, BuildContext context) {
    if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا الحساب موجود بالفعل')));
    } else {}
  }

  void forgetPass(BuildContext context) async {
    try {
      if (phoneC.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة رقم الهاتف')));
      } else {
        await authService.getPassword(phoneC.text.trim());
      }
    } catch (e) {
      log(e.toString());
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, bool>((ref) {
  final authService = ref.read(authServiceProvider);
  return SignUpController(authService);
});
