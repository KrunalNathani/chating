import 'dart:io';
import 'package:firebase_core/firebase_core.dart'as firebase_core;
import 'package:path/path.dart' as path;
import 'package:chating/model/chatScreenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

String? massageType;

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

  UploadTask? upload;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? imageFiles;
  File? videoFiles;

  bool urlComplete = false;
  bool vidUrlComplete = false;
  String? imgUrl1;
  String? vidUrl;

  ScrollController _scrollController = ScrollController();

  File? _video;
  final picker = ImagePicker();

  // VideoPlayerController? _videoPlayerController;

  VideoPlayerController? _controller;


  @override
  void initState() {
    // TODO: implement initState
    if (_scrollController.positions.isNotEmpty) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent)
          });
    }


    super.initState();
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
                  : SingleChildScrollView(
                      controller: _scrollController,
                      // primary: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs.map((document) {
                              EpochToDateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document['dateTime']));
                              // print(DateFormat.jm().format(EpochToDateTime!));
                              // print('snap id ==>>>> ${widget.receiverUID}');

                              if (_scrollController.positions.isNotEmpty) {
                                WidgetsBinding.instance?.addPostFrameCallback(
                                    (_) => {
                                          _scrollController.jumpTo(
                                              _scrollController
                                                  .position.maxScrollExtent)
                                        });
                              }


                              return ChatBubbleText(
                                text: document['massage'],
                                messageType: document['massageType'],
                                imageUrl: document['url'] ?? '',
                                videoWidget:_controller != null && _controller!.value.isInitialized
                                    ? AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!),
                                )
                                    : SizedBox(height: 50,) ,

                                onPress: (){
                                  print('object');
                                  // downloadFileExample(document['url']);
                                  // downloadFileExample(document['url']);
                              },
                                // isCurrentUser: false,
                                isCurrentUser: widget.receiverUID ==
                                    document['receiverUID'],
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
          padding: MediaQuery.of(context).viewInsets,
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
                          height: MediaQuery.of(context).size.height * 0.15,
                          color: Colors.transparent,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: ListView(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await getFromGallery();
                                    if (imageFiles != null) {
                                      Navigator.pop(context);
                                      chatMassage.text = imageFiles.toString();
                                    }
                                    if (videoFiles != null) {
                                      Navigator.pop(context);
                                      chatMassage.text = videoFiles.toString();
                                    }

                                    print("imageFile==> $videoFiles");
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
                                  onPressed: () async{

                                    await getVideoFromGallery();

                                    if (videoFiles != null) {
                                      Navigator.pop(context);
                                      chatMassage.text = videoFiles.toString();
                                    }

                                    print("videoFile==> $videoFiles");
                                    types = 'Videos';

                                      // _pickVideo();

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
                      types = "text";

                      /// Image upload and download url

                      if (imageFiles != null) {
                        setState(() {
                          urlComplete = true;
                        });

                        await uploadFile();
                        print("imageFile==> $imageFiles");
                        await downloadURLExample();
                        types = "Image";
                      }

                      /// Video upload and download url

                      if (videoFiles != null) {
                        setState(() {
                          vidUrlComplete = true;
                        });

                        await uploadVideoFile();
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
                      // print('$dateTimeToEpoch (milliseconds)');

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
                      vidurl:vidUrl
                      );

                      /// this types is selected and after value is null so this types = '';
                      types = '';
                      imgUrl1 = '';
                      vidUrl = '';

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

  getFromGallery() async {

    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery,maxHeight: 1800,maxWidth: 1800);
    // XFile? pickedFiles = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFiles = File(pickedFile.path);
        print('gallery imageFiles ==> ${imageFiles}');
      });
    }
  }

  Future<void> uploadFile() async {
    final String fileName = path.basename(imageFiles!.path);

    upload = storage.ref(fileName).putFile(imageFiles!);
    print('upload $upload');
  }

  /// get image url in cloud storage and send this url in model
  Future<void> downloadURLExample() async {
    var storageimage = FirebaseStorage.instance.ref().child(imageFiles!.path);
    UploadTask task1 = storageimage.putFile(imageFiles!);

// to get the url of the image from firebase storage
    imgUrl1 = await (await task1).ref.getDownloadURL();
    print("imgUrl1 ${imgUrl1}");

    // Within your widgets:
    // Image.network(downloadURL);
    imageFiles = null;
    setState(() {
      urlComplete = false;
    });
  }



  getVideoFromGallery() async {


    XFile? pickedFiles = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFiles != null) {
      setState(() {
        videoFiles = File(pickedFiles.path);
        print('gallery videoFiles ==> ${videoFiles}');
      });
    }
  }

  Future<void> uploadVideoFile() async {
    final String fileName = path.basename(videoFiles!.path);

    upload = storage.ref(fileName).putFile(videoFiles!);
    print('upload $upload');
  }

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

    _controller = VideoPlayerController.network(
        vidUrl!)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

}

