import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const String routeName = "/user-info-screen";

  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final nameController = TextEditingController();
  File? image;

  void selectImage() async {
    image = await pickImageGallery(context);
    setState(() {});
  }

  void storeuserData() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDatatoFirebase(context, name, image!);
    }
    showSnackbar(context: context, text: "Profile Created");
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Stack(
            children: [
              image == null
                  ? const CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://t4.ftcdn.net/jpg/00/65/77/27/360_F_65772719_A1UV5kLi5nCEWI0BNLLiFaBPEkUbv5Fv.jpg"),
                      radius: 60,
                    )
                  : CircleAvatar(
                      backgroundImage: FileImage(image!),
                      radius: 60,
                    ),
              Positioned(
                  bottom: -9,
                  left: 70,
                  child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      )))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(hintText: "Enter Your Name"),
                ),
              ),
              IconButton(onPressed: storeuserData, icon: const Icon(Icons.done))
            ],
          )
        ],
      ),
    )));
  }
}
