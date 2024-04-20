import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:citgroupvn_carwash/api/api.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  String? _details = "";
  var showSpinner = false;

  @override
  void initState() {
    getPrivacyPolicyDetails();
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

  Future<void> getPrivacyPolicyDetails() async {
    check().then((internet) async {
      if (internet) {
        // Internet Present Case
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('privacy_policy');
        var body = json.decode(res.body);
        var theData = body['data'];
        setState(() {
          showSpinner = false;
          _details = theData;
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
                        builder: (context) => PrivacyPolicy(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: darkBlue,
          icon: Icon(
            Icons.chevron_left,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     color: darkBlue,
        //     icon: Icon(FontAwesomeIcons.bars, size: 22),
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CustomDrawer(),
        //           ));
        //     },
        //   )
        // ],
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: darkBlue,
            fontSize: 18.0,
            fontFamily: 'FivoSansMedium',
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Html(
                data: _details,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