// Future<bool> _requestPermission(Permission permission) async {
//   if (await permission.isGranted) {
//     return true;
//   } else {
//     var result = await permission.request();
//     if (result == PermissionStatus.granted) {
//       return true;
//     }
//   }
//   return false;
// }

// Future<void> downloadFileExample(String ref) async {
//
//   Directory directory;
//
//   if (Platform.isAndroid) {
//     if (await _requestPermission(Permission.storage)) {
//       directory = (await getExternalStorageDirectory())!;
//
//       String newPath = "";
//
//       print(directory);
//       List<String> paths = directory.path.split("/");
//       for (int x = 1; x < paths.length; x++) {
//         String folder = paths[x];
//         if (folder != "Android") {
//           newPath += "/" + folder;
//         } else {
//           break;
//         }
//       }
//       newPath = newPath + "/FireDemo";
//       directory = Directory(newPath);
//
//     } else {
//       return ;
//     }
//   } else {
//     if (await _requestPermission(Permission.photos)) {
//       directory = await getTemporaryDirectory();
//     } else {
//       return ;
//     }
//   }
//   if (!await directory.exists()) {
//     await directory.create(recursive: true);
//   }
//
//
//   File downloadToFile = File('${directory.path}/$ref');
//
//   print(downloadToFile);
//
//   try {
//     await FirebaseStorage.instance
//         .ref(ref)
//         .writeToFile(downloadToFile);
//   } on firebase_core.FirebaseException catch (e) {
//     // e.g, e.code == 'canceled'
//   }
// }



class ChatBubbleText extends StatelessWidget {
  const ChatBubbleText({
    Key? key,
    required this.text,
    required this.isCurrentUser,
    required this.dateTime,
    required this.senderName,
    required this.messageType,
    required this.imageUrl,
    required this.videoWidget,
    required this.onPress,
  }) : super(key: key);
  final String text;
  final bool isCurrentUser;
  final String dateTime;
  final String senderName;
  final String messageType;
  final String imageUrl;
  final Widget videoWidget;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return messageType == "text"
        ? Padding(
            /// asymmetric padding
            padding: EdgeInsets.fromLTRB(
              isCurrentUser ? 64.0 : 16.0,
              4,
              isCurrentUser ? 16.0 : 64.0,
              4,
            ),
            child: Align(
              /// align the child within the container
              alignment:
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
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
                            color:
                                isCurrentUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 1),
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
          )
        : messageType == "Image"? Padding(
            /// asymmetric padding
            padding: EdgeInsets.fromLTRB(
              isCurrentUser ? 64.0 : 16.0,
              4,
              isCurrentUser ? 16.0 : 64.0,
              4,
            ),
            child: Align(
              /// align the child within the container
              alignment:
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    /// chat bubble decoration
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.blue : Colors.grey[500],
                      // borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          Image.network(imageUrl),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 0,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: Colors.white,
                          //     ),
                          //     height: 35,
                          //     alignment: Alignment.center,
                          //     child: IconButton(
                          //         onPressed: () {
                          //           onPress;
                          //         },
                          //         icon: Icon(
                          //           Icons.download,
                          //           color: Colors.green,
                          //         )),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 1),
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
          ) :Padding(
      /// asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        /// align the child within the container
        alignment:
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              /// chat bubble decoration
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey[500],
                // borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: videoWidget,
                // child: VideoPlayer(VideoPlayerController.network(videoWidget)..initialize().then((_) => setState())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 1),
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
    ) ;
  }
}
