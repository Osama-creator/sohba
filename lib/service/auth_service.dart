import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/local_service.dart';

abstract class AuthServiceInterface {
  Future<void> signUp(UserModel user);
  Future<UserCredential> signInWithEmailAndPassword(String phone, String password);
  Future<DocumentSnapshot> getUserData(String userToken);
}

class AuthService implements AuthServiceInterface {
  @override
  Future<void> signUp(
    UserModel user,
  ) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: "${user.phone}@gmail.com", password: user.password!);
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(user.toJson());
    await UserDataService.saveUserDataToLocal(user.toJson());
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String phone, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$phone@gmail.com",
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DocumentSnapshot> getUserData(String userToken) async {
    try {
      return await FirebaseFirestore.instance.collection('users').doc(userToken).get();
    } catch (e) {
      rethrow;
    }
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);
