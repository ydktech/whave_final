import 'package:flutter/material.dart';
import 'main.dart';
import 'example.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  TextEditingController nickname = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(70),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'CCTV의 이름을 등록합니다',
                style: TextStyle(
                    fontSize: 21,
                    color: Color.fromARGB(255, 196, 216, 216),
                    fontFamily: 'Nanum'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: nickname,
                cursorColor: Colors.white,
                style: TextStyle(
                    color: Color.fromARGB(255, 196, 216, 216),
                    fontFamily: 'Nanum'),
                decoration: InputDecoration(
                    hintText: '여기에 이름을 입력하세요 예) 거실, 방',
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 196, 216, 216),
                        fontFamily: 'Nanum'),
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hoverColor: Colors.white),
              ),
              SizedBox(
                height: 30,
              ),
              IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (nickname.text.contains('/', 0)) {
                    alert(context);
                  }
                  else{
                  final DocumentReference postsRef = Firestore.instance
                      .collection('users')
                      .document(WelcomePage.userid);
                  postsRef.get().then((ds) {
                    if (ds.exists) {
                      List<String> list;
                      list = List.from(ds['cameras']);
                      list.add(nickname.text);
                      postsRef.updateData({
                        'cameras': list,
                      });
                    } else {
                      postsRef.setData({
                        'cameras': [nickname.text],
                      });
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyApp(
                                  nickname: nickname.text,
                                )));
                  });
                }},
                iconSize: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> alert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('유효하지 않은 이름입니다', style: TextStyle(fontFamily: 'Nanum'),),
        content: const Text('이름에 / 는 사용할 수 없습니다. 다시 입력해 주세요.', style: TextStyle(fontFamily: 'Nanum'),),
        actions: <Widget>[
          FlatButton(
            child: Text('확인', style: TextStyle(fontFamily: 'Nanum'),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
