import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/friend_model.dart';
import 'package:sohba/model/user_model.dart';
import 'package:sohba/service/friends_service.dart';

final searchUsersProvider = FutureProvider.family<List<FriendModel>, String>(
  (ref, userPhone) => ref.read(friendsServiceProvider).searchUsers(userPhone),
);

class FriendsNotifier extends StateNotifier<AsyncValue<List<FriendModel>>> {
  final FriendsService _friendsService;

  FriendsNotifier(this._friendsService) : super(const AsyncValue.loading());

  Future<void> loadFriends({bool forceRefresh = false}) async {
    if (forceRefresh) {
      try {
        state = const AsyncValue.loading();
        final friends = await _friendsService.getFriends();
        state = AsyncValue.data(friends);
      } catch (e) {
        // state = AsyncValue.error(e);
      }
    } else {
      try {
        final friends = await _friendsService.getFriends();
        state = AsyncValue.data(friends);
      } catch (e) {
        // state = AsyncValue.error(e);
      }
    }
  }

  Future<void> addFriend(String friendId) async {
    try {
      await _friendsService.addFriend(friendId);
      await loadFriends(forceRefresh: true);
    } catch (e) {
      // Handle error
    }
  }
}

final friendsNotifierProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<FriendModel>>>((ref) {
  return FriendsNotifier(ref.read(friendsServiceProvider));
});
