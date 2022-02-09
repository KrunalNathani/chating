import 'package:chating/constants/string_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserService{
  /// chat_user_page in display all data in StreamBuilder
  showMessageAllData(senderUID){
    return FirebaseFirestore.instance
        .collection('${userDetail}')
        .where('${uid}', isNotEqualTo: senderUID)
        .snapshots();
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


  /// chat_user_page in senderDetailsCollect and use this data in model
  senderDetailsCollect(senderUid)  {
    return   FirebaseFirestore.instance
        .collection('${userDetail}')
        .doc(senderUid)
        .get();
  }

}