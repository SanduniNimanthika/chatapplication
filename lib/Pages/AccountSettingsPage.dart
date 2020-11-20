import 'dart:async';

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapplication/Pages/HomePage.dart';
import 'package:chatapplication/Widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapplication/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purpleAccent,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(currentUserID: null)));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: Text(
            "settings",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SettingsScreen(),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nicknametexteditingcontroller;
  TextEditingController aboutmetexteditingcontroller;
  SharedPreferences preferences;
  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  File image;
  bool isLoading = false;
  final FocusNode nicknamefocusnode = FocusNode();
  final FocusNode aboutmefocusnode = FocusNode();

  @override
  void initState() {
    super.initState();
    readData();
  }

  void readData() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    nickname = preferences.getString('nickname');
    photoUrl = preferences.getString('photoUrl');
    aboutMe = preferences.getString('aboutMe');

    nicknametexteditingcontroller = TextEditingController(text: nickname);
    aboutmetexteditingcontroller = TextEditingController(text: aboutMe);
    setState(() {});
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    File newImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        this.image = newImage;
        isLoading = true;
      });
    }
    uploadimage();
  }

  Future uploadimage() async {
    String mfilename = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mfilename);
    StorageUploadTask storageUploadTask = storageReference.putFile(image);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((value) {
          photoUrl = value;
          Firestore.instance.collection('users').document(id).updateData({
            'photoUrl': photoUrl,
            'nickname': nickname,
            'aboutMe': aboutMe,
          }).then((data) async {
            await preferences.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: 'sucessfully update');
          });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'error occured in url');
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void uploadData() {
    nicknamefocusnode.unfocus();
    aboutmefocusnode.unfocus();
    setState(() {
      isLoading = false;
    });
    Firestore.instance.collection('users').document(id).updateData({
      'photoUrl': photoUrl,
      'nickname': nickname,
      'aboutMe': aboutMe,
    }).then((data) async {
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('nickname', nickname);
      await preferences.setString('aboutMe', aboutMe);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'sucessfully update');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (image == null)
                          ? (photoUrl != '')
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.lightBlueAccent),
                                      ),
                                      width: 200.0,
                                      height: 200,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: Colors.grey,
                                )
                          : Material(
                              //new update

                              child: Image.file(
                                image,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125)),
                              clipBehavior: Clip.hardEdge),
                      IconButton(
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.grey,
                        iconSize: 200,
                        icon: Icon(Icons.camera_alt,
                            size: 40.0, color: Colors.grey.withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoading ? circularProgress() : Container(),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0),
                    child: Container(
                      child: Text(
                        "Profile name ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                            color: Colors.purple),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,top: 5,right: 25),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            focusedBorder:OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:Colors.purple,
                                  style: BorderStyle.solid,
                                  width: 1
                              ),
                           //   borderRadius: new BorderRadius.circular(22.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:Colors.purple,
                                  style: BorderStyle.solid,
                                  width: 1
                              ),
                            //  borderRadius: new BorderRadius.circular(22.0),
                            ),

                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'name',
                          ),
                          controller: nicknametexteditingcontroller,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: nicknamefocusnode,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,top:22.0),
                    child: Container(
                      child: Text(
                        "About me ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                            color: Colors.purple),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right: 25,top: 5),
                    child: Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.lightBlueAccent),
                        child: TextField(
                          decoration: InputDecoration(
                            focusedBorder:OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:Colors.purple,
                                  style: BorderStyle.solid,
                                  width: 1
                              ),
                           //   borderRadius: new BorderRadius.circular(22.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:Colors.purple,
                                  style: BorderStyle.solid,
                                  width: 1
                              ),
                             // borderRadius: new BorderRadius.circular(22.0),
                            ),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'aboutme',
                          ),
                          controller: aboutmetexteditingcontroller,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: aboutmefocusnode,
                        ),
                      ),
                    ),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              Padding(
                padding: EdgeInsets.only(top:28.0),
                child: Material(
                  borderRadius: BorderRadius.circular(25),
                  elevation: 4,
                  child: InkWell(
                    onTap: uploadData,
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.lightBlueAccent,Colors.purpleAccent],),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "update",
                          style: TextStyle(fontSize: 16.0,color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                   //   margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top:18.0,bottom: 28),
                child: Material(
                  borderRadius: BorderRadius.circular(25),
                  elevation: 4,
                  child: InkWell(
                    onTap: logoutUser,
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red,Colors.redAccent],),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "logout",
                          style: TextStyle(fontSize: 16.0,color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                      //   margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
                    ),
                  ),
                ),
              ),

            ],
          ),
        )
      ],
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
