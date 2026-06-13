import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/widgets/chat_list.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';
import 'package:whatapp_clone/models/user_model.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = "/mobile-chat-screen";

  final String name;
  final String uid;

  const MobileChatScreen({super.key, required this.name, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<UserModel>(
      stream: ref.read(authControllerProvider.notifier).getUserById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("User not found"));
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: appBarColor,
            centerTitle: false,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.profilePic.isNotEmpty
                      ? NetworkImage(user.profilePic)
                      : null,
                  child: user.profilePic.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontSize: 18)),
                    Text(
                      user.isOnline ? "Online" : "Offline",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: ChatList(recieverUserId: uid)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BottomChatField(recieverUserId: uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
