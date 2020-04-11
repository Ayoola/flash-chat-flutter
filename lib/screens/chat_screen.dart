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
  final messageTextController = TextEditingController();

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
            StreamBuilder(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, asyncSnapshot) {
                List<MessageBubble> messageBubbles = [];
                if (asyncSnapshot.hasData) {
                  QuerySnapshot messagesSnapshot = asyncSnapshot.data;
                  for (var document in messagesSnapshot.documents) {
                    final documentMessageText = document.data['messageText'];
                    final documentMessageSender = document.data['messageSender'];
                    final messageBubble = MessageBubble(
                      messageSender: documentMessageSender,
                      messageText: documentMessageText,
                    );
                    messageBubbles.add(messageBubble);
                  }
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
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
                      messageTextController.clear();
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

class MessageBubble extends StatelessWidget {
  final String messageSender;
  final String messageText;

  MessageBubble({this.messageSender, this.messageText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            messageSender,
            style: TextStyle(
              fontSize: 10.0,
            ),
          ),
          Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                messageText,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
