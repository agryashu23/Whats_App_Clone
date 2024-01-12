import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/error_screen.dart';
import 'package:whats_app_clone/common/widgtes/loader.dart';
import 'package:whats_app_clone/features/select_contacts/controller/select_contact_controller.dart';

final selectedGroupContact = StateProvider<List<Contact>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
  List<int> selectContactIndex = [];

  void selectContact(int index, Contact contact) {
    if (selectContactIndex.contains(index)) {
      selectContactIndex.remove(index);
      //Can be changed
    } else {
      selectContactIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContact.notifier)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactProvider).when(
        data: (contactList) => Expanded(
            child: ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final contact = contactList[index];
                  return InkWell(
                    onTap: () => selectContact(index, contact),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                          leading: selectContactIndex.contains(index)
                              ? IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.done))
                              : null,
                          title: Text(
                            contact.displayName,
                            style: const TextStyle(fontSize: 18),
                          )),
                    ),
                  );
                })),
        error: (error, stackTrace) => ErrorScreen(error: error.toString()),
        loading: () => const LoadingPage());
  }
}
