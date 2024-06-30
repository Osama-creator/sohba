import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohba/model/user_model.dart';

class UserDataService {
  final SharedPreferences _prefs;
  UserDataService(this._prefs);
  static const String userDataKey = 'userData';

  static Future<void> saveUserDataToLocal(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userDataKey, jsonEncode(userData));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveUserDataToPrefs(Map<String, dynamic> userData) async {
    try {
      await _prefs.setString(
        'userData',
        jsonEncode({
          'name': userData['name'],
          'phone': userData['phone'],
          'avatar': userData['avatar'],
        }),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDataFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearUserDataLocal() async {
    try {
      await _prefs.remove(userDataKey);
      await _prefs.remove('userToken');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserFromLocal() async {
    try {
      final userData = await getUserDataFromLocal();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
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
