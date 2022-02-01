import 'dart:io';
import 'package:chating/CommonFile/Permission%20Requast.dart';
import 'package:chating/CommonFile/chat_massage_design.dart';
import 'package:chating/Notification/notification_api.dart';
import 'package:chating/model/chatScreenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

String? massageType;
DateTime? EpochToDateTime;

class ChatScreen extends StatefulWidget {
  /// next Screen data pass
  ChatScreen({
    Key? key,
    required this.senderName,
    required this.receiverToken,
    required this.receiverName,
    required this.combineID,
    required this.senderUID,
    required this.receiverUID,
    required this.receiverFCMToken,
  });

  /// next Screen data pass parameter
  String? senderName;
  String? receiverName;
  String? receiverToken;
  String? combineID;
  String? senderUID;
  String? receiverUID;
  String? receiverFCMToken;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController chatMassage = TextEditingController();

  /// massage type
  String types = '';

  /// massage time convert DateTime to epoch and epoch to DateTime

  int? dateTimeToEpoch;

  /// Image and video file upload and download
  UploadTask? upload;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFiles;
  File? videoFiles;
  bool urlComplete = false;
  bool vidUrlComplete = false;
  String? imgUrl1;
  String? vidUrl;

  /// massage autoscroll controller
  ScrollController _scrollController = ScrollController();

  /// image picker create object
  final picker = ImagePicker();

  /// show video controller
  VideoPlayerController? _controller;

  /// message raed or not bool
  bool isMassageRead = false;

  ///Image tap popup menu and open popup menu as itis down position
  Offset? _tapPosition;

  /// download images
  Dio dio = Dio();
  bool loading = false;
  double progress = 1;

  String timeAgo = '';
  String timeUnit = '';
  int timeValue = 0;
  String? messageDate;
  DateTime? messageDatessss;

