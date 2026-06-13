import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatapp_clone/common/enums/message_enum.dart';
import 'package:whatapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/common/widgets/my_message_card.dart';
import 'package:whatapp_clone/common/widgets/sender_message_card.dart';
import 'package:whatapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatapp_clone/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;

  const ChatList({super.key, required this.recieverUserId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController scrollController = ScrollController();
  String formatDate(DateTime timeSent) {
    return DateFormat('h:mm a').format(timeSent);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.notifier).state = MessageReply(
      message,
      isMe,
      messageEnum,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref
          .read(chatControllerProvider)
          .chatStream(widget.recieverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          var err = snapshot.stackTrace;
          debugPrint(err.toString());
          return Center(child: Text("start chats"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("User not found"));
        }

        final messagesData = snapshot.data!;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });

        return ListView.builder(
          itemCount: snapshot.data!.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            final message = messagesData[index];
            if (!message.isSeen &&
                message.recieverId == FirebaseAuth.instance.currentUser!.uid) {
              ref
                  .read(chatControllerProvider)
                  .setChatMessageSeen(
                    context,
                    widget.recieverUserId,
                    message.messageId,
                  );
            }

            if (messagesData[index].senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: message.text.toString(),
                date: formatDate(message.timeSent),
                type: message.type,
                repliedText: message.repliedMessage,
                userName: message.repliedTo,
                repliedMessageType: message.repliedMessageType,

                onLeftSwipe: () =>
                    onMessageSwipe(message.text, true, message.type),
                isSeen: message.isSeen,
              );
            }
            return SenderMessageCard(
              message: message.text.toString(),
              date: formatDate(message.timeSent),
              type: message.type,
              repliedText: message.repliedMessage,
              userName: message.repliedTo,
              repliedMessageType: message.repliedMessageType,
              onRightSwipe: () =>
                  onMessageSwipe(message.text, false, message.type),
            );
          },
        );
      },
    );
  }
}
