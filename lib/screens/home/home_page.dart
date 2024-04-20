import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:citgroupvn_carwash/Const/pref_utils.dart';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';
import 'package:citgroupvn_carwash/Provider/notificaton_auth.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/main.dart';
import 'package:citgroupvn_carwash/models/coworkerM.dart';
import 'package:citgroupvn_carwash/models/employee_profile_skills.dart';
import 'package:citgroupvn_carwash/models/home_category.dart';
import 'package:citgroupvn_carwash/models/home_offer.dart';
import 'package:citgroupvn_carwash/screens/constants.dart';
import 'package:citgroupvn_carwash/screens/custom_drawer.dart';
import '../employee_profile.dart';
import '../services.dart';
import '../specialist_full_page.dart';
import 'package:connectivity/connectivity.dart';

const containerBackground = Color(0xFFE9F0F7);
const darkBlue = Color(0xFF265E9E);
const ratingStar = Color(0xFFFECD03);

class HomePage extends StatefulWidget {
  final String homepage = '/HomePage';
  final appId;

  const HomePage({Key? key, this.appId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var showSpinner = false;
  String? _userImage = "";
  String? _userName = '';
  var _isLoggedIn = false;
  var appId;
  bool? checkConnectivity;
  DateTime? currentBackPressTime;
  late double _currentLatitude;
  late double _currentLongitude;
  late double _shopLatitude;
  late double _shopLongitude;
  late NotificationAuth notificationAuth;
  @override
  void initState() {
    super.initState();
    appId = widget.appId;
    notificationAuth = Provider.of<NotificationAuth>(context, listen: false);
    _getImage();
    paymentSettingData();
    getLatLong();

    ///category
    getDataCategories();
    _getDataSpecialist();

    ///specialist
    _getDataSpecial();

    ///offer
    _getDataOffer();
    _isLoggedIn ? changeTokenStatus() : null;
    var initializationAndroidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationAndroidSettings);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings, /* onSelectNotification: onSelectNotification*/
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> dataValue = message.data;
      String screen = dataValue['screen'].toString();
      // vendorImage = dataValue['vendorImage'].toString();
      // vendorName = dataValue['vendorName'].toString();
      // vendorId = dataValue['vendorShopId'].toString();
      // print("Screen: " + screen);

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: "@mipmap/ic_launcher",
              ),
            ),
            payload: screen);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        // if (SharedPreferenceHelperUtils.getString(PrefConstant.emailkey) != "N/A") {
        //   if (vendorId.isNotEmpty && vendorName.isNotEmpty && vendorImage.isNotEmpty) {
        //     Navigator.of(
        //       navigatorKey.currentState!.context,
        //     ).push(MaterialPageRoute(
        //         builder: (context) => ChatWithVendor(
        //           vendorId: vendorId,
        //           vendorImage: vendorImage,
        //           vendorName: vendorName,
        //           whichPage: "login",
        //         )));
        //   }
        // } else {
        //   Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(builder: (context) => LoginPage()));
        // }
      }
    });
  }

  onSelectNotification(payload) {
    if (payload == "screen") {
      // if (SharedPreferenceHelperUtils.getString(PrefConstant.emailkey) != "N/A") {
      //   if (vendorId.isNotEmpty && vendorName.isNotEmpty && vendorImage.isNotEmpty) {
      //     Navigator.of(
      //       navigatorKey.currentState!.context,
      //     ).push(MaterialPageRoute(
      //         builder: (context) => ChatWithVendor(
      //           vendorId: vendorId,
      //           vendorImage: vendorImage,
      //           vendorName: vendorName,
      //           whichPage: "login",
      //         )));
      //   }
      // } else {
      //   Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(builder: (context) => LoginPage()));
      // }
    }
  }

  void changeTokenStatus() async {
    if (notificationAuth.getUserFirebaseId() != "N/A" ||
        notificationAuth.getUserFirebaseId()!.isNotEmpty) {
      await notificationAuth.updateDataFirestore(
          NotificationConstant.pathCollection,
          notificationAuth.getUserFirebaseId()!, {
        'pushToken': SharedPreferenceHelperUtils.getString(
            NotificationConstant.notificationRegisterKey)
      });
      print("Firebase ID:" + notificationAuth.getUserFirebaseId()!);
      print("Notification Token:" +
          SharedPreferenceHelperUtils.getString(
              NotificationConstant.notificationRegisterKey)!);
    }
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

  Future<void> _getImage() async {
    check().then((internet) async {
      if (internet) {
        // Internet Present Case
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var user = localStorage.getString('user');
        if (user != null) {
          setState(() {
            _isLoggedIn = true;
          });
        } else {
          _isLoggedIn = false;
        }
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('user');
        var body = json.decode(res.body);
        var theData = body;
        if (theData != null) {
          _userName = theData['name'];
          _userImage = theData['completeImage'];
        }
        setState(() {
          showSpinner = false;
        });
      }
      // No-Internet Case
      else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('Internet connection'),
            content: Text('Check your internet connection'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
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

  Future<void> paymentSettingData() async {
    check().then((internet) async {
      if (internet) {
        // Internet Present Case
        var res = await CallApi().getWithToken('payment_setting');
        var body = json.decode(res.body);
        var theData = body['data'];
        var stripePublishKey = '';
        var stripeSecretKey = '';
        if (theData['stripe_publish_key'] != null) {
          stripePublishKey = theData['stripe_publish_key'];
        }
        if (theData['stripe_secret_key'] != null) {
          stripeSecretKey = theData['stripe_secret_key'];
        }
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('stripePublishKey', stripePublishKey);
        localStorage.setString('stripeSecretKey', stripeSecretKey);
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('Internet connection'),
            content: Text('Check your internet connection'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                },
                child: Text('OK'),
              )
            ],
          ),
          context: context,
        );
      }
      // No-Internet Case
    });
  }

  Future<void> _getData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = localStorage.getString('user');
    if (user != null) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    _getImage();
    paymentSettingData();
    getLatLong();

    ///category
    getDataCategories();
    _getDataSpecialist();

    ///specialist
    _getDataSpecial();

    ///offer
    _getDataOffer();
  }

  Future<void> getLatLong() async {
    setState(() {
      showSpinner = true;
    });
    var res = await CallApi().getWithToken('setting');
    var body = json.decode(res.body);
    var theData = body['data'];
    var apiLat = theData['latitude'];
    var apiLong = theData['longitude'];
    SharedPreferenceHelper.setString(
        Constants.currencySymbol, theData['currency_symbol']);
    SharedPreferenceHelper.setString(
        Constants.currencyCode, theData['currency']);
    _shopLatitude = double.parse(apiLat.toString());
    _shopLongitude = double.parse(apiLong.toString());
    var permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;
    _currentLatitude = double.parse(lat.toString());
    _currentLongitude = double.parse(long.toString());
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setDouble('currentLatitude', _currentLatitude);
    localStorage.setDouble('currentLongitude', _currentLongitude);
    localStorage.setDouble('shopLatitude', _shopLatitude);
    localStorage.setDouble('shopLongitude', _shopLongitude);
    setState(() {
      showSpinner = false;
    });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    notificationAuth = Provider.of<NotificationAuth>(context);
    _isLoggedIn ? changeTokenStatus() : null;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // Theme.of(context).primaryColor
              SliverAppBar(
                backgroundColor: Theme.of(context).primaryColor,
                collapsedHeight: 60,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                expandedHeight: 150,
                automaticallyImplyLeading: false,
                pinned: true,
                title: Row(
                  children: [
                    _isLoggedIn
                        ? Container(
                            margin: EdgeInsets.all(5.5),
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 1,
                                  spreadRadius: 1.0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image(
                                image: (_userImage!.isNotEmpty
                                        ? NetworkImage(
                                            _userImage!,
                                          )
                                        : AssetImage(
                                            'assets/images/no_image.png'))
                                    as ImageProvider<Object>,
                                height: 30.0,
                                width: 30.0,
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.all(5.5),
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 1,
                                  spreadRadius: 1.0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset(
                                    'assets/icons/profile_picture.png')),
                          ),
                    SizedBox(
                      width: 15,
                    ),
                    _isLoggedIn
                        ? Text(
                            _userName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FivoSansMedium',
                              fontSize: 18.0,
                            ),
                          )
                        : Text(
                            "Justine Hayes",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FivoSansMedium',
                              fontSize: 18.0,
                            ),
                          ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(""),
                  background: Padding(
                    padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: MediaQuery.of(context).size.height * 0.15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'FivoSansMedium',
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Shine Wash',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nadillas',
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // flexibleSpace: FlexibleSpaceBar(
                //   title: Container(),
                //   background: GestureDetector(
                //     onTap: () {
                //       FocusScopeNode currentFocus = FocusScope.of(context);
                //       if (!currentFocus.hasPrimaryFocus) {
                //         currentFocus.unfocus();
                //       }
                //     },
                //     child: Container(
                //       // height: MediaQuery.of(context).size.height / 6,
                //       width: MediaQuery.of(context).size.width,
                //       decoration: BoxDecoration(
                //         color: Theme.of(context).primaryColor,
                //         borderRadius: BorderRadiusDirectional.vertical(
                //           bottom: Radius.circular(40.0),
                //         ),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 10.0),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             SizedBox(height: 18.0),
                //             Padding(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 15.0),
                //               child: Text(
                //                 'Welcome to',
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontFamily: 'FivoSansMedium',
                //                   fontSize: 18,
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 15.0),
                //               child: Text(
                //                 'Shine Wash',
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontFamily: 'Nadillas',
                //                   fontSize: 20,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // actions: [
                //       IconButton(
                //         onPressed: () {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => CustomDrawer(),
                //               ));
                //         },
                //         icon: Icon(
                //           FontAwesomeIcons.bars,
                //           size: 22,
                //           color: Colors.white,
                //         ),
                //       ),
                // ],
                actions: [
                  IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => CustomDrawer(),
                        //     ));
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(
                        FontAwesomeIcons.bars,
                      ))
                ],
                floating: false,
              )
            ];
          },
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: _getData,
            child: SafeArea(
                child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  /* ///welcome
                    GestureDetector(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(40.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 18.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text(
                                  'Welcome to',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'FivoSansMedium',
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text(
                                  'Shine Wash',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nadillas',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
                  // SizedBox(height: 20.0),

                  ///category
                  theCategory,
                  SizedBox(height: 10.0),

                  ///specialist
                  specialist,

                  ///offer
                  offer,
                  SizedBox(height: 10.0),
                ],
              ),
            )),
          ),
        ),
        drawer: CustomDrawer(),
        // appBar: AppBar (
        //   elevation: 0,
        //   leading: Row(
        //     children: [
        //       SizedBox(
        //         width: 13.0,
        //       ),
        //       _isLoggedIn? Container(
        //         margin: EdgeInsets.all(5.5),
        //         height: 30.0,
        //         width: 30.0,
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           border: Border.all(color: Colors.white, width: 1.5),
        //           shape: BoxShape.circle,
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.white,
        //               blurRadius: 1,
        //               spreadRadius: 1.0,
        //             ),
        //           ],
        //         ),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(20.0),
        //           child: Image(
        //             image: (_userImage!.isNotEmpty
        //                         ? NetworkImage(
        //                             _userImage!,
        //                           )
        //                         : AssetImage('assets/images/no_image.png'))
        //                 as ImageProvider<Object>,
        //             height: 30.0,
        //             width: 30.0,
        //             fit: BoxFit.fill,
        //           ),
        //         ),
        //       ) : Container(),
        //     ],
        //   ),
        //   backgroundColor: Theme.of(context).primaryColor,
        //   title: _isLoggedIn ? Text(
        //     _userName!,
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontFamily: 'FivoSansMedium',
        //       fontSize: 18.0,
        //     ),
        //   ) : null,
        //   actionsIconTheme: IconThemeData(color: Colors.white),
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
        //       child: IconButton(
        //         onPressed: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) => CustomDrawer(),
        //               ));
        //         },
        //         icon: Icon(
        //           FontAwesomeIcons.bars,
        //           size: 22,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  ///category no data
  var passTheData;
  int? previousSpeId = 3;
  int? previousCatId = 1;
  var selectedSkills;
  var passId;
  List<CoworkerModel> cw = <CoworkerModel>[];

  List<Categories> ct = <Categories>[];
  Categories c = Categories();

  Future<void> _getDataSpecialist() async {
    ct.clear();
    var res = await CallApi().getWithToken('all_coworker');
    var body = json.decode(res.body);
    var theData = body['data'];
    cw = [];
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      cw.add(CoworkerModel.fromJson(map));
    }
    passId = cw.first.id;
  }

  Future<Categories?> getDataCategories() async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('category');
        var body = json.decode(res.body);
        var theData = body['data'];
        for (int i = 0; i < theData.length; i++) {
          Map<String, dynamic> map = theData[i];
          ct.add(Categories.fromJson(map));
        }
        setState(() {
          showSpinner = false;
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
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

  Future<void> getData(passTheData, index, categories) async {
    setState(() {
      showSpinner = true;
    });
    var res =
        await CallApi().postData(passTheData, 'category_wise_service_coworker');
    var body = json.decode(res.body);
    var theData = body['data'];
    selectedSkills = theData.length;
    if (selectedSkills != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Services(
              index: index,
              categoryId: categories,
              selecetedSkill: selectedSkills,
              previuosSpeId: passId,
            ),
          ));
    }
    setState(() {
      showSpinner = false;
    });
  }

  Widget get theCategory {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      // height: MediaQuery.of(context).size.height / 5.25,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  color: darkBlue,
                  fontFamily: 'FivoSansMedium',
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height / 6.2, //115.0
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ct.length,
              itemBuilder: (context, index) {
                Categories categories = ct[index];
                return InkWell(
                  onTap: () {
                    previousCatId = categories.id;
                    previousSpeId = passId;
                    passTheData = {
                      "coworker_id": '$previousSpeId',
                      "category_id": '$previousCatId'
                    };
                    getData(passTheData, index, categories.id);
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(8.0),
                        height: MediaQuery.of(context).size.height / 11,
                        width: MediaQuery.of(context).size.width / 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image(
                            fit: BoxFit.fill,
                            height: 28,
                            width: 27,
                            image: NetworkImage('${categories.image}'),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        color: Colors.white,
                        child: Text(
                          categories.categoryName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontFamily: 'FivoSansRegular',
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ///specialist no data
  Future<void> _getDataSpecial() async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('all_coworker');
        var body = json.decode(res.body);
        var theData = body['data'];
        sp.clear();
        for (int i = 0; i < theData.length; i++) {
          Map<String, dynamic> map = theData[i];
          sp.add(CoworkerModel.fromJson(map));
        }
        var servicename = {"service_name": ""};
        for (int j = 0; j < theData.length; j++) {
          if (theData[j]['service'].length > 0) {
            Map<String, dynamic> map = theData[j]['service'][0];
            sk.add(Skill.fromJson(map));
          } else {
            Map<String, dynamic> map = servicename;
            sk.add(Skill.fromJson(map));
          }
        }
        setState(() {
          showSpinner = false;
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
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

  var passIdSpecialist;
  List<CoworkerModel> sp = <CoworkerModel>[];
  CoworkerModel s = new CoworkerModel();
  List<Skill> sk = <Skill>[];

  Widget get specialist {
    return Container(
      // height: MediaQuery.of(context).size.height / 3.1,
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Specialist',
                  style: TextStyle(
                    color: darkBlue,
                    fontFamily: 'FivoSansMedium',
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: 'FivoSansMedium',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecialistFull(),
                        ));
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.5),
            height: MediaQuery.of(context).size.height / 3.7, //185.0
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sp.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                CoworkerModel specialists = sp[index];
                Skill skill = sk[index];
                return GestureDetector(
                  onTap: () {
                    check().then((internet) {
                      if (internet) {
                        // Internet Present Case
                        passIdSpecialist = sp[index].id;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmployeeProfile(
                                      specialistId: passIdSpecialist,
                                    )));
                      }
                      // No-Internet Case
                      else {
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
                                        builder: (context) => HomePage(),
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
                  },
                  child: Container(
                    width: 112,
                    margin: EdgeInsets.all(10.0),
                    // color: Colors.yellow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image(
                            height: 100.0,
                            width: 100.0,
                            fit: BoxFit.cover,
                            image: NetworkImage('${specialists.image}'),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          specialists.name!,
                          style: TextStyle(
                            color: darkBlue,
                            fontFamily: 'FivoSansMedium',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 5.0),
                        //TODO:migration updated
                        Align(
                          alignment: Alignment.topLeft,
                          child: RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: specialists.rating!.toDouble(),
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 15,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: ratingStar,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          skill.name!,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 12,
                            fontFamily: 'FivoSansMedium',
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ///offerData
  Future<void> _getDataOffer() async {
    check().then((internet) async {
      if (internet) {
        // Internet Present Case
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('offer');
        var body = json.decode(res.body);
        var theData = body['data'];
        of.clear();
        for (int i = 0; i < theData.length; i++) {
          Map<String, dynamic> map = theData[i];
          of.add(Offers.fromJson(map));
        }
        setState(() {
          showSpinner = false;
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ));
                },
                child: Text('OK'),
              )
            ],
          ),
          context: context,
        );
      }
      // No-Internet Case
    });
  }

  List<Offers> of = <Offers>[];
  Offers o = Offers();

  Widget get offer {
    return Container(
      // height: MediaQuery.of(context).size.height / 4.3,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Offer',
              style: TextStyle(
                color: darkBlue,
                fontFamily: 'FivoSansMedium',
                fontSize: 18,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 4, //133.0
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: of.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Offers offer = of[index];
                return Container(
                  height: 183,
                  width: 253,
                  margin: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image(
                          height: 113,
                          width: 250,
                          fit: BoxFit.fill,
                          image: NetworkImage(offer.image!),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        offer.description!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkBlue,
                          fontFamily: 'FivoSansMedium',
                          fontSize: 14.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
