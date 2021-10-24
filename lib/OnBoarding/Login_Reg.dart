import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abitplay/Screens/Home.dart';
import 'package:abitplay/network_utils/api.dart';
import 'package:abitplay/providers/app_provider.dart';
import 'package:abitplay/services/firebase_analytics.dart';
import 'package:abitplay/utils/CustomWidgets.dart';
import 'package:app_settings/app_settings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginReg extends StatefulWidget {
  final bool loginreg;
  final bool loginBiometrics;
  LoginReg({this.loginreg, this.loginBiometrics});
  @override
  _LoginRegState createState() => _LoginRegState();
}

class _LoginRegState extends State<LoginReg> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCont = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _countryCont = TextEditingController();
  final TextEditingController _otpCont = TextEditingController();
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool isAuthenticated = false;
  bool isLoading = false;
  bool isRegCodeSent = false;
  bool isResetCodeSent = false;
  bool checkboxValue = true;
  bool _isobscure = true;
  bool isLogin;
  bool isOTPLoading = false;
  String _email;
  String _refEmail;
  String _otp;
  String _password, _error, _dob, _country, _pin;
  String _ConfirmPassword;
  String _fullName, _phoneNum;
  bool _pwReset = false;
  bool _isBiometirecs = true;
  bool _showPin = false;

  String initValue = "Select your Birth Date";
  bool isDateSelected = false;
  DateTime birthDate; // instance of DateTime
  String birthDateInString;
  String _debugLabelString = "";
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('90');

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  var authenticateLoc;
  bool isBmtricallyAuthenticated = false;
  bool isDeviceSupported;
  bool isBiometricsEnabled = false;

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
    super.initState();
    _getLocalStorage();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    setState(() {
      isLogin = widget.loginreg;
      _isBiometirecs = widget.loginBiometrics;
    });
    print('current screen is ' +
        (isLogin ? 'Login Screen' : 'Registration Screen'));
    analytics.setCurrentScreen(
        screenName: isLogin ? 'LoginScreen' : 'RegistrationScreen');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // SystemChrome.setEnabledSystemUIOverlays([]);
    super.dispose();
  }

  _checkDeviceSupport() {
    auth.isDeviceSupported().then((isSupported) {
      setState(() {
        _supportState =
            isSupported ? _SupportState.supported : _SupportState.unsupported;
        isDeviceSupported = isSupported;
      });
      print("**************sup");
      print(isSupported);
      if (!isSupported) {
        setState(() {
          _showMsg("Biometrics not set", "setting",
              AppSettings.openSecuritySettings);
          isBmtricallyAuthenticated = true;
        });
      }
    });
  }

  Future<void> _checkBiometrics() async {
    await _checkDeviceSupport();
    print(_supportState);
    if (_supportState != _SupportState.unsupported) {
      bool canCheckBiometrics;
      try {
        canCheckBiometrics = await auth.canCheckBiometrics;
      } on PlatformException catch (e) {
        canCheckBiometrics = false;
        print(e);
      }
      if (!mounted) return;

      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
      });
    } else {
      print(_supportState);
      setState(() {
        _canCheckBiometrics = false;
      });
    }
  }

  Future<void> _authenticate() async {
    await _checkBiometrics();
    if (_canCheckBiometrics) {
      bool authenticated = false;

      try {
        setState(() {
          _isAuthenticating = true;
          _authorized = 'Authenticating';
        });
        authenticated = await auth.authenticate(
            localizedReason: 'Enter Security check to continue',
            useErrorDialogs: true,
            stickyAuth: true);
        if (authenticated) {
          _login();
          setState(() {
            isBmtricallyAuthenticated = authenticated;
          });
        }
        setState(() {
          _isAuthenticating = false;
        });
      } on PlatformException catch (e) {
        print(e);
        setState(() {
          _isAuthenticating = false;
          _authorized = "Error - ${e.message}";
        });
        return;
      }
      if (!mounted) return;
      setState(
          () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    } else {
      setState(() {
        isBmtricallyAuthenticated = true;
      });
    }
  }

  _buildPasscodeRestoreButton() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
          child: TextButton(
            child: Text(
              "Reset passcode",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            onPressed: _resetAppPassword,
            // splashColor: Colors.white.withOpacity(0.4),
            // highlightColor: Colors.white.withOpacity(0.2),
            // ),
          ),
        ),
      );

  _resetAppPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _showRestoreDialog(() {
        Navigator.maybePop(context);
        setState(() {
          isLogin = true;
          _isBiometirecs = false;
          _showPin = true;
        });
        //TODO: Clear your stored passcode here
      });
    });
  }

  _showRestoreDialog(VoidCallback onAccepted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Reset passcode",
            style: const TextStyle(color: Colors.black87),
          ),
          content: Text(
            "Passcode reset is a non-secure operation!\n\nthis will remove previous pass code and register a new one after user authentication",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text(
                "Cancel",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
            TextButton(
              child: Text(
                "I understand",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: onAccepted,
            ),
          ],
        );
      },
    );
  }

  _showLockScreen(
    BuildContext context, {
    bool opaque,
    CircleUIConfig circleUIConfig,
    KeyboardUIConfig keyboardUIConfig,
    Widget cancelButton,
    List<String> digits,
  }) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: Text(
              'Enter App Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
            passwordDigits: 6,
            bottomWidget: _buildPasscodeRestoreButton(),
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = storedPasscode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      _login();
      setState(() {
        this.isAuthenticated = isValid;
      });
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
    return Scaffold(
      key: _scaffoldKey,
//      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
//        padding: const EdgeInsets.all(28.0),
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
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24),
            height: MediaQuery.of(context).size.height,
            child: ListView(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            mainAxisAlignment: MainAxisAlignment.center,
//              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
//              SizedBox(),
                SafeArea(
                    top: true,
                    bottom: true,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: _title(),
                    )),
                _isBiometirecs
                    ? Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton.icon(
                                onPressed: () async {
                                  await _getLocalStorage();
                                  if (_email != null && _password != null) {
                                    _authenticate();
                                  } else {
                                    AwesomeDialog(
                                        context: context,
                                        animType: AnimType.LEFTSLIDE,
                                        headerAnimationLoop: false,
                                        dialogType: DialogType.NO_HEADER,
                                        title: "Authentication Failed",
                                        desc:
                                            '\nBiometric authentication\nhas not been set up\n',
                                        btnOkText: "Set Up Now",
                                        btnOkOnPress: () {
                                          setState(() {
                                            _isBiometirecs = false;
                                            _showPin = false;
                                          });
                                          debugPrint('OnClcik');
                                        },
                                        btnOkIcon: Icons.check_circle,
                                        onDissmissCallback: () {
                                          debugPrint(
                                              'Dialog Dissmiss from callback');
                                        })
                                      ..show();
                                  }
                                },
                                icon: Icon(Icons.fingerprint),
                                label: Text("Biometrics Login"),
                              ),
                            ),
                            TextButton.icon(
                                onPressed: () async {
                                  await _getLocalStorage();

                                  if (_email != null &&
                                      _password != null &&
                                      _pin != null) {
                                    _showLockScreen(
                                      context,
                                      opaque: false,
                                      cancelButton: Text(
                                        'Cancel',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        semanticsLabel: 'Cancel',
                                      ),
                                    );
                                  } else {
                                    AwesomeDialog(
                                        context: context,
                                        animType: AnimType.LEFTSLIDE,
                                        headerAnimationLoop: false,
                                        dialogType: DialogType.NO_HEADER,
                                        title: "Authentication Failed",
                                        desc:
                                            '\nPin authentication\nhas not been set up\n',
                                        btnOkText: "Set Up Now",
                                        btnOkOnPress: () {
                                          setState(() {
                                            _isBiometirecs = false;
                                            _showPin = true;
                                          });
                                          debugPrint('OnClcik');
                                        },
                                        btnOkIcon: Icons.check_circle,
                                        onDissmissCallback: () {
                                          debugPrint(
                                              'Dialog Dissmiss from callback');
                                        })
                                      ..show();
                                  }
                                },
                                icon: Icon(Icons.security),
                                label: Text("Pin Login")),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextButton(
                                      style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor:
                                              Theme.of(context).accentColor),
                                      onPressed: () {
                                        setState(() {
                                          _isBiometirecs = false;
                                          isLogin = false;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                          "Create Account",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          _form(),
                          SizedBox(
                            height: 0,
                          ),
                          isLogin ? SizedBox() : _tC(),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.bottomCenter,
                              child: _submitButton()),
                          isLogin ? _forgotPW() : SizedBox(),
                          _pwReset ? SizedBox() : _loginAccountLabel(),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$assetName',
            width: 150.0,
            height: 80,
          ),
          // Flexible(child: SizedBox(height: 300,)),
        ],
      ),
      // child: Image.asset('assets/images/$assetName', width: 300.0, height: 200 ,),
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _title() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Theme.of(context).accentColor.withOpacity(0.2),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_backspace,
                        color: Theme.of(context).accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox(),

        SizedBox(
          height: 0,
        ),

        _buildImage('logo.png'),

        SizedBox(
          height: 20,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _pwReset
                  ? "Reset Password"
                  : isLogin
                      ? 'Welcome back'
                      : 'Create an Account',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: Text(
                  _pwReset
                      ? "Ahh, you forgot your password send in your email  and we’ll do the rest for you"
                      : isLogin
                          ? 'Kindly login to continue'
                          : 'Create an ABiT-SSO account and join our fun filled platform while earning Tatcoins!',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      height: 1.5,
                      fontSize: 15,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),

//        _pwReset ? SizedBox() : Row(
//          children: [
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Container(
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(10.0),
//                  color: Theme.of(context).accentColor.withOpacity(0.1),
//                ),
//                child: InkWell(
//                  child: Padding(
//                    padding: const EdgeInsets.all(12.0),
//                    child: Image.asset(
//                      'assets/images/google.png', height: 15, width: 15,),
//                  ),
//                ),
//              ),
//            ),
//            SizedBox(width: 20,),
//
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Container(
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(10.0),
//                  color: Theme.of(context).accentColor.withOpacity(0.1),
//                ),
//                child: InkWell(
//                  child: Padding(
//                    padding: const EdgeInsets.all(12.0),
//                    child: Image.asset(
//                      'assets/images/facebook.png', height: 15, width: 15,),
//                  ),
//                ),
//              ),
//            ),
//
//
//          ],
//        )
      ],
    );
  }

  Widget _submitButton() {
    return Column(
//      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FlatButton(
            // onPressed:!isLoading?
            // _pwReset ?
            // isResetCodeSent? _login
            //
            //     :
            // isLogin ?
            // _login
            //     : isRegCodeSent? _login :_getOTP :(){}:(){},
            onPressed: () {
              if (!isLoading) {
                ///action here
                if (isLogin) {
                  if (_pwReset) {
                    if (isResetCodeSent) {
                      print("resetting password");
                      _login();
                    }
                  } else {
                    print("logging in");
                    _login();
                  }
                } else {
                  if (isRegCodeSent) {
                    _login();
                  } else {
                    _getOTP();
                  }
                }
              } else {
                print("loading an action already");
              }
            },

            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            color: isLoading
                ? Theme.of(context).accentColor.withOpacity(0.5)
                : Theme.of(context).accentColor,
//      alignment: Alignment.center,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: isLoading
                ? Theme(
                    data: ThemeData(
                        cupertinoOverrideTheme:
                            CupertinoThemeData(brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  )
                : Text(
                    _pwReset
                        ? 'Reset'
                        : isLogin
                            ? 'Set PIN'
                            : isRegCodeSent
                                ? 'Register'
                                : "Verify",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _forgotPW() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              !_pwReset ? 'Forgot your password?' : 'Nope i forgot nothing ? ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: _pwReset
                  ? () {
                      _pass.clear();
                      setState(() {
                        _pwReset = false;
                        _showPin = true;
                      });
                    }
                  : () {
                      _pass.clear();
                      setState(() {
                        _pwReset = true;
                        _showPin = false;
                      });
                    },
              child: Text(
                !_pwReset ? 'Click here' : 'Sign in',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget datePick() {
    return GestureDetector(
        child: new Icon(Icons.calendar_today),
        onTap: () async {
          final datePick = await showDatePicker(
              context: context,
              initialDate: new DateTime.now(),
              firstDate: new DateTime(1900),
              lastDate: new DateTime(2100));
          if (datePick != null && datePick != birthDate) {
            setState(() {
              birthDate = datePick;
              isDateSelected = true;

              // put it here
              birthDateInString =
                  "${birthDate.month}/${birthDate.day}/${birthDate.year}"; // 08/14/2019
            });
          }
        });
  }

  List<DatePickerMode> date = [
    DatePickerMode.year,
    DatePickerMode.day,
  ];

  void _pickDate() async {
    final datePick = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      // helpText: 'Help Text',
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.year,
      firstDate: new DateTime(1900),
      lastDate: new DateTime(2100),
    );
    if (datePick != null && datePick != birthDate) {
      print(datePick);
      setState(() {
        birthDate = datePick;
        isDateSelected = true;

        // put it here
        birthDateInString =
            "${birthDate.year}-${birthDate.month}-${birthDate.day}"; // 08/14/2019
        _date.text = birthDateInString;
      });
    }
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            isLogin ? 'Don\'t have an account?' : 'Already have an account?',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: isLogin
                ? () {
                    _pass.clear();
                    setState(() {
                      isLogin = false;
                    });
                  }
                : () {
                    _pass.clear();
                    setState(() {
                      isLogin = true;
                      _isBiometirecs = true;
                    });
                  },
            child: Text(
              isLogin ? 'Register' : 'Login',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _form() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: new Form(
        key: _formKey,
        child: AutofillGroup(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 10, top: 0),
                child: CustomTextFieldLogin2(
                  label: "Gaius Chibueze@yahoo.com",
                  KeyBoardType: TextInputType.emailAddress,
                  list: [
                    FilteringTextInputFormatter.deny(RegExp('[ ]')),
                  ],
                  textInputAction:
                      _pwReset ? TextInputAction.go : TextInputAction.next,
                  onSaved: (input) {
                    _email = input;
                  },
                  controller: _emailCont,
                  validator: (value) => !EmailValidator.validate(value, true)
                      ? 'Not a valid email.'
                      : null,
                  icon: Icon(Icons.email),
                  autofillHints: [AutofillHints.email],
                  icon2: _pwReset || !isLogin
                      ? GestureDetector(
                          onTap: () {
                            print("tapped");
                            if (!EmailValidator.validate(_emailCont.text)) {
                              _showMsg("Invalid Email Address");
                            } else {
                              _getOTP();
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isOTPLoading
                                  ? Theme(
                                      data: ThemeData(
                                          cupertinoOverrideTheme:
                                              CupertinoThemeData(
                                                  brightness: Theme.of(context)
                                                      .brightness)),
                                      child: CupertinoActivityIndicator(
                                        animating: true,
                                      ),
                                    )
                                  : Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isLogin ? "Get Code" : "Verify",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).accentColor,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  hint: "Enter Email",
                )),

            _pwReset
                ? isResetCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextFieldLogin(
                          list: [
                            FilteringTextInputFormatter.deny(RegExp('[ ]')),
                          ],
                          textInputAction: TextInputAction.next,
                          onSaved: (input) {
                            _otp = input;
                          },
                          validator: (value) =>
                              value.isEmpty ? '*Required' : null,
                          icon: Icon(Icons.admin_panel_settings_sharp),
                          // autofillHints: [AutofillHints.oneTimeCode],
                          icon2: (null),
                          hint: "Verification Code",
                        ))
                    : SizedBox()
                : isLogin
                    ? SizedBox()
                    : isRegCodeSent
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10, top: 0),
                            child: CustomTextFieldLogin(
                              list: [
                                FilteringTextInputFormatter.deny(RegExp('[ ]')),
                              ],
                              textInputAction: TextInputAction.next,
                              onSaved: (input) {
                                _otp = input;
                              },
                              validator: (value) =>
                                  value.isEmpty ? '*Required' : null,
                              icon: Icon(Icons.admin_panel_settings_sharp),
                              // autofillHints: [AutofillHints.oneTimeCode],
                              icon2: (null),
                              hint: "Verification Code",
                            ))
                        : SizedBox(),

            isLogin
                ? SizedBox()
                : isRegCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextFieldLogin(
                          textInputAction: TextInputAction.next,
                          validator: DisplayNameValidator.validate,
                          onSaved: (input) => _fullName = input,
                          icon: Icon(Icons.account_circle),
                          icon2: (null),
                          hint: "Full Name",
                        ))
                    : SizedBox(),

            ///country is next

            isLogin
                ? SizedBox()
                : isRegCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextField2(
                            controller: _countryCont,
                            onSaved: (input) => _country = input,
                            validator: (input) =>
                                input.isEmpty ? "*Required" : null,
                            icon2: Icons.arrow_drop_down_circle_outlined,
                            hint: "Country",
                            obscure: () {
                              if (Platform.isAndroid) {
                                _openCountryPickerDialog();
                                // Android-specific code
                              } else if (Platform.isIOS) {
                                _openCountryPickerDialog();
                                // _openCupertinoCountryPicker();
                                // iOS-specific code
                              } else {
                                _openCountryPickerDialog();
                              }
                            }
//                          ,
                            ),
                      )
                    : SizedBox(),

            isLogin
                ? SizedBox()
                : isRegCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextFieldLogin2(
                          list: [
                            FilteringTextInputFormatter.deny(RegExp('[ ]')),
                          ],
                          textInputAction: _pwReset
                              ? TextInputAction.go
                              : TextInputAction.next,
                          onSaved: (input) {
                            _refEmail = input;
                          },
                          // controller: _emailCont,
                          // validator: (value) =>
                          // !EmailValidator.validate(value, true)
                          //     ? 'Not a valid email.'
                          //     : null,
                          icon: Icon(Icons.email),
                          autofillHints: [AutofillHints.email],
                          hint: "Referrer Email Optional",
                        ))
                    : SizedBox(),
            isLogin
                ? SizedBox()
                : isRegCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextField(
                          validator: (input) =>
                              input.isEmpty ? "*Required" : null,
                          onSaved: (input) => _phoneNum = input,
                          textInputAction: TextInputAction.go,
                          icon: Icon(Icons.call),
                          icon2: (null),
                          hint: "Mobile Number",
                        ))
                    : SizedBox(),
//                 isLogin? SizedBox() : Padding(
//                     padding: EdgeInsets.only(bottom: 10, top: 0),
//                     child: CustomTextField2(
//                       controller: _date,
//                       onSaved: (input) => _dob = input,
//                       validator: (input) =>
//                       input.isEmpty ? "*Required" : null,
//                       icon2: Icons.date_range,
//                       hint: "DOB",
//                       obscure: _pickDate,
//                     )),
//                 isLogin? SizedBox() : Padding(
//                   padding: EdgeInsets.only(bottom: 10, top: 0),
//                   child: CustomTextField2(
//                       controller: _countryCont,
//                       onSaved: (input) => _country = input,
//                       validator: (input) =>
//                       input.isEmpty ? "*Required" : null,
//                       icon2: Icons.arrow_drop_down_circle_outlined,
//                       hint: "Country",
//                       obscure:
//                           () {
//                         if (Platform.isAndroid) {
//                           _openCountryPickerDialog();
//                           // Android-specific code
//                         } else if (Platform.isIOS) {
//                           _openCountryPickerDialog();
//                           // _openCupertinoCountryPicker();
//                           // iOS-specific code
//                         } else {
//                           _openCountryPickerDialog();
//                         }
//                       }
// //                          ,
//                   ),
//                 ),

            _pwReset
                ? isResetCodeSent
                    ? CustomTextFieldLogin(
                        controller: _pass,
                        autofillHints: [AutofillHints.password],
                        textInputAction:
                            isLogin ? TextInputAction.go : TextInputAction.next,
                        onSaved: (input) => _password = input,
                        validator: (input) => input.isEmpty ? "Required" : null,
                        icon: Icon(Icons.lock),

//                    icon2: (null),
                        hint: "New Password",
                        obsecure: _isobscure ? true : false,
                        icon2: !_isobscure
                            ? (Icons.visibility)
                            : (Icons.visibility_off),
                        obscure: _isobscure
                            ? () {
                                setState(() {
                                  _isobscure = false;
                                });
                              }
                            : () {
                                setState(() {
                                  _isobscure = true;
                                });
                              },
                      )
                    : SizedBox()
                : isLogin
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextFieldLogin(
                          controller: _pass,
                          autofillHints: [AutofillHints.password],
                          textInputAction: isLogin
                              ? TextInputAction.go
                              : TextInputAction.next,
                          onSaved: (input) => _password = input,
                          validator: (input) =>
                              input.isEmpty ? "Required" : null,
                          icon: Icon(Icons.lock),

//                    icon2: (null),
                          hint: "Enter Password",
                          obsecure: _isobscure ? true : false,
                          icon2: !_isobscure
                              ? (Icons.visibility)
                              : (Icons.visibility_off),
                          obscure: _isobscure
                              ? () {
                                  setState(() {
                                    _isobscure = false;
                                  });
                                }
                              : () {
                                  setState(() {
                                    _isobscure = true;
                                  });
                                },
                        ))
                    : isRegCodeSent
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10, top: 0),
                            child: CustomTextFieldLogin(
                              KeyboardType: TextInputType.visiblePassword,
                              controller: _pass,
                              autofillHints: [AutofillHints.password],
                              textInputAction: isLogin
                                  ? TextInputAction.go
                                  : TextInputAction.next,
                              onSaved: (input) => _password = input,
                              validator: (input) =>
                                  input.isEmpty ? "Required" : null,
                              icon: Icon(Icons.lock),

//                    icon2: (null),
                              hint: "Password",
                              obsecure: _isobscure ? true : false,
                              icon2: !_isobscure
                                  ? (Icons.visibility)
                                  : (Icons.visibility_off),
                              obscure: _isobscure
                                  ? () {
                                      setState(() {
                                        _isobscure = false;
                                      });
                                    }
                                  : () {
                                      setState(() {
                                        _isobscure = true;
                                      });
                                    },
                            ))
                        : SizedBox(),

            isLogin
                ? _showPin
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 0),
                        child: CustomTextFieldLogin2(
                          label: "123456",
                          list: [
                            new LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.deny(RegExp('[ ]')),
                          ],
                          textInputAction: TextInputAction.go,
                          KeyBoardType: TextInputType.number,
                          onSaved: (input) {
                            _pin = input;
                          },
                          validator: (value) =>
                              value.length != 6 ? 'Requires 6 Digits' : null,
                          icon: Icon(Icons.security),
                          hint: "Set Lock New Pin Code - 6 Digits",
                        ))
                    : SizedBox()
                : SizedBox(),

            isLogin
                ? SizedBox()
                : isRegCodeSent
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 0, top: 0),
                        child: CustomTextFieldLogin(
                          textInputAction: TextInputAction.go,
                          onSaved: (input) => _ConfirmPassword = input,
                          validator: (String input) {
                            if (input.isEmpty) return '*Required';
                            if (input != _pass.text)
                              return "*password doesn\'t match;";
                            else
                              return null;
                          },
                          icon: Icon(Icons.lock),
//                    icon2: (null),
                          hint: "Confirm Password",
                          obsecure: _isobscure ? true : false,
                          icon2: _isobscure
                              ? (Icons.visibility)
                              : (Icons.visibility_off),
                          obscure: _isobscure
                              ? () {
                                  setState(() {
                                    _isobscure = false;
                                  });
                                }
                              : () {
                                  setState(() {
                                    _isobscure = true;
                                  });
                                },
                        ))
                    : SizedBox(),
          ]),
        ),
      ),
    );
  }

  Widget _tC() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 10.0),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'By clicking the button below, you agree to AbitNetwork ',
                          style: TextStyle(
                              color: Color(0xffADADAD),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600),
                        ),
                        // TextSpan(
                        //     text: 'Terms and Conditions',
                        //     style: TextStyle(color: Theme.of(context).accentColor,
                        //       fontSize: 12.0, fontWeight: FontWeight.w600,
                        //       decoration: TextDecoration.underline,),
                        //     recognizer: TapGestureRecognizer()
                        //       ..onTap = () {
                        //         showDialog(context: context, builder: (context) {
                        //           return _dialogue(
                        //               Icons.assignment_ind, "Terms and Conditions"
                        //               .toUpperCase(),
                        //               """
                        //               Terms and Condition Here
                        //               """
                        //           );
                        //         });
                        //         print('Terms of Service"');
                        //       }),
                        // TextSpan(text: ' and also the ',
                        //   style: TextStyle(color: Color(0xffADADAD), fontSize: 12.0, fontWeight: FontWeight.w600),),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return _dialogue(
                                          Icons.privacy_tip,
                                          "Privacy Policy".toUpperCase(),
                                          """<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'>At ABIT MOBILE APPLICATION LTD (ABiT Network), one of our main priorities is the privacy of our visitors. This Privacy Policy notifies you of the ways we work to ensure confidentiality and privacy of Personal Information and outlines the information we collect, how we use those Personal Information and the circumstances under which we disclose such information to third-parties.</p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'>We periodically review this Privacy Policy to make sure that any new obligations and changes to our business model are adequately considered. We may amend this Privacy Policy at any time by posting an amended version on our website.</p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Content</span></p>
<ol style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Information about ABiT Network</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Collection of Personal Information</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Use of Personal Information</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Disclosure of Personal Information</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Security of Personal Information</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">GDPR Data Protection Rights</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Links to other sites</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Children&apos;s Information</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Acceptance</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Questions and Complaints</li>
</ol>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">1. Information on ABiT Network</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">ABIT MOBILE APPLICATION LTD also known as ABiT Network is a technology company established with the aim of providing solutions to the needs of everyone using blockchain technology through the company&rsquo;s utility token called TATCOIN. The company is leading the decentralized solution movement in Africa with its network of blockchain-powered applications, thereby bridging the gap between blockchain technology and the numerous wealth creation opportunities it offers to the common man with more focus on the African community.</div>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiT Network&rsquo;s products and services include:</div>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTrader - Cryptocurrency learning platform.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTgo - Tourism and travels.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTfarm - Agriculture.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTcharity - Humanitarian projects, Charity and Corporate Social Responsibility.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTreps - A community of ABiT Network enthusiasts.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTskillsmart - A digital learning and skills acquisition platform.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTcrowd - Real estate.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTDiscountshopper - e-commerce</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiTplaygame - Recreation and games.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">College Situation - A platform that connects people to schools for admission.</li>
</ul>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">2. Collection of Personal Information</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">The Personal Information that you are asked to provide, and the reasons why you are asked to provide it, will be made clear to you at the point we ask you to provide your Personal Information. If you contact us directly, we may receive additional information about you such as your name, email address, phone number, the contents of the message and/or attachments you may send us, and any other information you may choose to provide.</div>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">When you access or use our Services or purchase our Products, we collect the following information:</div>
<p style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Information You Provide to Us:</span> We receive and store the information you provide to us when filling in forms on our website or through our app or reaching out to us via email or phone including information you provide when you register to use our Products/Services and when you report a problem with the website or with our app.</p>
<p style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Information We Automatically Collect About You:</span> ABiT Network uses cookies, web beacons and other technologies to automatically collect certain types of information when you visit our website or use our app and also through email communications. This information enables us to personalise your online experience and make improvements on our performance and measure the effectiveness of our marketing activities.<br style="box-sizing: border-box; color: rgb(1, 3, 34);">With respect to your visits to our website or our mobile applications, we automatically collect the following information.</p>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Login Information:</span> We log technical information about your use of our products and services. ABiT Network follows a standard procedure of using log files. These files log visitors when they visit websites. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), the wallet identifier, date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users&apos; movement on the website, and gathering demographic information.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Device Information:</span> We collect information about the device you use to access your account, including the model of the hardware, operating system and version, and unique device identifiers. However, this information is not tied to any particular person and is unidentified.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Wallet Information:</span> When you create a Block chain Wallet through our Services, you will generate a public and private key pair and when you log out of the Wallet, we collect an encrypted file that, if it is unencrypted, would contain these keys, as well as your transaction history. When you allow notifications through your Account Settings, we will collect the unencrypted public key in order to provide such notifications. We do not collect an unencrypted private key from you neither do we decrypt any Wallet file data.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Transaction Information:</span> We may collect and keep information relating to transactions you carry out in your Wallet that change one virtual currency to another.</li>
</ul>
<p><br></p>
<p style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Information We Collect in fulfilment of legal obligations:</span> We may collect information from you in order to meet legal and regulatory obligations. The legal grounds upon which we process your Personal Information include:</p>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Legal obligation:</span> We may be required to process your Personal Information in order to comply with a legal obligation or providing information to a public body or law enforcement agency.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Performance of a contract:</span> We may process your Personal Information when necessary in order to perform our obligations under a contract.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Consent:</span> We may, from time to time, request your permission to process some of your Personal Information and where you grant your permission, we will process your Personal Information. You may withdraw your consent at any time by contacting&hellip;.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Legitimate interests:</span> We may process your Personal Information where it is in our legitimate interest in running a lawful business to do so as to advance that business, provided that it does not outweigh your interests.</li>
</ul>
<p><br></p>
<p style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Information We Collect from Other Sources:</span> We also collect information from other sources and merge that with the information we collect through our Products and Services. For example:</p>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">When you choose to register or login to an ABiT Network website using a third-party single sign-in service that authenticates your identity and connects your social media login information (For example, Facebook, LinkedIn, Google, Twitter or another site) with ABiT Network, we will collect any information or content needed for the registration or log-in that you have permitted the social media provider to share with us, such as your name and email address.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">We also use &quot;cookies&quot; from time to time to help personalize your online experience with us. A cookie is a small file of letters and numbers that we put on your computer if you agree. These cookies are used to store information including visitors&apos; preferences, and the pages on the website that the visitor accessed or visited. The information is used to optimize the users&apos; experience by customizing our web page content based on visitors&apos; browser type and/or other information. Cookies allow us to distinguish you from other users of our website and mobile applications, which helps us to provide you with an enhanced browsing experience. We process Personal Information collected through cookies in accordance with this Privacy Policy.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Banks or payment processors that you use to transfer fiat currency may provide us with basic Personal Data like your name and address and also your bank account information.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Advertising or analytics providers may provide us with unidentified information about you, such as how you found our website.</li>
</ul>
<p><br></p>
<p style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Personal Information we collect from third parties:</span> We may collect and/or verify the following classes of Personal Information about you from third parties:</p>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Identification Information,</span> like name, phone number, email, postal address, government identification numbers. (such as passport number, driver&rsquo;s license number, et cetera);</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Financial Information,</span> like bank account information, routing number;</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Transaction Information,</span> like public blockchain data (bitcoin, ether, and other digital assets are not truly anonymous. Anyone who can match your public digital assets address to your Personal Information, may be able to recognize you from a blockchain transaction because, in some cases, Personal Information published on a blockchain (such as your digital asset address and IP address) can be matched with Personal Information that we and others may have. Moreover, by using data analysis methods on a given blockchain, it may be possible to identify other Personal Information about you); and</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Additional Information,</span> at the choice of our Compliance Team to comply with legal obligations, which may include criminal records or alleged criminal activity.<br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);">We may retain Personal Information you provide during the registration process even if your registration is left incomplete or abandoned.</li>
</ul>
<p><br></p>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">3. Use of Personal Information</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">We may use your Personal Information for the following purposes:</div>
<ol style="box-sizing: border-box; color: rgb(1, 3, 34);" type="a">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Provision of Services:</span> We use your Personal Information to provide you with our Services pursuant to the terms of our User Agreement. For instance, in order to facilitate fiat transfers into and out of your account, we need to know your financial information.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Compliance with legal and regulatory requirements:</span> We process your Personal Information to comply with applicable laws and regulations. For instance, we have requirements for identity verification so as to fulfill our obligations under the anti-money laundering laws of numerous jurisdictions.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Detection and Prevention of fraud:</span> We process your Personal Information to detect and prevent fraudulent or other criminal activity</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Provision of Customer support:</span> We process your Personal Information when you contact our Customer Support team with issues bordering on your account.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Optimizing and enhancing our services:</span> We use your Personal Information to understand how our products and Services are being utilized so as to improve our Services and develop new products.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Product Marketing:</span> We may reach out to you with information about our Products and Services.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Other business purposes:</span> We may use your information for additional purposes if that purpose is communicated to you before we collect the information or if we obtain your permission.</li>
</ol>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">4. Disclosure of Personal Information</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">We may need to share your personal data with third parties for the following purposes:</div>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Service Providers:</span> We may share your Personal Information with third-party service providers for business or commercial purposes. Your Personal Information may be shared so that they can provide us with services, including identity verification, fraud detection and prevention, security threat detection, payment processing, customer support, data analytics, Information Technology, advertising, marketing, data processing, network infrastructure, storage, transaction monitoring, and tax reporting. Our third-party service providers are subject to strict confidentiality obligations.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Affiliates:</span> We may share your Personal Information with our affiliates, for the purposes outlined above, and as it is necessary to provide you with our Services.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Business transfers:</span> As we continue to develop our business, we might sell or buy other businesses or services. In such transactions, customer information may be transferred together with other business assets.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Detecting fraud and abuse:</span> We release accounts and other personal data to other companies and organizations for fraud protection and credit risk reduction, and to comply with the law.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">Law Enforcement.</span> We may be compelled to share your Personal Information with law enforcement, government officials, and regulators.</li>
</ul>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">When we share your Personal Information with third parties we will:</div>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">require them to agree to use your Personal Information in accordance with the terms of this Privacy Policy and in accordance with the law; and</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);">only permit them to process your Personal Information for specified purposes and we prohibit our service providers from using or disclosing your Personal Information for any other purpose.</li>
</ul>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">Funding and transaction information related to your use of certain Services may be recorded on a public block chain. Public block chains are distributed ledgers, intended to permanently record transactions across wide networks of computer systems. Many block chains can be analyzed forensically and that can lead to re-identification of the anonymous data source and the unexpected disclosure of private financial information, especially when block chain data is combined with other data.<br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);">Since block chains are redistributed or third-party networks that are not controlled or operated by ABiT Network or its affiliates, we are not able to erase, modify, or alter Personal Information from such networks.</div>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">5. Security of your Personal Information</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiT Network has reasonable security policies and procedures in place to protect Personal Information from unauthorized loss, misuse, alteration, or destruction. Despite ABiT Network&apos;s best efforts, security cannot be absolutely guaranteed against all threats. Measures we take include encryption of the ABiT Network website communications with SSL; required two-factor authentication for all sessions; periodic review of our Personal Information collection, storage, and processing practices; and restricted access to your Personal Information on a need-to-know basis for our employees, contractors and agents who are subject to strict contractual confidentiality obligations and may be disciplined or terminated if they fail to meet these obligations.</div>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">6. GDPR Data Protection Rights</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">We would like to make sure you are fully aware of all of your data protection rights. Every user is entitled to the following:</div>
<ul style="box-sizing: border-box; color: rgb(1, 3, 34);">
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to access</span> &ndash; You have the right to request copies of your Personal Information. Before providing Personal Information to you, we may ask for proof of identity and sufficient information about your interactions with us so as to locate your Personal Information.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to rectification</span> &ndash; You have the right to request that we correct any information you believe is inaccurate. You also have the right to request that we complete the information you believe is incomplete. You may inform us at any time that your Personal Information has changed by contacting us at&nbsp;<span style="box-sizing: border-box; color: blue;"><a href="https://abitnetwork.tawk.help/" style="box-sizing: border-box; color: inherit; text-decoration: none; cursor: pointer;" target="_blank">help center</a></span> and we will correct your Personal Information in accordance with your instructions. To proceed with such requests, in some cases we may need supporting documents from you as evidence that we are required to keep for regulatory or other legal purposes.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to erasure</span> &ndash; You have the right to request that we erase your Personal Information in certain circumstances such as if we no longer need it, provided that we have no legal or regulatory obligation to retain that information.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to restrict processing</span> &ndash; You have the right to request that we restrict the processing of your Personal Information, under certain conditions such as, if you contest the accuracy of that Personal Information or object to us processing it. It will not stop us from storing your Personal Information. We will inform you before we decide not to agree with any requested restriction.</li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to object to processing</span> &ndash; You have the right to object to our processing of your Personal Information, under certain conditions. You can ask us to stop processing your Personal Information, and we will do so if we are:<br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);">
        <ol style="box-sizing: border-box; color: rgb(1, 3, 34);" type="a">
            <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Depending on our own or someone else&rsquo;s justifiable interests to process your Personal Information, unless we can demonstrate strong legal grounds for the processing;</li>
            <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Processing your Personal Information for direct marketing;</li>
            <li style="box-sizing: border-box; color: rgb(1, 3, 34);">Processing your Personal Information for research, unless we reasonably believe such processing is imperative for the performance of a piece of work carried out in the public interest (such as by a regulatory or enforcement agency).</li>
        </ol>
    </li>
    <li style="box-sizing: border-box; color: rgb(1, 3, 34);"><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">The right to data portability</span> &ndash; You have the right to request that we transfer the Personal Information you have provided us with (in a structured, commonly used and machine-readable format) and to re-use it elsewhere or ask us to transfer this to a third party of your choice.</li>
</ul>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">If you make a request, we have 30 days to respond to you. If you would like to exercise any of these rights, please contact us at&nbsp;<span style="box-sizing: border-box; color: blue;"><a href="https://abitnetwork.tawk.help/" style="box-sizing: border-box; color: inherit; text-decoration: none; cursor: pointer;" target="_blank">help center</a></span></div>
<p><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">7. Links to other sites</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">Please be aware that ABiT Network website may contain links to other sites, including the websites of other brands of ABiT Network, that are not governed by this Privacy Policy but by other Privacy Policy that may differ somewhat. We encourage users to review the Privacy Policy of each Website visited before disclosing any Personal Information. By registering on any ABiT Network website and then navigating to another ABiT Network website while still logged in, you agree to the use of your Personal Information in accordance with the Privacy Policy of the ABiT Network&rsquo;s web site you are visiting.</div>
<p><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">8. Children&apos;s Information</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">Another part of our priority is adding protection for children while using the internet. We encourage parents and guardians to observe, participate in, and/or monitor and guide their online activity.<br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiT Network does not knowingly collect any Personal Identifiable Information from children under the age of 13. If you think that your child provided this kind of information on our website, we strongly encourage you to contact us immediately and we will do our best efforts to promptly remove such information from our records.</div>
<p><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">9. Acceptance</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">By using our Products and Services, you agree to this Privacy Policy. ABiT Network reserves the right to change or amend this Privacy Policy at any time. If we make any substantial changes to this Privacy Policy, the revised Policy will be posted here and we will notify our users before the changes take effect so that you are always aware of what information we collect, how we use it and under what circumstances we disclose it.</div>
<p><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<p><br></p>
<p style='box-sizing: border-box; color: rgb(1, 3, 34); font-weight: 400; font-size: 14px; line-height: 22px; font-family: "Circular Std"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;'><span class="bold" style="box-sizing: border-box; color: rgb(1, 3, 34); font-weight: bold; font-size: 18px;">10. Questions and Complaints</span><br style="box-sizing: border-box; color: rgb(1, 3, 34);"><br style="box-sizing: border-box; color: rgb(1, 3, 34);"></p>
<div style="box-sizing: border-box; color: rgb(1, 3, 34);">ABiT Network is committed to protecting the online privacy of your Personal Information. If you have any questions or complaints about this Privacy Policy, the collection, use, processing or disclosure of Personal Information by ABiT Network or access to your Personal Information as required by law, please contact us at&nbsp;<span style="box-sizing: border-box; color: blue;"><a href="https://abitnetwork.tawk.help/" style="box-sizing: border-box; color: inherit; text-decoration: none; cursor: pointer;" target="_blank">help center</a></span></div>
<p><br></p>""");
                                    });
                                print('Privacy Policy"');
                              }),
                      ],
                    ),
                  ),
                ),
                !checkboxValue
                    ? Text(
                        'Required.',
                        style: TextStyle(color: Colors.red, fontSize: 10.0),
                        textAlign: TextAlign.left,
                      )
                    : SizedBox(),
              ],
            ),
          ),

