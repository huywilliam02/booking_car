import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/Const/pref_utils.dart';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';
import 'package:citgroupvn_carwash/Provider/notification_provider.dart';
import 'package:citgroupvn_carwash/api/api.dart';

import 'all_appointment.dart';

class DemoStripeScreen extends StatefulWidget {
  final String? cardNumber;
  final String? expDate;
  final String? cvv;
  final String? cardHolderName;
  final int? paymentTokenKnow;
  final int? paymentStatus;
  final String? paymentType;
  final int? selectedIndex;
  final bool? addressShop;
  final bool? addressHome;
  final String? addressHomeText;

  const DemoStripeScreen({
    Key? key,
    this.paymentTokenKnow,
    this.paymentStatus,
    this.paymentType,
    this.cardNumber,
    this.expDate,
    this.cvv,
    this.cardHolderName,
    this.selectedIndex,
    this.addressShop,
    this.addressHomeText,
    this.addressHome,
  }) : super(key: key);

  @override
  State<DemoStripeScreen> createState() => _DemoStripeScreenState();
}

class _DemoStripeScreenState extends State<DemoStripeScreen> {
  String? stripePublicKey;
  String? stripeSecretKey;
  String? stripeToken;
  int? paymentTokenKnow;
  int? paymentStatus;
  String? paymentType;
  // ScrollController _controller = ScrollController();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  int? selectedIndex;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var totalPayableAmount;
  var totalDiscount;
  bool? addressShop;
  bool? addressHome;
  bool? addressView;
  String? addressHomeText;
  List<int> serviceIdList = <int>[];
  var coworkerId;
  var timeSlot;
  var date;
  var offerId;
  String serviceType = '';
  var lat;
  var long;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late NotificationProvider notificationProvider;
  @override
  void initState() {
    super.initState();
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    setStripeKey();
    paymentTokenKnow = widget.paymentTokenKnow;
    paymentStatus = widget.paymentStatus;
    paymentType = widget.paymentType;
    selectedIndex = widget.selectedIndex;
    addressShop = widget.addressShop;
    addressHome = widget.addressHome;
    addressHomeText = widget.addressHomeText;
    _totalPayableAmount();
    getLocation();
  }

