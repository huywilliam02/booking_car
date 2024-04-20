import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/notification.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  var showSpinner = false;
  List<NotificationsData> nd = <NotificationsData>[];
  List<NotificationUser> nu = <NotificationUser>[];
  List<NotificationOrder> no = <NotificationOrder>[];

  @override
  void initState() {
    getNotificationData();
    super.initState();
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

  Future<void> getNotificationData() async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('notification');
        var body = json.decode(res.body);
        var theData = body['data'];
        nd.clear();
        nu.clear();
        no.clear();
        for (int i = 0; i < theData.length; i++) {
          Map<String, dynamic> map = theData[i];
          nd.add(NotificationsData.fromJson(map));
        }

        for (int j = 0; j < theData.length; j++) {
          Map<String, dynamic> map = theData[j]['user'];
          nu.add(NotificationUser.fromJson(map));
        }

        for (int k = 0; k < theData.length; k++) {
          Map<String, dynamic> map = theData[k]['order'];
          no.add(NotificationOrder.fromJson(map));
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
                        builder: (context) => Notifications(),
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

  Future<void> _getData() async {
    getNotificationData();
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
          'Notification',
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
        //   )
        // ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: _getData,
            child: nd.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: nd.length,
                    itemBuilder: (context, index) {
                      NotificationsData notificationsData = nd[index];
                      NotificationUser notificationsUserData = nu[index];
                      NotificationOrder notificationsOrderData = no[index];
                      return Card(
                        margin: EdgeInsets.all(7.0),
                        child: ListTile(
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
                                      blurRadius: 0.5,
                                      spreadRadius: 0.5,
                                    )
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                                child: Image(
                                  image: NetworkImage(
                                    notificationsUserData.image!,
                                  ),
                                  fit: BoxFit.fill,
                                  height: 75,
                                  width: 75,
                                ),
                              )),
                          title: Text(
                            notificationsUserData.name!,
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 18,
                              fontFamily: 'FivoSansMedium',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 7.0),
                              Text(
                                '${notificationsOrderData.date} - ${notificationsOrderData.time}',
                                style: TextStyle(
                                  color: extraDarkBlue,
                                  fontSize: 14,
                                  fontFamily: 'FivoSansRegular',
                                ),
                              ),
                              Text(
                                '${notificationsData.message}',
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
                  )
                : Center(
                    child: Text(
                      "data not Found",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontFamily: 'FivoSansMediumOblique',
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
