import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/models/user_model.dart';
import 'package:whats_app_clone/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepoProvider = Provider.autoDispose(
    (ref) => SelectContactRepo(firestore: FirebaseFirestore.instance));

class SelectContactRepo {
  final FirebaseFirestore firestore;

  SelectContactRepo({required this.firestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNo =
            selectedContact.phones[0].number.replaceAll(' ', '');
        if (selectedPhoneNo == userData.phoneNumber) {
          isFound = true;
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, MobileChatScreen.routeName,
              arguments: {'name': userData.name, 'uid': userData.uid});
        }
      }
      if (!isFound) {
        // ignore: use_build_context_synchronously
        showSnackbar(context: context, text: "This number doesn't exist");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }
}
