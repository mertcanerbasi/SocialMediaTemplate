import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (BuildContext context) => AuthService(),
      child: MaterialApp(
        title: 'Flutter Demoasdasda',
        theme: ThemeData(),
        home: const Navigation(),
      ),
    );
  }
}
