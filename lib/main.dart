

import 'package:chating/pages/chat/chat_user_page.dart';
import 'package:chating/pages/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_data/shared_preference.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   runApp( MyApp());
}

class MyApp extends StatelessWidget {

   String? LoginUID;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   LoginUID = getLoginPrefData().toString();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:FirebaseAuth.instance.currentUser == null ?  HomePage():ChatUserPage(UID: LoginUID??''),
    );
  }

}


