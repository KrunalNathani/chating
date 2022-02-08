import 'package:chating/constants/string_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget receiverUnreadMessage(String ID) {
  String _chatRoomID = senderUID.hashCode <= ID.hashCode
      ? '${senderUID} ${ID}'
      : '${ID} ${senderUID}';

  return StreamBuilder(

    /// chat room create and create chat massage user and receiver
      stream: FirebaseFirestore.instance
          .collection("${chat}")
          .doc(_chatRoomID)
          .collection("${Chats}")
          .where('${CombineID}', isEqualTo: _chatRoomID)
          .where('${senderUID}', isEqualTo: ID)
          .where('${readMessage}', isEqualTo: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              height: 20,
              width: 20,
              decoration:
              BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text("${snapshot.data!.docs.length}"),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      });
}