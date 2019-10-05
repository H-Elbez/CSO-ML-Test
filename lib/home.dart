// First screen code

import 'package:flutter/material.dart';
import 'camera_preview_scanner.dart';
import 'picture_scanner.dart';

class homePage extends StatefulWidget {
  homePage({Key key}) : super(key: key);

  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.stretch,
           children: <Widget>[
             Expanded(
               flex: 1,
               child: Material(
                      color: Color(0xFFFF5E62),
                      child: InkWell(
                      splashColor: Color(0xFFFF9966),
                      onTap: (){ Navigator.of(context).push(new
        MaterialPageRoute(builder: (BuildContext context) => new
        CameraPreviewScanner()));},
                     child: Container(
                       alignment: Alignment.center,
                     child: Text("Using Camera",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w400),),
                   ),
                 ),
               ),
             ),
              Expanded(
               flex: 1,
               child: Material(
                      color: Color(0xFFFF9966),
                      child: InkWell(
                     splashColor: Color(0xFFFF5E62),
                   onTap: (){ Navigator.of(context).push(new
        MaterialPageRoute(builder: (BuildContext context) => new
        PictureScanner()));},
                   child: Container(
                       alignment: Alignment.center,
                     child: Text("Using Photo",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w400)),
                   ),
                 ),
               ),
             )
           ],
       ),
    );
  }
}