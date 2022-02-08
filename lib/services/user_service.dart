import 'package:chating/Pages/login/login_page.dart';
import 'package:chating/constants/function_constants.dart';
import 'package:chating/constants/string_constant.dart';
import 'package:chating/model/chat_screen_model.dart';
import 'package:chating/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserService{

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

  /// chat_user_page in senderDetailsCollect and use this data in model
  senderDetailsCollect(senderUid)  {
  return   FirebaseFirestore.instance
        .collection('${userDetail}')
        .doc(senderUid)
        .get();
  }

  /// chat_user_page in receiverDetailsCollect and use this data in model
    receiverDetailsCollect(
      receiverID)async{
    /// Find Receiver Name
      DocumentSnapshot<Map<String, dynamic>> recieiverSnapshot = await FirebaseFirestore.instance
        .collection('${userDetail}')
        .doc(receiverID)
        .get();
      print(recieiverSnapshot.data());
return recieiverSnapshot.data();
  }

  /// chat_user_page in display all data in StreamBuilder
  showMessageAllData(senderUID){
   return FirebaseFirestore.instance
        .collection('${userDetail}')
        .where('${uid}', isNotEqualTo: senderUID)
        .snapshots();
  }

  /// image upload cloud store and get image url
  Future<String> uploadImageAndDownloadURL(imageFiles) async {
    var storageImage = FirebaseStorage.instance.ref(imageFiles!.path);
    UploadTask task1 = storageImage.putFile(imageFiles!);
    return await (await task1).ref.getDownloadURL();
  }


  /// create chat and chats entry in fire store
  createChatRoom(ChatDetailItem? model, String? combineID)async{

    final FirebaseFirestore fireStore =
        FirebaseFirestore.instance;

    /// create two uer combine IDs and add pass model
    final CollectionReference _mainCollection =
    fireStore.collection('chat');

    /// create two uer chatting collection in firebase
    await _mainCollection
        .doc('${combineID}')
        .collection('${Chats}')
        .add(model!.toJson())
        .catchError((e) => print(e));

  }

  /// delete Image message
  deleteImageTypeMessage(String? messages, String? combineID, context) {

    FirebaseFirestore.instance
        .collection("${chat}")
        .doc(combineID)
        .collection("${Chats}")
    // .where("dateTime", isEqualTo: dateTimeToEpoch.toString())
        .where('${url}', isEqualTo: messages)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("${chat}")
            .doc(combineID)
            .collection("${Chats}")
            .doc(element.id)
            .delete()
            .then((value) {
          displaySnackBar(context, "${messageDeleteSuccessfully}");
        });
      });
    });
  }

  /// delete Text message
  deleteTextTypeMessage(String? messages, String? combineID,BuildContext context) async{
  await  FirebaseFirestore.instance
        .collection("chat")
        .doc(combineID)
        .collection("Chats")
    // .where("dateTime", isEqualTo: dateTimeToEpoch.toString())
        .where('massage', isEqualTo: messages)
        .get()
        .then((value) {
      value.docs.forEach((element) {
       FirebaseFirestore.instance
            .collection("chat")
            .doc(combineID)
            .collection("Chats")
            .doc(element.id)
            .delete()
            .then((value) {
             displaySnackBar(context, "${messageDeleteSuccessfully}");
        });
      });
    });
  }

  /// clear Chat
  clearChat(combineID) async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection =
    instance.collection('${chat}').doc(combineID).collection('${Chats}');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// message show or not function
  readMessages(id, id1, combineID) async {
    FirebaseFirestore.instance
        .collection("${chat}")
        .doc(combineID)
        .collection("${Chats}")
        .where('${senderUID}', isEqualTo: id1)
        .snapshots()
        .listen((event) async {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection("${chat}")
          .doc(combineID)
          .collection("${Chats}")
          .doc(id);
      documentReference.update({'${readMessage}': true});
    });
  }
}