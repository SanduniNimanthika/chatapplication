import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:chatapplication/Pages/HomePage.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}):super(key:key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn=GoogleSignIn();
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  SharedPreferences sharedPreferences;

  bool isLogin=false;
  bool isLoad=false;
  FirebaseUser currentUser;
  @override
  void initState(){
    super.initState();
    signin();

  }
void signin()async{
    this.setState((){
      isLogin=true;
    });

    SharedPreferences preferences= await SharedPreferences.getInstance();
    isLogin=await googleSignIn.isSignedIn();
    if(isLogin){
      Navigator.push(context, MaterialPageRoute(builder:
          (context)=>HomeScreen(currentUserID:preferences.getString('id'))));
    }
    this.setState((){
      isLogin=false;
    });

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.lightBlueAccent,Colors.purpleAccent]
          )
        ),
alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Welcome to Dear",style:TextStyle(
              fontFamily: 'Quintessential',

              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white



            )),

            GestureDetector(
              onTap: controlSignIn,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 35,
                      width: 120,
                      decoration: BoxDecoration(

                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomLeft,
                              colors: [Colors.red,Colors.redAccent]
                          )
                      ),
                      child: Center(
                        child: Text("Sign in",style:TextStyle(fontFamily: 'Quintessential',

                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white



                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:isLoad? CircularProgressIndicator():Container()
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );

  }
Future <Null>controlSignIn() async{
   SharedPreferences preferences=await SharedPreferences.getInstance();
this.setState((){
  isLoad=true;
});

GoogleSignInAccount googleSignInAccount=await googleSignIn.signIn();
GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount.authentication;


final AuthCredential credential=GoogleAuthProvider.getCredential(idToken:googleSignInAuthentication.idToken,
    accessToken: googleSignInAuthentication.accessToken);

FirebaseUser firebaseUser=(await firebaseAuth.signInWithCredential(credential)).user;

if(firebaseUser==null){
  Fluttertoast.showToast(msg: "Try again");
  this.setState((){
    isLoad=false;
  });
}else{
  //check already signuo
final QuerySnapshot resultQuery=await Firestore.instance.collection('users')
    .where('id',isEqualTo: firebaseUser.uid).getDocuments();
final List<DocumentSnapshot> documentSnapshot=resultQuery.documents;

//save data if user is new
if(documentSnapshot.length==0){
  Firestore.instance.collection('users').document(firebaseUser.uid)
      .setData(
    {
      'nickname':firebaseUser.displayName,
      'photoUrl':firebaseUser.photoUrl,
      'id':firebaseUser.uid,
      'aboutMe':"hai",
      'createdAt':DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith':null,
    }
  );
  //write data to local
  currentUser=firebaseUser;
  await preferences.setString('id', currentUser.uid);
  await preferences.setString('nickname',currentUser.displayName);
  await preferences.setString('photoUrl', currentUser.photoUrl);



}else{
  //write data to local
  currentUser=firebaseUser;
  await preferences.setString('id', documentSnapshot[0]['id']);
  await preferences.setString('nickname', documentSnapshot[0]['nickname']);
  await preferences.setString('photoUrl', documentSnapshot[0]['photoUrl']);
  await preferences.setString('aboutMe', documentSnapshot[0]['aboutMe']);

}
  Fluttertoast.showToast(msg: "Sucess");
  this.setState((){
    isLoad=false;
  });
  Navigator.push(context, MaterialPageRoute(builder:
      (context)=>HomeScreen(currentUserID:firebaseUser.uid)));

}


}
}
