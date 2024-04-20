import 'dart:convert';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/addvalueforservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'offer.dart';
import 'payment.dart';
import 'sign_in.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class AppointmentReview extends StatefulWidget {
  final previousDate;
  final previousTimeSlot;
  final List<AddValues>? addvalues;
  final previousSpecialistId;
  final previousTotalValue;
  final previousTotalTime;
  final previousDisplayDate;
  final selectedOfferId;
  final int? selectedOfferDiscount;
  final selectedOfferType;

  const AppointmentReview({
    Key? key,
    this.addvalues,
    this.previousDate,
    this.previousTimeSlot,
    this.previousSpecialistId,
    this.previousTotalValue,
    this.previousTotalTime,
    this.previousDisplayDate,
    this.selectedOfferType,
    this.selectedOfferDiscount,
    this.selectedOfferId,
  }) : super(key: key);

  @override
  _AppointmentReviewState createState() => _AppointmentReviewState();
}

class _AppointmentReviewState extends State<AppointmentReview> {
  bool _isLoggedIn = false;
  var showSpinner = false;
  var previousDate;
  var previousDisplayDate;
  var previousTimeSlot;
  var previousSpecialistId;
  var previousTotalValue;
  var discountType;
  var percentageCalculation;
  var discountSymbol;
  var coWorkerName;
  int? discountAmount;
  var totalDiscount;
  var totalPayableAmount;
  String? image = '';
  String? name = '';
  String? singleCoWorkerUserId = "";
  String? skillName = '';
  var offerId;
  var previousTotalTime;
  var discountVisible;
  var serviceId;
  var selectedOfferId;
  int? selectedOfferDiscount;
  var selectedOfferType;
  int? newTotalDiscount;
  int? newTotalPayableAmount = 0;
  var passTotolPayableAmount;
  List<String> passValue = [];
  List<AddValues>? addvalue;

  @override
  void initState() {
    previousTotalTime = widget.previousTotalTime;
    previousDate = widget.previousDate;
    previousDisplayDate = widget.previousDisplayDate;
    previousTimeSlot = widget.previousTimeSlot;
    addvalue = widget.addvalues;
    previousSpecialistId = widget.previousSpecialistId;
    previousTotalValue = widget.previousTotalValue;
    selectedOfferId = widget.selectedOfferId;
    selectedOfferDiscount = widget.selectedOfferDiscount;
    selectedOfferType = widget.selectedOfferType;

    _checkIfLoggedIn();
    if (selectedOfferId != null) {
      _calculation();
    }
    _getSpecialistInfo(previousSpecialistId);
    super.initState();
  }

