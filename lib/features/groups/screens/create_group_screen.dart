import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/utils/colors.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/features/groups/controller/group_controller.dart';
import 'package:whats_app_clone/features/groups/widgets/select_contacts_group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = "/create-group-screen";
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController controller = TextEditingController();

  void selectImage() async {
    image = await pickImageGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (controller.text.isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(context,
          controller.text.trim(), image!, ref.read(selectedGroupContact));
      ref.read(selectedGroupContact.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 10,
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
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter Group name"),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.all(15),
            child: const Text(
              "Select Contacts ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SelectContactsGroup(),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
