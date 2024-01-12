import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whats_app_clone/common/enums/message_enum.dart';
import 'package:whats_app_clone/common/providers/message_reply.dart';
import 'package:whats_app_clone/features/auth/controller/auth_controller.dart';
import 'package:whats_app_clone/features/chat/repository/chat_respository.dart';
import 'package:whats_app_clone/models/chat_contact.dart';
import 'package:whats_app_clone/models/group.dart';
import 'package:whats_app_clone/models/message.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getchatContacts();
  }

  Stream<List<GroupModel>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Message>> chatStream(String receiverUserId) {
    return chatRepository.getChatsStream(receiverUserId);
  }

  Stream<List<Message>> groupStream(String groupId) {
    return chatRepository.getGroupsStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
    bool isgroup,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            messageReply: messageReply,
            isgroup: isgroup));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) {
    chatRepository.setChatMessageSeen(context, receiverUserId, messageId);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    MessageEnum messageEnum,
    String receiverUserId,
    bool isgroup,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            messageEnum: messageEnum,
            ref: ref,
            senderUserData: value!,
            messageReply: messageReply,
            isgroup: isgroup));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifURL,
    String receiverUserId,
    bool isgroup,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    int gifPartIndex = gifURL.lastIndexOf('-') + 1;
    String gifUrlPart = gifURL.substring(gifPartIndex);
    String baseGIFUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    ref.read(userDataAuthProvider).whenData((value) =>
        chatRepository.sendGIFMessage(
            context: context,
            gifURL: baseGIFUrl,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            messageReply: messageReply!,
            isgroup: isgroup));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }
}
