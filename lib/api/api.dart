import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_carwash/Const/pref_utils.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';
import 'package:citgroupvn_carwash/Provider/notificaton_auth.dart';

class CallApi {
  final String _url = "https://ruaxe.citgroup.vn/api/";
  // Note:- Don't remove /api/

  postData(data, apiUrl) async {
    var fullUrl = Uri.parse(_url + apiUrl);
    return await http.post(fullUrl, body: data);
  }

  postDataWithHeader(data, apiUrl) async {
    var fullUrl = Uri.parse(_url + apiUrl);
    return await http.post(fullUrl, body: data, headers: _setHeaders());
  }

  postDataWithToken(data, apiUrl) async {
    var fullUrl = Uri.parse(_url + apiUrl);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token')!;
    return await http.post(fullUrl, body: json.encode(data), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token
    });
  }

  getData(apiUrl) async {
    var fullUrl = Uri.parse(_url + apiUrl);
    return await http.get(fullUrl, headers: _setHeader());
  }

  _setHeaders() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
      };

  _setHeader() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  getWithToken(apiUrl) async {
    var fullUrl = Uri.parse(_url + apiUrl);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    // print('token from api $token');
    return await http.get(fullUrl, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  logout(BuildContext context) async {
    Provider.of<NotificationAuth>(context, listen: false).signOutUser();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    SharedPreferenceHelperUtils.remove(NotificationConstant.firebaseId);
    SharedPreferenceHelperUtils.remove(NotificationConstant.userName);
    SharedPreferenceHelperUtils.remove(NotificationConstant.email);
    SharedPreferenceHelperUtils.remove(NotificationConstant.userId);
    SharedPreferenceHelperUtils.remove(NotificationConstant.imageUrl);
    SharedPreferenceHelperUtils.remove(NotificationConstant.phone);
    SharedPreferenceHelperUtils.remove(NotificationConstant.type);
    SharedPreferenceHelperUtils.remove(
        NotificationConstant.notificationRegisterKey);
    SharedPreferenceHelperUtils.clearPref();
    SharedPreferenceHelperUtils.setBool(
        NotificationConstant.signInFirebaseUser, false);
    localStorage.remove('user');
    localStorage.remove('token');
  }
}
