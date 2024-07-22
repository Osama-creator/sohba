import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:sohba/service/challenge_service.dart';

class ChallengeNotifier extends ChangeNotifier {
  final ChallengService _challengService;

  ChallengeNotifier(this._challengService);

  Future<void> addChallenge(Challenge challenge, bool isPrivate) async {
    try {
      await _challengService.addChallenge(challenge, isPrivate);
      notifyListeners();
    } catch (e) {
      log('Error adding challenge: $e');
    }
  }

  Future<void> addMemberToChallenge(String challengeId, String memberId) async {
    try {
      await _challengService.addMemberToChallenge(challengeId, memberId);
      notifyListeners();
    } catch (e) {
      log('Error adding member to challenge: $e');
    }
  }

  Future<void> updateChallengeDay(
    String challengeId,
    String collectionKey,
  ) async {
    try {
      await _challengService.clearTasks(challengeId, collectionKey);
      notifyListeners();
    } catch (e) {
      log('Error adding member to challenge: $e');
    }
  }

  Future<void> addTaskToChallenge(String challengeId, Task newTask, String collectionKey) async {
    try {
      await _challengService.addTaskToChallenge(challengeId, newTask, collectionKey);
      notifyListeners();
    } catch (e) {
      log('Error adding task to challenge: $e');
    }
  }

  Future<void> removeChallengeFromAll(String challengeId, String collectionKey) async {
    try {
      await _challengService.removeChallenge(challengeId, collectionKey);
      notifyListeners();
    } catch (e) {
      log('Error In Removiing challenge: $e');
    }
  }

  Future<void> leaveChallenge(
    String challengeId,
  ) async {
    try {
      await _challengService.leaveChallenge(
        challengeId,
      );
      notifyListeners();
    } catch (e) {
      log('Error In leaving challenge: $e');
    }
  }

  Future<void> checkTask(String challengeId, String taskId, String collectionKey) async {
    try {
      await _challengService.toggleTaskCheck(challengeId, taskId, collectionKey);

      notifyListeners();
    } catch (e) {
      log('Error checking task in challenge: $e');
    }
  }

  Future<void> deleteTask(String challengeId, String taskId, String collectionKey) async {
    try {
      await _challengService.deleteTask(challengeId, taskId, collectionKey);
      notifyListeners();
    } catch (e) {
      log('Error Date task in challenge: $e');
    }
  }

  Future<void> updateTask(String challengeId, Task task, String collectionKey) async {
    try {
      await _challengService.updateTask(challengeId, task, collectionKey);
      notifyListeners();
    } catch (e) {
      log('Error updating task: $e');
    }
  }
}

final challengeNotifierProvider = ChangeNotifierProvider<ChallengeNotifier>(
  (ref) {
    final challengeService = ref.watch(chalengeServiceProvider);
    return ChallengeNotifier(challengeService);
  },
);
