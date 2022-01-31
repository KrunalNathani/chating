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
    required this.onPressImagePopup,
    required this.onTapDownImagePopup,
    required this.onPressTextPopup,
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
  final GestureTapCallback onPressImagePopup;
  final Function onTapDownImagePopup;
  final GestureTapCallback onPressTextPopup;



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
                  GestureDetector(
                    onLongPress: onPressTextPopup,
                    onTapDown: (details) => onTapDownImagePopup(details),
                    child: DecoratedBox(
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
                      child: GestureDetector(
                        onLongPress: onPressImagePopup,
                        onTapDown: (details) => onTapDownImagePopup(details),

                        child: Image.network(
                          imageUrl,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
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