  _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = localStorage.getString('user');
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  _calculation() {
    setState(() {
      showSpinner = true;
    });
    offerId = selectedOfferId;

    discountAmount = selectedOfferDiscount;
    discountType = selectedOfferType;

    discountType == 'amount' ? discountSymbol = '\$' : discountSymbol = '\%';
    percentageCalculation = (previousTotalValue * discountAmount / 100);
    discountType == 'amount'
        ? totalPayableAmount = (previousTotalValue - discountAmount)
        : totalPayableAmount = (previousTotalValue - percentageCalculation);
    discountType == 'amount'
        ? totalDiscount = discountAmount
        : totalDiscount = percentageCalculation;
    newTotalDiscount = totalDiscount.toInt();
    newTotalPayableAmount = totalPayableAmount.toInt();
    discountVisible = true;
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> _getSpecialistInfo(previousSpecialistId) async {
    print('previous id is $previousSpecialistId');
    setState(() {
      showSpinner = true;
    });
    var res =
        await CallApi().getWithToken('single_coworker/$previousSpecialistId');
    var body = json.decode(res.body);
    var theData = body['data'];
    image = theData['completeImage'];
    name = theData['name'];
    singleCoWorkerUserId = theData['user_id'].toString();
    coWorkerName = theData['name'].toString();
    setState(() {});
    var skill = theData['skills'];
    skillName = skill[0]['service_name'];
    setState(() {
      showSpinner = false;
    });
  }

  static Future<bool> putStringList(String key, List<String> value) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.setStringList(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 24,
            color: darkBlue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Appointment Review',
          style: TextStyle(
            color: darkBlue,
            fontSize: 18.0,
            fontFamily: 'FivoSansMedium',
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       FontAwesomeIcons.bars,
        //       size: 22,
        //       color: darkBlue,
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CustomDrawer(),
        //           ));
        //     },
        //   )
        // ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Stack(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            child: image!.isNotEmpty
                                ? Image.network(
                                    image!,
                                    fit: BoxFit.fill,
                                    height: 75,
                                    width: 75,
                                  )
                                : Image.asset(
                                    "assets/images/no_image.png",
                                    fit: BoxFit.fill,
                                    height: 75,
                                    width: 75,
                                  ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            alignment: Alignment.topLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 18,
                                      fontFamily: 'FivoSansMedium'),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  skillName!,
                                  style: TextStyle(
                                    color: extraDarkBlue,
                                    fontSize: 14,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Date & Time',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 18.0,
                              fontFamily: 'FivoSansMedium',
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            '$previousDisplayDate -- $previousTimeSlot',
                            style: TextStyle(
                              color: extraDarkBlue,
                              fontSize: 14.0,
                              fontFamily: 'FivoSansMedium',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Services',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 18,
                              fontFamily: 'FivoSansMedium',
                            ),
                          ),
                          SizedBox(height: 10.0),
                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            physics: ClampingScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10.0),
                            shrinkWrap: true,
                            itemCount: addvalue!.length,
                            itemBuilder: (context, index) {
                              AddValues addvalues = addvalue![index];
                              serviceId = addvalues.modelServiceId;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                    )
                                  ],
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).primaryColor,
                                          spreadRadius: -1.0,
                                          offset: Offset(-5, 0)),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            addvalues.serviceName!,
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontSize: 18,
                                              fontFamily: 'FivoSansMedium',
                                            ),
                                          ),
                                        ),
                                        Text(
                                          SharedPreferenceHelper.getString(
                                                  Constants.currencySymbol) +
                                              '${addvalues.servicePrice}',
                                          style: TextStyle(
                                            color: darkBlue,
                                            fontFamily: 'FivoSansMedium',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Duration : ${addvalues.serviceDuration} Min',
                                                style: TextStyle(
                                                  color: extraDarkBlue,
                                                  fontSize: 14,
                                                  fontFamily: 'FivoSansMedium',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            addvalues.serviceDescription!,
                                            style: TextStyle(
                                              color: extraDarkBlue,
                                              fontSize: 14,
                                              fontFamily: 'FivoSansMedium',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFFF4848), width: 1.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/discount.svg',
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Offers(
                                                  previousTotalValue:
                                                      previousTotalValue,
                                                  previousSpecialistId:
                                                      previousSpecialistId,
                                                  addvalues: addvalue,
                                                  previousTimeSlot:
                                                      previousTimeSlot,
                                                  previousDate: previousDate,
                                                  previousTotalTime:
                                                      previousTotalTime,
                                                  previousDisplayDate:
                                                      previousDisplayDate,
                                                ),
                                              ));
                                        },
                                        child: Text(
                                          'Apply Promocode',
                                          style: TextStyle(
                                            color: darkBlue,
                                            fontSize: 18.0,
                                            fontFamily: 'FivoSansMedium',
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                offerId != null
                                    ? Text(
                                        '$discountAmount$discountSymbol Discount',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      )
                                    : Text(
                                        'Select Discount',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Bill Detail',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18.0,
                                fontFamily: 'FivoSansMedium',
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Charge',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14.0,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                                Text(
                                  SharedPreferenceHelper.getString(
                                          Constants.currencySymbol) +
                                      '$previousTotalValue',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14.0,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Discount',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                                totalDiscount != null
                                    ? Text(
                                        SharedPreferenceHelper.getString(
                                                Constants.currencySymbol) +
                                            '${totalDiscount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      )
                                    : Text(
                                        'No discount',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Divider(
                              height: 15.0,
                              color: extraDarkBlue.withOpacity(0.7),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'To Pay',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14.0,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                                totalPayableAmount == null
                                    ? Text(
                                        SharedPreferenceHelper.getString(
                                                Constants.currencySymbol) +
                                            '${previousTotalValue.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 14.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      )
                                    : Text(
                                        SharedPreferenceHelper.getString(
                                                Constants.currencySymbol) +
                                            '$newTotalPayableAmount',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 14.0,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'Duration : $previousTotalTime Min',
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14.0,
                                fontFamily: 'FivoSansOblique',
                              ),
                            ),
                          ],
                        ),
                      ),
                      discountVisible == true
                          ? Container(
                              height: 50.0,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(top: 20.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFE9F0F7),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'You have save ${SharedPreferenceHelper.getString(Constants.currencySymbol)}  ${totalDiscount.toStringAsFixed(0)} on this appointment',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14,
                                    fontFamily: 'FivoSansMediumOblique',
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 1,
                              width: 1,
                            ),
                      SizedBox(height: MediaQuery.of(context).size.height / 16),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0.01,
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    totalPayableAmount == null
                        ? passTotolPayableAmount = previousTotalValue
                        : passTotolPayableAmount = totalPayableAmount;
                    SharedPreferences localStorage =
                        await SharedPreferences.getInstance();
                    List<String> putLsModelServiceId = [];
                    for (int i = 0; i < addvalue!.length; i++) {
                      putLsModelServiceId
                          .add(addvalue![i].modelServiceId.toString());
                    }
                    putStringList('modelServiceId', putLsModelServiceId);
                    localStorage.setInt('addValueLength', addvalue!.length);
                    localStorage.setStringList('addValue', passValue);
                    localStorage.setString('isFrom', 'BookAppointment');
                    localStorage.setString('totalPayableAmount',
                        passTotolPayableAmount.toString());
                    localStorage.setInt('serviceId', serviceId);
                    localStorage.setString(
                        'coworkerId', previousSpecialistId.toString());
                    localStorage.setString('timeSlot', previousTimeSlot);
                    localStorage.setString('date', previousDate);
                    localStorage.setString(
                        'totalDiscount', totalDiscount.toString());
                    localStorage.setString(
                        "coworkerIdUser", singleCoWorkerUserId.toString());
                    localStorage.setString(
                        "coWorkerName", coWorkerName.toString());
                    var user = localStorage.getString('user');
                    if (user != null) {
                      setState(() {
                        _isLoggedIn = true;
                      });
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              _isLoggedIn ? Payment() : SignIn(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  child: Text(
                    'book appointment'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: 'FivoSansMedium',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
