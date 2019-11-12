import 'package:flutter/material.dart';
import 'package:Whave/example.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThirdPage extends StatefulWidget {
  String nickname;
  ThirdPage({Key key, nickname}) : super(key : key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(50),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '모션인식을 사용하실건가요?',
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green,),
                    onPressed: () {
                      Firestore.instance.collection('users').document(WelcomePage.userid).get().then((DocumentSnapshot ds){
                      print(ds['cameras']);
                    });
                    },
                    iconSize: 50,
                  ),
                  SizedBox(width: 50,),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.red,),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp())),
                    iconSize: 50,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
