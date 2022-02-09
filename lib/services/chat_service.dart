import 'package:chating/constants/function_constants.dart';
import 'package:chating/constants/string_constant.dart';
import 'package:chating/model/chat_screen_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class ChatService{
  /// message show or not function
  readMessages(id, id1, combineID) async {
    FirebaseFirestore.instance
        .collection("${chat}")
        .doc(combineID)
        .collection("${chats}")
        .where('${senderUID}', isEqualTo: id1)
        .snapshots()
        .listen((event) async {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection("${chat}")
          .doc(combineID)
          .collection("${chats}")
          .doc(id);
      documentReference.update({'${readMessage}': true});
    });
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
        .collection('${chats}')
        .add(model!.toJson())
        .catchError((e) => print(e));

  }

  /// delete Image message
  deleteImageTypeMessage(String? messages, String? combineID, context) {

    FirebaseFirestore.instance
        .collection("${chat}")
        .doc(combineID)
        .collection("${chats}")
    // .where("dateTime", isEqualTo: dateTimeToEpoch.toString())
        .where('${url}', isEqualTo: messages)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("${chat}")
            .doc(combineID)
            .collection("${chats}")
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
    instance.collection('${chat}').doc(combineID).collection('${chats}');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}