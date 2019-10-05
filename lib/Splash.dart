// Splash Screen code 

import 'dart:async';
import 'package:flutter/material.dart';

import 'home.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
@override
  void initState() {
    Timer(Duration(seconds: 4), ()=> Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder:(BuildContext context)=> homePage())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
           decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffff5e62),Color(0xffff9966)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          ),
        child: Center(child: Container(
          child: Image.asset("assets/logo.png",width: MediaQuery.of(context).size.width/2,)),),
      )
        );}}