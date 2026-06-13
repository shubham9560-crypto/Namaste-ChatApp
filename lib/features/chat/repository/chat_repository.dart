import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:whatapp_clone/common/enums/message_enum.dart';
import 'package:whatapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/models/chat_contact.dart';
import 'package:whatapp_clone/models/message.dart';
import 'package:whatapp_clone/models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  void sendFileMessage({
    required BuildContext context,
    required XFile file,
    required String recieverUserId,
    required UserModel senderUserData,
    required Ref ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messagedId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepository)
          .storeFileToFirebase(
            'chats/${messageEnum.type}/${senderUserData.uid}/$recieverUserId$messagedId',
            file,
          );

      UserModel recieverUserData;

      var userDataMap = await firestore
          .collection('users')
          .doc(recieverUserId)
          .get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = "\u{1F4F7} Photo";
          break;

        case MessageEnum.video:
          contactMsg = "\u{1F3AC} Video";
          break;

        case MessageEnum.audio:
          contactMsg = "\u{1F50A} Audio";
          break;

        case MessageEnum.gif:
          contactMsg = "\u{1F50A} GIF";
          break;

        default:
          contactMsg = "Gif";
      }

      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
      );

      _saveMessageToMessageSubscollection(
        recieverUserId: recieverUserId,
        msg: imageUrl,
        timeSent: timeSent,
        messageId: messagedId,
        username: senderUserData.name,
        recieverUserName: recieverUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        senderUserName: senderUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy("timeSent")
        .snapshots()
        .map((event) {
          List<Message> messages = [];
          for (var document in event.docs) {
            messages.add(Message.fromMap(document.data()));
          }

          return messages;
        });
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
          List<ChatContact> contacts = [];
          for (var document in event.docs) {
            var chatContact = ChatContact.fromMap(document.data());
            var userData = await firestore
                .collection('users')
                .doc(chatContact.contactId)
                .get();

            var user = UserModel.fromMap(userData.data()!);

            contacts.add(
              ChatContact(
                name: user.name,
                profilePic: user.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
              ),
            );
          }

          return contacts;
        });
  }

  void _saveMessageToMessageSubscollection({
    required String recieverUserId,
    required String msg,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required recieverUserName,
    required MessageEnum messageType,

    required MessageReply? messageReply,
    required String senderUserName,
  }) async {
    final mesage = Message(
      senderId: auth.currentUser!.uid,
      recieverId: recieverUserId,
      text: msg,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? "" : messageReply.message,
      repliedTo: messageReply == null
          ? ""
          : messageReply.isMe
          ? senderUserName
          : recieverUserName,

      repliedMessageType: messageReply == null
          ? MessageEnum.text
          : messageReply.messageEnum,
    );

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(mesage.toMap());

    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(mesage.toMap());
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel recieverUserData,
    String msg,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    var recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: msg,
    );

    // var messageId = const Uuid().v1();
    // for reciever
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection("chats")
        .doc(senderUserData.uid)
        .set(recieverChatContact.toMap());

    // debugPrint("yha tak pahoch gye");

    //for sender
    var senderChatContact = ChatContact(
      name: recieverUserData.name,
      profilePic: recieverUserData.profilePic,
      contactId: recieverUserData.uid,
      timeSent: timeSent,
      lastMessage: msg,
    );

    await firestore
        .collection('users')
        .doc(senderUserData.uid)
        .collection("chats")
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String message,
    required String receiverId,
    required UserModel senderUser,
    required MessageReply? messageReplyData,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap = await firestore
          .collection('users')
          .doc(receiverId)
          .get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      // debugPrint("kam se kam ");

      String messageId = Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        message,
        timeSent,
        receiverId,
      );

      _saveMessageToMessageSubscollection(
        recieverUserId: receiverId,
        msg: message,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUserName: receiverUserData.name,
        messageType: MessageEnum.text,
        messageReply: messageReplyData,
        senderUserName: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGifMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap = await firestore
          .collection('users')
          .doc(receiverId)
          .get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      // debugPrint("kam se kam ");
      String messageId = Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        'GIF',
        timeSent,
        receiverId,
      );

      _saveMessageToMessageSubscollection(
        recieverUserId: receiverId,
        msg: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUserName: receiverUserData.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        senderUserName: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
