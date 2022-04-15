import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialmediaapp/pages/discover_page/discover_page.dart';
import 'package:socialmediaapp/pages/flow_page/flow_page.dart';
import 'package:socialmediaapp/pages/notifications_page/notifications_page.dart';
import 'package:socialmediaapp/pages/profile_page/profile_page.dart';
import 'package:socialmediaapp/pages/upload_page/upload_page.dart';
import 'package:socialmediaapp/services/auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _activePage = 0;
  PageController? _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          FlowPage(),
          DiscoverPage(),
          UploadPage(),
          NotificationsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activePage,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey[300],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Flow'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (value) {
          setState(() {
            _activePage = value;
            _pageController?.jumpToPage(_activePage);
          });
        },
      ),
    );
  }
}
