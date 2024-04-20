import 'package:flutter/cupertino.dart';
import 'package:citgroupvn_carwash/Const/pref_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:citgroupvn_carwash/Provider/Model/notification_model.dart';
import 'notification_const_key.dart';

class NotificationAuth extends ChangeNotifier {
  String? getUserFirebaseId() {
    return SharedPreferenceHelperUtils.getString(
        NotificationConstant.firebaseId);
  }

  Future<bool> signInWithFirebase(String email, String password, String userId,
      String userImage, String userName, String phoneNumber) async {
    try {
      bool checkUserRegister = SharedPreferenceHelperUtils.getBoolean(
          NotificationConstant.signInFirebaseUser);
      if (checkUserRegister) {
        User? firebaseUser = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password))
            .user;
        if (firebaseUser != null) {
          setDataFireCloudStorage(
              firebaseUser, email, userId, userImage, userName, phoneNumber);
        }
      } else {
        User? firebaseUser = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email, password: password))
            .user;
        if (firebaseUser != null) {
          setDataFireCloudStorage(
              firebaseUser, email, userId, userImage, userName, phoneNumber);
        }
      }
      SharedPreferenceHelperUtils.setBool(
          NotificationConstant.signInFirebaseUser, true);
      return true;
    } on FirebaseAuthException catch (err) {
      bool checkS = false;
      print("Firebase Login and sign error" + err.toString());
      if (err.code == "email-already-in-use") {
        User? firebaseUser =
            (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        ))
                .user;
        if (firebaseUser != null) {
          await setDataFireCloudStorage(
              firebaseUser, email, userId, userImage, userName, phoneNumber);
          SharedPreferenceHelperUtils.setBool(
              NotificationConstant.signInFirebaseUser, true);
          checkS = true;
        }
        return checkS;
      }
      return checkS;
    }
  }

  Future<void> setDataFireCloudStorage(
      User firebaseUser,
      String userEmail,
      String userId,
      String userImage,
      String userName,
      String userPhone) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(NotificationConstant.pathCollection)
        .where(NotificationConstant.firebaseId, isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isEmpty) {
      DateTime currentPhoneDate = DateTime.now(); //DateTime
      Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);
      FirebaseFirestore.instance
          .collection(NotificationConstant.pathCollection)
          .doc(firebaseUser.uid)
          .set({
        NotificationConstant.firebaseId: firebaseUser.uid,
        NotificationConstant.userId: userId,
        NotificationConstant.userName: userName,
        NotificationConstant.email: userEmail,
        NotificationConstant.imageUrl: userImage,
        NotificationConstant.phone: userPhone,
        NotificationConstant.createdAt: myTimeStamp,
        NotificationConstant.type: "user"
      });

      User? currentUser = firebaseUser;
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.firebaseId, currentUser.uid);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.userName, userName);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.email, userEmail);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.userId, userId);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.imageUrl, userImage);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.phone, userPhone);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.type, "user");
      print("current user" + currentUser.email!);
    } else {
      DocumentSnapshot documentSnapshot = documents[0];
      NotificationUser notificationUser =
          NotificationUser.fromDocument(documentSnapshot);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.firebaseId, firebaseUser.uid);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.userId, notificationUser.id);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.userName, notificationUser.userName);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.imageUrl, notificationUser.image);
      await SharedPreferenceHelperUtils.setString(
          NotificationConstant.type, notificationUser.type);
    }
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    // return FirebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}
