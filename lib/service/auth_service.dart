import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/local_service.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';

abstract class AuthServiceInterface {
  Future<void> signUp(UserModel user);
  Future<void> signInWithEmailAndPassword(String phone, String password);
  Future<FriendModel> getUserData();
  Future<void> getPassword(String phone);
}

class AuthService implements AuthServiceInterface {
  @override
  Future<void> signUp(
    UserModel user,
  ) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: "${user.phone}@gmail.com", password: user.password!);
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(user.toJson());
    String? token = await userCredential.user?.getIdToken();
    if (token != null) {
      UserDataService.saveUserToken(token);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String phone, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$phone@gmail.com",
        password: password,
      );
      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        UserDataService.saveUserToken(token);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FriendModel> getUserData() async {
    try {
      String id = FirebaseAuth.instance.currentUser?.uid ?? '';
      var data = await FirebaseFirestore.instance.collection('users').doc(id).get();
      return FriendModel.fromJson(data.data() as Map<String, dynamic>, id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    UserDataService.clearUserDataLocal();
  }

  @override
  Future<void> getPassword(String phone) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone).get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs.first;
      var password = userDoc.data()['password'];

      await WhatsAppSenderFlutter.send(
        phones: ["+2$phone"],
        message: "Your password is: $password",
      );
    } else {
      log('Phone number not found');
    }
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);
