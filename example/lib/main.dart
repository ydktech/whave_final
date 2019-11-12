import 'package:flutter/material.dart';
import 'second.dart';
import 'google_sign_in.dart';
import 'package:flutter/services.dart';

void main() => runApp(AppStartPoint());

class AppStartPoint extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whave: 웨일에서 만나는 안전한 우리집',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  static String userid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/whale_icon.png"), height: 200),
              SizedBox(height: 100),
              Text(
                'Whave',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 196, 216, 216), fontFamily: 'Nanum'),
                textAlign: TextAlign.center,
              ),
              Text(
                '\n웨일에서 만나는 안전한 우리집',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 196, 216, 216), fontFamily: 'Nanum'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 100),
              _signInButton(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _signInButton(context) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () {
      signInWithGoogle().whenComplete(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return SecondPage();
              },
            ),
          );
      });
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Google 계정으로 시작',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Nanum',
                color: Color.fromARGB(255, 196, 216, 216),
            ),
          )
          ),
        ],
      ),
    ),
  );
}

Future<void> alert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const Text('네트웨크 상태를 확인해주세요', style: TextStyle(fontFamily: 'Nanum'),),
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
