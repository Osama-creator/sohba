import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/user_model.dart';

abstract class FriendsServiceInterface {
  Future<List<FriendModel>> getFriends();
  Future<void> addFriend(String friendId);
  Future<List<FriendModel>> searchUsers(String phone);
}

class FriendsService implements FriendsServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addFriend(String friendId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _firestore.collection('users').doc(currentUserId).collection('friends').doc(friendId).set({});
  }

  @override
  Future<List<FriendModel>> getFriends() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    List<String> friendIds = (await _firestore.collection('users').doc(currentUserId).collection('friends').get())
        .docs
        .map((doc) => doc.id)
        .toList();
    List<FriendModel> friends = await Future.wait(
      friendIds.map((friendId) async =>
          FriendModel.fromJson((await _firestore.collection('users').doc(friendId).get()).data()!, friendId)),
    );
    return friends;
  }

  @override
  Future<List<FriendModel>> searchUsers(String phone) async {
    Query query = _firestore.collection('users').where('phone', isEqualTo: phone);
    return (await query.get())
        .docs
        .map((doc) => FriendModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}

final friendsServiceProvider = Provider<FriendsService>(
  (ref) => FriendsService(),
);
