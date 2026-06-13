// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:riverpod/legacy.dart';
import 'package:whatapp_clone/common/enums/message_enum.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply(this.message, this.isMe, this.messageEnum);
}

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);
