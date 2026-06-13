import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatapp_clone/features/select_contacts/repository/select_contact_repository.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

final getContactProvider = FutureProvider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return selectContactsRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactController(
    ref: ref,
    selectContactsRepository: selectContactsRepository,
  );
});

class SelectContactController {
  final Ref ref;
  final SelectContactsRepository selectContactsRepository;

  SelectContactController({
    required this.ref,
    required this.selectContactsRepository,
  });

  void selectContact(Contact selectedContact, BuildContext context) {
    selectContactsRepository.selectContact(selectedContact, context);
  }

  Future<List<Contact>> searchContact(String query) async {
    return await selectContactsRepository.searchContact(query);
  }
}