//           CheckboxListTile(
//             contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//             value: checkboxValue,
//             onChanged: (val) {
//               setState(() => checkboxValue = val
//               );
//             },
//             subtitle: !checkboxValue
//                 ? Text(
//               'Required.',
//               style: TextStyle(color: Colors.red, fontSize: 10.0),
//             )
//                 : null,
//             title: new RichText(
//               text: TextSpan(
//                 style: TextStyle(color: Colors.black, fontSize: 10.0),
//                 children: <TextSpan>[
//                   TextSpan(text: 'By clicking Sign Up, you agree to our ',
//                     style: TextStyle(color: Color(0xffADADAD), fontSize: 10.0),),
//                   TextSpan(
//                       text: 'Terms and Conditions',
//                       style: TextStyle(color: Theme.of(context).accentColor,
//                         fontSize: 10.0,
//                         decoration: TextDecoration.underline,),
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () {
//                           showDialog(context: context, builder: (context) {
//                             return _dialogue(
//                                 Icons.assignment_ind, "Terms and Conditions"
//                                 .toUpperCase(),
//                                 """<h3 style="box-sizing: border-box; margin: 35px 0px 20px; font-weight: 400; line-height: normal; font-size: 23px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-stretch: inherit; vertical-align: baseline; font-family: kenyancoffeerg; color: rgb(85, 85, 85); text-transform: uppercase; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">THESE TERMS WERE LAST REVISED ON MAY 18, 2020.</h3>
// <p style="box-sizing: border-box; margin: 10px 0px 15px; font-family: atami; font-size: 14px; color: rgb(116, 116, 116); letter-spacing: 0.5px; line-height: 26px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-weight: 400; font-stretch: inherit; vertical-align: baseline; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">V. A statement by you, made under penalty of perjury, that the information in your notice is accurate and that you are the copyright owner or authorized to act on the copyright owner&rsquo;s behalf; and</p>
// <p style="box-sizing: border-box; margin: 10px 0px 15px; font-family: atami; font-size: 14px; color: rgb(116, 116, 116); letter-spacing: 0.5px; line-height: 26px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-weight: 400; font-stretch: inherit; vertical-align: baseline; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">VI. Your address, telephone number, and e-mail address. Scholarship Africa&rsquo;s Copyright Agent for notice of claims of copyright infringement on its site can be reached as follows: Copyright Agent:</p>
// <p style="box-sizing: border-box; margin: 10px 0px 15px; font-family: atami; font-size: 14px; color: rgb(116, 116, 116); letter-spacing: 0.5px; line-height: 26px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-weight: 400; font-stretch: inherit; vertical-align: baseline; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">OnyeamachiAdigo&amp; Co. ATTN: LEGAL, 3rd Floor Danax Plaza, 55 Oyo RoadMokola Ibadan, Nigeria legal@scholarship.africa</p>"""
//                             );
//                           });
//                           print('Terms of Service"');
//                         }),
//                   TextSpan(text: ' and that you have read our ',
//                     style: TextStyle(color: Color(0xffADADAD), fontSize: 10.0,),),
//                   TextSpan(
//                       text: 'Privacy Policy',
//                       style: TextStyle(color: Theme.of(context).accentColor,
//                         fontSize: 10.0,
//                         decoration: TextDecoration.underline,),
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () {
//                           showDialog(context: context, builder: (context) {
//                             return _dialogue(Icons.privacy_tip, "Privacy Policy"
//                                 .toUpperCase(),
//                                 """<h3 style="box-sizing: border-box; margin: 35px 0px 20px; font-weight: 400; line-height: normal; font-size: 23px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-stretch: inherit; vertical-align: baseline; font-family: kenyancoffeerg; color: rgb(85, 85, 85); text-transform: uppercase; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">THESE TERMS WERE LAST REVISED ON MAY 18, 2020.</h3>
// <h3 style="box-sizing: border-box; margin: 35px 0px 20px; font-weight: 400; line-height: normal; font-size: 23px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-stretch: inherit; vertical-align: baseline; font-family: kenyancoffeerg; color: rgb(85, 85, 85); text-transform: uppercase; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">REPORT VIOLATIONS</h3>
// <p style="box-sizing: border-box; margin: 10px 0px 15px; font-family: atami; font-size: 14px; color: rgb(116, 116, 116); letter-spacing: 0.5px; line-height: 26px; padding: 0px; border: 0px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-weight: 400; font-stretch: inherit; vertical-align: baseline; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">You should report any security violations to us at support@pay4me.app</p>"""
//                             );
//                           });
//                           print('Privacy Policy"');
//                         }),
//                 ],
//               ),
//             ),
//             controlAffinity: ListTileControlAffinity.leading,
//             activeColor: Colors.green,
//           ),
        ],
      ),
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CountryPickerDialog(
                titlePadding: EdgeInsets.all(8.0),
                searchCursorColor: Colors.pinkAccent,
                searchInputDecoration: InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: Text('Select your Country'),
                onValuePicked: (Country country) => setState(() {
                      _selectedDialogCountry = country;
                      _countryCont.text = country.name;
                    }),
//            itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
                priorityList: [
                  CountryPickerUtils.getCountryByIsoCode('NG'),
//              CountryPickerUtils.getCountryByIsoCode('ZAF'),
//              CountryPickerUtils.getCountryByIsoCode('GHA'),
//              CountryPickerUtils.getCountryByIsoCode('KEN'),
//              CountryPickerUtils.getCountryByIsoCode('RWA'),
//              CountryPickerUtils.getCountryByIsoCode('TR'),
                  CountryPickerUtils.getCountryByIsoCode('US'),
                ],
                itemBuilder: _buildDialogItem)),
      );

  void _openCupertinoCountryPicker() => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CountryPickerCupertino(
          pickerSheetHeight: 200.0,
          onValuePicked: (Country country) => setState(() {
            _selectedDialogCountry = country;
            _countryCont.text = country.name;
          }),
//          itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('NG'),
            CountryPickerUtils.getCountryByIsoCode('US'),
          ],
        );
      });

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  Widget _dialogue(IconData icon, String title, String html) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      title: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        title: Text(title,
            maxLines: 2,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(0.0),
          child: Html(
            data: html,
          ),
        ),
        Row(
          children: <Widget>[
//            MaterialButton(
//              onPressed: () {
//                Navigator.pop(context);
//              },
//              child: Text("Dismiss"),
//            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Dismiss",
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  _showSuccess(String title) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        title: title,
        desc: 'kindly login to continue',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDissmissCallback: () {
          debugPrint('Dialog Dissmiss from callback');
        })
      ..show();
  }

  bool loginValidateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Map<String, String> data() {
    Map<String, String> _data;
    if (isLogin) {
      if (_pwReset) {
        _data = {
          'email': _email.toString(),
          "password": _password,
          "token": _otp.toString(),
        };
      } else {
        _data = {
          'email': _email.toString(),
          "password": _password,
          "code":
              "DAFSJHFDJasjfhasdfsdfw523451244****43213WHFOIHFGAQW45892037548TR34523534\$%&\$%^\$%^\$&^%WREUIFHASHR",
        };
      }
    } else {
      _data = {
        "email": _email.toString(),
        "name": _fullName,
        "nationality": _country,
        "phone": _phoneNum,
        "appName": Constant.appName,
        "referrer": _refEmail ?? "",
        "password": _password.toString(),
        "verificationCode": _otp.toString(),
      };
    }
    return _data;
  }

  String apiUrl() {
    String _apiUrl;
    if (isLogin) {
      if (_pwReset) {
        _apiUrl = "${Constant.BASE_URL}/password/reset";
      } else {
        _apiUrl = "${Constant.AUTH_URL}/login";
      }
    } else {
      _apiUrl = "${Constant.BASE_URL}/email/verify";
    }
    return _apiUrl;
  }

  //todo handling login
  void _login() async {
    if (loginValidateAndSave()) {
      if (this.mounted) {
        setState(() {
          isLoading = true;
          // Your state change code goes here
        });
      }
      // var data = {
      //   'email': _email.toString(),
      //   "password": _password,
      //   "code" : _otp,
      // };
      // print(data);
      try {
        http.Response res = await Network().authData(data(), apiUrl());
        print(res.statusCode);
        var body = json.decode(res.body);
        // print(res.body);
        if (res.statusCode == 200) {
          // print(body["profile"]);
          print(res.body);
          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (!isLogin) {
            _otpCont.clear();
            _showSuccess('Account \nCreated Successfully');
            setState(() {
              isRegCodeSent = false;
              isResetCodeSent = false;
              _pwReset = false;
              isLogin = true;
              _isBiometirecs = true;
            });
          } else {
            if (_pwReset) {
              _otpCont.clear();
              _showSuccess("Password \nSet Successfully");
              setState(() {
                isRegCodeSent = false;
                isResetCodeSent = false;
                _pwReset = false;
                isLogin = true;
              });
            } else {
              if (!_isBiometirecs) {
                SharedPreferences localStorage =
                    await SharedPreferences.getInstance();
                localStorage.setString('user', json.encode(body));
                Provider.of<AppProvider>(context, listen: false)
                    .updateAccount(body);
                analytics.logEvent(name: 'Login', parameters: {
                  'User': _email,
                });
                localStorage.setString('email', _email);
                print(_password);
                localStorage.setString('password', _password);
                if (_pin != null) {
                  localStorage.setString('pin', _pin);
                }
                Fluttertoast.showToast(
                    msg: "Successful, kindly login to continue");

                setState(() {
                  _isBiometirecs = true;
                });
              } else {
                SharedPreferences localStorage =
                    await SharedPreferences.getInstance();
                localStorage.setString('user', json.encode(body));
                Provider.of<AppProvider>(context, listen: false)
                    .updateAccount(body);
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return Home();
                    },
                  ),
                  (_) => false,
                );
              }
            }
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

  String otpapiUrl() {
    String _apiUrl;
    if (isLogin) {
      if (_pwReset) {
        print("sending password reset otp");
        _apiUrl = "${Constant.BASE_URL}/password/reset-token";
      } else {
        print("sending login OTP");
        _apiUrl = "${Constant.BASE_URL}/otp/email";
      }
    } else {
      _apiUrl = "${Constant.BASE_URL}/users";
    }
    return _apiUrl;
  }

  void _getOTP() async {
    print(otpapiUrl());
    if (_emailCont.text.isNotEmpty) {
      print("sending");
      setState(() {
        isOTPLoading = true;
      });
      var data = {
        'email': _emailCont.text,
      };
      try {
        http.Response res = await Network().getOTP(data, otpapiUrl());
        print(res.statusCode);
        print(res);
        if (res.statusCode == 200) {
          print("sending");
          setState(() {
            isOTPLoading = false;
          });
          var body = json.decode(res.body);
          _showMsg(body["message"]);
          print(!isLogin);
          if (isLogin && _pwReset) {
            isResetCodeSent = true;
          }
          if (!isLogin) {
            setState(() {
              isRegCodeSent = true;
            });
          }
        } else {
          print("sending");
          setState(() {
            isOTPLoading = false;
          });
          var body = json.decode(res.body);
          print(body);
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
          } else {
            _showMsg("an error occurred please try again later");
          }
        }
      } on Exception catch (e) {
        setState(() {
          isOTPLoading = false;
        });
        _showMsg(e.toString());
      }
    }
  }

  void _reset() async {
    if (loginValidateAndSave()) {
      print("sending");
      setState(() {
        isLoading = true;
      });
      var data = {
        'email': _emailCont.text,
      };
      try {
        http.Response res = await Network()
            .getOTP(data, 'https://api.abitnetwork.com/otp/email');
        print(res.statusCode);
        print(res);
        if (res.statusCode == 200) {
          print("sending");
          setState(() {
            isLoading = false;
          });
          var body = json.decode(res.body);
          _showMsg(body["message"]);
        } else {
          print("sending");
          setState(() {
            isLoading = false;
          });
          var body = json.decode(res.body);
          print(body);
          if (body["error"] != null) {
            _showMsg(body["error"]["message"].toString());
          } else {
            _showMsg("an error occurred please try again later");
          }
        }
      } on Exception catch (e) {
        setState(() {
          isLoading = false;
        });
        _showMsg(e.toString());
      }
    }
  }

  //todo handling login
  void signUp() async {
    if (loginValidateAndSave() && checkboxValue) {
      setState(() {
        isLoading = true;
      });
      var data = {
        'name': _fullName,
        'email': _email,
        // 'mobile_number' : _phoneNum,
        'country': _country,
        'password': _password,
        'date_of_birth': _dob,
      };
      try {
        var res = await Network().authData(data, '/api/auth/register');
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        // print (res);
        var body = json.decode(res.body);
        print('Printing body****************');
        print(body);
        print(body['success']);
        print(body['status']);
        print('printing access token*********');
        print(body['message']);

        if (body['success'] == null) {
          if (body['message'] == null) {
            _showMsg(body['fields']
                .toString()
                .replaceAll('{', '')
                .replaceAll('}', '')
                .replaceAll('[', '')
                .replaceAll(']', ''));
          } else {
            _showMsg(body['message'].toString());
          }
        } else if (body['success'] && body['success'] != null) {
          var bodyDetails = body['data'];
          print(bodyDetails);

          print('successful');
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString('token', json.encode(bodyDetails['token']));
          localStorage.setString('user', json.encode(body['data']));
          localStorage.setBool('verification', bodyDetails["email_verified"]);
          analytics.logEvent(name: 'Register', parameters: {
            'User': _email,
          });
          // _handleSendNotification('Welcome to Scholarships Africa', 'this is your first step into a trove of opportunities.');
          // if(bodyDetails["email_verified"]!=null){
          //   if(bodyDetails["email_verified"]){
          //     _handleSendNotification('Welcome Back', 'You have successfully logged in to scholarships Africa');
          //     Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //           return Home();
          //         },
          //       ),
          //           (_) => false,
          //     );
          //     // Navigator.of(context).pushReplacement(
          //     //     MaterialPageRoute(builder: (context) => Home()));
          //   }else{
          //     _handleSendNotification('Welcome Back', 'Verify your email to continue');
          //     Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //           return EmailVerificationPage(auto: false,);
          //         },
          //       ),
          //           (_) => false,
          //     );
          //     Navigator.of(context).pushReplacement(
          //         MaterialPageRoute(builder: (context) => EmailVerificationPage(auto: false,)));
          //   }
          // }else if(bodyDetails["email_verified"]==null){
          //   Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //     MaterialPageRoute(
          //       builder: (BuildContext context) {
          //         return Home();
          //       },
          //     ),
          //         (_) => false,
          //   );
          //   // Navigator.of(context).pushReplacement(
          //   //     MaterialPageRoute(builder: (context) => Home()));
          //   localStorage.setBool('verification', true);
          // }

          setState(() {
            isLoading = false;
          });
        } else if (body['error'] != null) {
          var error = body['error'];
          var inError = error['fields'];
//        var error = body['error'];
          print(error['message']);
          setState(() {
            isLoading = false;
          });
          print('not successful');
          if (error['message'] != null) {
            _showMsg(error['message'].toString());
          } else if (error['fields'] != null) {
            print(error['fields']);
//            _showMsg(error['fields'].toString());
//            _showMsg(error['fields'].toString().replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', ''));
            _showMsg(((error['message'] != null)
                    ? error['message']
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '')
                    : '') +
                ((inError['email'] != null)
                    ? inError['email']
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '')
                    : '') +
                ((inError['date_of_birth'] != null)
                    ? inError['date_of_birth']
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '')
                    : '') +
                ((inError['password'] != null)
                    ? inError['password']
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '')
                    : ''));
          }

//        _showMsg(((error['message'] != null)? error['message'].toString().replaceAll('[', '' ).replaceAll(']', '' ) : '') + ((inError['email'] != null)? inError['email'].toString().replaceAll('[', '' ).replaceAll(']', '' ) : ''));

        } else {
          setState(() {
            isLoading = false;
          });
          _showMsg('an error occurred, please try again later');
        }
        setState(() {
          isLoading = false;
        });
      } on SocketException catch (e) {
        _showMsg('You are not connected to internet');
        print("You are not connected to internet");
        print(e.message);
        setState(() {
          isLoading = false;
        });
      } on HandshakeException catch (e) {
        _showMsg(e.message);
        setState(() {
          isLoading = false;
        });
        print(e);
      } on Exception catch (e) {
        _showMsg(e.toString());
        if (this.mounted) {
          setState(() {
            isLoading = false;
          });
        }
        print(e);
        print('server down');
      }
    }
  }
  //todo for sending notifications
//   void _handleSendNotification(String heading, String content) async {
//     var status = await OneSignal.shared.getPermissionSubscriptionState();
//     var stat = await OneSignal.shared.getPermissionSubscriptionState();
//     var playerId = status.subscriptionStatus.userId;
//     var playerI = stat.subscriptionStatus.pushToken;
//     var imgUrlString =
//         "https://scholarships.africa/img/home/student.png";
//
//     var notification = OSCreateNotification(
//         playerIds: [playerId],
//         content: content,
//         heading: heading,
//         iosAttachments: {"id1": imgUrlString},
// //        sendAfter: DateTime.now(),
//         bigPicture: imgUrlString,
// //        buttons: [
// //          OSActionButton(text: "test1", id: "id1"),
// //          OSActionButton(text: "test2", id: "id2")
// //        ]
//     );
//
//     var response = await OneSignal.shared.postNotification(notification);
//     print(response);
//
//     // this.setState(() {
//     //   _debugLabelString = "Sent notification with response: $response";
//     // });
//   }

}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
