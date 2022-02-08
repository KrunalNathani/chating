import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

displaySnackBar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message!)));
}

/// download images
Dio dio = Dio();
bool loading = false;

/// image pickup in gallery
getFromGallery() async {
  XFile? pickedFile = await ImagePicker()
      .pickImage(source: ImageSource.gallery, maxHeight: 1800, maxWidth: 1800);

  if (pickedFile != null) {
    File imageFiles = File(pickedFile.path);
    print('gallery imageFiles ==> ${imageFiles}');
    return imageFiles;
  }
}

/// Download image in your gallery
Future<bool> saveImage(
    String url, String fileName, Function setStateProgress) async {
  print("saveImageURL ${url}");
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
        print("object 111");
      } else {
        return false;
      }
    } else {
      if (await _requestPermission(Permission.photos)) {
        directory = await getTemporaryDirectory();
        print("object 222");
      } else {
        return false;
      }
    }
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print("object 333");
    }
    if (await directory.exists()) {
      File saveFile = File(directory.path + "/$fileName");
      print("saveFile => $saveFile");
      print("direc => $directory");
      await dio.download(url, saveFile.path,
          onReceiveProgress: (value1, value2) {
        setStateProgress.call(value1 / value2);
      });

      if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(saveFile.path,
            isReturnPathOfIOS: true);
        print("object");
      }
      print("object 444");
      return true;
    }
    if (await directory.exists()) {
      File saveFile = File(directory.path + "/$fileName");
      print("saveFile => $saveFile");
      print("diourl => $url");
      await dio.download(url, saveFile.path,
          onReceiveProgress: (value1, value2) {
        setStateProgress.call(value1 / value2);
      });
      print("object 555");
      if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(saveFile.path,
            isReturnPathOfIOS: true);
      }
      print("object 666");
      return true;
    }
  } catch (e) {
    print(e);
  }
  print("object 777");
  return false;
}

downloadFile(String? imageDownload, Function setStateProgress,
    BuildContext context) async {
  // saveVideo will download and save file to Device and will return a boolean
  // for if the file is successfully or not\
  print("imageDownload ${imageDownload}");
  bool downloaded = await saveImage(
      imageDownload!, "v_${DateTime.now()}.jpg", setStateProgress);
  print("downloaded ${downloaded}");
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

/// message Time
String displayTimeAgoFromTimestamp(String? timestamp) {
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
