import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/comments.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/posts.dart';
import '../../models/users.dart';

class CommentsPage extends StatefulWidget {
  final Posts? post;
  const CommentsPage({Key? key, this.post}) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Comments",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [_showComments(), _addComment()],
      ),
    );
  }

  Widget _showComments() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FireStoreService().getComments(widget.post?.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Comments comment = Comments.fromDocument(snapshot.data?.docs[index]);
                return _commentLine(comment);
              });
        },
      ),
    );
  }

  Widget _addComment() {
    return ListTile(
      title: TextFormField(
        controller: _commentController,
        keyboardType: TextInputType.multiline,
        maxLength: null,
        maxLines: null,
        decoration: InputDecoration(hintText: "Comment Here"),
      ),
      trailing: IconButton(onPressed: _sendComment, icon: Icon(Icons.send)),
    );
  }

  void _sendComment() {
    String? _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    FireStoreService().addComment(_activeUserId, widget.post, _commentController.text);
    _commentController.clear();
  }

  Widget _commentLine(Comments? comment) {
    return FutureBuilder<AppUsers?>(
        future: FireStoreService().searchUser(comment!.publisherId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          AppUsers? publisher = snapshot.data;
          return ListTile(
            leading: publisher?.fotoUrl != ""
                ? CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(publisher?.fotoUrl ?? ""),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: AssetImage("assets/images/default_user.png"),
                  ),
            title: RichText(
              text: TextSpan(text: "${publisher!.userName}" + " ", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), children: [
                TextSpan(
                  text: comment.content ?? "",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                )
              ]),
            ),
            subtitle: Text(timeago.format(comment.creationDate!.toDate(), locale: "tr")),
          );
        });
  }
}
