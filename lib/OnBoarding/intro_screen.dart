import 'dart:async';

import 'package:abitplay/OnBoarding/Login_Reg.dart';
import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
//   final bool isLogin;
//
//   IntroScreen({
//     Key key,
//     @required this.isLogin
// }) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  VideoPlayerController _controller;
  bool _visible = false;
  String _url = Constant.regUrl;

  void _onIntroEnd(context, bool isLogin, bool loginBiometrics) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => LoginReg(
                loginreg: isLogin,
                loginBiometrics: loginBiometrics,
              )),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$assetName',
            width: 220.0,
            height: 120,
          ),
          // Flexible(child: SizedBox(height: 300,)),
        ],
      ),
      // child: Image.asset('assets/images/$assetName', width: 300.0, height: 200 ,),
      alignment: Alignment.bottomCenter,
    );
  }

  // Widget _buildLottie(String assetName, Alignment alignment){
  //   return Align(child: Lottie.asset('assets/images/$assetName.json', fit: BoxFit.cover, width: 300.0, height: 200 , ), alignment: alignment,);
  // }

  @override
  initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    _controller = VideoPlayerController.asset("assets/videos/splashVideo.mp4");
    _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.setVolume(0.0);
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          _controller.play();
          _visible = true;
        });
      });
    });
    // FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    analytics.setCurrentScreen(screenName: "OnBoarding_Welcome_Screen_Slider");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
  }

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    });
    const bodyStyle = TextStyle(fontSize: 14.0, color: Colors.white);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 35.0,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyTextStyle: bodyStyle,
      titlePadding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.transparent,
      imagePadding: EdgeInsets.zero,
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _getVideoBackground(),
          _getBackgroundColor(),
          _getBackgroundColor2(),
          // Container(
          //   height: 200,
          //   width: 200,
          //   color: Colors.green,
          // ),
          IntroductionScreen(
            globalBackgroundColor: Colors.transparent,
            key: introKey,
            pages: [
              PageViewModel(
                title: "The Unlimited Gamer",
                body:
                    "Ranging from arcade to action and adventure, ABiT Play is a multipurpose gaming hub which gives you the ability to play anywhere, anytime.",
                image: _buildImage('img2.png'),
                // image: _buildLottie('sch1', Alignment.center),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: 'Non-Stop Play',
                body:
                    'New updates and deliveries will appear at your game hub with new challenging levels as you progress',
                image: _buildImage('img3.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: 'Earn As You Play',
                body:
                    'ABiTPlay ensures a fun experience with easy payments and earnings across board with tatacoin while you earn at every turn.',
                image: _buildImage('img3.png'),
                decoration: pageDecoration,
              ),
//              PageViewModel(
//                title: 'Earn and be \nEntertained',
//                body:
//                    'ABiTplay ensures a fun experience with easy payments and earning across board while you\'re entertained',
//                image: _buildImage('img3.png'),
//                decoration: pageDecoration,
//              ),
              PageViewModel(
                title: 'Welcome',
                body: 'Kindly register or Login to Continue',
                image: _buildImage('logo.png'),
                decoration: pageDecoration,
              ),
            ],

            onDone: () {
              ///uncomment this to launcg reg is the website
              // _launchURL();
              _onIntroEnd(context, false, false);
            },
            //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
            showSkipButton: true,
            skipFlex: 0,
            nextFlex: 0,
            last: SizedBox(),
            skip: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            next: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
            next2: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
            done: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text(
                'Register',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            done2: Padding(
              padding: const EdgeInsets.all(6.0),
              child: const Text('Login',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            onDone2: () {
              // flutterWebviewPlugin.launch("https://www.google.com",
              //   withOverviewMode: true,
              //   rect: new Rect.fromLTWH(
              //     MediaQuery.of(context).size.width/2,
              //     MediaQuery.of(context).size.height/2,
              //     MediaQuery.of(context).size.width/2,
              //     300.0,
              //   ),
              // );
              _onIntroEnd(context, true, true);
            },
            dotsDecorator: const DotsDecorator(
              size: Size(8.0, 5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              color: Colors.white,
              activeColor: Colors.white,
              activeSize: Size(20.0, 5.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getVideoBackground() {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 100),
      child: VideoPlayer(_controller),
    );
  }

  _getBackgroundColor() {
    return Container(
      color: Colors.black.withAlpha(120),
      // color: Colors.blue.withAlpha(120),
    );
  }

  _getBackgroundColor2() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      // color: Colors.blue.withAlpha(120),
    );
  }
}
