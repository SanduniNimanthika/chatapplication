import 'package:chatapplication/Pages/LoginPage.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Clone',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
