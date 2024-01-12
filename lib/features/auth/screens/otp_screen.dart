// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';

class OtpScreen extends ConsumerWidget {
  static const String routeName = "/otp-screen";
  final String verificationId;

  const OtpScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  void verifyotp(BuildContext context, String userOtp, WidgetRef ref) {
    ref
        .read(authControllerProvider)
        .verifyOtp(context, verificationId, userOtp);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Verfying your number"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text("We have sent an sms with code."),
          Center(
            child: SizedBox(
              width: size.width * 0.45,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 6) {
                    FocusManager.instance.primaryFocus!.unfocus;
                    verifyotp(context, val.toString().trim(), ref);
                  }
                },
                decoration: const InputDecoration(
                    hintText: '- - - - - -',
                    hintStyle: TextStyle(fontSize: 30)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
