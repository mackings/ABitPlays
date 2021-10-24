import 'dart:convert';

import 'package:abitplay/ViewScreen/webview.dart';
import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _name, _newPhoneNum;
  bool isFullName = false;
  bool isPhoneNum = false;
  String _newName;
  bool isLoading = false;
  bool isLogin = false;
  bool _pwReset = false;
  String _pin, _email;
  String _otp;
  String _password;

  _showMsg(msg, [String btnName, Function function]) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: btnName ?? 'Close',
        onPressed: function ??
            () {
              // Some code to undo the change!
            },
      ),
    );
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  String storedPasscode;

  _getLocalStorage() async {
    setState(() {
      _email = null;
      _password = null;
      _pin = null;
      storedPasscode = null;
    });
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey("email")) {
      String storeEmail = localStorage.getString('email');
      setState(() {
        _email = storeEmail;
      });
    }
    if (localStorage.containsKey("password")) {
      print("contains password");
      String storePassword = localStorage.getString('password');
      setState(() {
        _password = storePassword;
      });
    }
    if (localStorage.containsKey("pin")) {
      String storePassword = localStorage.getString('pin');
      setState(() {
        _pin = storePassword;
        storedPasscode = storePassword;
      });
    }
    print(_email);
    print(_password);
    print(_pin);
  }

  @override
  void initState() {
    // _getUser();
    _getLocalStorage();
    // TODO: implement initState
    super.initState();
  }

  _getUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final String user = localStorage.getString('user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff031D39),
        elevation: 0.0,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            // color: Colors.red,
                            height: 90,
                            width: 90,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: Image(
                                image: AssetImage(
                                  "assets/images/avatar.jpeg",
                                ),
                                fit: BoxFit.cover,
                              ),
//                              CachedNetworkImage(
//                                fit: BoxFit.cover,
//                                imageUrl: Provider.of<AppProvider>(context)
//                                    .data['pictureUrl']
//                                    .toString(),
//                                placeholder: (context, url) => Image(
//                                  image: AssetImage(
//                                    "assets/images/avatar.jpeg",
//                                  ),
//                                  fit: BoxFit.cover,
//                                ),
//                                // errorWidget: (context, url, error) => Image(image: AssetImage("assets/images/avatar2.png",)),
//                              ),

                              // Center(child: Image(image: AssetImage("assets/images/avatar2.png",))),
                            ),
                          ),
                          // SizedBox(height: 6,),
                          // Text('Game ID: ' , style: TextStyle( fontSize: 10),),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      // Row(
                      //   children: [
                      //     Flexible(
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text('Welcome', style: TextStyle(fontWeight: FontWeight.w400),),
                      //
                      //           Padding(
                      //             padding: const EdgeInsets.symmetric(vertical:3.0),
                      //             child: Row(
                      //               children: [
                      //                 Flexible(child: Text(Provider.of<AppProvider>(context).data['name'].toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),maxLines: 1, overflow: TextOverflow.ellipsis,)),
                      //               ],
                      //             ),
                      //           ),
                      //
                      //           // Text((_email != null)? _email : 'abituser.com' , style: TextStyle( fontSize: 10),),
                      //           SizedBox(height: 3,),
                      //           Text('TAT Bal : 700',  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w800),),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).hintColor.withOpacity(0.15),
                      offset: Offset(0, 3),
                      blurRadius: 10)
                ],
              ),
              child: ListView(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  ListTile(
                    dense: false,
                    leading: Icon(Icons.person),
                    title: Text(
                      "Account Information",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    trailing: InkWell(
                        onTap: () {
                          _showDialog();
                        },
                        child: Icon(Icons.edit)),
// this place for data update
                  ),
                  ListTile(
                    onTap: () {},
                    dense: true,
                    title: Text(
                      "Full Name",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    trailing: Text(
                      Provider.of<AppProvider>(context).data['name'].toString(),
                      style: TextStyle(),
                    ),
                  ),
                  ListTile(
                    onTap: () {},
                    dense: true,
                    title: Text(
                      "email",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    trailing: Text(
                      Provider.of<AppProvider>(context)
                          .data['email']
                          .toString(),
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ListTile(
                    onTap: () {},
                    dense: true,
                    title: Text(
                      "Mobile number",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    trailing: Text(
                      Provider.of<AppProvider>(context)
                                  .data["phone"]
                                  .toString() !=
                              null.toString()
                          ? Provider.of<AppProvider>(context)
                              .data["phone"]
                              .toString()
                          : "",
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ListTile(
                  //   onTap: () {},
                  //   dense: true,
                  //   title: Text(
                  //     "Verification",
                  //     style: Theme.of(context).textTheme.bodyText2,
                  //   ),
                  //   // trailing: Text(
                  //   //   ((_verified != null) ? _verified? "Verified":"Not Verified"  : '' ) ,
                  //   //   style: TextStyle(color: Colors.grey),
                  //   //   maxLines: 1,
                  //   //   overflow: TextOverflow.ellipsis,
                  //   // ),
                  //
                  // ),
                ],
              ),
            ),
//
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).hintColor.withOpacity(0.15),
                      offset: Offset(0, 3),
                      blurRadius: 10)
                ],
              ),
              child: ListView(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(
                      "App setting",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
//                                        trailing: IconButton(
//                                          icon: Icon(Icons.edit_attributes),
//                                          onPressed: (){},
//                                        )
                  ),
                  ListTile(
//                                      onTap: () {
//                                        Navigator.of(context).pushNamed('/Languages');
//                                      },
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          Icons.translate,
                          size: 22,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "languages",
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                    trailing: Text(
                      "english",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    trailing: Text(
                      Provider.of<AppProvider>(context)
                          .data['nationality']
                          .toString(),
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    title: Row(
                      children: <Widget>[
                        Icon(
                          Icons.place,
                          size: 22,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Country",
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
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
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (context){
                      //   return Contact();
                      // }));
                    },
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          Icons.help,
                          size: 22,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "FAQ & Support",
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDialog() async {
    String txt;
    await showDialog<String>(
      builder: (context) =>
          TimerBuilder.periodic(Duration(milliseconds: 1), builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return new AlertDialog(
            title: Text(isLoading ? "Updating Profile" : 'Update Profile'),
            contentPadding: const EdgeInsets.all(16.0),
            content: Form(
              key: _formKey2,
              child: isLoading
                  ? SizedBox()
                  : new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        isFullName
                            ? new TextFormField(
                                autofocus: true,
                                validator: (input) {
                                  if (input.isEmpty) return "*Required";
                                  if (input ==
                                      Provider.of<AppProvider>(context,
                                              listen: false)
                                          .data['name']
                                          .toString())
                                    return "Name Matches with previous Name";
                                  else
                                    return null;
                                },
                                onSaved: (input) => _newName = input,
                                // initialValue: _name,
                                decoration: new InputDecoration(
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isFullName = false;
                                          });
                                        },
                                        child:
                                            Icon(Icons.remove_circle_outlined)),
                                    labelText: 'Full Name',
                                    hintText: 'Full Name'),
                              )
                            : Row(
                                children: [
                                  FlatButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          isFullName = true;
                                        });
                                      },
                                      icon: Icon(Icons.add_circle_outlined),
                                      label: Text('Update Name')),
                                ],
                              ),
                        // isEmail?new TextFormField(
                        //   autofocus: true,
                        //   validator: (value) {
                        //     if (value == _email) return 'Email Matches with previous address';
                        //     if (!EmailValidator.validate(value, true)) return "not a valid mail";
                        //     else return null;
                        //   },
                        //   // !EmailValidator.validate(value, true)
                        //   //     ? 'Not a valid email.'
                        //   //     : null,
                        //   onSaved: (input) => _newEmail = input,
                        //   // initialValue: _email,
                        //   decoration: new InputDecoration(
                        //       suffixIcon: InkWell(
                        //           onTap: (){
                        //             setState(() {
                        //               isEmail = false;
                        //             });
                        //           },
                        //           child: Icon(Icons.remove_circle_outlined)),
                        //       labelText: 'Email', hintText: 'Email'),
                        // ):Row(
                        //   children: [
                        //     FlatButton.icon(onPressed: (){
                        //       setState(() {
                        //         isEmail = true;
                        //       });
                        //     }, icon: Icon(Icons.add_circle_outlined), label: Text('Update Email')),
                        //   ],
                        // ),

                        isPhoneNum
                            ? new TextFormField(
                                autofocus: true,
                                validator: (value) {
                                  if (value ==
                                      Provider.of<AppProvider>(context,
                                              listen: false)
                                          .data['phone']
                                          .toString())
                                    return 'phone number Matches with previous date';
                                  if (value.isEmpty)
                                    return "*Required";
                                  else
                                    return null;
                                },
                                // !EmailValidator.validate(value, true)
                                //     ? 'Not a valid email.'
                                //     : null,
                                onSaved: (input) => _newPhoneNum = input,
                                // initialValue: _email,
                                decoration: new InputDecoration(
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isPhoneNum = false;
                                          });
                                        },
                                        child:
                                            Icon(Icons.remove_circle_outlined)),
                                    labelText: 'Phone Number',
                                    hintText:
                                        'eg: ${Provider.of<AppProvider>(context, listen: false).data['phone'].toString()}'),
                              )
                            : Row(
                                children: [
                                  FlatButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          isPhoneNum = true;
                                        });
                                      },
                                      icon: Icon(Icons.add_circle_outlined),
                                      label: Text('Update Phone number')),
                                ],
                              ),
                      ],
                    ),
            ),
            actions: <Widget>[
              isLoading
                  ? SizedBox()
                  : new FlatButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
              isLoading
                  ? Theme(
                      data: ThemeData(
                          cupertinoOverrideTheme:
                              CupertinoThemeData(brightness: Brightness.light)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoActivityIndicator(
                          animating: true,
                        ),
                      ),
                    )
                  : new FlatButton(
                      child: const Text('UPDATE'),
                      onPressed: () {
                        // Navigator.pop(context);
                        _update();
                      })
            ],
          );
        });
      }),
      context: context,
    );
  }

  bool newInputValidateAndSave() {
    final form = _formKey2.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Map<String, String> data() {
    Map<String, String> _data;
    if (isLogin) {
      _data = {
        'email': _email.toString(),
        "password": _password,
        "code":
            "DAFSJHFDJasjfhasdfsdfw523451244****43213WHFOIHFGAQW45892037548TR34523534\$%&\$%^\$%^\$&^%WREUIFHASHR",
      };
    } else {
      _data = {
        'name': _newName ??
            Provider.of<AppProvider>(context, listen: false)
                .data['name']
                .toString(),
        "phone": _newPhoneNum ??
            Provider.of<AppProvider>(context, listen: false)
                .data['phone']
                .toString(),
        "pin": "12345"
      };
    }
    return _data;
  }

  String apiUrl() {
    String _apiUrl;
    if (isLogin) {
      _apiUrl = "${Constant.AUTH_URL}/login";
    } else {
      _apiUrl = "${Constant.BASE_URL}/users";
    }
    return _apiUrl;
  }

  void _update() async {
    if (newInputValidateAndSave()) {
      if (this.mounted) {
        setState(() {
          isLoading = true;
          // Your state change code goes here
        });
      }
      var _data = {
        'name': _newName ??
            Provider.of<AppProvider>(context, listen: false)
                .data['name']
                .toString(),
        "phone": _newPhoneNum ??
            Provider.of<AppProvider>(context, listen: false)
                .data['phone']
                .toString(),
        // "pin" : "12345"
      };

      try {
        print(data());
        http.Response res = !isLogin
            ? await Network().putData(_data, apiUrl())
            : await Network().authData(data(), apiUrl());
        var body = json.decode(res.body);
        print(res.statusCode);
        print(res.body);
        if (res.statusCode == 200) {
          // print(body["profile"]);
          // print(res.body);
          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (!isLogin) {
            setState(() {
              _pwReset = false;
              isLogin = true;
            });
            print("updating");
            _update();
          } else {
            SharedPreferences localStorage =
                await SharedPreferences.getInstance();
            localStorage.setString('user', json.encode(body));
            Provider.of<AppProvider>(context, listen: false)
                .updateAccount(body);
            Fluttertoast.showToast(msg: "Successful");
            Navigator.pop(context);
            setState(() {
              _pwReset = false;
              isLogin = false;
            });
          }
        } else {
          // print(res.body);
          // print(body);
          if (body["errors"] != null) {
            _showMsg(body["errors"]
                .toString()
                .replaceAll('{', '')
                .replaceAll('}', '')
                .replaceAll('[', '')
                .replaceAll(']', ''));
          } else if (body["message"] != null) {
            _showMsg(body["message"]
                .toString()
                .replaceAll('{', '')
                .replaceAll('}', '')
                .replaceAll('[', '')
                .replaceAll(']', ''));
          }

          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } on Exception catch (e) {
        _showMsg(e.toString());
        if (this.mounted) {
          setState(() {
            isLoading = false;
          });
        }
        print(e);
      }
    }
  }
}
