import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  final String? id;
  final String? content;
  final String? publisherId;
  final Timestamp? creationDate;

  Comments({this.id, this.content, this.publisherId, this.creationDate});

  factory Comments.fromDocument(DocumentSnapshot? doc) {
    return Comments(
      id: doc?.id,
      content: doc?['content'],
      publisherId: doc?['publisherId'],
      creationDate: doc?['creationDate'],
    );
  }
}
