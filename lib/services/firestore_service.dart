import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/services/auth.dart';

class FireStoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();

  Future<void> createUser(id, email, username, {photoUrl = ""}) async {
    await _firebaseFirestore.collection("users").doc(id).set({
      "username": username,
      "email": email,
      "photoUrl": photoUrl,
      "about": "",
      "creationDate": date
    });
  }

  Future<AppUsers?> searchUser(id) async {
    DocumentSnapshot data =
        await _firebaseFirestore.collection("users").doc(id).get();
    if (data.exists) {
      AppUsers? user = AppUsers.fromDocument(data);
      return user;
    } else {
      return null;
    }
  }
}
