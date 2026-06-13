import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatapp_clone/common/enums/message_enum.dart';
import 'package:whatapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatapp_clone/features/chat/repository/chat_repository.dart';
import 'package:whatapp_clone/features/landing/screens/auth/controller/auth_controller.dart';
import 'package:whatapp_clone/models/chat_contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp_clone/models/message.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final Ref ref;

  ChatController({required this.chatRepository, required this.ref});

  void sendGifMessage(
    BuildContext context,
    String gifUrl,
    String recieverUsedId,
  ) {
    // https://i.giphy.com/media
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;

    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = "https://i.giphy.com/media/$gifUrlPart/200.gif";
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) {
      chatRepository.sendGifMessage(
        context: context,
        gifUrl: newGifUrl,
        receiverId: recieverUsedId,
        senderUser: value!,
        messageReply: messageReply,
      );
    });

    ref.read(messageReplyProvider.notifier).state = null;
  }

  void sendFileMessage(
    BuildContext context,
    XFile file,
    String recieverUserId,
    MessageEnum messageEnum,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) {
      chatRepository.sendFileMessage(
        context: context,
        file: file,
        recieverUserId: recieverUserId,
        senderUserData: value!,
        ref: ref,
        messageEnum: messageEnum,
        messageReply: messageReply,
      );
    });
    ref.read(messageReplyProvider.notifier).state = null;
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(context, recieverUserId, messageId);
  }

  void sendTextMessage(
    BuildContext context,
    String message,
    String receiverId,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    ref
        .read(userDataAuthProvider)
        .whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            message: message,
            receiverId: receiverId,
            senderUser: value!,
            messageReplyData: messageReply,
          ),
        );

    ref.read(messageReplyProvider.notifier).state = null;
  }

  Stream<List<ChatContact>> getChatsContacts() {
    return chatRepository.getChatContacts();
  }
}
