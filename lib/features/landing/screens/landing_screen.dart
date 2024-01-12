import 'package:flutter/material.dart';
import 'package:whats_app_clone/common/utils/colors.dart';
import 'package:whats_app_clone/common/custom_button.dart';
import 'package:whats_app_clone/features/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void naviagteToLogin(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 50),
          const Center(
            child: Text(
              "Welcome to WhatsApp",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: size.height / 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset("assets/bg.png", color: tabColor),
          ),
          SizedBox(height: size.height / 9),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Read our Privacy Policy. Tap 'Agree and Continue' to accept the Terms of Service",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: greyColor),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
              width: size.width * 0.9,
              child: CustomButton(
                  text: "Agree and Continue",
                  onPressed: () => naviagteToLogin(context)))
        ]),
      ),
    );
  }
}
