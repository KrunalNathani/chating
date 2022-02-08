import 'dart:io';
import 'package:chating/Notification/notification_api.dart';
import 'package:chating/constants/string_constant.dart';
import 'package:chating/services/user_service.dart';
import 'package:chating/widget/chat_massage_design.dart';
import 'package:chating/constants/function_constants.dart';
import 'package:chating/model/chat_screen_model.dart';
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

class ChatPage extends StatefulWidget {
  /// next Screen data pass
  ChatPage({
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
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  UserService userService = UserService();

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

  setStateFunction(progress) {
    setState(() {
      progress = progress;
    });
  }

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

    // String roughTimeString = DateFormat('jm').format(dateTime);
    // print("roughTimeString ${roughTimeString}");
    // if (localDateTime.day == now.day &&
    //     localDateTime.month == now.month &&
    //     localDateTime.year == now.year) {
    //   print("messageDate @@ ${messageDate}");
    //   return  roughTimeString;
    // }

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
            List _messageList = [];
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
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final element = snapshot.data!.docs[index];
                                  print("element ${element['dateTime']}");

                                  EpochToDateTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse("${element['dateTime']}"));

                                  /// autoscroll is not Empty then this scroll is start
                                  if (_scrollController.positions.isNotEmpty) {
                                    WidgetsBinding.instance
                                        ?.addPostFrameCallback((_) => {
                                              _scrollController.jumpTo(
                                                  _scrollController
                                                      .position.maxScrollExtent)
                                            });
                                    // print("LiveTime => ${DateFormat.jm().format(DateTime.now())}");
                                  }
                                  //
                                  if (widget.senderUID !=
                                      element['senderUID']) {
                                    print("check Condition and data add");
                                    userService.readMessages(
                                        element.id,
                                        element['receiverUID'],
                                        widget.combineID);
                                  } else {
                                    print("data not add");
                                  }

                                  String messagesDate = DateFormat('dd/MM/yyyy')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(element['dateTime'])));

                                  print('lsit ${_messageList}');
                                  print('messagesDate ${messagesDate}');
                                  print(
                                      'messageList.contains(messagesDate) ${_messageList.contains(messagesDate)}');

                                  if (!_messageList.contains(messagesDate)) {
                                    _messageList.add(messagesDate);
                                    // messageLists = messageList.toSet();
                                    return Center(
                                        child: Text(
                                      "------ $messagesDate ------",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ));
                                  } else {
                                    return ChatBubbleText(
                                      text: element['massage'],
                                      messageType: element['massageType'],
                                      imageUrl: element['url'] ?? '',
                                      onPressImagePopup: () {
                                        _onPress(element['url']);
                                      },
                                      onTapDownImagePopup: _onTapDown,
                                      onPressTextPopup: () {
                                        _onPressTextPopup(element['massage']);
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
                                          element['receiverUID'],
                                      // dateTime:
                                      //     '${DateFormat.jm().format(EpochToDateTime!)}',
                                      dateTime:
                                          '${displayTimeAgoFromTimestamp(EpochToDateTime.toString())}',
                                      senderName: widget.receiverUID ==
                                              element['receiverUID']
                                          ? '${widget.senderName}'
                                          : '${widget.receiverName}',
                                    );
                                  }
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
                                            setState(() {});
                                            // setState(() async {
                                            imageFiles = await getFromGallery();
                                            // });

                                            if (imageFiles != null) {
                                              Navigator.pop(context);
                                            }

                                            // if (videoFiles != null) {
                                            //   Navigator.pop(context);
                                            //   chatMassage.text =
                                            //       videoFiles.toString();
                                            // }

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
                    child: imageFiles != null
                        ? Container(
                            padding: EdgeInsets.all(5),
                            height: 100,
                            width: double.infinity,
                            child: Image.file(imageFiles!),
                          )
                        : Container(
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

                            imgUrl1 = await userService
                                .uploadImageAndDownloadURL(imageFiles);
                            print("imageFile==> $imageFiles");
                            // await downloadURLExample();

                            imageFiles = null;
                            setState(() {
                              urlComplete = false;
                            });
                            types = "Image";
                          }

                          // /// Video upload and download url
                          // if (videoFiles != null) {
                          //   setState(() {
                          //     vidUrlComplete = true;
                          //   });
                          //
                          //   // await uploadVideoFile();
                          //   print("vidFile==> $videoFiles");
                          //   await downloadVideoURLExample();
                          //   types = "Video";
                          // }

                          /// DateTime to convert ephoch time
                          final DateTime date = DateTime.now();

                          dateTimeToEpoch = date.millisecondsSinceEpoch;

                          /// send notification receiver
                          sendNotification(
                              chatMassage.text,
                              widget.senderName.toString(),
                              widget.receiverFCMToken.toString(),
                              imgUrl1.toString());

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

                          userService.createChatRoom(model, widget.combineID);
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Text(''),
                    ),
                  )
                ],
              )),
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
                        SnackBar(content: Text('${CopySuccessfully}')));
                  });
                  print(
                      "uuurl ${Clipboard.setData(new ClipboardData(text: url))}");

                  Navigator.pop(context);
                },
                icon: Icon(Icons.copy),
                label: Text('${Copy}')),
            value: '1'),
        PopupMenuItem<String>(
            child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    loading = true;
                  });
                  print("url11 ${url}");
                  // await downloadFile(url,setStateFunction);
                  await downloadFile(url, setStateFunction, context);
                  setState(() {
                    loading = false;
                  });
                },
                icon: Icon(Icons.download),
                label: Text('${Download}')),
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
                        title: new Text("${alert}"),
                        content: new Text("${AreYouSureDeleteMessage}"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("${Close}"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("${delete}"),
                            onPressed: () {
                              userService.deleteImageTypeMessage(
                                  url, widget.combineID, context);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('${Delete}')),
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
                        SnackBar(content: Text('${CopySuccessfully}')));
                  });
                  print(
                      "uuurl ${Clipboard.setData(new ClipboardData(text: message))}");
                  Navigator.pop(context);
                },
                icon: Icon(Icons.copy),
                label: Text('${Copy}')),
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
                        title: new Text("${alert}"),
                        content: new Text("${AreYouSureDeleteMessage}"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("${Close}"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("${delete}"),
                            onPressed: () {
                              userService.deleteTextTypeMessage(
                                  message, widget.combineID, context);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('${Delete}')),
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
                        title: new Text("${alert}"),
                        content: new Text("${AreYouSureClearChat}"),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          TextButton(
                            child: new Text("${Close}"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: new Text("${Clear}"),
                            onPressed: () async {
                              await userService.clearChat(widget.combineID);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
                label: Text('${ClearChat}')),
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

}
