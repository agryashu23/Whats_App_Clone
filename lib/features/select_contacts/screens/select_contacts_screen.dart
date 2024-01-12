import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/utils/colors.dart';
import 'package:whats_app_clone/common/error_screen.dart';
import 'package:whats_app_clone/common/widgtes/loader.dart';
import 'package:whats_app_clone/features/select_contacts/controller/select_contact_controller.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = "/select-contacts";
  const SelectContactScreen({super.key});

  // ignore: non_constant_identifier_names
  void SelectContact(
      WidgetRef ref, Contact selectContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contacts"),
        backgroundColor: appBarColor,
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ref.watch(getContactProvider).when(
          data: (contactList) => SizedBox(
                child: ListView.builder(
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      final contact = contactList[index];
                      return InkWell(
                        onTap: () => SelectContact(ref, contact, context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              contact.displayName,
                              style: const TextStyle(fontSize: 18),
                            ),
                            leading:
                                // contact.photo == null
                                //     ? Container()
                                //     :
                                const CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 30,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
          error: (error, stackTrace) => ErrorScreen(error: error.toString()),
          loading: () => const LoadingPage()),
    );
  }
}
