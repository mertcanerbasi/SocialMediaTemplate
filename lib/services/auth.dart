import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialmediaapp/models/users.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<AppUsers?> get stateControl {
    return _firebaseAuth.authStateChanges().map(_createUser);
  }
  
    Future<AppUsers?> signupWithMail(String email, String password) async {
    var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _createUser(result.user);
  }

  signOut() {
    return _firebaseAuth.signOut();
  }


  Future<AppUsers?> loginWithMail(String email, String password) async {
    var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _createUser(result.user);
  }

  AppUsers? _createUser(User? user) {
    return user == null ? null : AppUsers.fromFirebase(user);
  }


  Future<AppUsers?> loginWithGoogle() async {
    GoogleSignInAccount? googleAccount =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();
    GoogleSignInAuthentication? googleAuthentication =
        await googleAccount!.authentication;
    AuthCredential? authCreds = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);
    UserCredential userCreds =
        await _firebaseAuth.signInWithCredential(authCreds);

    return _createUser(userCreds.user);
  }
}
