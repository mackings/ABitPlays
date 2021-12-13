import 'dart:convert';

import 'package:abitplay/OnBoarding/Login_Reg.dart';
import 'package:abitplay/Screens/Achievements.dart';
import 'package:abitplay/Screens/Profile.dart';
import 'package:abitplay/Screens/Settings.dart';
import 'package:abitplay/ViewScreen/webview.dart';
import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  // final Function function;
  // final Function function2;
  // final Function function3;
  // final Function function4;
  //
  //
  // NavDrawer({
  //   @required this.function,
  //   @required this.function2,
  //   @required this.function3,
  //   @required this.function4,
  // });
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  var token;
  String _name, _email;
  bool _visible = false;
  bool _visible3 = false;
  bool _visible2 = false;
  Future<dynamic> futur;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'));
    print('token is Bearer $token');
  }

  _loadUserData() async {
    // await _getToken();
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
    _loadUserData();
    futur = sendCountriesDataRequest3(1);
    super.initState();
//    _loadUserData();
  }

  _setAuthHeaders() => {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
  Future sendCountriesDataRequest3(int page) async {
    print("starting");
    String url = Uri.encodeFull(
        '${Constant.BALANCE_URL}/balance/${Provider.of<AppProvider>(context, listen: false).data['email'].toString()}?baseCurrencyNGN');
    http.Response response =
        await http.get(Uri.parse(url), headers: _setAuthHeaders());
    var body = json.decode(response.body);
    // var body = response.body;
    print(body);
    print(body["TAT"]);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xff031D39),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DrawerHeader(
              // margin: const EdgeInsets.only(bottom: 0.0),
                //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Color(0xff031D39),
//                  image: DecorationImage(
//                      fit: BoxFit.fill,
//                      image: AssetImage('')
//                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        pushNewScreen(
                                          context,
                                          screen: Profile(),
                                          withNavBar:
                                         
                                            false, // OPTIONAL VALUE. True by default.
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(75.0),
                                          child: Image(
                                            image: AssetImage(
                                              "assets/images/avatar.jpeg",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
//                                          CachedNetworkImage(
//                                            fit: BoxFit.cover,
//                                            imageUrl: Provider.of<AppProvider>(
//                                                    context)
//                                                .data['pictureUrl'],
//                                            placeholder: (context, url) =>
//                                                Image(
//                                              image: AssetImage(
//                                                "assets/images/avatar.jpeg",
//                                              ),
//                                              fit: BoxFit.cover,
//                                            ),
//                                            // errorWidget: (context, url, error) => Image(image: AssetImage("assets/images/avatar2.png",)),
//                                          ),

//                                     Center(child: Image(image: AssetImage("assets/images/avatar2.png",))),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    // Text('Game ID: ' , style: TextStyle( fontSize: 10),),
                                  ],
                                ),

                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Game Id: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          Provider.of<AppProvider>(context)
                                              .data['id']
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Text((_email != null)? _email : 'abituser.com' , style: TextStyle( fontSize: 10),),
                                SizedBox(
                                  height: 3,
                                ),
                                FutureBuilder(
                                  future: futur,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.none:
                                      case ConnectionState.waiting:
                                      case ConnectionState.active:
                                        return Text("...");
                                      case ConnectionState.done:
                                        if (snapshot.hasError) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Text(
                                                    'Please check your internet connection'),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  setState(() {
                                                    futur =
                                                        sendCountriesDataRequest3(
                                                            1);
                                                  });
                                                  // paginatorGlobalKey.currentState.changeState(
                                                  //     pageLoadFuture: sendCountriesDataRequest, resetState: true);
                                                },
                                                child: Text('Retry'),
                                              )
                                            ],
                                          );
                                        }
