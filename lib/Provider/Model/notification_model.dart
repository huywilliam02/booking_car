import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:citgroupvn_carwash/Provider/notification_const_key.dart';

class NotificationUser {
  String id;
  String image;
  String userName;
  String type;
  String token;

  NotificationUser(
      {required this.id,
      required this.image,
      required this.userName,
      required this.type,
      required this.token});

  Map<String, String> toJson() {
    return {
      NotificationConstant.userId: id,
      NotificationConstant.userName: userName,
      NotificationConstant.imageUrl: image,
      NotificationConstant.type: type,
      NotificationConstant.pushToken: token,
    };
  }

  factory NotificationUser.fromDocument(DocumentSnapshot doc) {
    String id = "";
    String userName = "";
    String image = "";
    String type = "";
    String token = "";
    try {
      id = doc.get(NotificationConstant.userId);
    } catch (e) {
      print(e);
    }
    try {
      userName = doc.get(NotificationConstant.userName);
    } catch (e) {
      print(e);
    }
    try {
      image = doc.get(NotificationConstant.imageUrl);
    } catch (e) {
      print(e);
    }
    try {
      type = doc.get(NotificationConstant.type);
    } catch (e) {
      print(e);
    }
    try {
      token = doc.get(NotificationConstant.pushToken);
    } catch (e) {
      print(e);
    }
    return NotificationUser(
        id: id, image: image, userName: userName, type: type, token: token);
  }
}
