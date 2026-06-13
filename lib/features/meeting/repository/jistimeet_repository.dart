import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:riverpod/riverpod.dart';

final jitsimeetRepositoryProvider = Provider(
  (ref) => JitsimeetRepository(JitsiMeet()),
);

class JitsimeetRepository {
  final JitsiMeet jitsiMeet;

  JitsimeetRepository(this.jitsiMeet);

  void createMeeting(
    String roomId,
    String userName, {
    required VoidCallback onMeetingClose,
  }) async {
    debugPrint("Creating Meeting");

    // List<String> participants = [];
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.opensuse.org/",
      room: roomId,

      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "subject": "room id: $roomId",
      },

      featureFlags: {
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.welcomePageEnabled: false,
        FeatureFlags.preJoinPageEnabled: false,
        FeatureFlags.lobbyModeEnabled: true,
        FeatureFlags.securityOptionEnabled: true,
        FeatureFlags.meetingPasswordEnabled: true,
        FeatureFlags.pipWhileScreenSharingEnabled: true,
        FeatureFlags.unsafeRoomWarningEnabled: false,
        FeatureFlags.inviteEnabled: false,
        FeatureFlags.pipEnabled: true,
        // FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
      },
      userInfo: JitsiMeetUserInfo(displayName: userName),
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        debugPrint("conferenceJoined: url: $url");
      },
      conferenceTerminated: (url, error) {
        debugPrint("conferenceTerminated: url: $url, error: $error");

        onMeetingClose();
      },

      participantLeft: (participantId) {
        onMeetingClose();
      },
    );
    //   conferenceWillJoin: (url) {
    //     debugPrint("conferenceWillJoin: url: $url");
    //   },
    //   participantJoined: (email, name, role, participantId) {
    //     debugPrint(
    //       "participantJoined: email: $email, name: $name, role: $role, "
    //       "participantId: $participantId",
    //     );
    //     participants.add(participantId!);
    //   },
    //   participantLeft: (participantId) {
    //     debugPrint("participantLeft: participantId: $participantId");
    //   },
    //   audioMutedChanged: (muted) {
    //     debugPrint("audioMutedChanged: isMuted: $muted");
    //   },
    //   videoMutedChanged: (muted) {
    //     debugPrint("videoMutedChanged: isMuted: $muted");
    //   },
    //   endpointTextMessageReceived: (senderId, message) {
    //     debugPrint(
    //       "endpointTextMessageReceived: senderId: $senderId, message: $message",
    //     );
    //   },
    //   screenShareToggled: (participantId, sharing) {
    //     debugPrint(
    //       "screenShareToggled: participantId: $participantId, "
    //       "isSharing: $sharing",
    //     );
    //   },
    //   chatMessageReceived: (senderId, message, isPrivate, timestamp) {
    //     debugPrint(
    //       "chatMessageReceived: senderId: $senderId, message: $message, "
    //       "isPrivate: $isPrivate, timestamp: $timestamp",
    //     );
    //   },
    //   chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
    //   participantsInfoRetrieved: (participantsInfo) {
    //     debugPrint(
    //       "participantsInfoRetrieved: participantsInfo: $participantsInfo, ",
    //     );
    //   },
    //   readyToClose: () {
    //     debugPrint("readyToClose");
    //   },
    // );

    await jitsiMeet.join(options, listener);
  }
}
