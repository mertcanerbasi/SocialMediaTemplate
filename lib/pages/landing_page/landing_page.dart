import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/pages/create_account_page/create_account_page.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  String? email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: [_PageElements(), _loadingAnimation()]));
  }

  Widget _loadingAnimation() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _PageElements() {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 150),
          child: ListView(
            // physics: NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  'Social Media',
                  style: GoogleFonts.lobsterTwo(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        letterSpacing: .5,
                        fontSize: 40,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey)),
                child: TextFormField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Enter your e-mail',
                    prefix: SizedBox(
                      width: 10,
                    ),
                    focusColor: null,
                    errorStyle: TextStyle(fontSize: 12),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "E-mail can not be empty";
                    } else if (!value.contains("@")) {
                      return "Please provide a valid mail adress";
                    }
                    return null;
                  },
                  onSaved: (value) => email = value,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey)),
                child: TextFormField(
                  autocorrect: false,
                  obscureText: true,
                  decoration: const InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      prefix: SizedBox(
                        width: 10,
                      ),
                      hintText: 'Enter your password',
                      errorStyle: TextStyle(fontSize: 12)),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password can not be empty";
                    } else if (value.length < 4) {
                      return "Password must be at least 5 charactes";
                    }
                    return null;
                  },
                  onSaved: (value) => password = value,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAccountPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.blue[500]),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.blue[800]),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text('or'),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _signinWithGoogle();
                  },
                  child: Text(
                    'Login with Google',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text('Forgot Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    final _authService = Provider.of<AuthService>(context, listen: false);
    var _formState = _formKey.currentState;
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        _loading = true;
      });

      try {
        await _authService.loginWithMail(email!, password!);
      } on FirebaseAuthException catch (error) {
        setState(() {
          _loading = false;
        });
        var errorMessage = _showError(errorCode: error.code);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 1),
        ));
      }
    }
  }

  _showError({required errorCode}) {
    String errorMessage = '';
    if (errorCode == 'invalid-email') {
      errorMessage = 'Invalid Mail';
    } else if (errorCode == 'user-disabled') {
      errorMessage = 'Account Suspended';
    } else if (errorCode == 'user-not-found' || errorCode == 'wrong-password') {
      errorMessage = 'Wrong mail or password';
    }
    return errorMessage;
  }

  _signinWithGoogle() async {
    var _authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _loading = true;
    });

    try {
      AppUsers? user = await _authService.loginWithGoogle();

      if (user != null) {
        AppUsers? fireStoreUser = await FireStoreService().searchUser(user.id);
        if (fireStoreUser == null) {
          FireStoreService().createUser(user.id, user.email, user.userName,
              photoUrl: user.fotoUrl);
          print("User created");
        }
      }
    } on FirebaseAuthException catch (error) {
      print(error.code);
      setState(() {
        _loading = false;
      });
      var errorMessage = _showError(errorCode: error.code);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
