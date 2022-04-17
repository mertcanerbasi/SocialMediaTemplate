import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/pages/home_page.dart';
import 'package:socialmediaapp/pages/landing_page/landing_page.dart';
import 'package:socialmediaapp/services/auth.dart';

class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder(
        stream: _authService.stateControl,
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshots.hasData) {
            AppUsers activeUser = snapshots.data as AppUsers;
            _authService.activeUserId = activeUser.id;
            return const Homepage();
          } else {
            return const LandingPage();
          }
        });
  }
}
