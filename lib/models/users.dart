import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUsers {
  final String? id;
  final String? userName;
  final String? fotoUrl;
  final String? email;
  final String? about;

  AppUsers({this.id, this.userName, this.fotoUrl, this.email, this.about});

  factory AppUsers.fromFirebase(User user) {
    return AppUsers(
      id: user.uid,
      userName: user.displayName,
      fotoUrl: user.photoURL,
      email: user.email,
    );
  }

  factory AppUsers.fromDocument(DocumentSnapshot doc) {
    return AppUsers(
      id: doc.id,
      userName: doc['username'],
      fotoUrl: doc['photoUrl'],
      email: doc['email'],
      about: doc['about'],
    );
  }
}
