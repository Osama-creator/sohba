import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sohba/model/friend_model.dart';

abstract class FriendsServiceInterface {
  Future<List<FriendModel>> getFriends();
  Future<void> addFriend(String friendId);
  Future<List<FriendModel>> searchUsers(String phone);
}

class FriendsService implements FriendsServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<FriendModel> _friendsBox = Hive.box<FriendModel>('friends');

  @override
  Future<void> addFriend(String friendId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _firestore.collection('users').doc(currentUserId).collection('friends').doc(friendId).set({});
    // Refresh the cache after adding a friend
    await _refreshCache();
  }

  @override
  Future<List<FriendModel>> getFriends() async {
    if (_friendsBox.isNotEmpty) {
      return _friendsBox.values.toList();
    } else {
      return await _refreshCache();
    }
  }

  @override
  Future<List<FriendModel>> searchUsers(String phone) async {
    Query query = _firestore.collection('users').where('phone', isEqualTo: phone);
    return (await query.get())
        .docs
        .map((doc) => FriendModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<FriendModel>> _refreshCache() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    List<String> friendIds = (await _firestore.collection('users').doc(currentUserId).collection('friends').get())
        .docs
        .map((doc) => doc.id)
        .toList();

    List<FriendModel> friends = await Future.wait(
      friendIds.map((friendId) async {
        DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
        FriendModel friend = FriendModel.fromJson(friendDoc.data() as Map<String, dynamic>, friendId);
        return friend;
      }),
    );

    _friendsBox.clear();
    _friendsBox.addAll(friends);
    return friends;
  }
}

final friendsServiceProvider = Provider<FriendsService>(
  (ref) => FriendsService(),
);
