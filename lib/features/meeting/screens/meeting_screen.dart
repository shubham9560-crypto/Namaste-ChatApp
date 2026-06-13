import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/features/meeting/controller/jistmeet_controller.dart';
import 'package:whatapp_clone/features/meeting/widget/meeting_btns.dart';

class MeetingScreen extends ConsumerWidget {
  const MeetingScreen({super.key});

  final String roomId = "------";

  final Gradient gradient = const LinearGradient(
    colors: [Color(0xff43e97b), Color(0xff38f9d7)],
  );

  final Gradient gradient2 = const LinearGradient(
    colors: [Color(0xff4facfe), Color(0xff00f2fe)],
  );

  void createMeeting(BuildContext context, WidgetRef ref) {
    debugPrint("calling create meeting");
    showJoinMeetingDialog(context, ref, true);
  }

  void joinMeeting(BuildContext context, WidgetRef ref) {
    showJoinMeetingDialog(context, ref, false);
  }

  void showJoinMeetingDialog(
    BuildContext context,
    WidgetRef ref,
    bool isCreating,
  ) {
    final TextEditingController roomIdController = TextEditingController();
    final TextEditingController userNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Meeting"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCreating)
                TextField(
                  controller: roomIdController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Enter Room ID",
                    border: OutlineInputBorder(),
                  ),
                ),

              TextField(
                controller: userNameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Enter Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                if (isCreating) {
                  final userName = userNameController.text.trim();

                  if (userName.isEmpty) {
                    showSnackBar(
                      context: context,
                      content: "Enter username",
                    ); // optionally show error
                    return;
                  }

                  Navigator.pop(context); // Close dialog
                  ref
                      .read(jitsimeetControllerProvider.notifier)
                      .createMeeting(userName);
                } else {
                  final roomId = roomIdController.text.trim();
                  final userName = userNameController.text.trim();

                  if (roomId.isEmpty) {
                    return; // optionally show error
                  }

                  Navigator.pop(context); // Close dialog
                  ref
                      .read(jitsimeetControllerProvider.notifier)
                      .joinMeeting(roomId, userName);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(jitsimeetControllerProvider).roomId;

    return Center(
      child: Column(
        children: [
          SizedBox(height: 30),

          SizedBox(
            width: 300,
            child: MeetingButton(
              context: context,
              title: "Create Meeting",
              icon: Icons.add_circle_outline_rounded,
              gradient: gradient,
              onTap: () => createMeeting(context, ref),
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            width: 300,
            child: MeetingButton(
              context: context,
              title: "Join Meeting",
              icon: Icons.video_call_rounded,
              gradient: gradient2,
              onTap: () => joinMeeting(context, ref),
            ),
          ),

          SizedBox(height: 20),

          Text(
            roomId == null || roomId.isEmpty ? "------" : "ID: $roomId",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ],
      ),
    );
  }
}
