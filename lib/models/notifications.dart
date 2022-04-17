import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String? id;
  final String? activatyUserId;
  final String? activityType;
  final String? postId;
  final String? postPhoto;
  final String? comment;
  final Timestamp? creationTime;

  Notifications({this.id, this.activatyUserId, this.activityType, this.postId, this.postPhoto, this.comment, this.creationTime});
  factory Notifications.fromDocument(DocumentSnapshot doc) {
    return Notifications(
      id: doc.id,
      activatyUserId: doc['activityUserId'],
      activityType: doc['activityType'],
      postId: doc['postId'],
      postPhoto: doc['postPhoto'],
      comment: doc['comment'],
      creationTime: doc['creationTime'],
    );
  }
}
