import 'package:flutter/material.dart';
import 'package:flutter_contacts/models/contact/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp_clone/common/widgets/loader.dart';
import 'package:whatapp_clone/features/select_contacts/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
  static const routeName = "/select-contact";
  const SelectContactsScreen({super.key});

  @override
  ConsumerState<SelectContactsScreen> createState() =>
      _SelectContactScreenState();
}

class _SelectContactScreenState extends ConsumerState<SelectContactsScreen> {
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(_allContacts);
      });
      return;
    }

    final results = await ref
        .read(selectContactControllerProvider)
        .searchContact(query);

    if (!mounted) return;
    setState(() {
      if (results.isNotEmpty) {
        _searchResults = results;
      }
    });
  }

  void selectContact(Contact contact) {
    ref.read(selectContactControllerProvider).selectContact(contact, context);
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(getContactProvider);

    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text("Select contacts")
            : TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  hintText: "Search contact",
                  border: InputBorder.none,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
                _searchResults.clear();
              });
            },
          ),
          // const Icon(Icons.more_vert),
          const SizedBox(width: 5),
        ],
      ),
      body: contactAsync.when(
        data: (data) {
          if (_allContacts.isEmpty) {
            _allContacts = data;
          }

          final list = _isSearching ? _searchResults : _allContacts;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final contact = list[index];

              print("Contact : ${contact.phones}");
              return ListTile(
                onTap: () => selectContact(contact),
                title: Text(
                  contact.displayName.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  contact.phones.isNotEmpty
                      ? contact.phones[0].normalizedNumber.toString()
                      : "",
                  style: const TextStyle(fontSize: 18),
                ),

                isThreeLine: true,
              );
            },
          );
        },
        error: (err, trace) {
          return Text(err.toString());
        },
        loading: () {
          return const Loader();
        },
      ),
    );
  }
}
