// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whats_app_clone/features/auth/repository/auth_repo.dart';
import 'package:whats_app_clone/models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRespository = ref.watch(authRespositoryProvider);
  return AuthController(authRepository: authRespository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getCurrentUser();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });

  void signInwithPhone(BuildContext context, String phoneNo) {
    authRepository.signInwithPhone(context, phoneNo);
  }

  void verifyOtp(BuildContext context, String verificationId, String userOtp) {
    authRepository.verifyOTP(
        context: context, verificationId: verificationId, userOtp: userOtp);
  }

  void saveUserDatatoFirebase(BuildContext context, String name, File proPic) {
    authRepository.saveProfileToFirebase(
        name: name, image: proPic, ref: ref, context: context);
  }

  Future<UserModel?> getCurrentUser() async {
    UserModel? user = await authRepository.getCurrentUser();
    return user;
  }

  Stream<UserModel> userById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}
