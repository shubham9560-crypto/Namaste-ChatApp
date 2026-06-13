import 'package:whatapp_clone/common/enums/message_enum.dart';

class Message {
  final String senderId;
  final String recieverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;

  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message({
    required this.senderId,
    required this.recieverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'senderId': senderId,
  //     'recieverId': recieverId,
  //     'text': text,
  //     'type': type.type,
  //     'timeSent': timeSent.millisecondsSinceEpoch,
  //     'messageId': messageId,
  //     'isSeen': isSeen,
  //   };
  // }

  // factory Message.fromMap(Map<String, dynamic> map) {
  //   final rawType = map['type'];
  //   return Message(
  //     senderId: map['senderId'] ?? '',
  //     recieverId: map['recieverId'] ?? '',
  //     text: map['text'] ?? '',
  //     type: rawType is String ? rawType.toEnum() : MessageEnum.text,
  //     // (map['type'] ?? MessageEnum.text.type).toEnum(),
  //     timeSent: map['timeSent'] != null
  //         ? DateTime.fromMillisecondsSinceEpoch(map['timeSent'])
  //         : DateTime.now(),
  //     messageId: map['messageId'] ?? '',
  //     isSeen: map['isSeen'] ?? false,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'recieverId': recieverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'];
    return Message(
      senderId: map['senderId'] as String,
      recieverId: map['recieverId'] as String,
      text: map['text'] as String,
      type: rawType is String ? rawType.toEnum() : MessageEnum.text,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      messageId: map['messageId'] as String,
      isSeen: map['isSeen'] as bool,
      repliedMessage: map['repliedMessage'] as String,
      repliedTo: map['repliedTo'] as String,
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }
}
