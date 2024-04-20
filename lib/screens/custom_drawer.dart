import 'dart:convert';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'all_appointment.dart';
import 'faq.dart';
import 'full_profile.dart';
import 'map/map.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';
import 'privacy_policy.dart';
import 'sign_in.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int? tappedIndex;
  String? _userName = '';
  String? _completeImage = '';
  var isLoggedIn = false;
  var isLoggedInAgain = false;
  var showSpinner = false;
  @override
  void initState() {
    _getUserInfo();
    _getLogAgain();
    tappedIndex = 0;
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

  Future<void> _getUserInfo() async {
    check().then((internet) async {
      if (internet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('edit_profile');
        var body = json.decode(res.body);
        var theData = body['data'];
        setState(() {
          showSpinner = false;
        });
        if (theData != null) {
          _userName = theData['name'];

          _completeImage = theData['completeImage'];
        }
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
                        builder: (context) => CustomDrawer(),
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

  Future<void> _getLogAgain() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = localStorage.getString('user');
    if (user != null) {
      setState(() {
        isLoggedInAgain = true;
      });
    }
  }

  // Future<void> _getLoginInfo() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   var user = localStorage.getString('user');
  //   if (user != null) {
  //     setState(() {
  //       isLoggedIn = true;
  //     });
  //   }
  //   Navigator.pop(context);
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => isLoggedIn ? FullProfile() : SignIn()));
  // }

  List items = [
    'Home',
    'Map',
    'Appointment',
    'Notification',
    'Privacy Policy',
    'FAQ',
    'Cred',
  ];
  List<IconData> iconList = [
    Icons.home,
    Icons.location_on,
    Icons.event_note,
    Icons.notification_important,
    Icons.security,
    Icons.quiz,
    Icons.logout
  ];

  List itemss = [
    'Home',
    'Map',
    'Appointment',
    'Notification',
    'Privacy Policy',
    'FAQ',
    'Cred',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: SpinKitCircle(
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10.0,
                        top: 10.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 22.0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      isLoggedInAgain
                          ? Positioned(
                              right: 10.0,
                              top: 10.0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 22.0,
                                ),
                                tooltip: "Edit Profile",
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullProfile()));
                                },
                              ),
                            )
                          : Positioned(
                              right: 10.0,
                              top: 10.0,
                              child: Container(
                                width: 1,
                                height: 1,
                              )),
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {},
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                  child: Image(
                                    image: (isLoggedInAgain == false
                                            ? AssetImage(
                                                'assets/icons/profile_picture.png')
                                            : _completeImage!.isNotEmpty
                                                ? NetworkImage(_completeImage!)
                                                : AssetImage(
                                                    'assets/images/no_image.png'))
                                        as ImageProvider<Object>,
                                    fit: BoxFit.fill,
                                    width: 100.0,
                                    height: 100.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            Text(
                              isLoggedInAgain == false
                                  ? 'Justine Hayes'
                                  : _userName!,
                              style: TextStyle(
                                fontFamily: 'FivoSansMedium',
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView.builder(
                  // separatorBuilder: (context,index)=>Divider(thickness: 1,color: Colors.grey,),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 15, top: 10),
                      visualDensity:
                          VisualDensity(vertical: -4, horizontal: -4),
                      leading: Icon(
                        iconList[index],
                        color: tappedIndex == index
                            ? Theme.of(context).primaryColor
                            : darkBlue,
                      ),
                      title: Text(
                        isLoggedInAgain == true
                            ? items[index] == "Cred"
                                ? "Logout"
                                : items[index]
                            : itemss[index] == "Cred"
                                ? "Login"
                                : itemss[index],
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tappedIndex == index
                              ? Theme.of(context).primaryColor
                              : darkBlue,
                          fontWeight: tappedIndex == index
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      onTap: () async {
                        SharedPreferences localStorage =
                            await SharedPreferences.getInstance();
                        if (items[index] == 'Home') {
                          Navigator.of(context).pop();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => HomePage(),
                          //   ),
                          // );
                        }
                        if (items[index] == 'Map') {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(),
                            ),
                          );
                        }
                        if (items[index] == 'Appointment') {
                          Navigator.of(context).pop();
                          var token = localStorage.getString('token');
                          if (token != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllAppointment(),
                              ),
                            );
                          } else {
                            showDialog(
                                builder: (context) => AlertDialog(
                                      title: Text('login Error'),
                                      content: Text(
                                          'Please login to view appointment'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignIn(),
                                                ));
                                          },
                                          child: Text('Login'),
                                        )
                                      ],
                                    ),
                                context: context);
                          }
                        }
                        if (items[index] == 'Notification') {
                          var token = localStorage.getString('token');
                          if (token != null) {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Notifications(),
                              ),
                            );
                          } else {
                            showDialog(
                                builder: (context) => AlertDialog(
                                      title: Text('login Error'),
                                      content: Text(
                                          'Please login to view notifications'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignIn(),
                                                ));
                                          },
                                          child: Text('Login'),
                                        )
                                      ],
                                    ),
                                context: context);
                          }
                        }
                        if (items[index] == 'Privacy Policy') {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicy(),
                            ),
                          );
                        }
                        if (items[index] == 'FAQ') {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FAQ(),
                            ),
                          );
                        }
                        if (items[index] == 'Cred') {
                          if (isLoggedInAgain) {
                            showDialog(
                                builder: (context) => AlertDialog(
                                      title: Text('logout'),
                                      content: Text(
                                          'Are you sure you want to Logout?'),
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
                                              CallApi().logout(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignIn(),
                                                ),
                                              );
                                            });
                                          },
                                          child: Text('Yes'),
                                        )
                                      ],
                                    ),
                                context: context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignIn(),
                              ),
                            );
                          }
                        }
                        setState(
                          () {
                            tappedIndex = index;
                          },
                        );
                      },
                      // subtitle: Divider(color: Colors.green,),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Drawer(
