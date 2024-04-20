import 'dart:convert';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/view_appoitment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'constants.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);
const ratingStar = Color(0xFFFECD03);

class Appointment extends StatefulWidget {
  final appoinmentId;

  Appointment({Key? key, this.appoinmentId}) : super(key: key);

  @override
  _AppointmentState createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  late var showSpinner;
  var previousAppointmentId;
  String? image = '';
  String? employeeName = '';
  String? employeeSkill = '';
  String? appointmentDate = '';
  String? appointmentId = '';
  String? appointmentTime = '';
  var selectedServiceName;
  var selectedServiceAmount;
  var selectedServiceDescription;
  var totalCharge = 0;
  String? totalDiscount = '';
  String? totalPay = '';
  String? totalDuration = '';
  String? paymentDoneBy = '';
  num rate = 0.0;
  bool isRate = false;
  String comment = "";
  var sendData;
  var visible = 0;
  var cancel = 0;

  List<ViewAppointmentService> vas = <ViewAppointmentService>[];

  @override
  void initState() {
    previousAppointmentId = widget.appoinmentId;
    getAppointmentData();
    super.initState();
  }

  Future<void> getAppointmentData() async {
    setState(() {
      showSpinner = true;
    });
    var res =
        await CallApi().getWithToken('show_appointment/$previousAppointmentId');
    var body = json.decode(res.body);
    var theData = body['data'];
    var coworker = theData['coworker'];
    appointmentId = theData['appointment_id'];
    image = coworker['completeImage'];
    employeeName = coworker['name'];
    var expertskill = coworker['service'][0];
    employeeSkill = expertskill['service_name'];
    appointmentDate = theData['date'];
    appointmentTime = theData['start_time'];
    if (theData['discount'] != null) {
      totalDiscount = theData['discount'];
    } else {
      totalDiscount = "0";
    }
    totalDuration = theData['duration'];
    totalPay = theData['amount'];
    totalCharge = int.parse(totalDiscount!) + int.parse(totalPay!);
    paymentDoneBy = theData['payment_type'];
    rate = coworker['rate'];
    isRate = theData['isReview'];
    if (isRate) {
      comment = theData['review']["comment"];
    }
    var showStatus = theData['appointment_status'];
    if (showStatus == 'COMPLETE' || showStatus == 'CANCEL') {
      visible = 1;
    }
    if (showStatus == 'PENDING') {
      cancel = 1;
    }
    for (int i = 0; i < theData['service'].length; i++) {
      Map<String, dynamic> map = theData['service'][i];
      vas.add(ViewAppointmentService.fromJson(map));
    }
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> addReview(data) async {
    setState(() {
      showSpinner = true;
    });
    var res = await CallApi().postDataWithToken(data, 'add_review');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Review'),
          content: Text(body['data'].toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, '/AppointmentReview');
              },
              child: Text('Thank you'),
            )
          ],
        ),
        context: context,
      );
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Review Error'),
          content: Text(body['data'].toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, '/AppointmentReview');
              },
              child: Text('Okay'),
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

  Future<void> cancelAppointment(data) async {
    setState(() {
      showSpinner = true;
    });
    var res = await CallApi().postDataWithToken(data, 'cancel_appointment');
    var body = json.decode(res.body);
    if (body["success"] == true) {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Appointment has been Cancelled successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, '/AllAppointment');
              },
              child: Text('Thank you'),
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
          'Appointment',
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
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CustomDrawer(),
        //         ),
        //       );
        //     },
        //   )
        // ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: ListView(
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
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: image!.isNotEmpty
                              ? Image(
                                  image: NetworkImage(image!),
                                  height: 74.0,
                                  width: 74.0,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  'assets/images/no_image.png',
                                  height: 74.0,
                                  width: 74.0,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  employeeName!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 18,
                                      fontFamily: 'FivoSansMedium'),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '$employeeSkill Specialist',
                                style: TextStyle(
                                  color: extraDarkBlue,
                                  fontSize: 14,
                                  fontFamily: 'FivoSansMedium',
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                'AP No : $appointmentId',
                                style: TextStyle(
                                  color: extraDarkBlue,
                                  fontSize: 14,
                                  fontFamily: 'FivoSansMedium',
                                ),
                              ),
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
                          '$appointmentDate - $appointmentTime',
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
                          itemCount: vas.length,
                          itemBuilder: (context, index) {
                            ViewAppointmentService viewappointmentservice =
                                vas[index];
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
                                          viewappointmentservice.serviceName,
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
                                            '${viewappointmentservice.servicePrice}',
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
                                              'Duration : ${viewappointmentservice.serviceDuration} Min',
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
                                          viewappointmentservice
                                              .serviceDiscription,
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
                                    totalCharge.toString(),
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
                              Text(
                                SharedPreferenceHelper.getString(
                                        Constants.currencySymbol) +
                                    totalDiscount!,
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
                            height: 10.0,
                            color: extraDarkBlue.withOpacity(0.7),
                          ),
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
                              Text(
                                SharedPreferenceHelper.getString(
                                        Constants.currencySymbol) +
                                    totalPay!,
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 14.0,
                                  fontFamily: 'FivoSansMedium',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Duration : $totalDuration Min',
                            style: TextStyle(
                              color: extraDarkBlue,
                              fontSize: 14.0,
                              fontFamily: 'FivoSansOblique',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xFFE9F0F7),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'You have save ${SharedPreferenceHelper.getString(Constants.currencySymbol)} + $totalDiscount on this appointment',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontFamily: 'FivoSansMediumOblique',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: TextStyle(
                              color: darkBlue,
                              fontFamily: 'FivoSansMedium',
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            'Payment successful by $paymentDoneBy.',
                            style: TextStyle(
                              color: extraDarkBlue,
                              fontFamily: 'FivoSansMedium',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Divider(
                            height: 5.0,
                            color: extraDarkBlue.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Visibility(
                      visible: visible == 1,
                      child: isRate
                          ? Center(
                              child: RatingBar.builder(
                                glowColor: ratingStar,
                                ignoreGestures: true,
                                initialRating: rate.toDouble(),
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                // itemCount: specialists.rating!.toInt(),
                                itemCount: 5,
                                itemSize: 28,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: ratingStar,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                            )
                          : Center(
                              child: RatingBar.builder(
                                glowColor: ratingStar,
                                ignoreGestures: false,
                                initialRating: 0,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                // itemCount: specialists.rating!.toInt(),
                                itemCount: 5,
                                itemSize: 28,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: ratingStar,
                                ),
                                onRatingUpdate: (rating) {
                                  rate = rating;
                                },
                              ),
                            ),
                    ),
                    Visibility(
                        visible: visible == 1, child: SizedBox(height: 20.0)),
                    Visibility(
                        visible: visible == 1,
                        child: isRate
                            ? Center(
                                child: Text(
                                  comment,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: 'FivoSansMedium',
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Comment',
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: 'FivoSansMedium',
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 1.0,
                                            spreadRadius: 0.5,
                                          )
                                        ],
                                      ),
                                      child: TextField(
                                        style: TextStyle(
                                          color: extraDarkBlue,
                                          fontSize: 14,
                                          fontFamily: 'FivoSansOblique',
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Type Your Message Here',
                                          hintStyle: TextStyle(
                                            color: extraDarkBlue,
                                            fontSize: 14,
                                            fontFamily: 'FivoSansOblique',
                                          ),
                                        ),
                                        onChanged: (text) {
                                          comment = text;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight,
        child: Column(
          children: [
            Visibility(
              visible: cancel == 1,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      builder: (context) => AlertDialog(
                            title: Text('Cancel Appointment'),
                            content: Text(
                                'Are you sure you want to cancel your appointment?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    sendData = {
                                      "order_id": previousAppointmentId,
                                    };
                                    Navigator.pop(context);
                                    cancelAppointment(sendData);
                                  });
                                },
                                child: Text('Yes'),
                              )
                            ],
                          ),
                      context: context);
                },
                child: Container(
                  height: kBottomNavigationBarHeight,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    'CANCEL APPOINTMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FivoSansMedium',
                      fontSize: 18,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.9),
                ),
              ),
            ),
            Visibility(
              visible: visible == 1,
              child: comment == ""
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          if (rate != 0.0 && comment != "") {
                            sendData = {
                              "order_id": previousAppointmentId,
                              "rate": rate,
                              "comment": comment,
                            };
                            addReview(sendData);
                          } else {
                            print("Data $rate $comment");
                            showDialog(
                              builder: (context) => AlertDialog(
                                title: Text('Review Error'),
                                content: Text("Fill data & rate"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Okay'),
                                  )
                                ],
                              ),
                              context: context,
                            );
                          }
                        },
                        child: Container(
                          height: kBottomNavigationBarHeight,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Text(
                            'SEND',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'FivoSansMedium',
                              fontSize: 18,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}
