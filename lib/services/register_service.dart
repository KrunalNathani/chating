import 'package:chating/constants/string_constant.dart';
import 'package:chating/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterService{
  /// mobile token generate
  getToken()async{
    return  await FirebaseMessaging.instance.getToken();
  }

  /// registerUserDetail in user registration and after add data in user model and create collection in fire store
  registerUserDetail(String? fName,String? lName,String? email,String? password,String? uid,String? fcmToken)async{
    final FirebaseFirestore fireStore =
        FirebaseFirestore.instance;

    final CollectionReference _mainCollection =
    fireStore.collection('${userDetail}');

    UserDetailItem model = UserDetailItem(
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
}