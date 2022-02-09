import 'package:chating/constants/string_constant.dart';
import 'package:chating/pages/login/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginService{

  /// login screen in update token
  loginUpdateToken(String? userID)async{

    await FirebaseMessaging.instance
        .getToken()
        .then((value) {
      print("value $value");
      newGenerateToken = value!;
    });
    print("newGenerateToken:- ${newGenerateToken}");
    await FirebaseFirestore.instance
        .collection('${userDetail}')
        .doc(userID)
        .update({'${fcmToken}': newGenerateToken})
        .then((value) => print("${userUpdated}"))
        .catchError((error) =>
        print("Failed to update user: $error"));
  }


}