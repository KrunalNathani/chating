import 'package:chating/CommonFile/commonFile.dart';
import 'package:chating/Screens/ChatHomeScreen.dart';
import 'package:chating/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String email = "";
String yourPassword = "";
String newGenerateToken = "";

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, this.userModel}) : super(key: key);
  final UserDetailsModel? userModel;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool password = true;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loggingIn = false;

  void login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loggingIn = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        loggingIn = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

  @override
  void initState() {
    FocusManager.instance.primaryFocus?.unfocus();
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black12,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: CommonTextField(
                        textInputType: TextInputType.emailAddress,
                        validatorOnTap: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Email';
                          } else {
                            return null;
                          }
                        },
                        controller: emailController,
                        hint: "Enter Your Email",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: CommonTextField(
                        controller: passwordController,
                        hint: "Enter Your Password",
                        obscureText: !password ? false : true,
                        // textInputType: TextInputType.phone,
                        validatorOnTap: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Password';
                          } else if (value.length <= 5) {
                            return 'Min 6 character PassWord';
                            // return 'Incorrect Email';
                          } else {
                            return null;
                          }
                        },
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                password = !password;
                              });
                            },
                            child: Icon(Icons.remove_red_eye,
                                color:
                                    password ? Colors.blue[400] : Colors.blue)),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Button(
                        buttonText: "Login",
                        pressedButton: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text);
                            setState(() {});

                            String? userID = userCredential.user!.uid;

                            // CollectionReference users = FirebaseFirestore.instance.collection('userDetail');

                            // FirebaseMessaging.instance.getToken().then((token){
                            //   fcmToken = token!;
                            //   print("token $fcmToken");
                            // });
                            print("uid is:- ${userID}");
                            await FirebaseMessaging.instance
                                .getToken()
                                .then((value) => newGenerateToken = value!);
                            print("newGenerateToken:- ${newGenerateToken}");
                            await FirebaseFirestore.instance
                                .collection('userDetail')
                                .doc(userID)
                                .update({'fcmToken': newGenerateToken})
                                .then((value) => print("User Updated"))
                                .catchError((error) =>
                                    print("Failed to update user: $error"));


                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatHomeScreen(
                                          UID: userID,
                                        )
                                ),
                                (route) => false);


                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              print('No user found for that email.');
                            } else if (e.code == 'wrong-password') {
                              print('Wrong password provided for that user.');
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
