import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app_clone/common/enums/message_enum.dart';
import 'package:whats_app_clone/common/providers/message_reply.dart';
import 'package:whats_app_clone/common/repository/firebase_storage_repo.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/models/chat_contact.dart';
import 'package:whats_app_clone/models/group.dart';
import 'package:whats_app_clone/models/message.dart';
import 'package:whats_app_clone/models/user_model.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getchatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timesent: chatContact.timesent,
            lastMessage: chatContact.lastMessage));
      }
      return contacts;
    });
  }

  Stream<List<GroupModel>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<GroupModel> groups = [];
      for (var document in event.docs) {
        var group = GroupModel.fromMap(document.data());
        if (group.memberUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatsStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timesent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      // print(messages);
      return messages;
    });
  }

  Stream<List<Message>> getGroupsStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timesent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      // print(messages);
      return messages;
    });
  }

  void _saveDatatoSubCollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timesent,
    String receiverUserId,
    bool isgroup,
  ) async {
    if (isgroup) {
      await firestore.collection('groups').doc(receiverUserId).update({
        'lastmessage': text,
        'timesent': DateTime.now().millisecondsSinceEpoch
      });
    } else {
      var receiverChatcontact = ChatContact(
          name: senderUserData.name,
          profilePic: senderUserData.profilePic,
          contactId: senderUserData.uid,
          timesent: timesent,
          lastMessage: text);

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(senderUserData.uid)
          .set(receiverChatcontact.toMap());
      //sender-receiver
      var senderChatcontact = ChatContact(
          name: receiverUserData!.name,
          profilePic: receiverUserData.profilePic,
          contactId: receiverUserData.uid,
          timesent: timesent,
          lastMessage: text);

      await firestore
          .collection('users')
          .doc(senderUserData.uid)
          .collection('chats')
          .doc(receiverUserId)
          .set(senderChatcontact.toMap());
    }
  }

  void _saveMessagetoSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String senderUsername,
    required String? receiverUsername,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isgroup,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageEnum,
      timesent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverUsername ?? "",
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );

    if (isgroup) {
      await firestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUserData,
    required MessageReply? messageReply,
    required bool isgroup,
  }) async {
    try {
      var timesent = DateTime.now();
      UserModel? receiverUserData;

      if (!isgroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();
      _saveDatatoSubCollection(
        senderUserData,
        receiverUserData,
        text,
        timesent,
        receiverUserId,
        isgroup,
      );

      _saveMessagetoSubCollection(
          receiverUserId: receiverUserId,
          text: text,
          timeSent: timesent,
          messageId: messageId,
          senderUsername: senderUserData.name,
          receiverUsername: receiverUserData?.name,
          messageEnum: MessageEnum.text,
          messageReply: messageReply,
          isgroup: isgroup);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isgroup,
  }) async {
    try {
      var timesent = DateTime.now();
      var messageId = const Uuid().v1();

      String fileUrl = await ref
          .read(commonFirebaseStorageProvider)
          .storeToFirebase(
              '/chats/${messageEnum.type}/${senderUserData.uid}/$receiverUserId',
              file);
      UserModel? receiverUserData;
      if (!isgroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }
      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎙️ Audio';
        case MessageEnum.gif:
          contactMsg = 'GIF';
        default:
          contactMsg = 'Text';
          break;
      }
      _saveDatatoSubCollection(senderUserData, receiverUserData, contactMsg,
          timesent, receiverUserId, isgroup);

      _saveMessagetoSubCollection(
        receiverUserId: receiverUserId,
        text: fileUrl,
        timeSent: timesent,
        messageId: messageId,
        senderUsername: senderUserData.name,
        receiverUsername: receiverUserData?.name,
        messageEnum: messageEnum,
        messageReply: messageReply,
        isgroup: isgroup,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifURL,
    required String receiverUserId,
    required UserModel senderUserData,
    required MessageReply messageReply,
    required bool isgroup,
  }) async {
    try {
      var timesent = DateTime.now();
      UserModel? receiverUserData;
      if (!isgroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }
      var messageId = const Uuid().v1();
      _saveDatatoSubCollection(
        senderUserData,
        receiverUserData,
        "GIF",
        timesent,
        receiverUserId,
        isgroup,
      );

      _saveMessagetoSubCollection(
          receiverUserId: receiverUserId,
          text: gifURL,
          timeSent: timesent,
          messageId: messageId,
          senderUsername: senderUserData.name,
          receiverUsername: receiverUserData?.name,
          messageEnum: MessageEnum.gif,
          messageReply: messageReply,
          isgroup: isgroup);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }

  void setChatMessageSeen(
      BuildContext context, String receiverUserId, String messageId) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({"isSeen": true});
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context: context, text: e.toString());
    }
  }
}
