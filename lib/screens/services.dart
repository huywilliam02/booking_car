import 'dart:async';
import 'dart:convert';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/addvalueforservice.dart';
import 'package:citgroupvn_carwash/models/category_wise_service_coworker.dart';
import 'package:citgroupvn_carwash/models/coworkerM.dart';
import 'package:citgroupvn_carwash/models/home_category.dart';
import 'package:citgroupvn_carwash/screens/book_appointment.dart';
import 'package:citgroupvn_carwash/screens/employee_profile.dart';

import 'constants.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);
const ratingStar = Color(0xFFFECD03);
const containerBackground = Color(0xFFE9F0F7);

class Services extends StatefulWidget {
  final int? index;
  final int? categoryId;
  final int? selecetedSkill;
  final int? previuosSpeId;

  Services(
      {Key? key,
      this.index,
      this.categoryId,
      this.selecetedSkill,
      this.previuosSpeId})
      : super(key: key);

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  var passId;
  var showSnipper = false;
  var specialistName;
  var coworkerId;
  var categoryId;
  int? verified;
  int? verifiedCat;
  int? categoryCheck;
  var totalValue;
  var totalDuration;
  var passTheData;
  var previousSpeId;
  var previousCatId;
  var selectedCatId;
  var serviceId;
  var sendCoworkerData;
  var selectCoworkerData;
  var dataFound = false;
  var dataNotFound = true;
  var servicelength;
  var forValueInsert;

  Map<int, dynamic>? checkbox;

  List<bool> checkboxBool = [];
  List<bool> selected = <bool>[];
  List<CoworkerModel> cw = <CoworkerModel>[];
  CoworkerModel cwc = CoworkerModel();

  List<Categories> ct = <Categories>[];
  Categories c = Categories();

  List<CategoryWiseServiceCoworker> cws = <CategoryWiseServiceCoworker>[];

  List<AddValues> av = <AddValues>[];

  @override
  void initState() {
    coworkerId = widget.previuosSpeId;
    previousCatId = widget.categoryId;
    selectedCatId = previousCatId;
    passTheData = {
      "coworker_id": '$coworkerId',
      "category_id": '$previousCatId'
    };
    print(passTheData);
    servicelength = widget.selecetedSkill;
    setState(() {
      if (0 < servicelength) {
        dataFound = true;
        for (int a = 0; a < servicelength; a++) {
          checkboxBool.add(false);
        }
      }
    });
    verified = 0;
    verifiedCat = widget.index;
    selected = [false];
    specialistName = 'Select Specialist';
    totalValue = 00;
    totalDuration = 00;
    categoryId = 1;
    _getDataSpecialist();
    _getDataCategory();
    _getDataServices(passTheData);
    super.initState();
  }

