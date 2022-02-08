
import 'package:chating/constants/function_constants.dart';
import 'package:chating/constants/string_constant.dart';
import 'package:chating/local_data/shared_preference.dart';
import 'package:chating/services/auth_service.dart';
import 'package:chating/services/user_service.dart';
import 'package:chating/widget/common_text_field.dart';
import 'package:chating/model/user_model.dart';
import 'package:chating/pages/chat/chat_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


String email = "";
String yourPassword = "";
String newGenerateToken = "";

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.userModel}) : super(key: key);
  final UserDetailsModel? userModel;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  AuthService authService = AuthService();
  UserService userService = UserService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool password = true;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loggingIn = false;

  String? userID;

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
              child:  Text(ok),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text(Error),
        ),
      );
    }
  }

  @override
  void initState() {
    FocusManager.instance.primaryFocus?.unfocus();

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
                            return '${enterEmail}';
                          } else {
                            return null;
                          }
                        },
                        controller: emailController,
                        hint: "${enterEmail}",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: CommonTextField(
                        controller: passwordController,
                        hint: "${enterPassword}",
                        obscureText: !password ? false : true,
                        // textInputType: TextInputType.phone,
                        validatorOnTap: (value) {
                          if (value == null || value.isEmpty) {
                            return '${enterPassword}';
                          } else if (value.length <= 5) {
                            return '${errorPasswordLength}';
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
                        buttonText: "${Login}",
                        pressedButton: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          try {

                            setState(() {});

                            UserCredential userCredential =await authService.checkAuthUser(emailController.text, passwordController.text);

                            userID = userCredential.user!.uid;
                            // CollectionReference users = FirebaseFirestore.instance.collection('userDetail');

                            // FirebaseMessaging.instance.getToken().then((token){
                            //   fcmToken = token!;
                            //   print("token $fcmToken");
                            // });
                            print("uid is:- ${userID}");

                            await userService.loginUpdateToken(userID);

                            await LoginUIDData(userCredential.user!.uid);
                            displaySnackBar(context, "${successLogin}");
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatUserPage(
                                          UID: userID,
                                        )
                                ),
                                (route) => false);

                          } on FirebaseAuthException catch (e) {
                            if (e.code == '${userNotFound}') {
                              displaySnackBar(context, "${noUserFoundForEmail}");
                            } else if (e.code == '${wrongPassword}') {
                              print('${wrongPasswordProvidedForUser}');
                              displaySnackBar(context, "${wrongPasswordProvidedForUser}");
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
