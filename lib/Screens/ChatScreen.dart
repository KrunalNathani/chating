import 'package:chating/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {


   ChatScreen({@ required this.UID}) ;
  String? UID;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            height: MediaQuery.of(context).size.height * 10,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: StreamBuilder(
                stream:
                FirebaseFirestore.instance.collection('chatDetail').where('uid', isNotEqualTo: widget.UID).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        child: ListTile(tileColor: Colors.green,
                          title: Text("${document['fName']} ${document['lName']}"),
                        ),
                      );


                    }).toList(),
                  );
                })),
      ),
    );
  }
}
