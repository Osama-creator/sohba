import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';

abstract class ChallengServiceInterface {
  Future<void> addChallenge(Challenge challenge, bool isPrivate);
  Stream<List<Challenge>> streamChallenges();
  Future<void> addMemberToChallenge(String challengeId, String memberId);
  Future<void> addTaskToChallenge(String challengeId, Task newTask, String collectionKey);
  Future<void> clearTasks(String challengeId, String collectionKey);
  Future<void> toggleTaskCheck(String challengeId, String taskId, String collectionKey);
  Stream<List<Challenge>> mainChallenges();
  Future<void> updateEndDate(String challengeId, DateTime endDate, String collectionKey);
  Future<void> removeChallenge(String challengeId, String collectionKey);
  Future<void> leaveChallenge(String challengeId);
  Future<void> deleteTask(String challengeId, String taskId, String collectionKey);
  Future<void> updateTask(String challengeId, Task updatedTask, String collectionKey);
}

class ChallengService implements ChallengServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'challenges';

  @override
  Future<void> addChallenge(Challenge challenge, bool isPrivate) async {
    DocumentReference docRef =
        isPrivate ? _firestore.collection(_collectionName).doc() : _firestore.collection('main_challenges').doc();

    // Update the challenge object with the document ID
    challenge.id = docRef.id;

    // Set the challenge details in Firestore
    await docRef.set(challenge.toJson());
    if (isPrivate) {
      for (var userId in challenge.friendsId) {
        await addMemberToChallenge(challenge.id, userId);
      }
    }
  }

  @override
  Future<void> removeChallenge(String challengeId, String collectionKey) async {
    // Get the challenge document
    DocumentSnapshot challengeDoc = await _firestore.collection(collectionKey).doc(challengeId).get();

    if (!challengeDoc.exists) {
      throw Exception('Challenge with ID $challengeId does not exist.');
    }

    // Get the list of user IDs from the challenge
    List<String> friendsId = List<String>.from(challengeDoc.get('friendsId'));

    // Remove the challenge document
    await _firestore.collection(collectionKey).doc(challengeId).delete();

    // Remove the challenge ID from each user's challenges collection
    WriteBatch batch = _firestore.batch();

    for (String userId in friendsId) {
      DocumentReference userChallengeDoc =
          _firestore.collection('users').doc(userId).collection(collectionKey).doc(challengeId);
      batch.delete(userChallengeDoc);
    }

    // Commit the batch
    await batch.commit();
  }

  @override
  Future<void> leaveChallenge(
    String challengeId,
  ) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'friendsId': FieldValue.arrayRemove([userId]),
    });
    await _firestore.collection('users').doc(userId).collection('challenges').doc(challengeId).delete();
  }

  @override
  Future<void> addMemberToChallenge(
    String challengeId,
    String memberId,
  ) async {
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'friendsId': FieldValue.arrayUnion([memberId]),
    });
    await _firestore.collection('users').doc(memberId).collection('challenges').doc(challengeId).set({});
  }

  @override
  Future<void> addTaskToChallenge(String challengeId, Task newTask, String collectionKey) async {
    await _firestore.collection(collectionKey).doc(challengeId).update({
      'tasks': FieldValue.arrayUnion([newTask.toJson()]),
    });
  }

  @override
  Future<void> toggleTaskCheck(String challengeId, String taskId, String collectionKey) async {
    String memberId = FirebaseAuth.instance.currentUser?.uid ?? '';

    DocumentSnapshot challengeSnapshot = await _firestore.collection(collectionKey).doc(challengeId).get();
    if (!challengeSnapshot.exists) {
      throw Exception('Challenge with ID $challengeId does not exist.');
    }

    List<dynamic> tasksJson = challengeSnapshot.get('tasks');
    List<Task> tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

    int taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      Task updatedTask = tasks[taskIndex];

      if (updatedTask.friendsId.contains(memberId)) {
        // Uncheck task
        updatedTask.friendsId.remove(memberId);

        int friendIndex = updatedTask.friendsCountList.indexWhere((item) => item.id == memberId);
        if (friendIndex != -1) {
          if (updatedTask.friendsCountList[friendIndex].count > 1) {
            updatedTask.friendsCountList[friendIndex].count--;
          } else {
            updatedTask.friendsCountList.removeAt(friendIndex);
          }
        }
      } else {
        // Check task
        updatedTask.friendsId.add(memberId);

        int friendIndex = updatedTask.friendsCountList.indexWhere((item) => item.id == memberId);
        if (friendIndex != -1) {
          updatedTask.friendsCountList[friendIndex].count++;
        } else {
          updatedTask.friendsCountList.add(FriendsCount(id: memberId, count: 1));
        }
      }

      tasks[taskIndex] = updatedTask;
      await _firestore.collection(collectionKey).doc(challengeId).update({
        'tasks': tasks.map((task) => task.toJson()).toList(),
      });
    } else {
      throw Exception('Task with ID $taskId not found in challenge $challengeId.');
    }
  }

  @override
  Future<void> updateEndDate(String challengeId, DateTime endDate, String collectionKey) async {
    await _firestore.collection(collectionKey).doc(challengeId).update({
      'endDate': endDate.toIso8601String(),
    });
  }

  @override
  Stream<List<Challenge>> streamChallenges() {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('challenges')
        .snapshots()
        .asyncMap((snapshot) async {
      List<String> challengesIds = snapshot.docs.map((doc) => doc.id).toList();
      List<Challenge> challenges = await Future.wait(
        challengesIds.map((challengeId) async {
          DocumentSnapshot challengeDoc = await _firestore.collection('challenges').doc(challengeId).get();
          Challenge challenge = Challenge.fromJson(
            challengeDoc.data() as Map<String, dynamic>,
          );
          return challenge;
        }),
      );
      return challenges;
    });
  }

  @override
  Stream<List<Challenge>> mainChallenges() {
    return _firestore.collection('main_challenges').snapshots().asyncMap((snapshot) async {
      List<String> challengesIds = snapshot.docs.map((doc) => doc.id).toList();
      List<Challenge> challenges = await Future.wait(
        challengesIds.map((challengeId) async {
          DocumentSnapshot challengeDoc = await _firestore.collection('main_challenges').doc(challengeId).get();
          Challenge challenge = Challenge.fromJson(
            challengeDoc.data() as Map<String, dynamic>,
          );
          return challenge;
        }),
      );
      return challenges;
    });
  }

  @override
  Future<void> clearTasks(String challengeId, String collectionKey) async {
    DateTime today = DateTime.now();
    DocumentSnapshot challengeDoc = await _firestore.collection(collectionKey).doc(challengeId).get();
    Challenge challenge = Challenge.fromJson(
      challengeDoc.data() as Map<String, dynamic>,
    );
    if (!isSameDay(today, challenge.today)) {
      try {
        List<Task> updatedTasks = challenge.tasks.map((task) {
          task.friendsId.clear();
          return task;
        }).toList();
        int newDayNumber = challenge.dayNumber + 1;
        await FirebaseFirestore.instance.collection(collectionKey).doc(challengeId).update({
          'tasks': updatedTasks.map((task) => task.toJson()).toList(),
          'today': today.toIso8601String(), // Update today in challenge
          'dayNumber': newDayNumber, // Increment dayNumber
        });
      } catch (e) {
        log('Error clearing tasks in challenge: $e');
        rethrow;
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Future<void> deleteTask(String challengeId, String taskId, String collectionKey) async {
    DocumentSnapshot challengeDoc = await _firestore.collection(collectionKey).doc(challengeId).get();

    if (challengeDoc.exists) {
      List<dynamic> tasks = challengeDoc['tasks'];

      // Find the task to be removed
      var taskToRemove = tasks.firstWhere((task) => task['id'] == taskId, orElse: () => null);

      if (taskToRemove != null) {
        await _firestore.collection(collectionKey).doc(challengeId).update({
          'tasks': FieldValue.arrayRemove([taskToRemove]),
        });
        log('Task removed successfully');
      } else {
        log('Task not found');
      }
    } else {
      log('Challenge document not found');
    }
  }

  @override
  Future<void> updateTask(String challengeId, Task updatedTask, String collectionKey) async {
    // Fetch the challenge document
    DocumentSnapshot challengeDoc = await _firestore.collection(collectionKey).doc(challengeId).get();

    if (challengeDoc.exists) {
      List<dynamic> tasks = List.from(challengeDoc['tasks']);

      // Find the index of the task to be updated
      int taskIndex = tasks.indexWhere((task) => task['id'] == updatedTask.id);

      if (taskIndex != -1) {
        // Update the task at the found index
        tasks[taskIndex] = updatedTask.toJson();

        // Update the tasks array in Firestore
        await _firestore.collection(collectionKey).doc(challengeId).update({
          'tasks': tasks,
        });

        log('Task updated successfully');
      } else {
        log('Task not found');
      }
    } else {
      log('Challenge document not found');
    }
  }
}

final chalengeServiceProvider = Provider<ChallengService>(
  (ref) => ChallengService(),
);
final challengesStreamProvider = StreamProvider<List<Challenge>>((ref) {
  final challengeService = ref.watch(chalengeServiceProvider);
  return challengeService.streamChallenges();
});
final mainchallengesStreamProvider = StreamProvider<List<Challenge>>((ref) {
  final challengeService = ref.watch(chalengeServiceProvider);
  return challengeService.mainChallenges();
});
