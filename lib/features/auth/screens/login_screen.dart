import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/custom_button.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = "/login-screen";
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country count) {
        setState(() {
          country = count;
        });
      },
    );
  }

  void sendPhoneNo() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      ref
          .read(authControllerProvider)
          .signInwithPhone(context, "+${country!.phoneCode}$phoneNumber");
    } else {
      showSnackbar(context: context, text: "Enter valid phone number");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Enter your phone number"),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(
          height: 10,
        ),
        const Text("WhatsApp will need to verify your Phone Number"),
        const SizedBox(
          height: 20,
        ),
        TextButton(
            onPressed: () => pickCountry(), child: const Text("Pick Country")),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            country != null
                ? Text(
                    "+${country!.phoneCode}",
                    style: const TextStyle(color: Colors.white),
                  )
                : Container(),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: size.width * 0.7,
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: "phone number"),
                onChanged: (val) {
                  if (val.length == 10) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
            )
          ],
        ),
        SizedBox(
          height: size.height * 0.6,
        ),
        SizedBox(
          width: 90,
          child: CustomButton(text: "NEXT", onPressed: () => sendPhoneNo()),
        )
      ]),
    );
  }
}
