import 'dart:async';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapplication/Models/user.dart';
import 'package:chatapplication/Pages/AccountSettingsPage.dart';
import 'package:chatapplication/Pages/ChattingPage.dart';
import 'package:chatapplication/Widgets/ProgressWidget.dart';
import 'package:chatapplication/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserID;
  HomeScreen({Key key,@required this.currentUserID}):super(key:key);
  @override
  State createState() => HomeScreenState(currentUserID:currentUserID);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key key,@required this.currentUserID});
  TextEditingController searchEditingController=TextEditingController();
  Future<QuerySnapshot> futureSearch;
final String currentUserID;
  homePageHeader(){
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder:
                (context)=>Settings()));
          },
          icon: Icon(Icons.settings),
        )
      ],
      backgroundColor: Colors.lightBlueAccent,
      title: Container(
        margin: EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0,color: Colors.white),
          controller: searchEditingController,
          decoration: InputDecoration(
            hintText: 'search here',
            hintStyle: TextStyle(
color: Colors.white,
            ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            filled: true,
            prefixIcon: Icon(Icons.person_pin,color: Colors.white,size: 30.0,),
              suffixIcon: IconButton(
                onPressed: emptyText(),
                  icon: Icon(Icons.clear,color: Colors.white,))
          ),
          onFieldSubmitted: controllsearching,

        ),
      )
      ,

    );
  }
  controllsearching(String name){
    Future<QuerySnapshot> foundname=Firestore.instance.collection("users").where('nickname',isGreaterThanOrEqualTo: name)
.getDocuments();
    setState(() {
      futureSearch=foundname;
    });
  }

  emptyText(){
    searchEditingController.clear();
  }
  @override
  Widget build(BuildContext context) {
       return Scaffold(
         appBar:homePageHeader(),
         body: futureSearch==null ? displaySearchResultScreen():displayUsaerScreen(),

       );


  }
  displayUsaerScreen(){
    return FutureBuilder(
      future: futureSearch,
      builder: (context,dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResult =[];
        dataSnapshot.data.documents.forEach((document){
          User eachUser= User.fromDocument(document);
          UserResult userResult =UserResult(eachUser);
          if(currentUserID!=document['id']){
            searchResult.add(userResult);
          }
        });
        return ListView(children: searchResult,);
      },
    );
  }

  displaySearchResultScreen(){
    final Orientation orientation=MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group,color: Colors.lightBlueAccent,size: 200,),
            Text("Search user",
            textAlign: TextAlign.center,
            )
          ],

        ),
      ),
    );
  }


}
class UserResult extends StatelessWidget
{
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        child: Column(
          children: <Widget>[

            GestureDetector(
              onTap:()=>sendUserTouch(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black87,
                  backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(eachUser.nickname),
                subtitle: Text("joined:"+DateFormat("dd MMMM,yyy - hh:mm:aa").format(DateTime.fromMillisecondsSinceEpoch(int.parse(eachUser.createdAt)))),
              ),
            )
          ],
        ),
      ),
    );

  }

  sendUserTouch(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Chat(
         receiverId:eachUser.id,receiverAvator:eachUser.photoUrl,receiverName:eachUser.nickname)));
  }
}
