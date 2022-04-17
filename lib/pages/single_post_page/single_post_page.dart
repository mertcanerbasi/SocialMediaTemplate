import 'package:flutter/material.dart';
import 'package:socialmediaapp/pages/widgets/postCard.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

import '../../models/posts.dart';
import '../../models/users.dart';

class SinglePostPage extends StatefulWidget {
  final String? postId, postOwnerId;
  const SinglePostPage({Key? key, this.postId, this.postOwnerId}) : super(key: key);

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  Posts? _post;
  AppUsers? _postOwner;
  bool _loading = true;

  _getPost(String? postId, String? postOwnerId) async {
    Posts? post = await FireStoreService().getOnePost(postId, postOwnerId);
    if (post != null) {
      AppUsers? owner = await FireStoreService().searchUser(post.publisherId);
      if (mounted) {
        setState(() {
          _post = post;
          _postOwner = owner;
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPost(widget.postId, widget.postOwnerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Post",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: _loading == false ? PostCards(post: _post, user: _postOwner) : Center(child: CircularProgressIndicator()),
    );
  }
}
