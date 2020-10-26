import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvator;
  final String receiverName;
  Chat({Key key,@required this.receiverId,@required this.receiverAvator,@required this.receiverName});
  @override
  Widget build(BuildContext context) {

    return Scaffold
      (
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black87,
              backgroundImage: CachedNetworkImageProvider(receiverAvator),
            ),
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(receiverName),
        centerTitle: true,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {

  @override
  State createState() => ChatScreenState();
}




class ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {

  }

}