import 'package:whats_app_clone/common/enums/message_enum.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timesent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.text,
      required this.type,
      required this.timesent,
      required this.messageId,
      required this.isSeen,
      required this.repliedMessage,
      required this.repliedTo,
      required this.repliedMessageType});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timesent': timesent.microsecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String,
      type: (map['type'] as String).toEnum(),
      timesent: DateTime.fromMillisecondsSinceEpoch(map['timesent'] as int),
      messageId: map['messageId'] as String,
      isSeen: map['isSeen'] as bool,
      repliedMessage: map['repliedMessage'] ?? '',
      repliedTo: map['repliedTo'] ?? '',
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }
}
