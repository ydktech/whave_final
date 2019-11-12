import 'package:flutter/material.dart';
import 'package:flutter_rtmp_publisher/flutter_rtmp_publisher.dart';
import 'package:Whave/main.dart';
import 'package:screen_keep_on/screen_keep_on.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  String nickname;
  MyApp({Key key, @required this.nickname}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = RtmpLiveViewController();

  @override
  void initState() {
    super.initState();
    ScreenKeepOn.turnOn(true);
    initAsync();
  }

  @override
  void dispose() {
    ScreenKeepOn.turnOn(false);
    super.dispose();
  }

  Future initAsync() async {
    await controller.initialize(
        width: 640,
        height: 480,
        fps: 30,
        cameraPosition: RtmpLiveViewCameraPosition.back);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return new WillPopScope(
        child: Scaffold(
            body: maincamera(),
            floatingActionButton: Stack(
              children: <Widget>[
                playbutton(),
                swapbutton(),
                escapebutton(),
              ],
            )),
        onWillPop: () async => false);
  }

  Widget escapebutton() {
    var index;
    //garo
    return Align(
        alignment: Alignment(1, 0.95),
        child: ValueListenableBuilder<RtmpStatus>(
          valueListenable: controller.status,
          builder: (context, status, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                onPressed: () {
                  List<String> list;
                  Firestore.instance.collection('users').document(WelcomePage.userid).get().then((ds){
                    list = List.from(ds['cameras']);
                    print(list);
                    list.remove(widget.nickname);
                    Firestore.instance.collection('users').document(WelcomePage.userid).setData({
                      'cameras': list,
                    });
                    Navigator.of(context).pop();
                  });

                }),)),
        );
  }

  Widget swapbutton() {
    return Align(
      alignment: Alignment(1, 0.6),
      child: ValueListenableBuilder<RtmpStatus>(
          valueListenable: controller.status,
          builder: (context, status, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 196, 216, 216),
              ),
              child: IconButton(
                  icon: Icon(status == null ? Icons.camera : Icons.swap_horiz),
                  onPressed: status == null
                      ? null
                      : () {
                          controller.swapCamera();
                        }))),
    );
  }

  Widget playbutton() {
    var index;
    return Align(
      alignment: Alignment(1, 0.25),
      child: ValueListenableBuilder<RtmpStatus>(
          valueListenable: controller.status,
          builder: (context, status, child) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 37, 208, 148),
                ),
                child: IconButton(
                    icon: Icon(status?.isStreaming == true
                        ? Icons.stop
                        : Icons.play_arrow),
                    onPressed: () {
                      List<String> list;
                      Firestore.instance.collection('users').document(WelcomePage.userid).get().then((ds){
                        list = List.from(ds['cameras']);
                        print(list);
                        index = list.indexOf(widget.nickname);
                        print('\n\n'+WelcomePage.userid + index.toString()+'\n\n');
                        if (!status.isStreaming) {
                          controller.connect(
                            rtmpUrl: 'rtmp://218.209.151.216:1935/stream',
                            streamName:
                            (WelcomePage.userid + index.toString()));
                        } else
                          controller.disconnect();
                      });

                    }),
              )),
    );
// is landscape
  }

  Widget maincamera() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      //margin: EdgeInsets.all(2),
      child: Container(
        alignment: Alignment.center,
        height: 300,
        width: 400,
        child: ValueListenableBuilder<RtmpStatus>(
            valueListenable: controller.status,
            builder: (context, status, child) => Column(children: <Widget>[
                  AspectRatio(
                      aspectRatio: status?.aspectRatio ?? 1.0,
                      child: RtmpLiveView(controller: controller),
                  ),
                ])),
      ),
    );
  }
}


