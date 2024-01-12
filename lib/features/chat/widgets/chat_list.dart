// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whats_app_clone/common/enums/message_enum.dart';
import 'package:whats_app_clone/common/providers/message_reply.dart';
import 'package:whats_app_clone/features/chat/controllers/chat_controller.dart';
import 'package:whats_app_clone/models/message.dart';
import 'package:whats_app_clone/features/chat/widgets/my_message_card.dart';
import 'package:whats_app_clone/features/chat/widgets/sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isgroup;
  const ChatList(
      {Key? key, required this.receiverUserId, required this.isgroup})
      : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void messageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.notifier).update((state) =>
        MessageReply(message: message, isMe: isMe, messageEnum: messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: StreamBuilder<List<Message>>(
          stream: widget.isgroup
              ? ref
                  .read(chatControllerProvider)
                  .groupStream(widget.receiverUserId)
              : ref
                  .read(chatControllerProvider)
                  .chatStream(widget.receiverUserId),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            SchedulerBinding.instance.addPostFrameCallback((_) {
              messageController
                  .jumpTo(messageController.position.maxScrollExtent);
            });
            return ListView.builder(
              controller: messageController,
              itemCount: snapshots.data!.length,
              itemBuilder: (context, index) {
                var messageData = snapshots.data![index];
                if (!messageData.isSeen &&
                    messageData.receiverId ==
                        FirebaseAuth.instance.currentUser!.uid) {
                  ref.read(chatControllerProvider).setChatMessageSeen(
                      context, widget.receiverUserId, messageData.messageId);
                }
                if (messageData.senderId ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  return MyMessageCard(
                    message: messageData.text,
                    type: messageData.type,
                    date:
                        DateFormat.Hm().format(messageData.timesent).toString(),
                    replyText: messageData.repliedMessage,
                    userName: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onLeftSwipe: () =>
                        messageSwipe(messageData.text, true, messageData.type),
                    isSeen: messageData.isSeen,
                  );
                }
                return SenderMessageCard(
                  message: messageData.text,
                  type: messageData.type,
                  date:
                      DateFormat("Hm").format(messageData.timesent).toString(),
                  userName: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onRightSwipe: () =>
                      messageSwipe(messageData.text, false, messageData.type),
                  replyText: messageData.repliedMessage,
                );
              },
            );
          }),
    );
  }
}
