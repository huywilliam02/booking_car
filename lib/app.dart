import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/Provider/notification_provider.dart';
import 'package:citgroupvn_carwash/Provider/notificaton_auth.dart';
import 'package:citgroupvn_carwash/screens/constants.dart';
import 'Const/preference.dart';
import 'api/api.dart';
import 'screens/all_appointment.dart';
import 'screens/home/home_page.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  bool deviceToken = false;
  var appId;
  String currencySymbol = "";
  String currencyCode = "";

  @override
  void initState() {
    super.initState();
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    // getOneSignalRequest();
  }

  // Future<void> getOneSignalRequest() async {
  //   //one signal mate
  //   await OneSignal.shared.setRequiresUserPrivacyConsent(true);
  //   var settingApi = await CallApi().getData('setting');
  //   var bodyy = json.decode(settingApi.body);
  //   Map theDataa = bodyy['data'];
  //   appId = theDataa['onesignal_app_id'];
  //   currencySymbol = theDataa['currency_symbol'];
  //   currencyCode = theDataa['currency'];
  //   OneSignal.shared.consentGranted(true);
  //   OneSignal.shared.setAppId("$appId");
  //   SharedPreferenceHelper.setString(Constants.currencySymbol, currencySymbol);
  //   SharedPreferenceHelper.setString(Constants.currencyCode, currencyCode);
  //
  //   OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  //
  //   OneSignal.shared.setAppId("$appId");
  //
  //   await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  //
  //   Timer(Duration(seconds: 2), () async {
  //     var playerId;
  //     await OneSignal.shared.getDeviceState().then((value) {
  //       playerId = value!.userId;
  //       print('the player id is ${value.userId}');
  //     });
  //     SharedPreferences localStorage = await SharedPreferences.getInstance();
  //     if (playerId != null) {
  //       localStorage.setBool('deviceToken', true);
  //       deviceToken = true;
  //     } else {
  //       deviceToken = false;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationAuth>(
          create: (context) => NotificationAuth(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(),
        )
      ],
      child: Consumer<NotificationAuth>(builder: (_, themeProvider, widget) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          },
          child: MaterialApp(
            title: 'Shinewash',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Color(0xFF6B48FF),
              scaffoldBackgroundColor: Colors.white,
              dividerColor: Colors.transparent,
            ),
            home: HomePage(),
            routes: <String, WidgetBuilder>{
              '/HomePage': (BuildContext context) => HomePage(),
              '/AllAppointment': (BuildContext context) => AllAppointment(),
            },
          ),
        );
      }),
    );
  }
}
