import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmediaapp/models/users.dart';
import 'package:socialmediaapp/services/auth.dart';
import 'package:socialmediaapp/services/firestore_service.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({Key? key}) : super(key: key);

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create Account')),
        body: ListView(
          children: [
            _loading
                ? const LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                  child: Column(
                    children: [
                      TextFormField(
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter email',
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
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.blue[500]),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  void _forgotPassword() async {
    final _authService = Provider.of<AuthService>(context, listen: false);

    var _formState = _formKey.currentState;
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        _loading = true;
      });
      try {
        await _authService.resetPassword(email);
        Navigator.pop(context);
      } on FirebaseAuthException catch (error) {
        setState(() {
          _loading = false;
        });
        var errorMessage = _showError(errorCode: error.code);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }

  _showError({required errorCode}) {
    String errorMessage = '';
    if (errorCode == 'invalid-email') {
      errorMessage = 'Invalid Mail';
    } else if (errorCode == 'user-not-found') {
      errorMessage = 'User not found';
    }
    return "ERROR " + errorMessage;
  }
}
