import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

const darkBlue = Color(0xFF265E9E);

class WebviewScreen extends StatefulWidget {
  final url;

  const WebviewScreen({Key? key, this.url}) : super(key: key);
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: WebView(
            navigationDelegate: (NavigationRequest request) {
              final uri = Uri.parse(request.url);
              final payerId = uri.queryParameters['transaction_id'];
              final status = uri.queryParameters['status'];
              if (status == 'successful') {
                if (payerId != null) {
                  Timer(Duration(seconds: 4), () async {
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
                        content: Flexible(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                    'assets/images/payment_success.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Booking Confirmed',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 25,
                                    fontFamily: 'PoppinsMedium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                            },
                            style: TextButton.styleFrom(
                                alignment: Alignment.center),
                            child: Text(
                              'Thank You',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          )
                        ],
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/HomePage', (route) => false);
                  });
                }
              }
              return NavigationDecision.navigate;
            },
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
