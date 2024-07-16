import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/config/utils/colors.dart';
import 'package:sohba/controller/friends_controller.dart';

class SelectFriendsScreen extends ConsumerStatefulWidget {
  const SelectFriendsScreen({super.key});

  @override
  _SelectFriendsScreenState createState() => _SelectFriendsScreenState();
}

class _SelectFriendsScreenState extends ConsumerState<SelectFriendsScreen> {
  final Set<String> _selectedFriendIds = {};

  @override
  void initState() {
    super.initState();
    ref.read(friendsNotifierProvider.notifier).loadFriends();
  }

  void _toggleFriendSelection(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedFriendIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Friends"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: friendsState.when(
        data: (friends) => ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final isSelected = _selectedFriendIds.contains(friend.id);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.black,
                backgroundImage: NetworkImage(friend.avatar ?? ''),
              ),
              title: Text(friend.name),
              trailing: isSelected
                  ? const Icon(Icons.check_box, color: Colors.green)
                  : const Icon(Icons.check_box_outline_blank),
              onTap: () => _toggleFriendSelection(friend.id),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
