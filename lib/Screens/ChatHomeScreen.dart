import 'package:chating/Screens/ChatScreen.dart';
import 'package:chating/model/chatScreenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen({@required this.UID});

  String? UID;

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String? senderName;
  String? receiverName;
  String? receiverToken;
  String? senderUID;
  String? receiverUID;
  String? receiverFCMToken;
  String? chatRoomID;

  List messageList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text(
                'LOG OUT',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height * 10,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMC9_TtbLRIW5YZCEMc8x8NuBaxdNn32ZrqlH32dCTaeYczcAL78J5h4E-OiotXSLDoJQ&usqp=CAU'),
                  fit: BoxFit.contain)),
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('userDetail')
                .where('uid', isNotEqualTo: widget.UID)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                children: snapshot.data!.docs.map((document) {
                  print('snap shot id -> ${snapshot.data!.docs.length}');
                  print('snap shot id -> ${document.id}');
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          ListTile(
                            tileColor: Colors.green,
                            title: Text(
                                "${document['fName']} ${document['lName']}"),
                            onTap: () async {
                              print(widget.UID);

                              /// find sender Name
                              await FirebaseFirestore.instance
                                  .collection('userDetail')
                                  .doc(widget.UID)
                                  .get()
                                  .then((value) {
                                print(value['fName'] + value['lName']);
                                senderName =
                                    '${value['fName']} ${value['lName']}';
                                print('senderName ${senderName}');
                              });

                              /// Find Receiver NAme
                              await FirebaseFirestore.instance
                                  .collection('userDetail')
                                  .doc(document.id)
                                  .get()
                                  .then((value) {
                                print(value['fName'] + value['lName']);
                                receiverName =
                                    '${value['fName']} ${value['lName']}';
                                print('receiverName ${receiverName}');
                              });

                              /// Find Receiver FCMToken
                              await FirebaseFirestore.instance
                                  .collection('userDetail')
                                  .doc(document.id)
                                  .get()
                                  .then((value) {
                                print(value['fcmToken']);
                                receiverFCMToken = '${value['fcmToken']}';
                                print('receiverFCMToken ${receiverFCMToken}');
                              });

                              /// Receiver Token Id
                              await FirebaseFirestore.instance
                                  .collection('userDetail')
                                  .doc(document.id)
                                  .get()
                                  .then((value) {
                                print(value['fcmToken']);
                                receiverToken = '${value['fcmToken']}';
                                print('fcmToken ${receiverToken}');
                              });

                              /// Sender UID
                              senderUID = widget.UID;
                              print('senderUID ${senderUID}');

                              /// Receiver UID
                              receiverUID = document.id;
                              print('receiverUID ${receiverUID}');

                              chatRoomID =
                                  senderUID.hashCode <= receiverUID.hashCode
                                      ? '${senderUID} ${receiverUID}'
                                      : '${receiverUID} ${senderUID}';
                              print('chatRoomID ==> ${chatRoomID}');

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(
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

                          StreamBuilder(
                              /// chat room create and create chat massage user and receiver
                              stream: FirebaseFirestore.instance
                                  .collection("chat")
                                  .doc(chatRoomID)
                                  .collection("Chats").where('receiverUID', isEqualTo: receiverUID)
                                  .where('readMessage', isEqualTo: false)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                 var result = snapshot.data!.docs.map((e) => e['readMessage']);
                                  print(result);
                                  if(result.isNotEmpty){
                                    messageList.add(result);
                                    // print(messageList);
                                    // print(messageList.length);
                                  } else{
                                    messageList.clear();
                                  }
                                }

                                return Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(alignment: Alignment.center,
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Text(messageList.length.toString()),
                                  ),
                                );
                              }),

                          // StreamBuilder<Object>(
                          //     stream: FirebaseFirestore.instance
                          //         .collection("chat")
                          //         .doc(chatRoomID)
                          //         .collection("Chats").where('readMessage', isEqualTo: false)
                          //         .snapshots(),
                          //     builder: (context, snapshot) {
                          //       return Positioned(
                          //         right: 0,
                          //         bottom: 0,
                          //         child: Container(
                          //           height: 20,
                          //           width: 20,
                          //           decoration: BoxDecoration(
                          //               color: Colors.red, shape: BoxShape.circle),
                          //           child: Text('data'),
                          //         ),
                          //       );
                          //     }
                          //   )
                        ],
                      ));
                }).toList(),
              );
            }),
      ]),
    );
  }
}