//                                        Future.microtask(() {
//                                          setState(() {});
//                                        });
                                        return Column(
                                          children: [
                                            Text(
                                                snapshot.data["TAT"]
                                                        .toString() +
                                                    " TAT",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            Text(
                                                snapshot.data["NGN"]
                                                        .toString() +
                                                    " NGN",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        );
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                )),

            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

//            ListTile(
//              onTap: Provider.of<AppProvider>(context).theme ==
//                      Constants.lightTheme
//                  ? () {
//                      Provider.of<AppProvider>(context, listen: false)
//                          .setTheme(Constants.darkTheme, "dark");
//                    }
//                  : () {
//                      Provider.of<AppProvider>(context, listen: false)
//                          .setTheme(Constants.lightTheme, "light");
//                    },
////              leading: Icon(
////                Provider.of<AppProvider>(context).theme == Constants.lightTheme
////                    ? Icons.brightness_2
////                    : Icons.brightness_high_rounded,
////              ),
//              // trailing: Switch(
//              //   value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
//              //       ? false
//              //       : true,
//              //   onChanged: (v) async{
//              //     if (v) {
//              //       Provider.of<AppProvider>(context, listen: false)
//              //           .setTheme(Constants.darkTheme, "dark");
//              //     } else {
//              //       Provider.of<AppProvider>(context, listen: false)
//              //           .setTheme(Constants.lightTheme, "light");
//              //     }
//              //   },
//              //   activeColor: Theme.of(context).accentColor,
//              // ),
////              title: Text(
////                Provider.of<AppProvider>(context).theme == Constants.lightTheme
////                    ? 'Dark Mode'
////                    : "Light Mode",
////                style: TextStyle(fontWeight: FontWeight.w600),
////              ),
//            ),

            // ListTile(
            //   onTap: (){
            //     // pushNewScreen(
            //     //   context,
            //     //   screen: MyScholarshipPage(),
            //     //   withNavBar: true, // OPTIONAL VALUE. True by default.
            //     //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
            //     // );
            //   },
            //   leading: Icon( Icons.brightness_medium, ),
            //   trailing: Switch(
            //     value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
            //         ? false
            //         : true,
            //     onChanged: (v) async{
            //       if (v) {
            //         Provider.of<AppProvider>(context, listen: false)
            //             .setTheme(Constants.darkTheme, "dark");
            //       } else {
            //         Provider.of<AppProvider>(context, listen: false)
            //             .setTheme(Constants.lightTheme, "light");
            //       }
            //     },
            //     activeColor: Theme.of(context).accentColor,
            //   ),
            //   title: Text(Provider.of<AppProvider>(context).theme == Constants.lightTheme? 'Dark Mode' : "Light Mode",style: TextStyle(fontWeight: FontWeight.w600),),
            // ),

            ListTile(
              onTap: () {
                pushNewScreen(
                  context,
                  screen: Profile(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              leading: Icon(
                Icons.people_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Achievements())),
              leading: Icon(
                Icons.security,
                color: Colors.white,
              ),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Achievement',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                pushNewScreen(
                  context,
                  screen: Settings(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              leading: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Share.share(
                    'Download ABiTPlay App\nEarn Tatcoin while having fun with handpicked Games, Music, and Movies\n https://abitplay.page.link/Share',
                    subject: 'ABiTPlay Invitation');
              },
              leading: Icon(
                Icons.share,
                color: Colors.white,
              ),
              title: Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            ListTile(
              onTap: () {
                pushNewScreen(
                  context,
                  screen: WebView(
                    title: "Help and Feedback",
                    url: "https://abitplay.io/support",
                  ),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
                // pushNewScreen(
                //   context,
                //   screen: MyScholarshipPage(),
                //   withNavBar: true, // OPTIONAL VALUE. True by default.
                //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
                // );
              },
              title: Text(
                'Help and Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(
              height: 60,
            ),

            // ListTile(
            //   leading: Container(
            //       decoration: BoxDecoration(
            //           color: const Color(0xffE50914),
            //           borderRadius: BorderRadius.circular(5.0)
            //       ),
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Icon(Icons.exit_to_app, color: Colors.white,),
            //       )),
            //   title: Text('Logout'),
            //   onTap: () {
            //     logout();
            //     print('user logged out');
            //   },
            // ),

            FlatButton(
              onPressed: () {
                AwesomeDialog(
                    context: context,
                    animType: AnimType.LEFTSLIDE,
                    headerAnimationLoop: false,
                    dialogType: DialogType.WARNING,
                    title: "Logout",
                    desc: '\nProceed to logout\n',
                    btnOkText: "Logout",
                    btnOkOnPress: () {
                      logout();
                      debugPrint('OnClcik');
                    },
                    btnOkIcon: Icons.check_circle,
                    onDissmissCallback: () {
                      debugPrint('Dialog Dissmiss from callback');
                    })
                  ..show();

                print('user logged out');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    Text(
                      "Log out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              color: Color(0xff971818),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void logout() async {
//    var res = await Network().getData('/logout');
//    var body = json.decode(res.body);
//    if(body['success']){
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    Navigator.pop(context);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginReg(
            loginreg: true,
            loginBiometrics: true,
          );
        },
      ),
      (_) => false,
    );
    // Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context, ) => LoginReg(loginreg: IntroScreen(isLogin: true))));
  }
//  }
}
