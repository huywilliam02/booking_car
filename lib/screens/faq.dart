import 'dart:convert';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/faq.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  List<Faq> f = <Faq>[];
  var showSpinner = false;

  @override
  void initState() {
    _getData();
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

  Future<void> _getData() async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('faq');
        var body = json.decode(res.body);
        var theData = body['data'];
        for (int i = 0; i < theData.length; i++) {
          Map<String, dynamic> map = theData[i];
          f.add(Faq.fromJson(map));
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
                        builder: (context) => FAQ(),
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
          'FAQ',
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
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 10.0,
            ),
            itemCount: f.length,
            itemBuilder: (context, index) {
              Faq faq = f[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "${index + 1}. " + faq.question,
                  style: TextStyle(
                    color: darkBlue,
                    fontFamily: 'FivoSansMedium',
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    faq.answer,
                    style: TextStyle(
                      color: extraDarkBlue,
                      fontFamily: 'FivoSansRegular',
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
