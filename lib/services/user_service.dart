import 'package:chating/Pages/login/login_page.dart';
import 'package:chating/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserService{

  getToken()async{
  return  await FirebaseMessaging.instance.getToken();

  }

  registerUserDetail(String? fName,String? lName,String? email,String? password,String? uid,String? fcmToken)async{
    final FirebaseFirestore fireStore =
        FirebaseFirestore.instance;

    final CollectionReference _mainCollection =
    fireStore.collection('userDetail');

    UserDetailsModel model = UserDetailsModel(
        fName: fName,
        lName: lName,
        email: email,
        password: password,
        uid: uid,
        fcmToken: fcmToken
    );

    await _mainCollection
        .doc(uid)
        .set(model.toJson())
        .catchError((e) => print(e));
  }

  loginUpdateToken(String? userID)async{
    await FirebaseMessaging.instance
        .getToken()
        .then((value) => newGenerateToken = value!);
    print("newGenerateToken:- ${newGenerateToken}");
    await FirebaseFirestore.instance
        .collection('userDetail')
        .doc(userID)
        .update({'fcmToken': newGenerateToken})
        .then((value) => print("User Updated"))
        .catchError((error) =>
        print("Failed to update user: $error"));
  }

}