  Future<void> _getDataSpecialist() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().getWithToken('all_coworker');
    var body = json.decode(res.body);
    var success = body['success'];
    if (success == true) {
      setState(() {
        showSnipper = false;
      });
    } else {
      setState(() {
        showSnipper = false;
        showDialog(
            builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Reload'),
                    )
                  ],
                ),
            context: context);
      });
    }
    var theData = body['data'];
    cw = [];
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      cw.add(CoworkerModel.fromJson(map));
    }
    specialistName = cw[0].name;
    passId = cw[0].id;
  }

  Future<void> _getDataCategory() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().getWithToken('category');
    var body = json.decode(res.body);
    var success = body['success'];
    if (success == true) {
      setState(() {
        showSnipper = false;
      });
    } else {
      setState(() {
        showSnipper = false;
        showDialog(
            builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Reload'),
                    )
                  ],
                ),
            context: context);
      });
    }
    var theData = body['data'];
    ct = [];
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      ct.add(Categories.fromJson(map));
    }
  }

  Future<void> _getDataServices(passTheData) async {
    setState(() {
      showSnipper = true;
    });
    try {
      var res = await CallApi()
          .postData(passTheData, 'category_wise_service_coworker');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        var theData = body['data'];
        if (body['success'] == true) {
          cws = [];
          servicelength = theData.length;
          if (theData.length != 0) {
            dataFound = true;
            for (int i = 0; i < theData.length; i++) {
              Map<String, dynamic> map = theData[i];
              cws.add(CategoryWiseServiceCoworker.fromJson(map));
            }
          }
        }
        setState(() {
          showSnipper = false;
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
  }

  servicePrice(servicePriceIndex, servicePrice) {
    servicePriceIndex == true
        ? totalValue += servicePrice
        : totalValue -= servicePrice;
  }

  serviceDuration(serviceDurationIndex, serviceDuration) {
    serviceDurationIndex == true
        ? totalDuration += serviceDuration
        : totalDuration -= serviceDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: darkBlue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select Services',
          style: TextStyle(
            color: darkBlue,
            fontFamily: 'FivoSansMedium',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
        //     child: IconButton(
        //       onPressed: () {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => CustomDrawer(),
        //             ));
        //       },
        //       icon: Icon(
        //         FontAwesomeIcons.bars,
        //         size: 22,
        //         color: darkBlue,
        //       ),
        //     ),
        //   ),
        // ],
        elevation: 0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSnipper,
        child: SafeArea(
          right: false,
          left: false,
          child: Stack(
            children: [
              CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                'Our Specialist',
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'FivoSansMedium',
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              height: 130.0,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cw.length,
                                itemBuilder: (context, index) {
                                  CoworkerModel specialist = cw[index];
                                  return GestureDetector(
                                    onTap: () {
                                      verified = index;
                                      coworkerId = specialist.id;
                                      passTheData = {
                                        'coworker_id': '$coworkerId',
                                        'category_id': '$selectedCatId'
                                      };
                                      _getDataServices(passTheData);
                                      print(passTheData);
                                      checkboxBool.clear();
                                      av.clear();
                                      totalDuration = 0;
                                      totalValue = 0;
                                      specialistName = specialist.name;
                                      passId = specialist.id;
                                      selected = [false];
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 130.0,
                                          width: 74.0,
                                          margin: EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Column(
                                              children: [
                                                Image(
                                                  height: 74.0,
                                                  width: 74.0,
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(
                                                      specialist.image!),
                                                ),
                                                Text(
                                                  specialist.name!,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 1.0,
                                          child: Container(
                                            height: 20.0,
                                            width: 20.0,
                                            decoration: BoxDecoration(
                                              color: verified == index
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: verified == index
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              size: 18.0,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(8.0),
                              child: InkWell(
                                child: Text(
                                  specialistName,
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 18,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeProfile(
                                            specialistId: passId),
                                      ));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'FivoSansMedium',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8.0),
                          height: 130.0,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ct.length,
                            itemBuilder: (context, index) {
                              Categories categoryicons = ct[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    verifiedCat = index;
                                    passTheData = {
                                      'coworker_id': '$coworkerId',
                                      'category_id': '${categoryicons.id}'
                                    };
                                    _getDataServices(passTheData);
                                    print(passTheData);
                                    checkboxBool.clear();
                                    av.clear();
                                    totalDuration = 0;
                                    totalValue = 0;
                                  });
                                  setState(() {
                                    selectedCatId = categoryicons.id;
                                  });
                                  selected = [false];
                                },
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.all(8.0),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                11,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image(
                                                image: NetworkImage(
                                                    categoryicons.image!),
                                                fit: BoxFit.fill,
                                                height: 28,
                                                width: 27,
                                              ),
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            categoryicons.categoryName!,
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
                                    Positioned(
                                      top: 5.5,
                                      right: 2.5,
                                      child: Container(
                                        height: 17.0,
                                        width: 17.0,
                                        decoration: BoxDecoration(
                                          color: verifiedCat == index
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: verifiedCat == index
                                              ? Colors.white
                                              : Colors.transparent,
                                          size: 16.0,
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
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        child: cws.length == 0
                            ? Container(
                                height: 100.0,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: Text(
                                  'data not found',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 16,
                                    fontFamily: 'FivoSansMediumOblique',
                                  ),
                                )))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: cws.length,
                                itemBuilder: (context, index) {
                                  CategoryWiseServiceCoworker
                                      servicelistdetails = cws[index];
                                  for (int bool = 0;
                                      bool < cws.length;
                                      bool++) {
                                    checkboxBool.add(false);
                                  }
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        checkboxBool[index] =
                                            !checkboxBool[index];
                                        servicePrice(checkboxBool[index],
                                            servicelistdetails.price);
                                        serviceDuration(checkboxBool[index],
                                            servicelistdetails.duration);
                                        serviceId = servicelistdetails.id;
                                        if (checkboxBool[index] == true) {
                                          av.add(AddValues(
                                            modelServiceId: serviceId,
                                            modelCoworkerId: coworkerId,
                                            serviceName:
                                                servicelistdetails.serviceName,
                                            servicePrice:
                                                servicelistdetails.price,
                                            serviceDuration:
                                                servicelistdetails.duration,
                                            serviceRate:
                                                servicelistdetails.rate,
                                            serviceDescription:
                                                servicelistdetails.description,
                                          ));
                                        }
                                        if (checkboxBool[index] == false) {
                                          for (int check = 0;
                                              check < av.length;
                                              check++) {
                                            if (servicelistdetails.id ==
                                                av[check].modelServiceId) {
                                              av.removeAt(check);
                                            }
                                          }
                                        }
                                      });
                                    },
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              servicelistdetails.serviceName!,
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
                                                '${servicelistdetails.price}',
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: 'FivoSansMedium',
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Container(
                                            height: 25.0,
                                            width: 25.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                    Colors.transparent,
                                              ),
                                              child: Checkbox(
                                                checkColor: Theme.of(context)
                                                    .primaryColor,
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                value: checkboxBool[index],
                                                onChanged: (value) {
                                                  setState(() {
                                                    checkboxBool[index] =
                                                        !checkboxBool[index];
                                                    servicePrice(
                                                        checkboxBool[index],
                                                        servicelistdetails
                                                            .price);
                                                    serviceDuration(
                                                        checkboxBool[index],
                                                        servicelistdetails
                                                            .duration);
                                                    serviceId =
                                                        servicelistdetails.id;
                                                    if (checkboxBool[index] ==
                                                        true) {
                                                      av.add(AddValues(
                                                        modelServiceId:
                                                            serviceId,
                                                        modelCoworkerId:
                                                            coworkerId,
                                                        serviceName:
                                                            servicelistdetails
                                                                .serviceName,
                                                        servicePrice:
                                                            servicelistdetails
                                                                .price,
                                                        serviceDuration:
                                                            servicelistdetails
                                                                .duration,
                                                        serviceRate:
                                                            servicelistdetails
                                                                .rate,
                                                        serviceDescription:
                                                            servicelistdetails
                                                                .description,
                                                      ));
                                                    }
                                                    if (checkboxBool[index] ==
                                                        false) {
                                                      for (int check = 0;
                                                          check < av.length;
                                                          check++) {
                                                        if (servicelistdetails
                                                                .id ==
                                                            av[check]
                                                                .modelServiceId) {
                                                          av.removeAt(check);
                                                        }
                                                      }
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          )
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Duration : ${servicelistdetails.duration}',
                                                  style: TextStyle(
                                                    color: extraDarkBlue,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        'FivoSansMedium',
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: RatingBar.builder(
                                                    ignoreGestures: true,
                                                    initialRating: double.parse(
                                                        servicelistdetails.rate
                                                            .toString()),
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 15,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Icon(
                                                      Icons.star,
                                                      color: ratingStar,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              servicelistdetails.description!,
                                              style: TextStyle(
                                                color: extraDarkBlue,
                                                fontSize: 14,
                                                fontFamily: 'FivoSansMedium',
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Divider(
                                              color: extraDarkBlue,
                                              height: 10.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  }, childCount: 1)),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15),
                    ]),
                  ),
                ],
              ),
              Positioned(
                bottom: 0.01,
                child: Column(
                  children: [
                    Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 1.07,
                      decoration: BoxDecoration(
                        color: Color(0xFFE9F0F7),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Payable',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 16,
                                    fontFamily: 'FivoSansMediumOblique',
                                  ),
                                ),
                                Text(
                                  'Duration : $totalDuration Min',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14,
                                    fontFamily: 'FivoSansOblique',
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  SharedPreferenceHelper.getString(
                                          Constants.currencySymbol) +
                                      '$totalValue',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 14,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          if (av.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookAppointment(
                                    previousTotalValue: totalValue,
                                    previousTotalTime: totalDuration,
                                    previousSpecialistID: passId,
                                    addValues: av,
                                  ),
                                ));
                          } else {
                            showDialog(
                                builder: (context) => AlertDialog(
                                      title: Text('Error'),
                                      content:
                                          Text('Please select any service'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('ok'),
                                        )
                                      ],
                                    ),
                                context: context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero)),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontFamily: 'FivoSansMedium',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
