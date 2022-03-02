import 'package:chating/constants/string_constant.dart';
import 'package:chating/local_data/shared_preference.dart';
import 'package:chating/pages/chat/receiver_unread_message.dart';
import 'package:chating/pages/login/login_page.dart';
import 'package:chating/services/auth_service.dart';
import 'package:chating/services/chat_user_service.dart';
import 'package:chating/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';

class ChatUserPage extends StatefulWidget {
  ChatUserPage({this.UID});

  String? UID;

  @override
  _ChatUserPageState createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  AuthService authService = AuthService();
  ChatUserService chatUserService = ChatUserService();

  String? senderName;
  String? receiverName;
  String? receiverToken;
  String? senderUID;
  String? receiverUID;
  String? receiverFCMToken;
  String? chatRoomID;

  List userChatRoomID = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${chatScreen}'),
        actions: [
          TextButton(
              onPressed: () async {
                await authService.logOutAuth();
                await removePrefData();

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              child: Text(
                '${logOut}',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body:
          // widget.UID!.isEmpty
          //     ? CircularProgressIndicator()
          //     :
          Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height * 10,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: NetworkImage('${bgImageURL}'), fit: BoxFit.contain)),
        ),
        StreamBuilder(
            stream: chatUserService.showMessageAllData(widget.UID),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              print("widget.UID11 ${widget.UID}");
              print("widget.UID11 ${snapshot.data}");
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                children: snapshot.data!.docs.map((document) {
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          ListTile(
                            tileColor: Colors.green,
                            title: Text(
                                "${document['${fName}']} ${document['${lName}']}"),
                            onTap: () async {
                              print("widget.UID ${widget.UID}");

                              /// sender Data
                            Map<String, dynamic> senderData = await chatUserService.receiverDetailsCollect(widget.UID);

                              /// find sender Name
                              senderName = "${senderData['fName']} ${senderData['lName']} ";

                              /// Sender UID
                              senderUID = widget.UID;

                              /// receiver Data
                              Map<String, dynamic> receiverData =
                                  await chatUserService.receiverDetailsCollect(
                                document.id,
                              );

                              receiverName = "${receiverData['fName']} ${receiverData['lName']}";
                              receiverFCMToken = receiverData['fcmToken'];
                              receiverToken = receiverData['fcmToken'];
                              receiverUID = document.id;

                              chatRoomID =
                                  senderUID.hashCode <= receiverUID.hashCode
                                      ? '${senderUID} ${receiverUID}'
                                      : '${receiverUID} ${senderUID}';
                              print("chatRoomID ${chatRoomID}");

                              userChatRoomID.add(chatRoomID);


                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  senderName: senderName,
                                  receiverName: receiverName,
                                  receiverToken: receiverToken,
                                  combineID: chatRoomID,
                                  senderUID: senderUID,
                                  receiverUID: receiverUID,
                                  receiverFCMToken: receiverFCMToken,
                                ),
                              ));
                            },
                          ),
                          // receiverUID != null
                          //     ? CircularProgressIndicator()
                          //     :
                          receiverUnreadMessage(
                                  receiverUID != null ? document.id : ''),
                        ],
                      ));
                }).toList(),
              );
            }),
      ]),
    );
  }
}
