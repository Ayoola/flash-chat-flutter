import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  FirebaseUser currentUser;
  String email;
  String password;

  Future<void> logUserIn() async {
    try {
      _authResult =
          await _auth.signInWithEmailAndPassword(email: this.email, password: this.password);
    } catch (e) {
      print(e);
    }
  }

  bool isSuccessfulLogin() {
    return (_authResult != null) ? true : false;
  }

  bool isLoggedIn() {
    return (currentUser != null) ? true : false;
  }

  @override
  void initState() {
    super.initState();
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
              label: 'Log In',
              color: Colors.lightBlueAccent,
              onPressed: () async {
                await logUserIn();
                if (isSuccessfulLogin()) {
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
