import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whats_app_clone/common/error_screen.dart';
import 'package:whats_app_clone/features/auth/screens/login_screen.dart';
import 'package:whats_app_clone/features/auth/screens/otp_screen.dart';
import 'package:whats_app_clone/features/auth/screens/user_info_screen.dart';
import 'package:whats_app_clone/features/groups/screens/create_group_screen.dart';
import 'package:whats_app_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whats_app_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whats_app_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whats_app_clone/features/status/screens/status_screen.dart';
import 'package:whats_app_clone/models/status_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case OtpScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OtpScreen(verificationId: verificationId));
    case UserInfoScreen.routeName:
      return MaterialPageRoute(builder: (context) => const UserInfoScreen());
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactScreen());
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isgroup = arguments['isgroup'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                name: name,
                uid: uid,
                isgroup: isgroup,
                profilePic: profilePic,
              ));
    case ConfirmStatusCreen.routeName:
      final filearguments = settings.arguments as File;
      return MaterialPageRoute(
          builder: (context) => ConfirmStatusCreen(
                file: filearguments,
              ));
    case StatusScreen.routeName:
      final statusarguments = settings.arguments as StatusModel;
      return MaterialPageRoute(
          builder: (context) => StatusScreen(
                status: statusarguments,
              ));
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(builder: (context) => const CreateGroupScreen());
    default:
      return MaterialPageRoute(
          builder: (context) => const ErrorScreen(error: "Wrong Route"));
  }
}
