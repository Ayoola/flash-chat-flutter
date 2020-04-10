import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  String email;
  String password;
  bool isSpinnerVisible = false;

  Future<void> logUserIn() async {
    try {
      _authResult =
          await _auth.signInWithEmailAndPassword(email: this.email, password: this.password);
    } catch (e) {
      print(e);
    }
  }

  void toggleSpinner() {
    if (isSpinnerVisible == true) {
      setState(() {
        isSpinnerVisible = false;
      });
    } else {
      setState(() {
        isSpinnerVisible = true;
      });
    }
  }

  bool isSuccessfulLogin() {
    return (_authResult != null) ? true : false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isSpinnerVisible,
        child: Padding(
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
                  toggleSpinner();
                  await logUserIn();
                  toggleSpinner();
                  if (isSuccessfulLogin()) {
                    Navigator.pushNamed(context, '/chat');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
