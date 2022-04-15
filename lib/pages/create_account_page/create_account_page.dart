import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  String? username, email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Account')),
        body: ListView(
          children: [
            _loading
                ? LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                  )
                : SizedBox(),
            SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextFormField(
                            autocorrect: true,
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              labelText: 'Username',
                              hintText: 'Enter Username',
                              prefix: SizedBox(
                                width: 10,
                              ),
                              focusColor: null,
                              errorStyle: TextStyle(fontSize: 12),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Username can not be empty";
                              } else if ((value.trim().length < 4) ||
                                  (value.trim().length > 10)) {
                                return "Username should be between 5 and 10 characters";
                              }
                              return null;
                            },
                            onSaved: (value) => username = value),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              labelText: 'E-mail',
                              hintText: 'Enter your e-mail',
                              prefix: SizedBox(
                                width: 10,
                              ),
                              focusColor: null,
                              errorStyle: TextStyle(fontSize: 12),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "E-mail can not be empty";
                              } else if (!value.contains("@")) {
                                return "Please provide a valid mail adress";
                              }
                              return null;
                            },
                            onSaved: (value) => email = value),
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
                              labelText: 'Password',
                              prefix: SizedBox(
                                width: 10,
                              ),
                              hintText: 'Enter your password',
                              errorStyle: TextStyle(fontSize: 12)),
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
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createAccount,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue[500]),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  void _createAccount() async {
    final _authService = Provider.of<AuthService>(context, listen: false);

    var _formState = _formKey.currentState;
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        _loading = true;
      });
      try {
        AppUsers? user = await _authService.signupWithMail(email!, password!);
        if (user != null) {
          FireStoreService().createUser(user.id, user.email, user.userName);
        }
        Navigator.pop(context);
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
    } else if (errorCode == 'weak-password') {
      errorMessage = 'Weak Password';
    } else if (errorCode == 'email-already-in-use') {
      errorMessage = 'Mail is already in use';
    }
    return errorMessage;
  }
}
