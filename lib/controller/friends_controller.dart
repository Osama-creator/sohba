import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/friends_service.dart';

final searchUsersProvider = FutureProvider.family<List<FriendModel>, String>(
  (ref, userPhone) => ref.read(friendsServiceProvider).searchUsers(userPhone),
);
final getFriendsProvider = FutureProvider<List<FriendModel>>(
  (ref) => ref.read(friendsServiceProvider).getFriends(),
);
// final addFriendProvider = FutureProvider.family<dynamic, String>(
//   (ref, userPhone) => ref.read(friendsServiceProvider).addFriend(userPhone),
// );
