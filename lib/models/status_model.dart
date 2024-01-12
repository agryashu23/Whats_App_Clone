// ignore_for_file: public_member_api_docs, sort_constructors_first

class StatusModel {
  final String uid;
  final String username;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createdAt;
  final String proPic;
  final String statusId;
  final List<String> whocansee;

  StatusModel(
      {required this.uid,
      required this.username,
      required this.phoneNumber,
      required this.photoUrl,
      required this.createdAt,
      required this.proPic,
      required this.statusId,
      required this.whocansee});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'proPic': proPic,
      'statusId': statusId,
      'whocansee': whocansee,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      phoneNumber: map['phoneNumber'] as String,
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      proPic: map['proPic'] as String,
      statusId: map['statusId'] as String,
      whocansee: List<String>.from(map['whocansee']),
    );
  }
}
