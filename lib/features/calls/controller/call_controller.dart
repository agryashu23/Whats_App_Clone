import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';
import 'package:whats_app_clone/features/calls/repository/call_repo.dart';
import 'package:whats_app_clone/models/call_model.dart';

final callControllerProvider = Provider((ref) {
  final callRepo = ref.read(callRepositoryProvider);
  return CallController(
      callRepository: callRepo, ref: ref, auth: FirebaseAuth.instance);
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;

  CallController(
      {required this.callRepository, required this.ref, required this.auth});

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverPic, bool isgroup) {
    String callId = const Uuid().v1();
    ref.read(userDataAuthProvider).whenData((value) {
      CallModel senderCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverPic,
        callId: callId,
        hasDialled: true,
      );
      CallModel receiverCallData = CallModel(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverPic,
        callId: callId,
        hasDialled: false,
      );
      if (isgroup) {
        callRepository.groupCall(senderCallData, context, receiverCallData);
      } else {
        callRepository.makeCall(senderCallData, context, receiverCallData);
      }
    });
  }

  void endCall(String callerId, String receiverId, BuildContext context) {
    callRepository.endCall(callerId, receiverId, context);
  }

  void endgroupCall(String callerId, String receiverId, BuildContext context) {
    callRepository.endCall(callerId, receiverId, context);
  }
}
