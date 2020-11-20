import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapplication/Widgets/FullImageWidget.dart';
import 'package:chatapplication/Widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvator;
  final String receiverName;
  Chat(
      {Key key,
      @required this.receiverId,
      @required this.receiverAvator,
      @required this.receiverName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(receiverName),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvator: receiverAvator),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvator;
  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvator,
  }) : super(key: key);

  @override
  State createState() =>
      ChatScreenState(receiverId: receiverId, receiverAvator: receiverAvator);
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvator;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvator,
  });
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;
  File imgFile;
  String imageUrl;
  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;
  final ScrollController listscrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;
    chatId = '';

    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id') ?? '';
    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': receiverId});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //create list
              creatListMg(),

              //show Sticker
              (isDisplaySticker ? createSticker() : Container()),
              //input controllers
              creatInput(),
            ],
          ),
          createLoading()
        ],
      ),
       onWillPop: onBackpress,
    );
  }

  createLoading() {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackpress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMg("mimi1", 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi2", 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi3", 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMg("mimi4", 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi5", 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi6", 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMg("mimi7", 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi8", 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMg("mimi9", 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          ),
        ],
      ),
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.greenAccent, width: 0.5))),
      height: 180.0,
    );
  }

 void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  creatListMg() {
    return Flexible(
        child: chatId == ''
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
                ),
              )
            : StreamBuilder(
                stream: Firestore.instance
                    .collection('message')
                    .document(chatId)
                    .collection(chatId)
                    .orderBy('time', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
                      ),
                    );
                  } else {
                    listMessage = snapshot.data.documents;
                    return ListView.builder(
                      itemBuilder: (context, index) =>
                          createItem(index, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                      controller: listscrollController,
                    );
                  }
                },
              ));
  }

  bool isLastRightmg(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
  bool isLastLeftmg(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
  Widget createItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      //sender mg
      return Row(
        children: <Widget>[
          document['type'] == 0
              ?
              //text
              Container(
                  width: 200,
                  margin: EdgeInsets.only(
                      bottom: isLastRightmg(index) ? 20.0 : 10.0),
                  child: Text(document['content']),
                )
              :

              //text img
              document['type'] == 1
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhoto(
                                      url: document['content'])));
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                              width: 200,
                              height: 220,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                            ),
                            errorWidget: (context, url, error) =>
                                Text("error image"),
                            imageUrl: document['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastLeftmg(index) ? 20.0 : 10.0),
                    )
                  :
                  //sticker
                  Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                          'images/${document['content']}.gif'),
                    )
        ],
      );
    } else {
      // receiver mg
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastLeftmg(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            width: 20,
                            height: 20,
                          ),
                          imageUrl: receiverAvator,
                          width: 35,
                          height: 35,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),

                //diplay mg
                document['type'] == 0
                    ? Container(
                        width: 200,
                        child: Text(document['content']),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document['content'])));
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                    width: 200,
                                    height: 220,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Text("error image"),
                                  imageUrl: document['content'],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                                'images/${document['content']}.gif'),
                          )
              ],
            ),
            // mg time
            isLastLeftmg(index)
                ? Container(
                    child: Text(DateFormat('dd MMMM, yyyy =hh:mm:aa').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['time'])))),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  creatInput() {
    return Container(
      child: Row(
        children: <Widget>[
          //pick image icon button
          Material(
            child: Container(
              child: IconButton(
                onPressed: () {
                  getImage();
                },
                icon: Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            color: Colors.white,
          ),
          // emoji button
          Material(
            child: Container(
              child: IconButton(
                onPressed: getSticker,
                icon: Icon(
                  Icons.face,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            color: Colors.white,
          ),

          //text feild

          Flexible(
            child: Container(
                child: TextField(
              controller: textEditingController,
              decoration: InputDecoration.collapsed(hintText: 'write here'),
              focusNode: focusNode,
            )),
          ),

          // send mg
          Material(
            child: Container(
              color: Colors.white,
              child: IconButton(
                onPressed: () => onSendMg(textEditingController.text, 0),
                icon: Icon(
                  Icons.send,
                  color: Colors.black87,
                ),
              ),
            ),
          )
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
    );
  }

  void onSendMg(String contentMsg, int type) {
    //type 0 its text msg
    //type 1 its imgfile
    //type 2 sticker
    if (contentMsg != "") {
      textEditingController.clear();
      var docref = Firestore.instance
          .collection('message')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docref, {
          'idFrom': id,
          'idto': receiverId,
          'time': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': contentMsg,
          'type': type,
        });
      });
      listscrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'empty message');
    }
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    imgFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imgFile != null) {
      isLoading = true;
    }
    uploadImgFile();
  }

  Future uploadImgFile() async {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('chat image').child(filename);
    StorageUploadTask storageUploadTask = storageReference.putFile(imgFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMg(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'error' + error);
    });
  }
}
