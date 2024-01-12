import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/features/calls/screens/call_screen.dart';
import 'package:whats_app_clone/models/call_model.dart';
import 'package:whats_app_clone/models/group.dart';

final callRepositoryProvider = Provider((ref) => CallRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ));

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({required this.firestore, required this.auth});

  void makeCall(CallModel senderCallData, BuildContext context,
      CallModel receiverCallData) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(receiverCallData.callerId)
          .set(receiverCallData.toMap());
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CallScreen(senderCallData.callId, senderCallData, false)));
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void groupCall(CallModel senderCallData, BuildContext context,
      CallModel receiverCallData) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      var groupSnaphot = await firestore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();
      GroupModel group = GroupModel.fromMap(groupSnaphot.data()!);
      for (var id in group.memberUid) {
        await firestore
            .collection('call')
            .doc(id)
            .set(receiverCallData.toMap());
      }
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CallScreen(senderCallData.callId, senderCallData, true)));
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void endgroupCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      var groupSnaphot =
          await firestore.collection('groups').doc(receiverId).get();
      GroupModel group = GroupModel.fromMap(groupSnaphot.data()!);
      for (var id in group.memberUid) {
        await firestore.collection('call').doc(id).delete();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();
}
