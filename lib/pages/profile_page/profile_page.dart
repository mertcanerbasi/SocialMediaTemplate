import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/posts.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/pages/edit_profile_page/edit_profile_page.dart';
import 'package:socialmediaapp/pages/widgets/postCard.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  final String? profileOwnerId;
  const ProfilePage({Key? key, this.profileOwnerId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Posts?> _posts = [];
  String postStyle = "list";
  String? _activeUserId;
  AppUsers? _profileOwner;
  bool _followed = false;

  _getFollowersCount() async {
    int result = await FireStoreService().followersCount(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _followerCount = result;
      });
    }
  }

  _getPosts() async {
    List<Posts?> data = await FireStoreService().getPosts(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _posts = data;
        _postCount = data.length;
      });
    }
  }

  _getFollowingsCount() async {
    int result = await FireStoreService().followingsCount(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _followingCount = result;
      });
    }
  }

  _followingStatCheck() async {
    bool? check = await FireStoreService().followCheck(_activeUserId, widget.profileOwnerId);
    setState(() {
      _followed = check;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getFollowersCount();
    _getFollowingsCount();
    _getPosts();
    _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    _followingStatCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          widget.profileOwnerId == _activeUserId
              ? IconButton(
                  onPressed: () {
                    signOut();
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ))
              : SizedBox()
        ],
      ),
      body: FutureBuilder<AppUsers?>(
          future: FireStoreService().searchUser(widget.profileOwnerId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            _profileOwner = snapshot.data;

            return ListView(
              children: [_profileDetails(snapshot.data), _showPosts(snapshot.data)],
            );
          }),
    );
  }

  Widget _profileDetails(AppUsers? profileData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              children: [
                profileData?.fotoUrl != ""
                    ? Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 50,
                          backgroundImage: NetworkImage(profileData?.fotoUrl ?? ""),
                        ),
                      )
                    : Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 50,
                          backgroundImage: AssetImage("assets/images/default_user.png"),
                        ),
                      ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialCounters('Posts', _postCount),
                      _socialCounters('Followers', _followerCount),
                      _socialCounters('Following', _followingCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Text(profileData?.userName?.toUpperCase() ?? "Username", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: Text(profileData?.about ?? "About",
                style: TextStyle(
                  fontSize: 15,
                )),
          ),
          widget.profileOwnerId == _activeUserId ? _editProfileButton() : _followStatusButton()
        ],
      ),
    );
  }

  Widget _followStatusButton() {
    return _followed ? _unfollowButton() : _followButton();
  }

  Widget _editProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                        profile: _profileOwner,
                      ))).then((value) {
            setState(() {});
          });
        },
        child: const Text('Edit Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _socialCounters(String title, int sayi) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  void signOut() {
    AuthService().signOut();
  }

  GridTile _createGrid(Posts? post) {
    GridTile _widget = GridTile(
        child: Image.network(
      post!.postImageUrl ?? "",
      fit: BoxFit.cover,
    ));
    try {
      return _widget;
    } catch (e) {
      return GridTile(
        child: Container(),
      );
    }
  }

  Widget _showPosts(AppUsers? user) {
    if (postStyle == "list") {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return PostCards(
              post: _posts[index],
              user: user,
            );
          });
    } else {
      List<GridTile> grids = [];
      _posts.forEach((post) {
        grids.add(_createGrid(post));
      });

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: grids,
        ),
      );
    }
  }

  Widget _followButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          FireStoreService().follow(_activeUserId, widget.profileOwnerId);
          setState(() {
            _followed = true;
            _followerCount = _followerCount + 1;
          });
        },
        child: const Text('Follow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _unfollowButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          FireStoreService().unFollow(_activeUserId, widget.profileOwnerId);
          setState(() {
            _followed = false;
            _followerCount = _followerCount - 1;
          });
        },
        child: const Text('Unfollow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
