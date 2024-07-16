import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sohba/controller/chalenge_controller.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:sohba/view/screens/challenge/add_friends_to_challenge.dart';

class AddChallengeScreen extends ConsumerStatefulWidget {
  const AddChallengeScreen({super.key});

  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends ConsumerState<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _challengeName = '';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final List<Task> _tasks = [];
  List<String> _selectedFriends = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var adminId = FirebaseAuth.instance.currentUser!.uid;
      _selectedFriends.add(adminId);
      final newChallenge = Challenge(
        adminId: adminId,
        id: "",
        name: _challengeName,
        endDate: _endDate,
        today: DateTime.now(),
        tasks: _tasks,
        friendsId: _selectedFriends,
      );

      ref.read(challengeNotifierProvider).addChallenge(newChallenge);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectFriends(BuildContext context) async {
    final selectedFriends = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SelectFriendsScreen(),
      ),
    );

    if (selectedFriends != null) {
      setState(() {
        _selectedFriends = selectedFriends;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Challenge Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a challenge name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _challengeName = value!;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('End Date: ${DateFormat.yMd().format(_endDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showAddTaskDialog(context);
                },
                child: const Text('Add Task'),
              ),
              const SizedBox(height: 16),
              ..._tasks.map((task) => ListTile(
                    title: Text(task.name),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _selectFriends(context);
                },
                child: const Text('Select Friends'),
              ),
              const SizedBox(height: 16),
              Text('صديق: ${_selectedFriends.length.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: taskNameController,
            decoration: const InputDecoration(hintText: "Task Name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _tasks.add(Task(
                    id: DateTime.now().toIso8601String(), // Unique ID for the task
                    name: taskNameController.text,
                    friendsId: [],
                    friendsCountList: [],
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
