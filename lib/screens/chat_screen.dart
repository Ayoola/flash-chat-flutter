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
        'timestamp': DateTime.now(),
      },
    );
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
              stream: _firestore.collection('messages').orderBy('timestamp', descending: true).snapshots(),
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
                      isMyBubble: documentMessageSender == currentUser.email,
                    );
                    messageBubbles.add(messageBubble);
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
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
  final bool isMyBubble;

  MessageBubble({this.messageSender, this.messageText, this.isMyBubble});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: isMyBubble ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            messageSender,
            style: TextStyle(
              fontSize: 10.0,
            ),
          ),
          Material(
            elevation: 1.0,
            borderRadius: BorderRadius.only(
              topLeft: !isMyBubble ? Radius.circular(1.0) : Radius.circular(15.0),
              topRight: isMyBubble ? Radius.circular(1.0) : Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
            color: isMyBubble ? Colors.lightBlueAccent : Colors.purpleAccent,
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
