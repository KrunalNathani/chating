import 'package:chating/constants/function_constants.dart';
import 'package:chating/constants/string_constant.dart';
import 'package:chating/services/auth_service.dart';
import 'package:chating/services/register_service.dart';
import 'package:chating/services/notification_service.dart';
import 'package:chating/widget/common_text_field.dart';
import 'package:chating/model/user_model.dart';
import 'package:chating/pages/login/login_page.dart';
import 'package:chating/utils/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  AuthService authService = AuthService();
  RegisterService registerService = RegisterService();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool confirmPassword = true;
  bool password = true;
  bool isAdult = false;

  String uID = '';
  String fcmToken = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Container(
            height: 380,
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
                          horizontal: 15, vertical: 6),
                      child: CommonTextField(
                        controller: fNameController,
                        textInputType: TextInputType.name,
                        hint: "${enterFirstName}",
                        validatorOnTap: (value) => nameValidation(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 6),
                      child: CommonTextField(
                        controller: lNameController,
                        textInputType: TextInputType.name,
                        hint: "${enterLastName}",
                        validatorOnTap: (value) => nameValidation(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 6),
                      child: CommonTextField(
                        controller: emailController,
                        textInputType: TextInputType.emailAddress,
                        hint: "${enterEmail}",
                        validatorOnTap: (value) => emailValidation(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 6),
                      child: CommonTextField(
                        controller: passwordController,
                        hint: "${enterPassword}",
                        obscureText: !password ? false : true,
                        validatorOnTap: (value) =>
                            passwordValidation(value, passwordController.text),
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                password = !password;
                              });
                            },
                            child: password
                                ? const Icon(Icons.remove_red_eye,
                                    color: Colors.blue)
                                : const Icon(CupertinoIcons.eye_slash,
                                    color: Colors.blue)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 6),
                      child: CommonTextField(
                        controller: confirmPasswordController,
                        hint: "${enterConfirmPassword}",
                        obscureText: !confirmPassword ? false : true,
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                confirmPassword = !confirmPassword;
                              });
                            },
                            child: confirmPassword
                                ? const Icon(Icons.remove_red_eye,
                                    color: Colors.blue)
                                : const Icon(CupertinoIcons.eye_slash,
                                    color: Colors.blue)),
                        validatorOnTap: (value) => confirmPassWordValidation(
                            value,
                            passwordController.text,
                            confirmPasswordController.text),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Button(
                        buttonText: "${register}",
                        pressedButton: () async {
                          if (_key.currentState!.validate()) {
                            /// Authentication Email and Password
                            try {
                              UserCredential userCredential =
                                  await authService.authCreateUSer(
                                      emailController.text,
                                      passwordController.text);
                              print(
                                  'userCredential==>${userCredential.user!.uid}');
                              uID = userCredential.user!.uid;
                            } on FirebaseAuthException catch (e) {
                              if (e.code == '${weakPassword}') {
                                print('The password provided is too weak.');
                                displaySnackBar(
                                    context, "${thePasswordProvidedIsTooWeak}");
                              } else if (e.code == '${emailAlreadyInUse}') {
                                displaySnackBar(context,
                                    "${theAccountAlreadyExistsForThatEmail}");
                              }
                            } catch (e) {
                              print(e);
                            }

                            /// Create FCM TOKEN
                            fcmToken = await registerService.getToken();
                            print("fcmToken ${fcmToken}");

                            /// Register in CloudFire Store user all data
                            await registerService.registerUserDetail(
                                fNameController.text,
                                lNameController.text,
                                emailController.text,
                                passwordController.text,
                                uID,
                                fcmToken);
                            displaySnackBar(context, "${successRegister}");
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            });
                          }
                        }),
                    const SizedBox(
                      height: 15,
                    ),
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
