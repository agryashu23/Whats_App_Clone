import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/common/repository/firebase_storage_repo.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/models/group.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository(
      {required this.firestore, required this.auth, required this.ref});

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) async {
    try {
      List<String> uids = [];

      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo:
                    selectedContact[i].phones[0].number.replaceAll(' ', ''))
            .get();
        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
        var groupId = const Uuid().v1();
        String groupUrl = await ref
            .read(commonFirebaseStorageProvider)
            .storeToFirebase('group/$groupId', profilePic);
        GroupModel group = GroupModel(
            senderId: auth.currentUser!.uid,
            name: name,
            groupId: groupId,
            lastmessage: "",
            groupPic: groupUrl,
            memberUid: [auth.currentUser!.uid, ...uids],
            timesent: DateTime.now());
        await firestore.collection('groups').doc(groupId).set(group.toMap());
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }
}
