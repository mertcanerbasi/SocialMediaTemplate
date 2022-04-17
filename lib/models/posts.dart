import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String? id;
  final String? postImageUrl;
  final String? about;
  final String? publisherId;
  final String? location;
  final int? likeCount;

  Posts({this.id, this.postImageUrl, this.about, this.publisherId, this.location, this.likeCount});

  factory Posts.fromDocument(DocumentSnapshot doc) {
    return Posts(
      id: doc.id,
      postImageUrl: doc['postImageUrl'],
      about: doc['about'],
      publisherId: doc['publisherId'],
      location: doc['location'],
      likeCount: doc['likeCount'],
    );
  }
}
