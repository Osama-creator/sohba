import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sohba/model/challenge.dart';
import 'package:sohba/model/task.dart';
import 'package:sohba/service/challenge_service.dart';

final getChallengesProvider = FutureProvider<List<Challenge>>(
  (ref) => ref.read(chalengeServiceProvider).getChallenges(),
);

class ChallengeNotifier extends ChangeNotifier {
  final ChallengService _challengService;

  ChallengeNotifier(this._challengService);

  Future<void> addChallenge(Challenge challenge) async {
    try {
      await _challengService.addChallenge(challenge);
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
  ) async {
    try {
      await _challengService.clearTasks(challengeId);
      notifyListeners();
    } catch (e) {
      log('Error adding member to challenge: $e');
    }
  }

  Future<void> addTaskToChallenge(String challengeId, Task newTask) async {
    try {
      await _challengService.addTaskToChallenge(challengeId, newTask);
      notifyListeners();
    } catch (e) {
      log('Error adding task to challenge: $e');
    }
  }

  Future<void> checkTask(
    String challengeId,
    String taskId,
  ) async {
    try {
      await _challengService.toggleTaskCheck(
        challengeId,
        taskId,
      );

      notifyListeners();
    } catch (e) {
      log('Error checking task in challenge: $e');
    }
  }

  Future<void> updateEndDate(String challengeId, DateTime endDate) async {
    try {
      await _challengService.updateEndDate(challengeId, endDate);
      notifyListeners();
    } catch (e) {
      log('Error updating end date of challenge: $e');
    }
  }
}

final challengeNotifierProvider = ChangeNotifierProvider<ChallengeNotifier>(
  (ref) {
    final challengeService = ref.watch(chalengeServiceProvider);
    return ChallengeNotifier(challengeService);
  },
);
