import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference _storage = FirebaseStorage.instance.ref();
  String? imageId;

  Future<String> uploadImage(File image) async {
    imageId = Uuid().v4();
    TaskSnapshot snapshot = await _storage.child("images/posts/post_$imageId.jpg").putFile(image);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(File image) async {
    imageId = Uuid().v4();
    TaskSnapshot snapshot = await _storage.child("images/profile/profile_$imageId.jpg").putFile(image);
    return await snapshot.ref.getDownloadURL();
  }

  deletePostImage(String? postImageUrl) async {
    RegExp search = RegExp(r"post_.+\.jpg");
    var result = search.firstMatch("$postImageUrl");
    String? fileName = result?[0];

    if (fileName != null) {
      await _storage.child("images/posts/$fileName").delete();
    }
  }
}
