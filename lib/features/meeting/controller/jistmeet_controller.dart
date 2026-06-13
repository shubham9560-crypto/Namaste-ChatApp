import 'dart:math';

import 'package:flutter/material.dart';
import 'package:riverpod/legacy.dart';
import 'package:whatapp_clone/features/meeting/repository/jistimeet_repository.dart';
import 'package:whatapp_clone/features/meeting/state/jitsimeet_state.dart';

final jitsimeetControllerProvider =
    StateNotifierProvider<JitsimeetController, JitsiMeetState>(
      (ref) => JitsimeetController(
        jitsiMeetRepository: ref.read(jitsimeetRepositoryProvider),
      ),
    );

class JitsimeetController extends StateNotifier<JitsiMeetState> {
  final JitsimeetRepository jitsiMeetRepository;

  JitsimeetController({required this.jitsiMeetRepository})
    : super(const JitsiMeetState());

  void createMeeting(String userName) {
    state = state.copyWith(isLoading: true);

    final roomId = generateNumericRoomId();

    jitsiMeetRepository.createMeeting(
      roomId,
      userName,
      onMeetingClose: () {
        //on close meeting
        onMeetingClose();
      },
    );

    state = state.copyWith(roomId: roomId, isLoading: false, error: null);
  }

  void onMeetingClose() {
    state = state.copyWith(roomId: '', isLoading: false, error: null);
    debugPrint("meeting closed ${state.roomId}");
  }

  String generateNumericRoomId() {
    final rand = Random.secure();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  void joinMeeting(String roomId, String userName) {
    if (roomId.isEmpty) {
      state = state.copyWith(error: "Room Id cannot be empty");
      return;
    }
    jitsiMeetRepository.createMeeting(
      roomId,
      userName,
      onMeetingClose: () {
        onMeetingClose();
      },
    );

    state = state.copyWith(roomId: roomId, isLoading: false, error: null);
  }
}
