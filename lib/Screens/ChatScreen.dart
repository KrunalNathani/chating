import 'package:chating/CommonFile/commonFile.dart';
import 'package:chating/model/chatScreenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.senderName,
    required this.receiverToken,
    required this.receiverName,
    required this.combineID,
    required this.senderUID,
    required this.receiverUID,
  });

  String? senderName;
  String? receiverName;
  String? receiverToken;
  String? combineID;
  String? senderUID;
  String? receiverUID;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController chatMassage = TextEditingController();

  String types = '';
  DateTime? EpochToDateTime;
  int? dateTimeToEpoch;

  @override
  void initState() {
    // TODO: implement initState
    print('initstate');
    super.initState();

    // // var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
    // final DateTime date1 = DateTime.now();
    //
    // final timestamp1 = date1.millisecondsSinceEpoch;
    // print('$timestamp1 (milliseconds)');
    //
    // var date = new DateTime.fromMillisecondsSinceEpoch(timestamp1);
    // print('date==>${date.runtimeType}');
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = new DateFormat('y-MM-d'); // <- use skeleton here
    return format.format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName!),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chat")
              .doc(widget.combineID)
              .collection("Chats")
              .orderBy('dateTime', descending: false)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data!.docs.length == 0) {
              return Center(
                child: Text(
                  "No recent chats found",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            } else {
              return SingleChildScrollView(primary: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: snapshot.data!.docs.map((document) {
                        EpochToDateTime = DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['dateTime']));
                        print(DateFormat.jm().format(EpochToDateTime!));
                        print('snap id ==>>>> ${widget.receiverUID}');

                        return ChatBubble(
                          text: document['massage'],
                          // isCurrentUser: false,
                          isCurrentUser:
                          widget.receiverUID == document['receiverUID'],
                          dateTime:
                          '${DateFormat.jm().format(EpochToDateTime!)}',
                          senderName: widget.receiverUID ==
                              document['receiverUID']
                              ? '${widget.senderName}'
                              : '${widget.receiverName}',
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }
          }),
      bottomNavigationBar: Container(
          padding: MediaQuery
              .of(context)
              .viewInsets,
          color: Colors.grey[300],
          child: Row(
            children: [
              Expanded(
                // child: PopupMenuButton(
                //     color: Colors.yellowAccent,
                //     elevation: 20,
                //     enabled: true,
                //     onCanceled: () {
                //       //do something
                //     },
                //     onSelected: (String? value) {
                //      types = value!;
                //      print(types);
                //     },
                //     itemBuilder: (context) =>
                //     [
                //       PopupMenuItem(
                //         child: Text("Image"),
                //         value: "Image",
                //       ),
                //       PopupMenuItem(
                //         child: Text("File"),
                //         value: "File",
                //       ),
                //     ]
                // )
                child: TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      elevation: 20,
                      builder: (context) {
                        return Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.15,
                          color: Colors.transparent,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            child: ListView(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    types = 'Images';

                                    showDialog(context: context,builder: (BuildContext context)
                                    {
                                      return AlertDialog(
                                        title: Text("Choose option",
                                          style: TextStyle(
                                              color: Colors.blue),),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: [
                                              Divider(
                                                height: 1, color: Colors.blue,),
                                              ListTile(
                                                onTap: () {
                                                  _openGallery(context);
                                                },
                                                title: Text("Gallery"),
                                                leading: Icon(Icons.account_box,
                                                  color: Colors.blue,),
                                              ),

                                              Divider(
                                                height: 1, color: Colors.blue,),
                                              ListTile(
                                                onTap: () {
                                                  _openCamera(context);
                                                },
                                                title: Text("Camera"),
                                                leading: Icon(Icons.camera,
                                                  color: Colors.blue,),
                                              ),
                                            ],
                                          ),
                                        ),);
                                    });
                                  },
                                  child: Text(
                                    "Images",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          Colors.blue)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    types = 'Videos';
                                  },
                                  child: Text(
                                    "Videos",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          Colors.blue)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.add_photo_alternate,
                    size: 30,
                  ),
                  label: Text(''),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: chatMassage,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message',
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: TextButton.icon(
                  onPressed: () async {
                    if (chatMassage.text.isNotEmpty) {
                      final FirebaseFirestore fireStore =
                          FirebaseFirestore.instance;
                      print('chatMAssages ;- ${chatMassage.text}');

                      /// create two uer combine IDs and add pass model
                      final CollectionReference _mainCollection =
                      fireStore.collection('chat');

                      /// DateTime to convert ephoch time
                      final DateTime date = DateTime.now();

                      dateTimeToEpoch = date.millisecondsSinceEpoch;
                      print('$dateTimeToEpoch (milliseconds)');

                      ChatDetailsModel model = ChatDetailsModel(
                          senderName: widget.senderName,
                          receiverName: widget.receiverName,
                          token: widget.receiverToken,
                          massage: chatMassage.text,
                          senderUid: widget.senderUID,
                          receiverUid: widget.receiverUID,
                          dateTime: dateTimeToEpoch.toString(),
                          massageType: types.isEmpty ? 'text' : types);

                      /// this types is selected and after value is null so this types = '';
                      types = '';

                      /// Chat Massage TextField Clear
                      chatMassage.clear();

                      /// create two uer chatting collection in firebase
                      await _mainCollection
                          .doc('${widget.combineID}')
                          .collection('Chats')
                          .add(model.toJson())
                          .catchError((e) => print(e));
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text(''),
                ),
              )
            ],
          )),
    );
  }

  PickedFile? imageFile = null;

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = pickedFile!;
    });
    Navigator.pop(context);
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      imageFile = pickedFile!;
    });

    Navigator.pop(context);
  }

}

class ChatBubble extends StatelessWidget {
  const ChatBubble(
      {Key? key,
      required this.text,
      required this.isCurrentUser,
      required this.dateTime,
      required this.senderName
      })
      : super(key: key);
  final String text;
  final bool isCurrentUser;
  final String dateTime;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      /// asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        /// align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              /// chat bubble decoration
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isCurrentUser ? Colors.white : Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 1),
              child: Text(
                dateTime,
                style: TextStyle(color: Colors.black26, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                senderName,
                style: TextStyle(color: Colors.black26, fontSize: 13),
              ),
            )
          ],
        ),
      ),
    );
  }
}