  getVerboseDateTimeRepresentation(DateTime dateTime) {
    print("dateTime ${dateTime}");
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    print("localDateTime ${localDateTime}");
    if (!localDateTime.difference(justNow).isNegative) {
      print("messageDate @ ${messageDate}");
      return messageDate = 'Today';
    }

    String roughTimeString = DateFormat('jm').format(dateTime);
    print("roughTimeString ${roughTimeString}");
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      print("messageDate @@ ${messageDate}");
      return messageDate = roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));
    print("yesterday ${yesterday}");
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == yesterday.month &&
        localDateTime.year == yesterday.year) {
      print("messageDate @@@ ${messageDate}");
      return messageDate = 'Yesterday, ';
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);

      print("messageDate @@@@ ${messageDate}");
      return messageDate = '$weekday';
    }

    print(
        "messageDate @@@@@ ${DateFormat('yMd').format(dateTime)},$roughTimeString");
    return messageDate = '${DateFormat('yMd').format(dateTime)}';
  }

  @override
  void initState() {
    // TODO: implement initState

    /// Scroll automatically code
    if (_scrollController.positions.isNotEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent)
          });
    }
    print("currentUserID ==> ${widget.senderUID}");
    // if(widget.receiverUID == ){}

    isMassageRead = true;
    super.initState();

    print('initState $messageDate');
    print('initState $isMassageRead');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    isMassageRead = false;
    super.dispose();
    print('dispose $isMassageRead');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Loading ==> $loading");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName!),
        actions: [
          GestureDetector(
              onTap: () {
                _onPressClearAllChatPopup();
              },
              onTapDown: (details) => _onTapDown(details),
              child: Icon(Icons.more_vert))
        ],
      ),
      body: StreamBuilder(

          /// chat room create and create chat massage user and receiver
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
                child: urlComplete
                    ? CircularProgressIndicator()
                    : Text(
                        "No recent chats found",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
              );
            } else {
              return urlComplete
                  ? Center(child: CircularProgressIndicator())
                  : loading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: CircularProgressIndicator(
                              color: Colors.green,
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: Colors.red,
                            )),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Downloading, please wait ...",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            )
                          ],
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          // primary: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //
                              // Text('- - - - ${displayTimeAgoFromTimestamp(
                              //     EpochToDateTime.toString())} - - - -'),
                              ListView.separated(
                                itemCount: snapshot.data!.docs.length,
                                separatorBuilder: (context, index) {
                                  //
                                  // print("messageDateSs${snapshot.data!.docs.length}");
                                  // snapshot.data!.docs.map((document) {
                                  //   print("messageDate111 ${document['dateTime']}");
                                  //   messageDatessss =  DateTime.fromMillisecondsSinceEpoch(int.parse("${document['dateTime']}"));
                                  //
                                  //   });
                                  // print('messageDatesss ${EpochToDateTime}');
                                  // getVerboseDateTimeRepresentation(EpochToDateTime!);
                                  // final int diffInHours = DateTime.now().difference(EpochToDateTime!).inHours;

                                  // print("messageDate1212 ${diffInHours}");
                                  // print("messageDate1212 ${diffInHours/24}");
                                  // print("messageDate1212 ${diffInHours/168}");
                                  // print("messageDate1212 ${diffInHours/2016}");
                                  //
                                  // if (diffInHours < 1) {
                                  //   timeValue = diffInHours;
                                  //   timeUnit = 'minute';
                                  //
                                  //   } else if (diffInHours < 24) {
                                  //     timeValue = diffInHours;
                                  //     timeUnit = 'hour';
                                  // } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
                                  //   timeValue = (diffInHours / 24).floor();
                                  //   timeUnit = 'day';
                                  //
                                  // } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
                                  //   timeValue = (diffInHours / (24 * 7)).floor();
                                  //   timeUnit = 'week';
                                  // } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
                                  //   timeValue = (diffInHours / (24 * 30)).floor();
                                  //   timeUnit = 'month';
                                  //
                                  // } else {
                                  //   timeValue = (diffInHours / (24 * 365)).floor();
                                  //   timeUnit = 'year';
                                  // }
                                  // timeAgo=  timeValue.toString() + ' ' + timeUnit;
                                  // timeAgo += timeValue > 1 ? 's' : '';
                                  // return Column(
                                  //   children:   snapshot.data!.docs.map((document) {
                                  //
                                  //     DateTime messageDate =  DateTime.fromMillisecondsSinceEpoch(int.parse("${document['dateTime']}"));
                                  //
                                  //         print("messageDate111 ${document['dateTime']}");
                                  //
                                  //         final int diffInHours = DateTime
                                  //             .now()
                                  //             .difference(messageDate)
                                  //             .inDays;
                                  //
                                  //         print("messageDate222 ${diffInHours}");
                                  //
                                  //         String? timeAgo = '';
                                  //         String? timeUnit = '';
                                  //         int timeValue = 0;
                                  //
                                  //         if (diffInHours < 1) {
                                  //           final diffInMinutes = DateTime
                                  //               .now()
                                  //               .difference(messageDate)
                                  //               .inDays;
                                  //           timeValue = diffInMinutes;
                                  //           timeUnit = 'day';
                                  //         // } else if (diffInHours < 24) {
                                  //         //   timeValue = diffInHours;
                                  //         //   timeUnit = 'hour';
                                  //         } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
                                  //           timeValue = (diffInHours / 24).floor();
                                  //           timeUnit = 'day';
                                  //         } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
                                  //           timeValue = (diffInHours / (24 * 7)).floor();
                                  //           timeUnit = 'week';
                                  //         } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
                                  //           timeValue = (diffInHours / (24 * 30)).floor();
                                  //           timeUnit = 'month';
                                  //         } else {
                                  //           timeValue = (diffInHours / (24 * 365)).floor();
                                  //           timeUnit = 'year';
                                  //         }
                                  //
                                  //         timeAgo = timeValue.toString() + ' ' + timeUnit;
                                  //
                                  //         timeAgo += timeValue > 1 ? 's' : '';
                                  //
                                  //     // return Divider();
                                  //     return Text("$timeAgo",style: TextStyle(color: Colors.red,fontSize: 25),);
                                  //   }).toList(),
                                  // );

                                  getVerboseDateTimeRepresentation(EpochToDateTime!);
                                  return Center(child: Text("------${messageDate}------"));
                                },
                                itemBuilder: (context, index) {
                                  final element = snapshot.data!.docs[index];
                                  print("element ${element['dateTime']}");
                                  return Column(
                                    children:
                                        snapshot.data!.docs.map((document) {
                                      EpochToDateTime =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                                  "${document['dateTime']}"));
                                      // print(DateFormat.jm().format(EpochToDateTime!));
                                      // print('dateTime==>>>> ${EpochToDateTime}');
                                      print("messageDAte ${EpochToDateTime}");

                                      /// autoscroll is not Empty then this scroll is start
                                      if (_scrollController
                                          .positions.isNotEmpty) {
                                        WidgetsBinding.instance
                                            ?.addPostFrameCallback((_) => {
                                                  _scrollController.jumpTo(
                                                      _scrollController.position
                                                          .maxScrollExtent)
                                                });
                                        // print("LiveTime => ${DateFormat.jm().format(DateTime.now())}");
                                      }

                                      if (widget.senderUID !=
                                          document['senderUID']) {
                                        print("check Condition and data add");
                                        readMessage(document.id,
                                            document['receiverUID']);
                                        // print("isMassageRead not match date");
                                        // print("isMassageRead not match date = ${isMassageRead}");
                                      } else {
                                        print("data not add");
                                      }

                                      // _controller = VideoPlayerController.network(
                                      //     document['vidurl'])
                                      //   ..initialize();
                                      // print('uuurl:- ${document['vidurl']}');

                                      return ChatBubbleText(
                                        text: document['massage'],
                                        messageType: document['massageType'],
                                        imageUrl: document['url'] ?? '',
                                        onPressImagePopup: () {
                                          _onPress(document['url']);
                                        },
                                        onTapDownImagePopup: _onTapDown,
                                        onPressTextPopup: () {
                                          _onPressTextPopup(
                                              document['massage']);
                                        },

                                        //   videoWidget:_controller != null && _controller!.value.isInitialized
                                        //       ? AspectRatio(
                                        //     aspectRatio: _controller!.value.aspectRatio,
                                        //     child: InkWell(
                                        //       onTap: () {
                                        //         setState(() {
                                        //           _controller!.value.isPlaying
                                        //               ? _controller!.pause()
                                        //               : _controller!.play();
                                        //         });
                                        //       },
                                        //       child: VideoPlayer(_controller!),
                                        //     ),
                                        //   )
                                        //       : SizedBox(height: 50,) ,
                                        //
                                        //   onPress: (){
                                        //     print('object');
                                        //     // downloadFileExample(document['url']);
                                        //     // downloadFileExample(document['url']);
                                        // },
                                        // isCurrentUser: false,
                                        // loader: loading
                                        //     ? Center(
                                        //         child: CircularProgressIndicator(
                                        //         color: Colors.green,
                                        //         value: progress,
                                        //       ))
                                        //     : Container(
                                        //         height: 20,
                                        //         color: Colors.red,
                                        //       ),
                                        isCurrentUser: widget.receiverUID ==
                                            document['receiverUID'],
                                        // dateTime:
                                        //     '${DateFormat.jm().format(EpochToDateTime!)}',
                                        dateTime:
                                            '${displayTimeAgoFromTimestamp(EpochToDateTime.toString())}',
                                        senderName: widget.receiverUID ==
                                                document['receiverUID']
                                            ? '${widget.senderName}'
                                            : '${widget.receiverName}',
                                      );
                                    }).toList(),
                                  );
                                },
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            ],
                          ),
                        );
            }
          }),

      /// this is massage typing box, select image and send button
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: MediaQuery.of(context).viewInsets,
              color: Colors.grey[300],
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          elevation: 20,
                          builder: (context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              color: Colors.transparent,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ListView(
                                  children: [
                                    Column(
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            await getFromGallery();
                                            if (imageFiles != null) {
                                              Navigator.pop(context);
                                            }

                                            if (videoFiles != null) {
                                              Navigator.pop(context);
                                              chatMassage.text =
                                                  videoFiles.toString();
                                            }

                                            print("imageFile==> $videoFiles");
                                          },
                                          child: Text(
                                            "Images",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blue)),
                                        ),
                                      ],
                                    ),
                                    // TextButton(
                                    //   onPressed: () async{
                                    //
                                    //     await getVideoFromGallery();
                                    //
                                    //     if (videoFiles != null) {
                                    //       Navigator.pop(context);
                                    //       chatMassage.text = videoFiles.toString();
                                    //     }
                                    //
                                    //     print("videoFile==> $videoFiles");
                                    //     types = 'Videos';
                                    //
                                    //       // _pickVideo();
                                    //
                                    //   },
                                    //   child: Text(
                                    //     "Videos",
                                    //     style: TextStyle(
                                    //         color: Colors.white, fontSize: 17),
                                    //   ),
                                    //   style: ButtonStyle(
                                    //       backgroundColor:
                                    //           MaterialStateProperty.all(
                                    //               Colors.blue)),
                                    // ),
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
                        types = "text";
                        if (imageFiles != null && chatMassage.text.isEmpty ||
                            imageFiles == null && chatMassage.text.isNotEmpty) {
                          /// Image upload and download url
                          if (imageFiles != null) {
                            setState(() {
                              urlComplete = true;
                            });

                            await upload_DownloadURL_File();
                            print("imageFile==> $imageFiles");
                            // await downloadURLExample();
                            types = "Image";
                          }

                          /// Video upload and download url
                          if (videoFiles != null) {
                            setState(() {
                              vidUrlComplete = true;
                            });

                            // await uploadVideoFile();
                            print("vidFile==> $videoFiles");
                            await downloadVideoURLExample();
                            types = "Video";
                          }

                          /// create chat and chats entry in fire store
                          final FirebaseFirestore fireStore =
                              FirebaseFirestore.instance;
                          // print('chatMAssages ;- ${chatMassage.text}');

                          /// create two uer combine IDs and add pass model
                          final CollectionReference _mainCollection =
                              fireStore.collection('chat');

                          /// DateTime to convert ephoch time
                          final DateTime date = DateTime.now();

                          dateTimeToEpoch = date.millisecondsSinceEpoch;
                          print('dddddddd ==> $dateTimeToEpoch (milliseconds)');

                          /// chetDetailsModel through add data in firestore
                          ChatDetailsModel model = ChatDetailsModel(
                              senderName: widget.senderName,
                              receiverName: widget.receiverName,
                              token: widget.receiverToken,
                              massage: chatMassage.text,
                              senderUid: widget.senderUID,
                              receiverUid: widget.receiverUID,
                              dateTime: dateTimeToEpoch.toString(),
                              massageType: types,
                              url: imgUrl1,
                              vidurl: vidUrl,
                              CombineID: widget.combineID,
                              readMessage: false);

                          /// this types is selected and after value is null so this types = '';
                          types = '';
                          imgUrl1 = '';
                          vidUrl = '';

                          /// Chat Massage TextField Clear
                          chatMassage.clear();

                          print("modelllll => ${model.toJson()}");

                          /// create two uer chatting collection in firebase
                          await _mainCollection
                              .doc('${widget.combineID}')
                              .collection('Chats')
                              .add(model.toJson())
                              .catchError((e) => print(e));

                          /// send notification receiver
                          sendNotification(
                              chatMassage.text,
                              widget.senderName.toString(),
                              widget.receiverFCMToken.toString());
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Text(''),
                    ),
                  )
                ],
              )),
          imageFiles != null
              ? Container(
                  padding: EdgeInsets.all(5),
                  height: 100,
                  width: double.infinity,
                  child: Image.file(imageFiles!),
                )
              : SizedBox()
        ],
      ),
    );
  }

  /// message long press and open popup menu, so this popup menu open this position
  _onTapDown(TapDownDetails details) {
    debugPrint("--> Detail --> $details ");

    _tapPosition = details.globalPosition;
  }

  /// Image message long press so open popup menu button
  _onPress(String? url) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromPoints(_tapPosition!, _tapPosition!),
          Offset.zero & overlay.size),
      items: [
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: url)).then((value) {
                    //only if ->
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copy Successfully')));
                  });
                  print(
                      "uuurl ${Clipboard.setData(new ClipboardData(text: url))}");
                },
                icon: Icon(Icons.copy),
                label: Text('Copy')),
            value: '1'),
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    loading = true;
                  });

                  await downloadFile(url);
                  setState(() {
                    loading = false;
                  });
                },
                icon: Icon(Icons.download),
                label: Text('Download')),
            value: '2'),
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text("Alert"),
                        content: new Text("Are you sure delete message!"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("delete"),
                            onPressed: () {
                              deleteImageTyeMessage(url);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('Delete')),
            value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String? itemSelected) {
      print("items ${itemSelected}");
      // if (itemSelected == null) return;
      //
      // if(itemSelected == "1"){
      //   //code here
      // }else if(itemSelected == "2"){
      //   //code here
      // }else{
      //   //code here
      // }
    });
  }

  /// text message long press so open popup menu button
  _onPressTextPopup(String? message) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromPoints(_tapPosition!, _tapPosition!),
          Offset.zero & overlay.size),
      items: [
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: message))
                      .then((value) {
                    //only if ->
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copy Successfully')));
                  });
                  print(
                      "uuurl ${Clipboard.setData(new ClipboardData(text: message))}");
                },
                icon: Icon(Icons.copy),
                label: Text('Copy')),
            value: '1'),
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text("Alert"),
                        content: new Text("Are you sure delete message!"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("delete"),
                            onPressed: () {
                              deleteTextTypeMessage(message);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('Delete')),
            value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String? itemSelected) {
      print("items ${itemSelected}");
      // if (itemSelected == null) return;
      //
      // if(itemSelected == "1"){
      //   //code here
      // }else if(itemSelected == "2"){
      //   //code here
      // }else{
      //   //code here
      // }
    });
  }

  /// Clear All chats
  _onPressClearAllChatPopup() {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromPoints(_tapPosition!, _tapPosition!),
          Offset.zero & overlay.size),
      items: [
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text("Alert"),
                        content: new Text("Are you sure Clear Chat!"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("Clear"),
                            onPressed: () async {
                              await clearChat();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('Clear Chat')),
            value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String? itemSelected) {
      print("items ${itemSelected}");
      // if (itemSelected == null) return;
      //
      // if(itemSelected == "1"){
      //   //code here
      // }else if(itemSelected == "2"){
      //   //code here
      // }else{
      //   //code here
      // }
    });
  }

  /// image pickup in gallery
  getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1800, maxWidth: 1800);

    if (pickedFile != null) {
      setState(() {
        imageFiles = File(pickedFile.path);
        print('gallery imageFiles ==> ${imageFiles}');
      });
    }
  }

  /// image upload cloud store and get image url
  Future<void> upload_DownloadURL_File() async {
    var storageImage = FirebaseStorage.instance.ref(imageFiles!.path);
    UploadTask task1 = storageImage.putFile(imageFiles!);
    imgUrl1 = await (await task1).ref.getDownloadURL();

    print('upload $imgUrl1');
    imageFiles = null;
    setState(() {
      urlComplete = false;
    });
  }

  /// get image url in cloud storage and send this url in model
