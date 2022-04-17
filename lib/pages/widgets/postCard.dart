import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/posts.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/pages/profile_page/profile_page.dart';

import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

import '../comments_page/comments_page.dart';

class PostCards extends StatefulWidget {
  final Posts? post;
  final AppUsers? user;

  const PostCards({Key? key, this.post, this.user}) : super(key: key);
  @override
  State<PostCards> createState() => _PostCardsState();
}

class _PostCardsState extends State<PostCards> {
  int? _likeCount = 0;
  bool _didUserLike = false;
  String? _activeUserId;
  @override
  void initState() {
    super.initState();
    _likeCount = widget.post!.likeCount;
    _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    _likeExists();
  }

  _likeExists() async {
    bool likeExists = await FireStoreService().likeCheck(widget.post, _activeUserId);
    if (likeExists) {
      if (mounted) {
        setState(() {
          _didUserLike = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [_postTitle(), _postImage(), _postFooter()],
        ));
  }

  _postOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("What you want to do ?"),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  FireStoreService().deletePost(_activeUserId, widget.post);

                  Navigator.pop(context);
                },
                child: Text("Delete Post"),
              ),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"))
            ],
          );
        }).then((value) {
      dispose();
    });
  }

  Widget _postTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ListTile(
        leading: widget.user?.fotoUrl != ""
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              profileOwnerId: widget.user!.id,
                            )),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(widget.user!.fotoUrl ?? ""),
                  radius: 20,
                ),
              )
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              profileOwnerId: widget.user!.id,
                            )),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage("assets/images/default_user.png"),
                ),
              ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(
                        profileOwnerId: widget.user!.id,
                      )),
            );
          },
          child: Text(
            widget.user!.userName ?? "Username",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: _activeUserId == widget.post?.publisherId
            ? IconButton(
                onPressed: () {
                  _postOptions();
                },
                icon: const Icon(Icons.more_vert))
            : null,
        contentPadding: const EdgeInsets.all(0),
      ),
    );
  }

  Widget _postImage() {
    return GestureDetector(
      onDoubleTap: () {
        _changeLikeStatus();
      },
      child: Image.network(
        widget.post?.postImageUrl ?? "",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _postFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              iconSize: 30,
              onPressed: _changeLikeStatus,
              icon: _didUserLike
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : Icon(Icons.favorite_border),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => CommentsPage(
                          post: widget.post,
                        )),
                  ),
                );
              },
              icon: const Icon(Icons.comment),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            "${_likeCount} Likes",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        widget.post!.about!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: RichText(
                  text: TextSpan(text: "${widget.user!.userName} ", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), children: [
                    TextSpan(
                      text: widget.post!.about ?? "About",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    )
                  ]),
                ),
              )
            : const SizedBox(),
        Row()
      ],
    );
  }

  void _changeLikeStatus() {
    if (_didUserLike) {
      print("remove like");
      setState(() {
        _likeCount = _likeCount! - 1;
        _didUserLike = false;
      });
      FireStoreService().removeLikePost(widget.post, _activeUserId);
    } else {
      print("add like");
      setState(() {
        _likeCount = _likeCount! + 1;
        _didUserLike = true;
      });
      FireStoreService().likePost(widget.post, _activeUserId);
    }
  }
}
