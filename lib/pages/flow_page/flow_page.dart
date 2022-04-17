import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/pages/widgets/undeletableFuture.dart';

import '../../models/posts.dart';
import '../../models/users.dart';
import '../../services/auth.dart';
import '../../services/firestore_service.dart';
import '../widgets/postCard.dart';

class FlowPage extends StatefulWidget {
  const FlowPage({Key? key}) : super(key: key);

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  List<Posts?> _posts = [];

  @override
  void initState() {
    super.initState();
    _getFlowPosts();
  }

  Future<void> _getFlowPosts() async {
    String? _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    List<Posts?> data = await FireStoreService().getFlowPosts(_activeUserId);
    if (mounted) {
      setState(() {
        _posts = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SocialApp'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _getFlowPosts,
          child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return UndeletableFutureBuilder(
                  future: FireStoreService().searchUser(_posts[index]?.publisherId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox();
                    }
                    AppUsers? user = snapshot.data;
                    return PostCards(post: _posts[index], user: user);
                  },
                );
              }),
        ));
  }
}
