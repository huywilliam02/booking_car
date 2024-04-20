import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:citgroupvn_carwash/Const/pref_utils.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends ChangeNotifier {
  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String? employeeId) {
    return FirebaseFirestore.instance
        .collection(pathCollection)
        .limit(limit)
        .where(NotificationConstant.userId, isEqualTo: employeeId)
        .snapshots();
  }

  Future<void> sendNotification(
      {required String content, required String token}) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              "key=AAAAEPNzQvA:APA91bEiLwlhbclSaKS4wvp9e9N-3ybh9zBMws0M5tZrOow3oaRw3rY28lY8KDOBKiinHadnJdYxWkAgujhTmq5IwrgXlVHiHHrmGNmu9Q6Er2Rk-ck63Wf-TtBN66ku_nVd6yyj1Aln",
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': content,
              'title': SharedPreferenceHelperUtils.getString(
                  NotificationConstant.userName),
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'screen': 'screen',
              'firebaseId': "userId",
              'userToken':
                  "SharedPreferenceHelperUtils.getString(PrefConstant.notificationRegisterKey)",
              'userImage':
                  "SharedPreferenceHelperUtils.getString(PrefConstant.profilePhotoKey)",
              'userName':
                  "SharedPreferenceHelperUtils.getString(PrefConstant.usernameKey)",
            },
            "to": token,
          },
        ),
      );
      if (response.statusCode == 200) {
        print("successes");
      } else {
        print("not send");
      }
    } catch (e) {
      print("error push notification");
    }
  }
}
