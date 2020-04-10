import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  String email;
  String password;

  Future<void> registerNewUser() async {
    try {
      _authResult =
          await _auth.createUserWithEmailAndPassword(email: this.email, password: this.password);
    } catch (e) {
      print(e);
    }
  }

  bool isSuccessfulRegistration() {
    return (_authResult != null) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              onChanged: (value) {
                this.email = value;
              },
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              onChanged: (value) {
                this.password = value;
              },
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              label: 'Register',
              color: Colors.blueAccent,
              onPressed: () async {
                await registerNewUser();
                if (isSuccessfulRegistration()) {
                  Navigator.pushNamed(context, '/chat');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
