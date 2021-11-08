import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abitplay/Screens/HomeBarScreens/Games.dart';
import 'package:abitplay/Screens/HomeBarScreens/Library.dart';
import 'package:abitplay/Screens/HomeBarScreens/Movies.dart';
import 'package:abitplay/Screens/HomeBarScreens/Wallet.dart';
import 'package:abitplay/Screens/NavDreaver.dart';
import 'package:abitplay/Screens/Profile.dart';
import 'package:abitplay/my_flutter_app_icons.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _connectionStatus = 'Unknown';
  String _networkStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentTabController _controller;
  DateTime backbuttonpressedTime;

  PageController _pageController;
  int _page = 0;
  String header = "Scholarships Africa";
  bool isFood = true;
  var token;
  String _name, _email;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'));
    print('token is Bearer $token');
  }

  _loadUserData() async {
    await _getToken();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    print('printing user details');
    print(user);
    print(user['email']);
    print(user['name']);

    setState(() {
      _name = user['name'];
      _email = user['email'];
    });
  }

  @override
  void initState() {
    // _getToken();
    // _loadUserData();
    _controller = PersistentTabController(initialIndex: 0);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      isFood = true;
    });
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent, animate: true);
    // FlutterStatusbarcolor.setNavigationBarColor(Colors.white, animate: true);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    // FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    super.initState();
    _pageController = PageController(initialPage: _page);
//    _pageController.jumpToPage(_page);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
    _pageController.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
//      case ConnectivityResult.none:
        //todo: i added this to ensure there is internet connection
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            print('connected');
            print(result);
            setState(() {
              _networkStatus = 'connected';
              // _showMsg(_networkStatus.toString());
              _network();
            });
          }
        } on SocketException catch (_) {
          print('not connected');
          setState(() {
            _networkStatus = 'no internet connection';
            // _showMsg(_networkStatus.toString());
            _network();
          });
        }
        //todo: end here
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.none:
        setState(() {
          _networkStatus = 'no internet connection';
          _network();
          // _showMsg(_networkStatus.toString());
          _connectionStatus = result.toString();
        });

        break;
      default:
        setState(() {
          _connectionStatus = 'Failed to get connectivity.';
          _networkStatus = 'no internet connection';
          _network();
        });
        break;
    }
  }

  Future<bool> onWillPop() async {
    if (Navigator.canPop(context)) {
    } else {
      DateTime currentTime = DateTime.now();
      //Statement 1 Or statement2
      bool backButton = backbuttonpressedTime == null ||
          currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);
      if (backButton) {
        backbuttonpressedTime = currentTime;
        Fluttertoast.showToast(
            msg: "Double Click to exit app",
            backgroundColor: Colors.black,
            textColor: Colors.white);
        return false;
      }
      SystemNavigator.pop();
      return true;
    }
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

//   Widget _network (){
//     if(_networkStatus == 'no internet connection')
//     {return Text(
//       _networkStatus,
// //              'no internet connection',
//       style: TextStyle(fontSize: 8, color: Theme.of(context).accentColor, fontWeight: FontWeight.w800),
//     );}else{
//       return SizedBox();
//     }
//   }

  void _network() {
    if (_networkStatus == 'no internet connection') {
      _showMsg(_networkStatus.toString());
    } else {
      print(_networkStatus);
    }
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff08315D),
      key: _scaffoldKey,
      drawer: NavDrawer(),
      appBar: AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        brightness: Brightness.light,
        backgroundColor: Color(0xff031D39),
        // brightness: isFood? Brightness.light: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
//        automaticallyImplyLeading: false,
        centerTitle: true,
//        leading: IconButton(
//          icon: Icon(Icons.arrow_back_ios),
//          onPressed: () {
//            Navigator.of(context).pop();
//          },
//        ),
        title: Image.asset(
          'assets/images/logo.png',
          width: 40,
        ),
        elevation: 0.0,
        actions: <Widget>[
          // IconButton(icon: Icon(Icons.notifications), onPressed: (){
          //   Fluttertoast.showToast(msg: 'No notifications yet');
          // }),
          Padding(
            padding: const EdgeInsets.only(top: 9.0, right: 12, bottom: 9.0),
            child: GestureDetector(
              onTap: () {
                pushNewScreen(
                  context,
                  screen: Profile(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Container(
                // color: Colors.red,
                height: 30,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(75.0),
                  child: Image(
                    image: AssetImage(
                      "assets/images/avatar.jpeg",
                    ),
                    fit: BoxFit.cover,
                  ),
//                  CachedNetworkImage(
//                    fit: BoxFit.cover,
//                    imageUrl: "",
//                    placeholder: (context, url) => Image(
//                      image: AssetImage(
//                        "assets/images/avatar.jpeg",
//                      ),
//                      fit: BoxFit.cover,
//                    ),
//                    // errorWidget: (context, url, error) => Image(image: AssetImage("assets/images/avatar2.png",)),
//                  ),

                  // Center(child: Image(image: AssetImage("assets/images/avatar2.png",))),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg.jpg',
//             width: 220.0,
//             height: 120,
            ),
//            colorFilter: ColorFilter.mode(
//                Colors.black.withOpacity(0.8), BlendMode.srcOver),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: PersistentTabView(
          context,
          backgroundColor: Colors.transparent,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          // backgroundColor: Theme.of(context).primaryColor, // Default is Colors.white.
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.transparent,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle
              .style6, // Choose the nav bar style with this property.
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      Games(),
//      Music(),
      Library(),
      Movies(),
      Wallet(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(MyFlutterApp.games),
        ),
        title: ("  Games"),
        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        iconSize: 20,
        activeColorPrimary: Color(0xffFFFFFF),
        inactiveColorPrimary: Color(0xff9E9E9E),
      ),
//      PersistentBottomNavBarItem(
//        icon: Padding(
//          padding: const EdgeInsets.all(6.0),
//          child: Icon(MyFlutterApp.music),
//        ),
//        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//        title: ("Music"),
//        iconSize: 20,
//        activeColorPrimary: Color(0xffFFFFFF),
//        inactiveColorPrimary: Color(0xff9E9E9E),
//      ),
      PersistentBottomNavBarItem(
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(Icons.search),
        ),
        title: ("Search"),
        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        iconSize: 24,
        activeColorPrimary: Color(0xffFFFFFF),
        inactiveColorPrimary: Color(0xff9E9E9E),
      ),
      PersistentBottomNavBarItem(
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(MyFlutterApp.movies),
        ),
        title: ("Leaderboard"),
        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        iconSize: 20,
        activeColorPrimary: Color(0xffFFFFFF),
        inactiveColorPrimary: Color(0xff9E9E9E),
      ),
      PersistentBottomNavBarItem(
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(Icons.grid_view),
        ),
        iconSize: 20,
        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        title: ("Wallet"),
        activeColorPrimary: Color(0xffFFFFFF),
        inactiveColorPrimary: Color(0xff9E9E9E),
      ),
    ];
  }
}
