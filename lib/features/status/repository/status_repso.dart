import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/common/repository/firebase_storage_repo.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/models/status_model.dart';
import 'package:whats_app_clone/models/user_model.dart';

final statusRepoProvider = Provider((ref) => StatusRepositroy(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class StatusRepositroy {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepositroy(
      {required this.firestore, required this.auth, required this.ref});

  void uploadStatus(
      {required String username,
      required String profile,
      required String phoneNumber,
      required File statusImg,
      required BuildContext context}) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(commonFirebaseStorageProvider)
          .storeToFirebase('/status/$statusId', statusImg);
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> uidWhoSee = [];

      for (int i = 0; i < contacts.length; i++) {
        var userDataFirebase = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoSee.add(userData.uid);
        }
      }

      List<String> imageUrls = [];
      var statussnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();
      // .where('createdAt',
      //     isLessThan: DateTime.now().subtract(const Duration(hours: 24)))
      if (statussnapshot.docs.isNotEmpty) {
        StatusModel status = StatusModel.fromMap(statussnapshot.docs[0].data());
        imageUrls = status.photoUrl;
        imageUrls.add(imageUrl);
        await firestore
            .collection('status')
            .doc(statussnapshot.docs[0].id)
            .update({'photoUrl': imageUrls});
        return;
      } else {
        imageUrls = [imageUrl];
      }
      StatusModel status = StatusModel(
          uid: uid,
          username: username,
          phoneNumber: phoneNumber,
          photoUrl: imageUrls,
          createdAt: DateTime.now(),
          proPic: profile,
          statusId: statusId,
          whocansee: uidWhoSee);
      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusSnapshot = await firestore
            .collection('status')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .where('createdAt',
                isGreaterThan: DateTime.now()
                    .subtract(const Duration(hours: 24))
                    .millisecondsSinceEpoch)
            .get();
        for (var tempData in statusSnapshot.docs) {
          StatusModel tempStatus = StatusModel.fromMap(tempData.data());
          if (tempStatus.whocansee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      } else {
        // ignore: use_build_context_synchronously
        showSnackbar(context: context, text: e.toString());
      }
    }
    return statusData;
  }
}
