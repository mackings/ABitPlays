import 'package:abitplay/ViewScreen/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool switchModeValue = false;

  void modeChange() async {
    setState(() {
      switchModeValue = !switchModeValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Settings",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        backgroundColor: Color(0xff031D39),
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "General",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      _sub("Play Game Videos On Wifi"),
                      _sub("Get Nofications and alerts"),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      //_sub("Sign into Games Automatically"),
                      // _sub("Show Game ID on launch"),
                      _sub("Recieve In game Invites"),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.perm_device_information,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      _sub("Share Game Data with App"),
                      // Text("Clean All Game Data",
                      // style: TextStyle(
                      //   color: Colors.white,
                      //  fontSize: 18,
                      // fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 8,
                      ),
                      // GestureDetector(
                      // onTap: (){
                      //  Fluttertoast.showToast(msg: '')
                      //},
                      //child: Text("Clean App Cache",
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //      fontSize: 18,
                      //      fontWeight: FontWeight.w600)),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Text(
                          "ABiTPlay",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () => pushNewScreen(
                          context,
                          screen: WebView(
                            title: "Achievement",
                            url: "https://abitplay.io/",
                          ),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: (){
                          WebView(
                              title: 'About ABitPlay',
                              url: 'https://abitplay.io/support ');
                        },
                        child: Text("Help and Feedback",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),

                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          WebView(
                              title: 'About ABitPlay',
                              url: 'https://abitplay.io/about');
                        },
                      
                        child: Text("About ABiTPlay",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),

                                  


                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sub(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        Switch(
          activeColor: Color(0xff031D67),
          value: switchModeValue,
          onChanged: (value) => modeChange,
        ),
      ],
    );
  }

  Widget _title(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 20),
        )
      ],
    );
  }
}
