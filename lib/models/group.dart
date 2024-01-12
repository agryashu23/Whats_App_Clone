// ignore_for_file: public_member_api_docs, sort_constructors_first
class GroupModel {
  final String senderId;
  final String name;
  final String groupId;
  final String lastmessage;
  final String groupPic;
  final List<String> memberUid;
  final DateTime timesent;
  GroupModel(
      {required this.senderId,
      required this.name,
      required this.groupId,
      required this.lastmessage,
      required this.groupPic,
      required this.memberUid,
      required this.timesent});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'name': name,
      'groupId': groupId,
      'lastmessage': lastmessage,
      'groupPic': groupPic,
      'memberUid': memberUid,
      'timesent': timesent.millisecondsSinceEpoch
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      senderId: map['senderId'] as String,
      name: map['name'] as String,
      groupId: map['groupId'] as String,
      lastmessage: map['lastmessage'] as String,
      groupPic: map['groupPic'] as String,
      memberUid: List<String>.from(map['memberUid']),
      timesent: DateTime.fromMillisecondsSinceEpoch(map['timesent'] as int),
    );
  }
}
