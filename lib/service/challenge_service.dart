import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';

abstract class ChallengServiceInterface {
  Future<void> addChallenge(Challenge challenge);
  Future<List<Challenge>> getChallenges();
  Future<void> addMemberToChallenge(String challengeId, String memberId);
  Future<void> addTaskToChallenge(String challengeId, Task newTask);
  Future<void> checkTask(String challengeId, String taskId, String memberId);
  Future<void> updateEndDate(String challengeId, DateTime endDate);
}

class ChallengService implements ChallengServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'challenges';

  @override
  Future<void> addChallenge(Challenge challenge) async {
    DocumentReference docRef = _firestore.collection(_collectionName).doc();

    // Update the challenge object with the document ID
    challenge.id = docRef.id;

    // Set the challenge details in Firestore
    await docRef.set(challenge.toJson());
    for (var userId in challenge.friendsId) {
      await addMemberToChallenge(challenge.id, userId);
    }
  }

  @override
  Future<void> addMemberToChallenge(String challengeId, String memberId) async {
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'friendsId': FieldValue.arrayUnion([memberId]),
    });
    await _firestore.collection('users').doc(memberId).collection('challenges').doc(challengeId).set({});
  }

  @override
  Future<void> addTaskToChallenge(String challengeId, Task newTask) async {
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'tasks': FieldValue.arrayUnion([newTask.toJson()]),
    });
  }

  @override
  Future<void> checkTask(String challengeId, String taskId, String memberId) async {
    DocumentSnapshot challengeSnapshot = await _firestore.collection(_collectionName).doc(challengeId).get();
    if (!challengeSnapshot.exists) {
      throw Exception('Challenge with ID $challengeId does not exist.');
    }

    List<dynamic> tasksJson = challengeSnapshot.get('tasks');
    List<Task> tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

    int taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      Task updatedTask = tasks[taskIndex];

      if (!updatedTask.friendsId.contains(memberId)) {
        updatedTask.friendsId.add(memberId);
      }

      int friendIndex = updatedTask.friendsCountList.indexWhere((item) => item.id == memberId);
      if (friendIndex != -1) {
        updatedTask.friendsCountList[friendIndex].count++;
      } else {
        updatedTask.friendsCountList.add(FriendsCount(id: memberId, count: 1));
      }

      tasks[taskIndex] = updatedTask;
      await _firestore.collection(_collectionName).doc(challengeId).update({
        'tasks': tasks.map((task) => task.toJson()).toList(),
      });
    } else {
      throw Exception('Task with ID $taskId not found in challenge $challengeId.');
    }
  }

  @override
  Future<void> updateEndDate(String challengeId, DateTime endDate) async {
    await _firestore.collection(_collectionName).doc(challengeId).update({
      'endDate': endDate.toIso8601String(),
    });
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    List<String> challengesIds =
        (await _firestore.collection('users').doc(currentUserId).collection('challenges').get())
            .docs
            .map((doc) => doc.id)
            .toList();

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
  }
}

final chalengeServiceProvider = Provider<ChallengService>(
  (ref) => ChallengService(),
);
