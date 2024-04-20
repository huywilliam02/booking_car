import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';
import 'package:citgroupvn_carwash/Provider/notificaton_auth.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/screens/home/home_page.dart';
import 'package:citgroupvn_carwash/screens/payment.dart';
import '../Const/pref_utils.dart';
import 'forgot_password.dart';
import 'otp_screen.dart';
import 'sign_up.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const darkBlue = Color(0xFF265E9E);
const containerShadow = Color(0xFF91B4D8);
const extraDarkBlue = Color(0xFF91B4D8);

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late NotificationAuth notificationAuth;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode email = FocusNode();
  FocusNode password = FocusNode();
  var showSnipper = false;
  String playerIddd = "";
  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    notificationAuth = Provider.of<NotificationAuth>(context, listen: false);
    // getDeviceToken();
    getToken();
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  // getDeviceToken() async {
  //   check().then((internet) async {
  //     if (internet) {
  //       await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  //       String status = "";
  //       await OneSignal.shared.getDeviceState().then((value) {
  //         if(value!.userId!=null)
  //           {
  //             status = value.userId!;
  //           }
  //         print('device token is $status');
  //       });
  //       playerIddd = "dkfihreajosidofjaaawehssewthgkl";
  //       print('device token is $playerIddd');
  //       SharedPreferences localStorage = await SharedPreferences.getInstance();
  //       localStorage.setString('device_token', status);
  //     } else {
  //       showDialog(
  //         builder: (context) => AlertDialog(
  //           title: Text('Internet connection'),
  //           content: Text('Check your internet connection'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () async {
  //                 Navigator.pop(context);
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => SignIn(),
  //                     ));
  //               },
  //               child: Text('OK'),
  //             )
  //           ],
  //         ),
  //         context: context,
  //       );
  //     }
  //   });
  // }

  void _login(data) async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSnipper = true;
        });
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var isFrom = localStorage.getString('isFrom');
        var navigate;
        isFrom == 'BookAppointment'
            ? navigate = Payment()
            : navigate = HomePage();
        var deviceToken = playerIddd;
        var checkDeviceToken = localStorage.getBool('deviceToken');
        if (checkDeviceToken == true) {
          data['device_token'] = deviceToken;
        }
        var res;
        var body;
        var resData;
        var userId;
        try {
          res = await CallApi().postData(data, 'login');
          body = json.decode(res.body);
          resData = body['data'];
          if (body['success'] == true) {
            notificationAuth.signInWithFirebase(
              body['data']['email'],
              _passwordController.text,
              body['data']['id'].toString(),
              body['data']['completeImage'],
              body['data']['name'],
              body['data']['phone'],
            );
            if (body['data']['is_verified'] == 1) {
              _emailController.text = '';
              _passwordController.text = '';
              SharedPreferences localStorage =
                  await SharedPreferences.getInstance();
              localStorage.setString('token', resData['token']);
              localStorage.setString('user', json.encode(resData));
              // var abc = localStorage.getString('token');
              if (isFrom != 'BookAppointment') {
                Fluttertoast.showToast(
                    msg: 'Login Successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM);
              }
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => navigate,
                  ));
            } else {
              showDialog(
                builder: (context) => AlertDialog(
                  title: Text('Login Error'),
                  content: Text('Please verify your account'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        _emailController.text = '';
                        _passwordController.text = '';
                        SharedPreferences localStorage =
                            await SharedPreferences.getInstance();
                        localStorage.setString('user', json.encode(resData));
                        userId = body['data']['id'];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTP(
                                userIdOfOtp: userId,
                              ),
                            ));
                      },
                      child: Text('OK'),
                    )
                  ],
                ),
                context: context,
              );
            }
          } else {
            print(body['message']);
            showDialog(
              builder: (context) => AlertDialog(
                title: Text('Login Error'),
                content: Text(body['message'].toString()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Try Again'),
                  )
                ],
              ),
              context: context,
            );
          }
        } catch (e) {
          showDialog(
            builder: (context) => AlertDialog(
              title: Text('Login Error'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Try Again'),
                )
              ],
            ),
            context: context,
          );
        }
        setState(() {
          showSnipper = false;
        });
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('Internet connection'),
            content: Text('Check your internet connection'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
                      ));
                },
                child: Text('OK'),
              )
            ],
          ),
          context: context,
        );
      }
    });
  }

  Future<bool> onWillPop() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    notificationAuth = Provider.of<NotificationAuth>(context);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Form(
        key: _formKey,
        child: Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: showSnipper,
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        child: Image(
                          alignment: Alignment.center,
                          height: 90.0,
                          width: 252.0,
                          image: AssetImage('assets/icons/shinewashicon.png'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(45.0)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Signin',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 20.0,
                                          fontFamily: 'Nadillas',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: containerShadow,
                                                blurRadius: 2,
                                                offset: Offset(0, 0),
                                                spreadRadius: 1,
                                              )
                                            ]),
                                        child: TextFormField(
                                          controller: _emailController,
                                          focusNode: email,
                                          onFieldSubmitted: (a) {
                                            email.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(password);
                                          },
                                          validator: (value) {
                                            Pattern pattern =
                                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                            RegExp regex =
                                                new RegExp(pattern as String);

                                            if (value!.isEmpty) {
                                              return 'please enter your email';
                                            } else if (!regex.hasMatch(value)) {
                                              return 'Enter valid email address';
                                            }

                                            return null;
                                          },
                                          enableSuggestions: false,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(15),
                                            border: InputBorder.none,
                                            suffixIcon: SvgPicture.asset(
                                              'assets/icons/usericon.svg',
                                              fit: BoxFit.scaleDown,
                                            ),
                                            hintText: 'E-mail Address',
                                            hintStyle: TextStyle(
                                              color: darkBlue,
                                              fontSize: 16,
                                              fontFamily: 'FivoSansMedium',
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: darkBlue,
                                            fontSize: 16,
                                            fontFamily: 'FivoSansMedium',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: containerShadow,
                                                blurRadius: 2,
                                                offset: Offset(0, 0),
                                                spreadRadius: 1,
                                              )
                                            ]),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please Enter Password";
                                            } else if (value.length < 6) {
                                              return "Password must be atleast 6 characters long";
                                            } else {
                                              return null;
                                            }
                                          },
                                          focusNode: password,
                                          onFieldSubmitted: (a) {
                                            password.unfocus();
                                          },
                                          obscureText: _isHidden,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(15),
                                            border: InputBorder.none,
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isHidden = !_isHidden;
                                                  });
                                                },
                                                icon: Icon(
                                                  _isHidden
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: darkBlue,
                                                  size: 20,
                                                )),
                                            hintText: 'Password',
                                            hintStyle: TextStyle(
                                              color: darkBlue,
                                              fontSize: 16,
                                              fontFamily: 'FivoSansMedium',
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: darkBlue,
                                            fontSize: 16,
                                            fontFamily: 'FivoSansMedium',
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ForgotPassword(),
                                                  ));
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: extraDarkBlue,
                                                fontFamily: 'FivoSansRegular',
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              SharedPreferences localStorage =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var isFrom = localStorage
                                                  .getString('isFrom');
                                              var navigate;
                                              isFrom == 'BookAppointment'
                                                  ? navigate = Payment()
                                                  : navigate = HomePage();
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        navigate,
                                                  ));
                                            },
                                            child: Text(
                                              'Skip Signing in',
                                              style: TextStyle(
                                                color: extraDarkBlue,
                                                fontFamily: 'FivoSansRegular',
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(10.0),
                                      width: MediaQuery.of(context).size.width,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(35.0)),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final body = {
                                              "email": _emailController.text,
                                              "password":
                                                  _passwordController.text,
                                              "provider": "LOCAL",
                                            };
                                            _login(body);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 2.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(35.0),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Signin',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: 'FivoSansRegular',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            'If you are new user?',
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontSize: 18,
                                                fontFamily: 'FivoSansRegular'),
                                          ),
                                        ),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          child: IconButton(
                                            icon: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  color: Color(0xFF004695),
                                                  fontSize: 25,
                                                  fontFamily: 'FivoSansMedium',
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignUp()));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String token = "";

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      print("Notification Token:" + token);
      SharedPreferenceHelperUtils.setString(
          NotificationConstant.notificationRegisterKey, token);
      // await chatProvider.updateDataFirestore(ChatConstant.pathCollection, chatAuthProvider.getUserFirebaseId()!, {'pushToken': token});
    }
  }
}
