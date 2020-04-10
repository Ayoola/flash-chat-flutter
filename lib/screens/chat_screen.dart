import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  String messageText;

  bool isLoggedIn() {
    return (currentUser != null) ? true : false;
  }

  void getCurrentUser() async {
    try {
      currentUser = await _auth.currentUser();
    } catch (e) {
      print(e);
    }
  }

  Future<void> logUserOut() async {
    await _auth.signOut();
  }

  Future<void> sendMessage() async {
    await _firestore.collection('messages').add(
      {
        'messageText': this.messageText,
        'messageSender': currentUser.email,
      },
    );
  }

  void getMessageStream() async {
    await for (var messageSnapshot in _firestore.collection('messages').snapshots()) {
      for (var document in messageSnapshot.documents) {
        print(document.data);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await logUserOut();
                Navigator.pushNamed(context, '/');
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: StreamBuilder(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, asyncSnapshot) {
                  List<Text> messageDocumentTextWidgets = [];
                  if (asyncSnapshot.hasData) {
                    QuerySnapshot messagesSnapshot = asyncSnapshot.data;
                    for (var document in messagesSnapshot.documents) {
                      final documentMessageText = document.data['messageText'];
                      final documentMessageSender = document.data['messageSender'];
                      final messageDocumentTextWidget = Text(
                        "$documentMessageText from $documentMessageSender}",
                      );
                      messageDocumentTextWidgets.add(messageDocumentTextWidget);
                    }
                  }
                  return Column(children: messageDocumentTextWidgets);
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        this.messageText = value;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await sendMessage();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
