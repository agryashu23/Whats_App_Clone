import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whats_app_clone/common/utils/colors.dart';
import 'package:whats_app_clone/common/enums/message_enum.dart';
import 'package:whats_app_clone/common/providers/message_reply.dart';
import 'package:whats_app_clone/common/utils/utils.dart';
import 'package:whats_app_clone/features/chat/controllers/chat_controller.dart';
import 'package:whats_app_clone/features/chat/widgets/message_reply_preview.dart';

// ignore: camel_case_types
class bottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isgroup;
  const bottomChatField({
    super.key,
    required this.receiverUserId,
    required this.isgroup,
  });

  @override
  ConsumerState<bottomChatField> createState() => _bottomChatFieldState();
}

// ignore: camel_case_types
class _bottomChatFieldState extends ConsumerState<bottomChatField> {
  bool isShowSend = false;
  final messageController = TextEditingController();
  bool isEmojiShow = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecordInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Mic Permission not allowed");
    }
    await _soundRecorder!.openRecorder();
    isRecordInit = true;
  }

  void sendTextMessage() async {
    if (isShowSend) {
      ref.read(chatControllerProvider).sendTextMessage(context,
          messageController.text.trim(), widget.receiverUserId, widget.isgroup);
      setState(() {
        messageController.text = "";
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecordInit) return;
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void hideEmojiCont() {
    setState(() {
      isEmojiShow = false;
    });
  }

  void showEmojiCont() {
    setState(() {
      isEmojiShow = true;
    });
  }

  void toggleEmoji() {
    if (isEmojiShow) {
      showKeyboard();
      hideEmojiCont();
    } else {
      hideKeyboard();
      showEmojiCont();
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  void dispose() {
    messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecordInit = false;
    super.dispose();
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
        context, file, messageEnum, widget.receiverUserId, widget.isgroup);
  }

  void selectImage() async {
    File? image = await pickImageGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      // ignore: use_build_context_synchronously
      ref.read(chatControllerProvider).sendGIFMessage(
          context, gif.url, widget.receiverUserId, widget.isgroup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: messageController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: toggleEmoji,
                            icon: isEmojiShow
                                ? const Icon(
                                    Icons.keyboard,
                                    color: Colors.grey,
                                  )
                                : const Icon(
                                    Icons.emoji_emotions,
                                    color: Colors.grey,
                                  ),
                          ),
                          IconButton(
                            onPressed: selectGIF,
                            icon: const Icon(
                              Icons.gif,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      isShowSend = true;
                      isEmojiShow = false;
                    });
                  } else {
                    isShowSend = false;
                    isEmojiShow = false;

                    setState(() {});
                  }
                },
                onTap: () {
                  setState(() {
                    isEmojiShow = false;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 3, left: 2),
              child: GestureDetector(
                onTap: sendTextMessage,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF128C7E),
                  child: Icon(isShowSend
                      ? Icons.send
                      : isRecording
                          ? Icons.close
                          : Icons.mic),
                ),
              ),
            )
          ],
        ),
        isEmojiShow
            ? SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      messageController.text += emoji.emoji;
                    });

                    if (!isShowSend) {
                      setState(() {
                        isShowSend = true;
                      });
                    }
                  },
                ),
              )
            : Container()
      ],
    );
  }
}