//
//     child: ListView(
//       children: [
//         DrawerHeader(
//           padding: EdgeInsets.zero,
//           child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor,
//             borderRadius:BorderRadius.only(
//               bottomLeft: Radius.circular(15),
//               bottomRight: Radius.circular(15)
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 left: 10.0,
//                 top: 10.0,
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.chevron_left,
//                     color: Colors.white,
//                     size: 22.0,
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//               _isLoggedInAgain ? Positioned(
//                 right: 10.0,
//                 top: 10.0,
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: Colors.white,
//                     size: 22.0,
//                   ),
//                   tooltip: "Edit Profile",
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => FullProfile()));
//                   },
//                 ),
//               ) : Positioned(
//                   right: 10.0,
//                   top: 10.0,
//                   child: Container(width: 1,height: 1,)),
//               Center(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                         height: MediaQuery.of(context).size.height *
//                             0.05),
//                     Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         border: Border.all(
//                           color: Colors.white,
//                           width: 3.0,
//                         ),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                         },
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(50.0),
//                           ),
//                           child: Image(
//                             image: (_isLoggedInAgain == false
//                                 ? AssetImage(
//                                 'assets/icons/profile_picture.png')
//                                 : _completeImage!.isNotEmpty
//                                 ? NetworkImage(_completeImage!)
//                                 : AssetImage(
//                                 'assets/images/no_image.png'))
//                             as ImageProvider<Object>,
//                             fit: BoxFit.fill,
//                             width: 100.0,
//                             height: 100.0,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                         height: MediaQuery.of(context).size.height *
//                             0.03),
//                     Text(
//                       _isLoggedInAgain == false
//                           ? 'Justine Hayes'
//                           : _userName!,
//                       style: TextStyle(
//                         fontFamily: 'FivoSansMedium',
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//             ],
//           ),
//         ),),
//         ListView.builder(
//           shrinkWrap: true,
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     _isLoggedInAgain == true
//                         ? items[index] == "Cred"
//                         ? "Logout"
//                         : items[index]
//                         : itemss[index] == "Cred"
//                         ? "Login"
//                         : itemss[index],
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: tappedIndex == index
//                           ? Theme.of(context).primaryColor
//                           : darkBlue,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//               onTap: () async {
//                 SharedPreferences localStorage =
//                 await SharedPreferences.getInstance();
//                 if (items[index] == 'Home') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => HomePage(),
//                     ),
//                   );
//                 }
//                 if (items[index] == 'Map') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MapScreen(),
//                     ),
//                   );
//                 }
//                 if (items[index] == 'Appointment') {
//                   var token = localStorage.getString('token');
//                   if (token != null) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AllAppointment(),
//                       ),
//                     );
//                   } else {
//                     showDialog(
//                         builder: (context) => AlertDialog(
//                           title: Text('login Error'),
//                           content: Text(
//                               'Please login to view appointment'),
//                           actions: <Widget>[
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           SignIn(),
//                                     ));
//                               },
//                               child: Text('Login'),
//                             )
//                           ],
//                         ),
//                         context: context);
//                   }
//                 }
//                 if (items[index] == 'Notification') {
//                   var token = localStorage.getString('token');
//                   if (token != null) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Notifications(),
//                       ),
//                     );
//                   } else {
//                     showDialog(
//                         builder: (context) => AlertDialog(
//                           title: Text('login Error'),
//                           content: Text(
//                               'Please login to view notifications'),
//                           actions: <Widget>[
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           SignIn(),
//                                     ));
//                               },
//                               child: Text('Login'),
//                             )
//                           ],
//                         ),
//                         context: context);
//                   }
//                 }
//                 if (items[index] == 'Privacy Policy') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PrivacyPolicy(),
//                     ),
//                   );
//                 }
//                 if (items[index] == 'FAQ') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FAQ(),
//                     ),
//                   );
//                 }
//                 if (items[index] == 'Cred') {
//                   if (_isLoggedInAgain) {
//                     showDialog(
//                         builder: (context) => AlertDialog(
//                           title: Text('logout'),
//                           content: Text(
//                               'Are you sure you want to Logout?'),
//                           actions: <Widget>[
//                             TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   Navigator.pop(context);
//                                 });
//                               },
//                               child: Text('No'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   CallApi().logout();
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           SignIn(),
//                                     ),
//                                   );
//                                 });
//                               },
//                               child: Text('Yes'),
//                             )
//                           ],
//                         ),
//                         context: context);
//                   } else {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SignIn(),
//                       ),
//                     );
//                   }
//                 }
//                 setState(
//                       () {
//                     tappedIndex = index;
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     ),
//   );
// }
}
