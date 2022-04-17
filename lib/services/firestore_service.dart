import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaapp/models/notifications.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/storage_service.dart';

import '../models/posts.dart';

class FireStoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();

  Future<void> createUser(id, email, username, {photoUrl = ""}) async {
    await _firebaseFirestore.collection("users").doc(id).set({"username": username, "email": email, "photoUrl": photoUrl, "about": "", "creationDate": date});
  }

  Future<AppUsers?> searchUser(id) async {
    DocumentSnapshot data = await _firebaseFirestore.collection("users").doc(id).get();
    if (data.exists) {
      AppUsers? user = AppUsers.fromDocument(data);
      return user;
    } else {
      return null;
    }
  }

  updateUser(String? userId, String? userName, String? about, {String? photoUrl = ""}) {
    _firebaseFirestore.collection("users").doc(userId).update({"username": userName, "about": about, "photoUrl": photoUrl});
  }

  follow(String? activeUserId, String? profileOwnerId) {
    _firebaseFirestore.collection("followers").doc(profileOwnerId).collection("usersFollowers").doc(activeUserId).set({});
    _firebaseFirestore.collection("followings").doc(activeUserId).collection("usersFollowings").doc(profileOwnerId).set({});
    if (activeUserId != profileOwnerId) {
      addNotification(activeUserId, profileOwnerId, "follow");
    }
  }

  unFollow(String? activeUserId, String? profileOwnerId) {
    _firebaseFirestore.collection("followers").doc(profileOwnerId).collection("usersFollowers").doc(activeUserId).get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    _firebaseFirestore.collection("followings").doc(activeUserId).collection("usersFollowings").doc(profileOwnerId).get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> followCheck(String? activeUserId, String? profileOwnerId) async {
    DocumentSnapshot doc = await _firebaseFirestore.collection("followings").doc(activeUserId).collection("usersFollowings").doc(profileOwnerId).get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> followersCount(String? userId) async {
    QuerySnapshot _snapshot = await _firebaseFirestore.collection("followers").doc(userId).collection("usersFollowers").get();
    return _snapshot.docs.length;
  }

  Future<int> followingsCount(String? userId) async {
    QuerySnapshot _snapshot = await _firebaseFirestore.collection("followings").doc(userId).collection("usersFollowings").get();
    return _snapshot.docs.length;
  }

  addNotification(String? activityUserId, String? profileOwnerId, String? activityType, {String? comment, Posts? post}) {
    _firebaseFirestore
        .collection("notifications")
        .doc(profileOwnerId)
        .collection("usersNotificaitons")
        .add({"activityUserId": activityUserId, "activityType": activityType, "postId": post?.id, "postPhoto": post?.postImageUrl, "comment": comment, "creationTime": date});
  }

  Future<List<Notifications?>> getNotifications(
    String? profileOwnerId,
  ) async {
    QuerySnapshot snapshot = await _firebaseFirestore.collection("notifications").doc(profileOwnerId).collection("usersNotificaitons").orderBy("creationTime", descending: true).limit(20).get();
    List<Notifications?> notifications = [];
    snapshot.docs.forEach((DocumentSnapshot doc) {
      Notifications notification = Notifications.fromDocument(doc);
      notifications.add(notification);
    });
    return notifications;
  }

  Future<int> postCounts(id) async {
    QuerySnapshot _snapshot = await _firebaseFirestore.collection("posts").doc(id).collection("usersPosts").get();
    return _snapshot.docs.length;
  }

  Future<void> createPost({postImageUrl, about, publisherId, location}) async {
    await _firebaseFirestore.collection("posts").doc(publisherId).collection("usersPosts").add(
      {"postImageUrl": postImageUrl, "about": about, "location": location, "publisherId": publisherId, "likeCount": 0, "creationDate": date},
    );
  }

  Future<List<Posts?>> getPosts(String? userId) async {
    QuerySnapshot snapshot = await _firebaseFirestore.collection("posts").doc(userId).collection("usersPosts").orderBy("creationDate", descending: true).get();
    List<Posts?> posts = snapshot.docs.map((doc) => Posts.fromDocument(doc)).toList();
    return posts;
  }

  Future<List<Posts?>> getFlowPosts(String? userId) async {
    QuerySnapshot snapshot = await _firebaseFirestore.collection("flows").doc(userId).collection("userFlowPosts").orderBy("creationDate", descending: true).get();
    List<Posts?> posts = snapshot.docs.map((doc) => Posts.fromDocument(doc)).toList();
    return posts;
  }

  likePost(Posts? post, String? activeUserId) async {
    var docRef = _firebaseFirestore.collection("posts").doc(post!.publisherId).collection("usersPosts");
    DocumentSnapshot doc = await docRef.doc(post.id).get();
    if (doc.exists) {
      Posts data = Posts.fromDocument(doc);
      int likeCount = data.likeCount! + 1;
      docRef.doc(data.id).update({
        "likeCount": likeCount,
      });

      _firebaseFirestore.collection("likes").doc(post.id).collection("postLikes").doc(activeUserId).set({});
      if (activeUserId != post.publisherId) {
        addNotification(activeUserId, post.publisherId, "like", post: post);
      }
    }
  }

  removeLikePost(Posts? post, String? activeUserId) async {
    var docRef = _firebaseFirestore.collection("posts").doc(post!.publisherId).collection("usersPosts");
    DocumentSnapshot doc = await docRef.doc(post.id).get();
    if (doc.exists) {
      Posts data = Posts.fromDocument(doc);
      int likeCount = data.likeCount! - 1;
      docRef.doc(data.id).update({
        "likeCount": likeCount,
      });
      DocumentSnapshot docLike = await _firebaseFirestore.collection("likes").doc(post.id).collection("postLikes").doc(activeUserId).get();
      if (docLike.exists) {
        docLike.reference.delete();
      }
    }
  }

  Future<bool> likeCheck(Posts? post, String? activeUserId) async {
    DocumentSnapshot docLike = await _firebaseFirestore.collection("likes").doc(post!.id).collection("postLikes").doc(activeUserId).get();
    if (docLike.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> getComments(String? postId) {
    return _firebaseFirestore.collection("comments").doc(postId).collection("postComments").orderBy("creationDate", descending: true).snapshots();
  }

  addComment(String? activeUserId, Posts? post, String content) {
    _firebaseFirestore.collection("comments").doc(post?.id).collection("postComments").add({
      "content": content,
      "publisherId": activeUserId,
      "creationDate": date,
    });
    if (activeUserId != post!.publisherId) {
      addNotification(activeUserId, post.publisherId, "comment", post: post, comment: content);
    }
  }

  Future<List<AppUsers?>> discoverSearchUser(String word) async {
    QuerySnapshot snapshot = await _firebaseFirestore.collection("users").where("username", isGreaterThanOrEqualTo: word).get();
    List<AppUsers?> users = snapshot.docs.map((doc) => AppUsers.fromDocument(doc)).toList();
    return users;
  }

  getOnePost(String? postId, String? postOwnerId) async {
    var docRef = _firebaseFirestore.collection("posts").doc(postOwnerId).collection("usersPosts");
    DocumentSnapshot doc = await docRef.doc(postId).get();
    Posts? posts = Posts.fromDocument(doc);
    return posts;
  }

  deletePost(String? activeUserId, Posts? post) async {
    var docRef = _firebaseFirestore.collection("posts").doc(activeUserId).collection("usersPosts");
    DocumentSnapshot doc = await docRef.doc(post!.id).get();
    if (doc.exists) {
      doc.reference.delete();
    }
    QuerySnapshot comment_snapshot = await _firebaseFirestore.collection("comments").doc(post.id).collection("postComments").get();
    comment_snapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot notification_snapshot = await _firebaseFirestore.collection("notifications").doc(activeUserId).collection("usersNotificaitons").where("postId", isEqualTo: post.id).get();
    notification_snapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    StorageService().deletePostImage(post.postImageUrl);
  }
}
