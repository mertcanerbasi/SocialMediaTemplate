import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/notifications.dart';
import 'package:socialmediaapp/pages/profile_page/profile_page.dart';
import 'package:socialmediaapp/pages/single_post_page/single_post_page.dart';
import 'package:socialmediaapp/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/users.dart';
import '../../services/auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notifications?>? notifications;
  String? _activeUserId;
  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activeUserId = Provider.of<AuthService>(context, listen: false).activeUserId;
    _getNotification();
  }

  Future<void> _getNotification() async {
    List<Notifications?>? notification = await FireStoreService().getNotifications(_activeUserId);
    if (mounted) {
      setState(() {
        notifications = notification;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: showNotifications(),
    );
  }

  Widget showNotifications() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (notifications!.isEmpty) {
      return Center(
        child: Text("You have not any notifications"),
      );
    }
    return RefreshIndicator(
      onRefresh: _getNotification,
      child: ListView.builder(
          itemCount: notifications?.length,
          itemBuilder: ((context, index) {
            Notifications? notification = notifications?[index];
            return _notificationLine(notification);
          })),
    );
  }

  Widget _notificationLine(Notifications? notification) {
    String? message = _createNotificationMessage(notification!.activityType);
    return FutureBuilder<AppUsers?>(
        future: FireStoreService().searchUser(notification.activatyUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          AppUsers? user = snapshot.data;
          return ListTile(
            leading: user?.fotoUrl != ""
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    profileOwnerId: notification.activatyUserId,
                                  )));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(user?.fotoUrl ?? ""),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    profileOwnerId: notification.activatyUserId,
                                  )));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: AssetImage("assets/images/default_user.png"),
                    ),
                  ),
            title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    profileOwnerId: notification.activatyUserId,
                                  )));
                    }),
                  text: "${user!.userName}" + " ",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = (() {
                          notification.activityType != 'follow'
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SinglePostPage(
                                            postId: notification.postId,
                                            postOwnerId: _activeUserId,
                                          )))
                              : null;
                        }),
                      text: "$message \n${notification.comment ?? " "}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    )
                  ]),
            ),
            subtitle: Text(timeago.format(notification.creationTime!.toDate(), locale: "tr")),
            trailing: notification.postPhoto != null
                ? GestureDetector(
                    onTap: () {
                      notification.activityType != 'follow'
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SinglePostPage(
                                        postId: notification.postId,
                                        postOwnerId: _activeUserId,
                                      )))
                          : null;
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: Center(child: Image.network(notification.postPhoto!)),
                    ),
                  )
                : null,
          );
        });
  }

  _createNotificationMessage(String? type) {
    if (type == "like") {
      return "liked your post";
    } else if (type == "follow") {
      return "followed you";
    } else if (type == "comment") {
      return "commented on your post";
    }
    return null;
  }
}
