class StatusModel {
  final String uid;
  final String userName;
  final String phoneNumber;
  final String profilePic;
  final String statusId;
  final List<String> photoUrl;
  final DateTime createdAt;
  final List<String> whoCanSee;

  StatusModel({
    required this.uid,
    required this.userName,
    required this.phoneNumber,
    required this.profilePic,
    required this.statusId,
    required this.photoUrl,
    required this.createdAt,
    required this.whoCanSee,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'statusId': statusId,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'whoCanSee': whoCanSee,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    DateTime createdAt = map['createdAt'].toDate();

    return StatusModel(
      uid: map['uid'] as String,
      userName: map['userName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      profilePic: map['profilePic'] as String,
      statusId: map['statusId'] as String,
      photoUrl: List<String>.from((map['photoUrl'] ?? [])),
      createdAt: createdAt,
      whoCanSee: List<String>.from((map['whoCanSee'] ?? [])),
    );
  }
}
