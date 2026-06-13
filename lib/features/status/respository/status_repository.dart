// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:whatapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/models/chat_contact.dart';
import 'package:whatapp_clone/models/status_model.dart';

final statusRepositoryProvider = Provider((ref) {
  return StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  );
});

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Ref ref;

  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  Future<void> uploadStatus({
    required BuildContext context,
    required String userName,
    required String profilePic,
    required String phoneNumber,
    required XFile statusImage,
  }) async {
    try {
      var statusId = Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(commonFirebaseStorageRepository)
          .storeFileToFirebase('/status/$statusId/$uid', statusImage);
      debugPrint("checkpoint: status image uploaded");
      // List<Contact> contacts = [];
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      // debugPrint("checkpoint: contacts are loaded");

      // List<String> normalizedNumbers = [];

      // for (final contact in contacts) {
      //   if (contact.phones.isEmpty) continue;
      //   final phone = PhoneNumber.parse(
      //     contact.phones.first.number,
      //     destinationCountry: IsoCode.IN,
      //   );

      //   if (phone.international.isNotEmpty) {
      //     normalizedNumbers.add(phone.international);
      //   }
      // }

      // get all the users who are can see my status
      List<String> uidWhoCanSee = [];

      //adding my own number here so that i can see my own status
      var myNumber = auth.currentUser!.uid;

      uidWhoCanSee.add(myNumber);
      var contacts = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .get();

      for (var contact in contacts.docs) {
        ChatContact user = ChatContact.fromMap(contact.data());
        uidWhoCanSee.add(user.contactId);
      }

      debugPrint("checkpoint:who can see are loaded");

      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          // .where(
          //   'createdAt',
          //   isLessThan: DateTime.now()
          //       .subtract(Duration(hours: 24))
          //       .microsecondsSinceEpoch,
          // )
          .orderBy('createdAt')
          .get();

      debugPrint(
        "checkpoint: status image are loaded status found ${statusesSnapshot.docs.length}",
      );

      if (statusesSnapshot.docs.isNotEmpty) {
        StatusModel status = StatusModel.fromMap(
          statusesSnapshot.docs[0].data(),
        );

        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);

        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({'photoUrl': statusImageUrls});

        debugPrint("checkpoint: photo url is updated");

        return;
      } else {
        statusImageUrls = [imageUrl];
      }

      StatusModel statusModel = StatusModel(
        uid: uid,
        userName: userName,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
        statusId: statusId,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        whoCanSee: uidWhoCanSee,
      );

      await firestore
          .collection('status')
          .doc(statusId)
          .set(statusModel.toMap());

      debugPrint("checkpoint: status saved");
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> statusData = [];

    try {
      debugPrint("checkpoint: contact loaded ");

      List<String> contactsId = [];

      //adding my own number here so that i can see my own status
      var myUID = auth.currentUser!.uid;

      contactsId.add(myUID);

      // get all the users who are can see my status
      var contacts = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .get();

      for (var contactUser in contacts.docs) {
        ChatContact contact = ChatContact.fromMap(contactUser.data());
        contactsId.add(contact.contactId);
      }

      debugPrint("checkpoint: all numbers are normalized");

      for (int i = 0; i < contactsId.length; i++) {
        if (contactsId.isEmpty) return statusData;

        var statusSnapshot = await firestore
            .collection('status')
            .where('uid', isEqualTo: contactsId[i])
            .where(
              'createdAt',
              isGreaterThan: DateTime.now().subtract(Duration(hours: 24)),
            )
            .get();

        for (var temp in statusSnapshot.docs) {
          StatusModel tempStatus = StatusModel.fromMap(temp.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }

      debugPrint("checkpoint: converting to status model ${statusData.length}");
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(context: context, content: e.toString());
    }

    return statusData;
  }
}
