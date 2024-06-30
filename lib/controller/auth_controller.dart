// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/auth_service.dart';
import 'package:sohba/view/screens/home/home.dart';

class SignUpController extends StateNotifier<bool> {
  final AuthServiceInterface authService;
  SignUpController(this.authService) : super(false);

  TextEditingController nameC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  Future<void> signUp(BuildContext context) async {
    if (!_validateInputs(context)) return;

    try {
      state = true; // isLoading
      UserModel user = UserModel(
        name: nameC.text.trim(),
        phone: phoneC.text.trim(),
        password: passwordC.text.trim(),
      );
      await authService.signUp(user);
      state = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
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

  bool _validateInputs(BuildContext context) {
    if (nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب ادخال الاسم')));
      return false;
    }
    if (phoneC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب ادخال رقم الهاتف')));
      return false;
    }
    if (passwordC.text.trim().isEmpty || passwordC.text.trim().length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('يجب ادخال كلمه السر ويجب ان تكون اكثر من 6 حروف')));
      return false;
    }
    return true;
  }

  void _handleFirebaseAuthException(FirebaseAuthException e, BuildContext context) {
    String message;
    if (e.code == 'weak-password') {
      message = 'كلمه السر ضعيفه';
    } else if (e.code == 'email-already-in-use') {
      message = 'هذا الحساب موجود بالفعل';
    } else {
      message = 'An error occurred: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, bool>((ref) {
  final authService = ref.read(authServiceProvider);
  return SignUpController(authService);
});
