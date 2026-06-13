import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatapp_clone/common/widgets/snackbar.dart';
import 'package:whatapp_clone/models/user_model.dart';
import 'package:whatapp_clone/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) =>
      SelectContactsRepository(firebaseFirestore: FirebaseFirestore.instance),
);

class SelectContactsRepository {
  final FirebaseFirestore firebaseFirestore;

  SelectContactsRepository({required this.firebaseFirestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    try {
      final s = await FlutterContacts.permissions.request(PermissionType.read);

      if (s == PermissionStatus.granted) {
        contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.photoThumbnail, ContactProperty.phone},
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  List<Contact> contacts = [];
  Future<List<Contact>> searchContact(String query) async {
    try {
      if (contacts.isEmpty) {
        if (await FlutterContacts.permissions.request(PermissionType.read) ==
            PermissionStatus.granted) {
          contacts = await FlutterContacts.getAll(
            properties: {ContactProperty.photoThumbnail, ContactProperty.phone},
          );
          debugPrint("adding contacts");
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (query.isEmpty) return [];
    return contacts
        .where(
          (contact) =>
              contact.displayName!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // for (Contact contact in contacts) {
  //   if (contact.displayName.contains(query)) {
  //     searchContact.add(contact);
  //     debugPrint('${contact.displayName} query=$query');
  //   }
  // }

  // return searchContact;

  void selectContact(Contact selectedContact, BuildContext context) async {
    print(selectedContact.phones);
    try {
      var users = await firebaseFirestore.collection('users').get();
      bool isFound = false;

      for (var user in users.docs) {
        var userData = UserModel.fromMap(user.data());
        // debugPrint(selectedContact.phones[0].number);

        String selectPhoneNumber = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );
        if (selectPhoneNumber == userData.phoneNumber) {
          isFound = true;

          // debugPrint("name ${userData.name}");
          // debugPrint("uid ${userData.uid}");

          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {'name': userData.name, 'uid': userData.uid},
          );
        }
      }

      if (!isFound) {
        showSnackBar(
          context: context,
          content: 'This number doesn\'t exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