//   Future<void> downloadURLExample() async {
//     var storageimage = FirebaseStorage.instance.ref().child(imageFiles!.path);
//
//
// // to get the url of the image from firebase storage
//
//     print("imgUrl1 ${imgUrl1}");
//
//     // Within your widgets:
//     // Image.network(downloadURL);
//
//   }

  /// delete message
  deleteTextTypeMessage(String? message) {
    print('selectDateTime ${dateTimeToEpoch}');
    FirebaseFirestore.instance
        .collection("chat")
        .doc(widget.combineID)
        .collection("Chats")
        // .where("dateTime", isEqualTo: dateTimeToEpoch.toString())
        .where('massage', isEqualTo: message)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("chat")
            .doc(widget.combineID)
            .collection("Chats")
            .doc(element.id)
            .delete()
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('message delete successfully!')));
          print("Success!");
        });
      });
    });
  }

  /// delete message
  deleteImageTyeMessage(String? url) {
    print('selectDateTime ${dateTimeToEpoch}');
    FirebaseFirestore.instance
        .collection("chat")
        .doc(widget.combineID)
        .collection("Chats")
        // .where("dateTime", isEqualTo: dateTimeToEpoch.toString())
        .where('url', isEqualTo: url)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection("chat")
            .doc(widget.combineID)
            .collection("Chats")
            .doc(element.id)
            .delete()
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('message delete successfully!')));
          print("Success!");
        });
      });
    });
  }

  /// clear Chat
  clearChat() async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection =
        instance.collection('chat').doc(widget.combineID).collection('Chats');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// message show or not function
  readMessage(id, id1) async {
    FirebaseFirestore.instance
        .collection("chat")
        .doc(widget.combineID)
        .collection("Chats")
        .where('receiverUID', isEqualTo: id1)
        .snapshots()
        .listen((event) async {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection("chat")
          .doc(widget.combineID)
          .collection("Chats")
          .doc(id);
      documentReference.update({'readMessage': true});
    });
  }

  /// video pickup from gallery
  getVideoFromGallery() async {
    XFile? pickedFiles =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFiles != null) {
      setState(() {
        videoFiles = File(pickedFiles.path);
        print('gallery videoFiles ==> ${videoFiles}');
      });
    }
  }

  //
  // Future<void> uploadVideoFile() async {
  //   final String fileName = path.basename(videoFiles!.path);
  //
  //   upload = storage.ref(fileName).putFile(videoFiles!);
  //   print('upload $upload');
  // }

  /// get image url in cloud storage and send this url in model
  Future<void> downloadVideoURLExample() async {
    var storageimage = FirebaseStorage.instance.ref().child(videoFiles!.path);
    UploadTask task1 = storageimage.putFile(videoFiles!);

// to get the url of the image from firebase storage
    vidUrl = await (await task1).ref.getDownloadURL();
    print("imgUrl1 ${vidUrl}");

    // Within your widgets:
    // Image.network(downloadURL);
    videoFiles = null;
    setState(() {
      vidUrlComplete = false;
    });

    _controller = VideoPlayerController.network(vidUrl!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  /// Download image in your gallery
  Future<bool> saveImage(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;

          String newPath = "";

          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Chatting App";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        print("saveFile => $saveFile");
        print("direc => $directory");
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });

        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        print("saveFile => $saveFile");
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });

        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  downloadFile(String? imageDownload) async {
    // saveVideo will download and save file to Device and will return a boolean
    // for if the file is successfully or not\

    bool downloaded =
        await saveImage(imageDownload!, "v_${DateTime.now()}.jpg");

    if (downloaded) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image Save Successfully!")));
      print("downloaded => $downloaded");
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  static String displayTimeAgoFromTimestamp(String? timestamp) {
    // final year = int.parse(timestamp!.substring(0, 4));
    // final month = int.parse(timestamp.substring(5, 7));
    // final day = int.parse(timestamp.substring(8, 10));
    // final hour = int.parse(timestamp.substring(11, 13));
    // final minute = int.parse(timestamp.substring(14, 16));

    // final DateTime videoDate = DateTime(year, month, day, hour, minute);
    // final int diffInHours = DateTime.now().difference(videoDate).inHours;

    // DateTime messageDate = Timestamp.fromMillisecondsSinceEpoch(int.parse(timestamp!)).toDate();

    DateTime messageDate = DateTime.parse(timestamp!);

    final int diffInHours = DateTime.now().difference(messageDate).inHours;

    String? timeAgo = '';
    String? timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(messageDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = 'minute';
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = 'hour';
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = 'day';
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = 'week';
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = 'month';
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = 'year';
    }

    timeAgo = timeValue.toString() + ' ' + timeUnit;
    timeAgo += timeValue > 1 ? 's' : '';

    print("timeAgo ${timeAgo}");

    return timeAgo + ' ago';
  }
}
