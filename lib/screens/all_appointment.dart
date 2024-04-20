import 'dart:convert';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/cancel_appointment.dart';
import 'package:citgroupvn_carwash/models/complete_appointment.dart';
import 'package:citgroupvn_carwash/models/pending_appointment.dart';
import 'package:citgroupvn_carwash/screens/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'appointment.dart';
import '../models/all_appointment.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class AllAppointment extends StatefulWidget {
  final String allAppointment = '/AllAppointment';

  @override
  _AllAppointmentState createState() => _AllAppointmentState();
}

class _AllAppointmentState extends State<AllAppointment>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  List<AllAppointmentData> aad = <AllAppointmentData>[];
  List<AllAppointmentDataCoworker> aadc = <AllAppointmentDataCoworker>[];
  List<AllAppointmentDataService> aads = <AllAppointmentDataService>[];

  List<PendingAppointment> pa = <PendingAppointment>[];
  List<PendingAppointmentCoworker> pac = <PendingAppointmentCoworker>[];
  List<PendingAppointmentService> pas = <PendingAppointmentService>[];

  List<CompleteAppointment> ca = <CompleteAppointment>[];
  List<CompleteAppointmentCoworker> cac = <CompleteAppointmentCoworker>[];
  List<CompleteAppointmentService> cas = <CompleteAppointmentService>[];

  List<CancelAppointment> cca = <CancelAppointment>[];
  List<CancelAppointmentCoworker> ccac = <CancelAppointmentCoworker>[];
  List<CancelAppointmentService> ccas = <CancelAppointmentService>[];

  var showSpinner = false;

  var showPendingAppointment;
  var showCompleteAppointment;
  var showCancelAppointment;
  var countPending = 0;
  var countCompete = 0;
  var countCancel = 0;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _tabController = TabController(length: 4, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    getAllAppointmentData();
    getPendingAppointmentData();
    getCompleteAppointmentData();
    getCancelAppointmentData();
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

  checkInternetConnection() {
    check().then((internet) async {
      if (internet && internet) {
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
                        builder: (context) => AllAppointment(),
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

  void _handleTabSelection() {
    setState(() {});
  }

  Future<void> getAllAppointmentData() async {
    aad.clear();
    aadc.clear();
    aads.clear();
    setState(() {
      showSpinner = true;
    });
    var res = await CallApi().getWithToken('appointment');
    var body;
    setState(() {
      showSpinner = false;
    });
    if (res.body.isNotEmpty) {
      body = json.decode(res.body);
    } else {
      setState(() {
        showSpinner = false;
      });
      showDialog(
          builder: (context) => AlertDialog(
                title: Text('something went wrong'),
                content: Text('Please reload the page'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllAppointment(),
                          ));
                    },
                    child: Text('Login'),
                  )
                ],
              ),
          context: context);
    }
    var theData = body['data'];
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      aad.add(AllAppointmentData.fromJson(map));
    }
    for (int j = 0; j < theData.length; j++) {
      Map<String, dynamic> map = theData[j]['coworker'];
      aadc.add(AllAppointmentDataCoworker.fromJson(map));
    }
    for (int k = 0; k < theData.length; k++) {
      var service = theData[k]['service'];
      for (int l = 0; l < service.length; l++) {
        Map<String, dynamic> map = service[l];
        aads.add(AllAppointmentDataService.fromJson(map));
      }
    }
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> getPendingAppointmentData() async {
    var res = await CallApi().getWithToken('appointment');
    var body;
    if (res.body.isNotEmpty) {
      body = json.decode(res.body);
    } else {
      showDialog(
          builder: (context) => AlertDialog(
                title: Text('something went wrong'),
                content: Text('Please reload the page'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllAppointment(),
                          ));
                    },
                    child: Text('Login'),
                  )
                ],
              ),
          context: context);
    }
    pa.clear();
    pac.clear();
    pas.clear();
    var theData = body['data'];
    for (int i = 0; i < theData.length; i++) {
      showPendingAppointment = theData[i]['appointment_status'];
      if (showPendingAppointment == 'PENDING') {
        for (int j = 0; j <= countPending; j++) {
          Map<String, dynamic> map = theData[i];
          pa.add(PendingAppointment.fromJson(map));
        }
        for (int k = 0; k <= countPending; k++) {
          Map<String, dynamic> map = theData[i]['coworker'];
          pac.add(PendingAppointmentCoworker.fromJson(map));
        }
        for (int l = 0; l <= countPending; l++) {
          var service = theData[l]['service'];
          for (int m = 0; m < service.length; m++) {
            Map<String, dynamic> map = service[m];
            pas.add(PendingAppointmentService.fromJson(map));
          }
        }
      }
    }
  }

  Future<void> getCompleteAppointmentData() async {
    var res = await CallApi().getWithToken('appointment');
    var body;
    if (res.body.isNotEmpty) {
      body = json.decode(res.body);
    } else {
      showDialog(
          builder: (context) => AlertDialog(
                title: Text('something went wrong'),
                content: Text('Please reload the page'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllAppointment(),
                          ));
                    },
                    child: Text('Login'),
                  )
                ],
              ),
          context: context);
    }
    ca.clear();
    cac.clear();
    cas.clear();
    var theData = body['data'];
    for (int i = 0; i < theData.length; i++) {
      showCompleteAppointment = theData[i]['appointment_status'];
      if (showCompleteAppointment == 'COMPLETE') {
        for (int j = 0; j <= countCompete; j++) {
          Map<String, dynamic> map = theData[i];
          ca.add(CompleteAppointment.fromJson(map));
        }
        for (int k = 0; k <= countCompete; k++) {
          Map<String, dynamic> map = theData[i]['coworker'];
          cac.add(CompleteAppointmentCoworker.fromJson(map));
        }
        for (int l = 0; l <= countCompete; l++) {
          var service = theData[l]['service'];
          for (int m = 0; m < service.length; m++) {
            Map<String, dynamic> map = service[m];
            cas.add(CompleteAppointmentService.fromJson(map));
          }
        }
      }
    }
  }

  Future<void> getCancelAppointmentData() async {
    var res = await CallApi().getWithToken('appointment');
    var body;
    if (res.body.isNotEmpty) {
      body = json.decode(res.body);
    } else {
      showDialog(
          builder: (context) => AlertDialog(
                title: Text('something went wrong'),
                content: Text('Please reload the page'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllAppointment(),
                          ));
                    },
                    child: Text('Login'),
                  )
                ],
              ),
          context: context);
    }
    var theData = body['data'];
    cca.clear();
    ccac.clear();
    ccas.clear();
    for (int i = 0; i < theData.length; i++) {
      showCancelAppointment = theData[i]['appointment_status'];
      if (showCancelAppointment == 'CANCEL') {
        for (int j = 0; j <= countCancel; j++) {
          Map<String, dynamic> map = theData[i];
          cca.add(CancelAppointment.fromJson(map));
        }
        for (int k = 0; k <= countCancel; k++) {
          Map<String, dynamic> map = theData[i]['coworker'];
          ccac.add(CancelAppointmentCoworker.fromJson(map));
        }
        for (int l = 0; l <= countCancel; l++) {
          var service = theData[l]['service'];
          for (int m = 0; m < service.length; m++) {
            Map<String, dynamic> map = service[m];
            ccas.add(CancelAppointmentService.fromJson(map));
          }
        }
      }
    }
  }

  Future<void> _getData() async {
    getAllAppointmentData();
    getPendingAppointmentData();
    getCompleteAppointmentData();
    getCancelAppointmentData();
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
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CustomDrawer(),
        //           ));
        //     },
        //   ),
        // ],
        bottom: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Color(0xFF91B4D8),
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 13,
            fontFamily: 'FivoSansMedium',
          ),
          unselectedLabelStyle: TextStyle(
            color: Color(0xFF91B4D8),
            fontSize: 13,
            fontFamily: 'FivoSansMedium',
          ),
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(
              text: 'All',
            ),
            Tab(
              text: 'Pending',
            ),
            Tab(
              text: 'Complete',
            ),
            Tab(
              text: 'Cancel',
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: TabBarView(
          children: [
            Container(
              child: aad.length == 0
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
                  : RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: _getData,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: aad.length,
                        itemBuilder: (context, index) {
                          AllAppointmentDataCoworker
                              allappointmentdataCoworker = aadc[index];
                          AllAppointmentData allappointmentdata = aad[index];
                          AllAppointmentDataService allappointmentdataService =
                              aads[index];
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Appointment(
                                        appoinmentId: allappointmentdata.id,
                                      ),
                                    ));
                              },
                              contentPadding: EdgeInsets.all(10.0),
                              leading: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0,
                                        )
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    child: Image(
                                      image: NetworkImage(
                                        allappointmentdataCoworker.image!,
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      allappointmentdataCoworker.name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
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
                                        '${allappointmentdata.amount /*.toStringAsFixed(0)*/}',
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 16,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 7.0),
                                  Text(
                                    '${allappointmentdata.date} - ${allappointmentdata.time}',
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  ),
                                  Text(
                                    'service : ${allappointmentdataService.serviceName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Container(
              child: pa.length == 0
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
                  : RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: _getData,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: pa.length,
                        itemBuilder: (context, index) {
                          PendingAppointment pendingappointmentdata = pa[index];
                          PendingAppointmentCoworker
                              pendingappointmentdataCoworker = pac[index];
                          PendingAppointmentService
                              pendingappointmentdataService = pas[index];
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Appointment(
                                        appoinmentId: pendingappointmentdata.id,
                                      ),
                                    ));
                              },
                              contentPadding: EdgeInsets.all(10.0),
                              leading: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0,
                                        )
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    child: Image(
                                      image: NetworkImage(
                                        pendingappointmentdataCoworker.image!,
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      pendingappointmentdataCoworker.name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
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
                                        '${pendingappointmentdata.amount /*.toStringAsFixed(0)*/}',
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 16,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 7.0),
                                  Text(
                                    '${pendingappointmentdata.date} - ${pendingappointmentdata.time}',
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  ),
                                  Text(
                                    'service : ${pendingappointmentdataService.serviceName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Container(
              child: ca.length == 0
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
                  : RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: _getData,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: ca.length,
                        itemBuilder: (context, index) {
                          CompleteAppointment completeappointmentdata =
                              ca[index];
                          CompleteAppointmentCoworker
                              completeappointmentdataCoworker = cac[index];
                          CompleteAppointmentService
                              completeappointmentdataService = cas[index];
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Appointment(
                                        appoinmentId:
                                            completeappointmentdata.id,
                                      ),
                                    ));
                              },
                              contentPadding: EdgeInsets.all(10.0),
                              leading: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0,
                                        )
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    child: Image(
                                      image: NetworkImage(
                                        completeappointmentdataCoworker.image!,
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      completeappointmentdataCoworker.name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
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
                                        '${completeappointmentdata.amount /*.toStringAsFixed(0)*/}',
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 16,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 7.0),
                                  Text(
                                    '${completeappointmentdata.date} - ${completeappointmentdata.time}',
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  ),
                                  Text(
                                    'service : ${completeappointmentdataService.serviceName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Container(
              child: cca.length == 0
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
                  : RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: _getData,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: cca.length,
                        itemBuilder: (context, index) {
                          CancelAppointment cancelappointmentdata = cca[index];
                          CancelAppointmentCoworker
                              cancelappointmentdataCoworker = ccac[index];
                          CancelAppointmentService
                              cancelappointmentdataService = ccas[index];
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Appointment(
                                        appoinmentId: cancelappointmentdata.id,
                                      ),
                                    ));
                              },
                              contentPadding: EdgeInsets.all(10.0),
                              leading: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0,
                                        )
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    child: Image(
                                      image: NetworkImage(
                                        cancelappointmentdataCoworker.image!,
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      cancelappointmentdataCoworker.name!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
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
                                        '${cancelappointmentdata.amount /*.toStringAsFixed(0)*/}',
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 16,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 7.0),
                                  Text(
                                    '${cancelappointmentdata.date} - ${cancelappointmentdata.time}',
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  ),
                                  Text(
                                    'service : ${cancelappointmentdataService.serviceName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansRegular',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}
