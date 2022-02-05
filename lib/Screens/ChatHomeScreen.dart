import 'package:chating/AuthScreen/LoginScreen.dart';
import 'package:chating/Screens/ChatScreen.dart';
import 'package:chating/model/chatScreenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen({this.UID});

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

  List userChatRoomID = [];
  Set? filterChatRoomID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
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
                  print('snap shot id -> ${document.data()}');

                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          ListTile(
                            tileColor: Colors.green,
                            title: Text(
                                "${document['fName']} ${document['lName']}"),
                            onTap: () async {
                              print("widget.UID ${widget.UID}");

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

                              userChatRoomID.add(chatRoomID);
                              filterChatRoomID = userChatRoomID.toSet();
                              print('filterChatRoomID ${filterChatRoomID}');

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

                          chatRoom(receiverUID != null ? document.id : ''),

                          // StreamBuilder(
                          //
                          //     /// chat room create and create chat massage user and receiver
                          //     stream: FirebaseFirestore.instance
                          //         .collection("chat")
                          //         .doc(chatRoomID)
                          //         .collection("Chats")
                          //         .where('CombineID', isEqualTo: chatRoomID)
                          //         .where('receiverUID', isEqualTo: receiverUID)
                          //         .where('readMessage', isEqualTo: false)
                          //         .snapshots(),
                          //     builder: (BuildContext context,
                          //         AsyncSnapshot<QuerySnapshot> snapshot) {
                          //       if (snapshot.hasData) {
                          //         print(
                          //             "dddaaaattaaa ${snapshot.data!.docs.length}");
                          //       }
                          //       return Positioned(
                          //         right: 0,
                          //         bottom: 0,
                          //         child: Container(
                          //           alignment: Alignment.center,
                          //           height: 20,
                          //           width: 20,
                          //           decoration: BoxDecoration(
                          //               color: Colors.red,
                          //               shape: BoxShape.circle),
                          //           child: Text(
                          //               snapshot.data!.docs.length.toString()),
                          //         ),
                          //       );
                          //     }),

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

  Widget chatRoom(String ID) {
    print('IDs +> ${ID}');
    List zz = [];


    String _chatRoomID = senderUID.hashCode <= ID.hashCode
        ? '${senderUID} ${ID}'
        : '${ID} ${senderUID}';

    return StreamBuilder(

        /// chat room create and create chat massage user and receiver
        stream: FirebaseFirestore.instance
            .collection("chat")
            .doc(_chatRoomID)
            .collection("Chats")
            .where('CombineID', isEqualTo: _chatRoomID)
            .where('senderUID', isEqualTo: ID)
            .where('readMessage', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            print("dddaaaattaaa ${snapshot.data!.docs.length}");
            zz.add(snapshot.data!.docs.length);
            print("qqqqq ==> ${zz}");
          }

          return Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              height: 20,
              width: 20,
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              // child: ListView.builder(
              //   itemCount: zz.length,
              //   itemBuilder: (context, index) => Center(child: Text(zz[index].toString(),style:TextStyle(fontSize: 15),)),
              // ),
              child: Text("${snapshot.data!.docs.length}"),
            ),
          );
        });
  }
}
