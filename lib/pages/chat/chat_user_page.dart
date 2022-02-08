import 'package:chating/constants/string_constant.dart';
import 'package:chating/pages/chat/receiver_unread_message.dart';
import 'package:chating/pages/login/login_page.dart';
import 'package:chating/services/user_service.dart';
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
  UserService userService = UserService();

  String? senderName;
  String? receiverName;
  String? receiverToken;
  String? senderUID;
  String? receiverUID;
  String? receiverFCMToken;
  String? chatRoomID;

  List userChatRoomID = [];
  Set? filterChatRoomID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${ChatScreen}'),
        actions: [
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                final success = await prefs.remove('${LoginUID}');
                print("Success ${success}");

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              child: Text(
                '${LOGOUT}',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: widget.UID!.isEmpty
          ? CircularProgressIndicator()
          : Stack(children: [
              Container(
                height: MediaQuery.of(context).size.height * 10,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: NetworkImage('${bgImageURL}'),
                        fit: BoxFit.contain)),
              ),
              StreamBuilder(
                  stream: userService.showMessageAllData(widget.UID),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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

                                    await userService.senderDetailsCollect(
                                        widget.UID, senderName, senderUID);

                                    await userService.receiverDetailsCollect(
                                        document.id,
                                        receiverName,
                                        receiverFCMToken,
                                        receiverToken,
                                        receiverUID);

                                    chatRoomID = senderUID.hashCode <=
                                            receiverUID.hashCode
                                        ? '${senderUID} ${receiverUID}'
                                        : '${receiverUID} ${senderUID}';

                                    userChatRoomID.add(chatRoomID);
                                    filterChatRoomID = userChatRoomID.toSet();
                                    print(
                                        'filterChatRoomID ${filterChatRoomID}');

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
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
                                receiverUID != null
                                    ? CircularProgressIndicator()
                                    : receiverUnreadMessage(
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
