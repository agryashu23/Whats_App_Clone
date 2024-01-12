import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/utils/colors.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';
import 'package:whats_app_clone/features/calls/controller/call_controller.dart';
import 'package:whats_app_clone/features/calls/screens/call_pickup_screen.dart';
import 'package:whats_app_clone/features/chat/widgets/bottom_textfield.dart';
import 'package:whats_app_clone/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerStatefulWidget {
  static const String routeName = "/mobile-chat-screen";
  final String name;
  final String uid;
  final bool isgroup;
  final String profilePic;
  const MobileChatScreen(
      {Key? key,
      required this.name,
      required this.uid,
      required this.isgroup,
      required this.profilePic})
      : super(key: key);

  @override
  ConsumerState<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
  void makeCall(
    // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
    WidgetRef,
    BuildContext context,
  ) {
    ref.read(callControllerProvider).makeCall(
        context, widget.name, widget.uid, widget.profilePic, widget.isgroup);
  }

  @override
  Widget build(BuildContext context) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: widget.isgroup
              ? Text(
                  widget.name,
                  style: const TextStyle(fontSize: 18),
                )
              : StreamBuilder(
                  stream: ref.read(authControllerProvider).userById(widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          snapshot.data!.isOnline ? "Online" : "Offline",
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    );
                  }),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  ChatList(receiverUserId: widget.uid, isgroup: widget.isgroup),
            ),
            bottomChatField(
              receiverUserId: widget.uid,
              isgroup: widget.isgroup,
            ),
          ],
        ),
      ),
    );
  }
}
