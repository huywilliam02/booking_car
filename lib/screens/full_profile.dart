import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:image_picker/image_picker.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class FullProfile extends StatefulWidget {
  @override
  _FullProfileState createState() => _FullProfileState();
}

class _FullProfileState extends State<FullProfile> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phone = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  String? name = '';
  var image;
  var showSnipper = false;
  var image64;
  var imageData;
  var changeName;
  var apiName;
  var apiPassword;
  String? completeImage = '';
  var nameChange = 0;
  var proPicChange = 0;
  var passwordCheck = 0;

  bool isHideCurrent = false;
  bool isHideNew = false;
  bool isHideConfirm = false;

  @override
  void initState() {
    _getProfileInfo();
    super.initState();
  }

  Future<void> updateImage() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(imageData, 'update_image');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Image error'),
          content: Text(body['data'].toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  Future<void> updateName(apiName) async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(apiName, 'update_profile');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Name error'),
          content: Text(body['data'].toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  Future<void> updatePassword(apiPassword) async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(apiPassword, 'change_password');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Fluttertoast.showToast(
          msg: 'Change Password Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('Password Error'),
          content: Text(body['data'].toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  _imgFromCamera() async {
    ImagePicker imagePickerCamera = ImagePicker();
    image = await imagePickerCamera.pickImage(source: ImageSource.camera);
    _image = File(image.path);
    final bytes = Io.File(image.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    image64 = img64;
    setState(() {
      imageData = {"image": "$image64"};
    });
  }

  _imgFromGallery() async {
    ImagePicker imagePickerGallery = ImagePicker();
    image = await imagePickerGallery.pickImage(source: ImageSource.gallery);
    _image = File(image.path);
    final bytes = Io.File(image.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    image64 = img64;
    setState(() {
      imageData = {"image": "$image64"};
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _getProfileInfo() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().getWithToken('user');
    var body = json.decode(res.body);
    var theData = body;
    name = theData['name'];
    _nameController.text = theData['name'];
    _phone.text = theData['phone'];
    _emailController.text = theData['email'];
    completeImage = theData['completeImage'];
    setState(() {
      showSnipper = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showSnipper,
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(50.0)),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 1.0,
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
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 30.0),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3.0,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          child: _image != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.file(
                                                    _image!,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.fill,
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: completeImage!
                                                          .isNotEmpty
                                                      ? Image.network(
                                                          completeImage!,
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.fill,
                                                        )
                                                      : Image.asset(
                                                          'assets/images/no_image.png'),
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 1.0,
                                        right: 1.0,
                                        child: Container(
                                          height: 30.0,
                                          width: 30.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              proPicChange = 1;
                                              _showPicker(context);
                                            },
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color: darkBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                  Text(
                                    name!,
                                    style: TextStyle(
                                      fontFamily: 'FivoSansMedium',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 30.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Information',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18.0,
                                fontFamily: 'FivoSansMedium',
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Name',
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14,
                                fontFamily: 'FivoSansRegular',
                              ),
                            ),
                            TextField(
                              controller: _nameController,
                              enableSuggestions: false,
                              keyboardType: TextInputType.visiblePassword,
                              onChanged: (name) {
                                nameChange = 1;
                                changeName = name;
                              },
                              decoration: InputDecoration(
                                hintText: 'Justin Hayes',
                                hintStyle: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'FivoSansMedium',
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'FivoSansMedium',
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Email',
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14,
                                fontFamily: 'FivoSansRegular',
                              ),
                            ),
                            TextField(
                              controller: _emailController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'User Email',
                                hintStyle: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'FivoSansMedium',
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'FivoSansMedium',
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Phone',
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14,
                                fontFamily: 'FivoSansRegular',
                              ),
                            ),
                            TextField(
                              controller: _phone,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Container(
                                  margin: EdgeInsets.all(10.0),
                                  height: 22,
                                  width: 61,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Rubik',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                                hintText: '+1 903 698 8574',
                                hintStyle: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'FivoSansMedium',
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'FivoSansMedium',
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(
                                'Change Password',
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18.0,
                                  fontFamily: 'FivoSansMedium',
                                ),
                              ),
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Password',
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'FivoSansRegular',
                                      ),
                                    ),
                                    TextFormField(
                                      onTap: () {
                                        passwordCheck = 1;
                                      },
                                      controller: _oldPasswordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please Enter Password";
                                        } else if (value.length < 6) {
                                          return "Password must be at Least 6 characters long";
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: isHideCurrent,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'FivoSansMedium',
                                          letterSpacing: 0.2,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              isHideCurrent = !isHideCurrent;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            'assets/icons/lockicon.svg',
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'FivoSansMedium',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'New Password',
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'FivoSansRegular',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please Enter Password";
                                        } else if (value.length < 6) {
                                          return "Password must be at least 6 characters long";
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: isHideNew,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'FivoSansMedium',
                                          letterSpacing: 0.2,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              isHideNew = !isHideNew;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            'assets/icons/lockicon.svg',
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'FivoSansMedium',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'Confirm Password',
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'FivoSansRegular',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please Enter Password";
                                        } else if (value !=
                                            _newPasswordController.text) {
                                          return "Password must be same as above";
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: isHideConfirm,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'FivoSansMedium',
                                          letterSpacing: 0.2,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              isHideConfirm = !isHideConfirm;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            'assets/icons/lockicon.svg',
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'FivoSansMedium',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Positioned(
                  //   bottom: 10,
                  //   child: Container(
                  //     height: 50.0,
                  //     width: MediaQuery.of(context).size.width,
                  //     padding: EdgeInsets.only(left: 10,right: 10),
                  //     child: ElevatedButton(
                  //       onPressed: () {
                  //         if (_formKey.currentState!.validate()) {
                  //           if (proPicChange == 1) {
                  //             updateImage();
                  //           }
                  //           if (passwordCheck == 1) {
                  //             apiPassword = {
                  //               "old_password":
                  //                   "${_oldPasswordController.text}",
                  //               "password": "${_newPasswordController.text}",
                  //               "password_confirmation":
                  //                   "${_confirmPasswordController.text}"
                  //             };
                  //             updatePassword(apiPassword);
                  //           }
                  //           if (nameChange == 1) {
                  //             apiName = {"name": "$changeName"};
                  //             updateName(apiName);
                  //           }
                  //         }
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         primary: Theme.of(context).primaryColor,
                  //         minimumSize: Size.fromWidth(MediaQuery.of(context).size.width),
                  //         padding: EdgeInsets.zero,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(20)
                  //         )
                  //       ),
                  //       child: Text(
                  //         'SAVE',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 18.0,
                  //           fontFamily: 'FivoSansMedium',
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (proPicChange == 1) {
                  updateImage();
                }
                if (passwordCheck == 1) {
                  apiPassword = {
                    "old_password": "${_oldPasswordController.text}",
                    "password": "${_newPasswordController.text}",
                    "password_confirmation":
                        "${_confirmPasswordController.text}"
                  };
                  updatePassword(apiPassword);
                }
                if (nameChange == 1) {
                  apiName = {"name": "$changeName"};
                  updateName(apiName);
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size.fromWidth(MediaQuery.of(context).size.width),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontFamily: 'FivoSansMedium',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
