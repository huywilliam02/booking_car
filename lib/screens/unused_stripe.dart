import 'dart:async';
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'appointment.dart';

class PaymentStripe extends StatefulWidget {
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

  const PaymentStripe({
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
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
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

  @override
  initState() {
    super.initState();
    getStripePublishKey();
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

  Future<void> getStripePublishKey() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    stripeSecretKey = localStorage.get('stripeSecretKey') as String?;
    stripePublicKey = localStorage.get('stripePublishKey') as String?;
    // Stripe.publishableKey = stripePublicKey!;
    Stripe.publishableKey = "pk_test_aSaULNS8cJU6Tvo20VAXy6rp";
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
    print(Stripe);
    //change
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: "$stripePublicKey",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));
  }

  setError(dynamic error) {
    print(error.toString());
  }

  // void onCreditCardModelChange(CreditCardModel creditCardModel) {
  //   setState(() {
  //     cardNumber = creditCardModel.cardNumber;
  //     expiryDate = creditCardModel.expiryDate;
  //     cardHolderName = creditCardModel.cardHolderName;
  //     cvvCode = creditCardModel.cvvCode;
  //     isCvvFocused = creditCardModel.isCvvFocused;
  //   });
  // }

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

  // TokenData? tokenData;
  // CardFieldInputDetails? _card;
  CardFormEditController? cardFormEditController;
  @override
  Widget build(BuildContext context) {
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardFormField(
                controller: cardFormEditController,
                onCardChanged: (value) {
                  print(value);
                },
              ),
              // CardField(
              //   enablePostalCode: true,
              //   onCardChanged: (card) {
              //     print(card);
              //     _card=card;
              //   },
              // ),
              TextButton(
                onPressed: () async {
                  // create payment method
                  final paymentMethod = await Stripe.instance
                      .createPaymentMethod(
                          params: PaymentMethodParams.card(
                              paymentMethodData: PaymentMethodData(
                                  billingDetails: BillingDetails(
                                    name: "rahul",
                                    address: Address(
                                        city: "rajkot",
                                        postalCode: "360022",
                                        line2: "mavdi",
                                        line1: "rk empire",
                                        country: "India",
                                        state: "Gujrat"),
                                  ),
                                  shippingDetails: ShippingDetails(
                                      address: Address(
                                          state: "gujrat",
                                          country: "India",
                                          line1: "gsrtc bus post",
                                          line2: "shop 2",
                                          postalCode: "362200",
                                          city: "rajkot"),
                                      name: "shop",
                                      carrier: "demno",
                                      phone: "1586978952",
                                      trackingNumber: "55215"))));
                  if (paymentMethod.id.isNotEmpty) {
                    print(paymentMethod.id);
                  }
                  // .createPaymentMethod(PaymentMethodParams.card(
                  //     paymentMethodData: PaymentMethodData(
                  //         billingDetails: BillingDetails(
                  //             name: "rahul",
                  //             address: Address(
                  //                 city: "rajkot",
                  //                 postalCode: "360022",
                  //                 line2: "mavdi",
                  //                 line1: "rk empire",
                  //                 country: "India",
                  //                 state: "Gujrat")),
                  //         shippingDetails: ShippingDetails(
                  //             address: Address(
                  //                 state: "gujrat",
                  //                 country: "India",
                  //                 line1: "gsrtc bus post",
                  //                 line2: "shop 2",
                  //                 postalCode: "362200",
                  //                 city: "rajkot"),
                  //             name: "shop",
                  //             carrier: "demno",
                  //             phone: "1586978952",
                  //             trackingNumber: "55215"))));
                },
                child: Text('pay'),
              )
              // CardField(
              //   autofocus: false,
              //   onCardChanged: (card) {
              //     setState(() {
              //       _card = card;
              //     });
              //   },
              // ),
              // ElevatedButton(
              //   onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
              //   child: Text(
              //     "Continue",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //       primary: Theme.of(context).primaryColor,
              //       minimumSize: Size(MediaQuery.of(context).size.width, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              // ),
            ],
          ),
        ),
      ),
      // body: ModalProgressHUD(
      //   inAsyncCall: showSpinner,
      //   child: Container(
      //     color: Colors.white,
      //     child: ListView(
      //       scrollDirection: Axis.vertical,
      //       controller: _controller,
      //       children: <Widget>[
      //         // CreditCardWidget(
      //         //   cardNumber: cardNumber,
      //         //   expiryDate: expiryDate,
      //         //   cardHolderName: cardHolderName,
      //         //   cvvCode: cvvCode,
      //         //   showBackView: isCvvFocused,
      //         // ),
      //         // SingleChildScrollView(
      //         //   child: CreditCardForm(
      //         //     formKey: formKey,
      //         //     onCreditCardModelChange: onCreditCardModelChange,
      //         //
      //         //     cardHolderName: cardHolderName,
      //         //     cardNumber: cardNumber,
      //         //     cvvCode: cvvCode,
      //         //     expiryDate: expiryDate,
      //         //     themeColor: Theme.of(context).primaryColor,
      //         //   ),
      //         // ),
      //         // SizedBox(height: MediaQuery.of(context).size.height * 0.06),
      //         CardField(
      //           autofocus: false,
      //           onCardChanged: (card) {
      //             setState(() {_card = card;
      //               print(card);
      //             });
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      // click to next
      // bottomNavigationBar: Container(
      //   color: Theme.of(context).primaryColor,
      //   child: TextButton(
      //     onPressed: () async{
      //         setState(() {
      //           showSpinner = true;
      //         });
      //         var expMonth = expiryDate.split('/')[0];
      //         var expYear = expiryDate.split('/')[1];
      //         int finalExpMonth = int.parse(expMonth.toString());
      //         int finalExpYear = int.parse(expYear.toString());
      //
      //         final tokenDataResponse=await Stripe.instance.createToken(CreateTokenParams.card(params: CardTokenParams(type: TokenType.Card)));
      //         this.tokenData = tokenDataResponse;
      //         callBookingApi(this.tokenData!.id);
      //         setState(() {
      //           showSpinner = false;
      //         });
      //         // StripePayment.createTokenWithCard(
      //         //   CreditCard(
      //         //     number: '$cardNumber',
      //         //     expMonth: finalExpMonth,
      //         //     expYear: finalExpYear,
      //         //     cvc: '$cvvCode',
      //         //     name: '$cardHolderName',
      //         //     currency:
      //         //         SharedPreferenceHelper.getString(Constants.currencyCode),
      //         //   ),
      //         // ).then((token) async {
      //         //
      //         //   try {
      //         //     stripeToken = token.tokenId;
      //         //     var totalDiscountINT;
      //         //     if (totalDiscount != 'null') {
      //         //       var a = double.parse(totalDiscount);
      //         //       totalDiscountINT = a.toInt();
      //         //     } else {
      //         //       totalDiscountINT = 0;
      //         //     }
      //         //     var b = double.parse(totalPayableAmount.toString());
      //         //     var totalPayableINT = b.toInt();
      //         //     var passAddress = '';
      //         //     setState(() {
      //         //       addressShop == true
      //         //           ? addressView = false
      //         //           : addressView = true;
      //         //     });
      //         //     if (addressView == false) {
      //         //       passAddress = 'SHOP';
      //         //       serviceType = 'SHOP';
      //         //     } else {
      //         //       serviceType = 'HOME';
      //         //       passAddress = addressHomeText.toString();
      //         //     }
      //         //     SharedPreferences localStorage =
      //         //         await SharedPreferences.getInstance();
      //         //     int addvaluelength = localStorage.getInt('addValueLength')!;
      //         //     List<String> lsModelserviceid = [];
      //         //     List<int> lsModelserviceidConverted = [];
      //         //     lsModelserviceid =
      //         //         (localStorage.getStringList('modelServiceId') ??
      //         //             <String>[]);
      //         //     var convertmodelserviceid;
      //         //     for (int a = 0; a < addvaluelength; a++) {
      //         //       convertmodelserviceid = int.parse(lsModelserviceid[a]);
      //         //       lsModelserviceidConverted.add(convertmodelserviceid);
      //         //     }
      //         //     serviceIdList.clear();
      //         //     for (int i = 0; i < addvaluelength; i++) {
      //         //       serviceIdList.add(lsModelserviceidConverted[i]);
      //         //     }
      //         //     Map<String, dynamic> body;
      //         //     addressView == true
      //         //         ? body = {
      //         //             'service_id': serviceIdList,
      //         //             'coworker_id': coworkerId,
      //         //             'start_time': timeSlot,
      //         //             'discount': totalDiscountINT,
      //         //             'coupen_id': offerId,
      //         //             'date': date,
      //         //             'payment_type': paymentType,
      //         //             'payment_token': stripeToken,
      //         //             'amount': totalPayableINT,
      //         //             'payment_status': '1',
      //         //             'service_type': serviceType,
      //         //             'lat': lat.toString(),
      //         //             'lang': long.toString(),
      //         //             'address': passAddress,
      //         //           }
      //         //         : body = {
      //         //             'service_id': serviceIdList,
      //         //             'coworker_id': coworkerId,
      //         //             'start_time': timeSlot,
      //         //             'discount': totalDiscountINT,
      //         //             'coupen_id': offerId,
      //         //             'date': date,
      //         //             'payment_type': paymentType,
      //         //             'payment_token': stripeToken,
      //         //             'amount': totalPayableINT,
      //         //             'payment_status': '1',
      //         //             'service_type': serviceType,
      //         //           };
      //         //     print(body);
      //         //     bookingAppointment(body);
      //         //   } catch (e) {
      //         //     showDialog(
      //         //       builder: (context) => AlertDialog(
      //         //         title: Text('Error'),
      //         //         content: Text(e.toString()),
      //         //         actions: <Widget>[
      //         //           TextButton(
      //         //             onPressed: () {
      //         //               Navigator.pop(context);
      //         //             },
      //         //             child: Text('Try Again'),
      //         //           )
      //         //         ],
      //         //       ),
      //         //       context: context,
      //         //     );
      //         //   }
      //         // }).catchError(setError);
      //         // print(setError);
      //         // setState(() {
      //         //   showSpinner = false;
      //         // });
      //       },
      //     style: ElevatedButton.styleFrom(
      //       primary: Theme.of(context).primaryColor,
      //     ),
      //     child: Text(
      //       'Continue',
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 18,
      //         fontFamily: 'FivoSansMedium',
      //       ),
      //     ),
      //   ),
      // ),
      // bottomNavigationBar: ElevatedButton(
      //   // onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
      //   onPressed: ()async{
      //     try
      //     {
      //       final tokenData = await Stripe.instance.createToken(CreateTokenParams.card(params: CardTokenParams(type: TokenType.Card)));
      //       print(tokenData.id);
      //     }
      //     catch(error)
      //     {
      //       print(error);
      //     }
      //   },
      //   child: Text(
      //     "Payment Data",
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   style: ElevatedButton.styleFrom(
      //       primary: Theme.of(context).primaryColor,
      //       minimumSize: Size(MediaQuery.of(context).size.width, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      // ),
    );
  }

  // Future<void> _handleCreateTokenPress() async {
  //   if (_card == null) {
  //     return;
  //   }
  //
  //   try {
  //     setState(() {
  //       showSpinner = true;
  //     });
  //     final tokenData = await Stripe.instance.createToken(CreateTokenParams.card(params: CardTokenParams(type: TokenType.Card,name: "Rahul",address: Address(city: "rajkot",country: "india",line1: "mavdi",line2: "rk empire",postalCode: "360022",state:"Gujarat"),currency: "IND"),));
  //     setState(() {
  //       showSpinner  = false;
  //       this.tokenData = tokenData;
  //       // CallApi(tokenData.id);
  //       if(tokenData.id.isNotEmpty)
  //         {
  //           callBookingApi(tokenData.id);
  //         }
  //     });
  //     print("Strip response Key:" + tokenData.id);
  //     return;
  //   } catch (e) {
  //     setState(() {
  //       showSpinner  = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  //     rethrow;
  //   }
  // }
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
}
