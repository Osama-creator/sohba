import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohba/model/user_model.dart';

class UserDataService {
  final SharedPreferences _prefs;
  UserDataService(this._prefs);

  static const String userDataKey = 'token';

  static Future<void> saveUserToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userDataKey, token);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(userDataKey);
      if (userDataString != null) {
        return userDataString;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearUserDataLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userDataKey);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(String userEmail) async {
    try {
      // Update user data in Firestore
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).get();
      if (userSnapshot.size == 0) {
        throw Exception("User data not found in Firestore");
      }
      // Update user data in SharedPreferences
      final userDoc = userSnapshot.docs.first;
      await _prefs.setString('userData', jsonEncode(userDoc.data()));
    } catch (e) {
      rethrow;
    }
  }
}
