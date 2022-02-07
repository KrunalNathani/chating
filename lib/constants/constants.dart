import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

displaySnackBar(BuildContext context, String? message){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message!)));
}

/// image pickup in gallery
getFromGallery() async {
  XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery, maxHeight: 1800, maxWidth: 1800);

  if (pickedFile != null) {

      File imageFiles = File(pickedFile.path);
      print('gallery imageFiles ==> ${imageFiles}');
      return imageFiles;
  }

}

