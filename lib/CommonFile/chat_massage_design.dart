import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubbleText extends StatelessWidget {
  const ChatBubbleText({
    Key? key,
    required this.text,
    required this.isCurrentUser,
    required this.dateTime,
    required this.senderName,
    required this.messageType,
    required this.imageUrl,
    // required this.videoWidget,
    required this.onPressPopup,
    required this.onTapDownPopup,
    // required this.loader,
  }) : super(key: key);
  final String text;
  final bool isCurrentUser;
  final String dateTime;
  final String senderName;
  final String messageType;
  final String imageUrl;
  // final Widget loader;

  // final Widget videoWidget;
  final GestureTapCallback onPressPopup;
  final Function onTapDownPopup;



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
        :
        // messageType == "Image"?

        Padding(
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

                          Image.network(
                            imageUrl,
                            height: 150,
                            fit: BoxFit.contain,
                          ),

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
                          //
                          //         },
                          //         icon: Icon(
                          //           Icons.download,
                          //           color: Colors.green,
                          //         )),
                          //   ),
                          // ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              height: 35,
                              width: 35,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTapDown: (details) => onTapDownPopup(details),
                                onTap: onPressPopup,
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
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
          );
    // :
    // Padding(
    //   /// asymmetric padding
    //   padding: EdgeInsets.fromLTRB(
    //     isCurrentUser ? 64.0 : 16.0,
    //     4,
    //     isCurrentUser ? 16.0 : 64.0,
    //     4,
    //   ),
    //   child: Align(
    //     /// align the child within the container
    //     alignment:
    //     isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         DecoratedBox(
    //           /// chat bubble decoration
    //           decoration: BoxDecoration(
    //             color: isCurrentUser ? Colors.blue : Colors.grey[500],
    //             // borderRadius: BorderRadius.circular(16),
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.all(4),
    //             child: videoWidget,
    //             // child: VideoPlayer(VideoPlayerController.network(videoWidget)..initialize().then((_) => setState())),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(
    //               horizontal: 8.0, vertical: 1),
    //           child: Text(
    //             dateTime,
    //             style: TextStyle(color: Colors.black26, fontSize: 13),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //           child: Text(
    //             senderName,
    //             style: TextStyle(color: Colors.black26, fontSize: 13),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // ) ;
  }
}
