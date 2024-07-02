import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/auth_service.dart';
import 'package:sohba/view/screens/home/home.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:developer';

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
        avatar: prfImage,
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

  void _handleFirebaseAuthException(FirebaseAuthException e, BuildContext context) {
    if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا الحساب موجود بالفعل')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ : ${e.message}')));
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, bool>((ref) {
  final authService = ref.read(authServiceProvider);
  return SignUpController(authService);
});