  _totalPayableAmount() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    totalPayableAmount = localStorage.getString('totalPayableAmount');
    totalDiscount = localStorage.getString('totalDiscount');
    coworkerId = localStorage.getString('coworkerId');
    timeSlot = localStorage.getString('timeSlot');
    date = localStorage.getString('date');
    totalDiscount = localStorage.getString('totalDiscount');
    offerId = localStorage.getString('offer_id');
    setState(() {
      showSpinner = false;
    });
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    long = position.longitude;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('latitude', lat.toString());
    localStorage.setString('longitude', long.toString());
  }

  setStripeKey() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    stripeSecretKey = localStorage.get('stripeSecretKey') as String?;
    stripePublicKey = localStorage.get('stripePublishKey') as String?;
    Stripe.publishableKey = stripePublicKey!;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
  }

  Future<void> bookingAppointment(data) async {
    setState(() {
      showSpinner = true;
    });
    try {
      var res = await CallApi().postDataWithToken(data, 'book_appoinment');

      var body = json.decode(res.body);
      print('body is $body');

      if (body['success'] == true) {
        setState(() {
          showSpinner = false;
        });
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('addValue');
        await notificationProvider.sendNotification(
            content:
                "Dear ${SharedPreferenceHelper.getString("WorkerName")} recently booked your appointment ${body['data']} date : ${date} time ${timeSlot}",
            token: SharedPreferenceHelper.getString("employeeToken"));
        // notificationProvider.sendNotification(content: "Dear ${SharedPreferenceHelper.getString("WorkerName")} , recently booked your appointment Appointment Id is ${body['data']} from ${SharedPreferenceHelper.getString("company")}", token:SharedPreferenceHelper.getString("employeeToken"));
        await notificationProvider.sendNotification(
            content:
                "Dear ${SharedPreferenceHelper.getString("UserName")} , recently booked your appointment Appointment Id is ${body['data']} from ${SharedPreferenceHelper.getString("company")}",
            token: SharedPreferenceHelperUtils.getString(
                NotificationConstant.notificationRegisterKey)!);
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, '/HomePage', (route) => false);
        });
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              'Payment Successful',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkBlue,
                fontSize: 20,
                fontFamily: 'PoppinsMedium',
              ),
            ),
            content: Wrap(
              children: [
                Image(
                  image: AssetImage(
                    'assets/images/payment_success.png',
                  ),
                  fit: BoxFit.fill,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Text(
                      'Booking Confirmed',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 25,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(alignment: Alignment.center),
                child: Text(
                  'Thank You',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
        );
      } else {
        setState(() {
          String str = "${body['message']}";

          List<String> parts = str.split("https");
          String startPart = parts[0].trim();

          List<String> parts1 = str.split(":");
          String startPart1 = parts1[0].trim();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Payment Fail'),
              content: startPart1 == "Invalid currency"
                  ? Text(startPart)
                  : Text(body['message']),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Try Again'),
                )
              ],
            ),
          );
        });
      }
    } catch (e) {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Error'),
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
      showSpinner = false;
    });
  }

  CardFieldInputDetails? cardFormEditController;

  Future<void> _handleCreateTokenPress() async {
    if (cardFormEditController == null) {
      return;
    }

    try {
      setState(() {
        showSpinner = true;
      });
      final tokenData = await Stripe.instance.createToken(
          CreateTokenParams.card(
              params: CardTokenParams(type: TokenType.Card)));
      setState(() {
        showSpinner = false;
        this.tokenData = tokenData;
        // CallApi(tokenData.id);
        if (tokenData.id.isNotEmpty) {
          callBookingApi(tokenData.id);
        }
      });
      print("Strip response Key:" + tokenData.id);
      return;
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  callBookingApi(String token) async {
    try {
      stripeToken = token;
      var totalDiscountINT;
      if (totalDiscount != 'null') {
        var a = double.parse(totalDiscount);
        totalDiscountINT = a.toInt();
      } else {
        totalDiscountINT = 0;
      }
      var b = double.parse(totalPayableAmount.toString());
      var totalPayableINT = b.toInt();
      var passAddress = '';
      setState(() {
        addressShop == true ? addressView = false : addressView = true;
      });
      if (addressView == false) {
        passAddress = 'SHOP';
        serviceType = 'SHOP';
      } else {
        serviceType = 'HOME';
        passAddress = addressHomeText.toString();
      }
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      int addvaluelength = localStorage.getInt('addValueLength')!;
      List<String> lsModelserviceid = [];
      List<int> lsModelserviceidConverted = [];
      lsModelserviceid =
          (localStorage.getStringList('modelServiceId') ?? <String>[]);
      var convertmodelserviceid;
      for (int a = 0; a < addvaluelength; a++) {
        convertmodelserviceid = int.parse(lsModelserviceid[a]);
        lsModelserviceidConverted.add(convertmodelserviceid);
      }
      serviceIdList.clear();
      for (int i = 0; i < addvaluelength; i++) {
        serviceIdList.add(lsModelserviceidConverted[i]);
      }
      Map<String, dynamic> body;
      addressView == true
          ? body = {
              'service_id': serviceIdList,
              'coworker_id': coworkerId,
              'start_time': timeSlot,
              'discount': totalDiscountINT,
              'coupen_id': offerId,
              'date': date,
              'payment_type': paymentType,
              'payment_token': stripeToken,
              'amount': totalPayableINT,
              'payment_status': '1',
              'service_type': serviceType,
              'lat': lat.toString(),
              'lang': long.toString(),
              'address': passAddress,
            }
          : body = {
              'service_id': serviceIdList,
              'coworker_id': coworkerId,
              'start_time': timeSlot,
              'discount': totalDiscountINT,
              'coupen_id': offerId,
              'date': date,
              'payment_type': paymentType,
              'payment_token': stripeToken,
              'amount': totalPayableINT,
              'payment_status': '1',
              'service_type': serviceType,
            };
      print(body);
      bookingAppointment(body);
    } catch (e) {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Error'),
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
  }

  TokenData? tokenData;

  @override
  Widget build(BuildContext context) {
    notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text(
          'Stripe Payment',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardField(
              onCardChanged: (value) {
                setState(() {
                  cardFormEditController = value;
                });
              },
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: cardFormEditController?.complete == true
                    ? _handleCreateTokenPress
                    : null,
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'FivoSansMedium',
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
