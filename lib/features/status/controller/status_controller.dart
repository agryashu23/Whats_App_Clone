import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';
import 'package:whats_app_clone/features/status/repository/status_repso.dart';
import 'package:whats_app_clone/models/status_model.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepoProvider);
  return StatusController(statusRepositroy: statusRepository, ref: ref);
});

class StatusController {
  final StatusRepositroy statusRepositroy;
  final ProviderRef ref;

  StatusController({required this.statusRepositroy, required this.ref});

  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData((value) {
      statusRepositroy.uploadStatus(
          username: value!.name,
          profile: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusImg: file,
          context: context);
    });
  }

  Future<List<StatusModel>> getStatus(BuildContext context) async {
    List<StatusModel> statuss = await statusRepositroy.getStatus(context);

    return statuss;
  }
}
