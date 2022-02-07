import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' ;




class StorageSaveData extends StatefulWidget {
  @override
  _StorageSaveDataState createState() => _StorageSaveDataState();
}

class _StorageSaveDataState extends State<StorageSaveData> {

  Dio dio = Dio();

  bool loading = false;
  double progress = 1;

  // Future<bool> saveVideo(String? url, String? fileName) async {
  //   // Code for Downloading and Saving Content will go here
  // }
  Future<bool> saveVideo(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          Directory tempDir = await getTemporaryDirectory();


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
          newPath = newPath + "/Prrrrroo";
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

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 1;
    });
    // saveVideo will download and save file to Device and will return a boolean
    // for if the file is successfully or not
    bool downloaded = await saveVideo(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
        "v_${DateTime.now()}.mkv");
    if (downloaded) {
      print("downloaded => $downloaded");
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
          ),
        )
            : FlatButton.icon(
            icon: const Icon(
              Icons.download_rounded,
              color: Colors.white,
            ),
            color: Colors.blue,
            onPressed: downloadFile,
            padding: const EdgeInsets.all(10),
            label: const Text(
              "Download Video",
              style: TextStyle(color: Colors.white, fontSize: 25),
            )),
      ),
    );
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
}