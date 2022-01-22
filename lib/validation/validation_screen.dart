import 'package:flutter/material.dart';

String? emailValidation(String? value) {
  String pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regex = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return 'Enter Email Address';
  }
  else if (!regex.hasMatch(value)) {
    return 'Enter Valid Email Address';
  }
  else {
    return null;
  }
}

String? validatePrefDate(String value, BuildContext context,String dateOfBirth ,bool? isAdult ) {
  // ignore: avoid_print
  print("isAdult -->>> $isAdult");
  if (dateOfBirth.isEmpty) {
    return "Enter DoB";
  }
  else {
    if(isAdult == false){
    return "Age Must Be 18";
  }
  else {
    return null;
  }
  }
}

String? passwordValidation(String? value,String? text) {
  if (value == null || value.isEmpty) {
    return 'Enter PassWord';
  } else if (text!.length <= 5) {
    return 'Enter Min 6 Character PassWord';
  }
  else {
    return null;
  }
}

confirmPassWordValidation
      (String? value,String? text,String textMatch) {
    if (value == null || value.isEmpty) {
      return 'Enter Confirm PassWord';
    } else if (text !=
        textMatch) {
      return 'Confirm Password Not Match';
    } else if (textMatch.length <= 5) {
      return 'Enter Min 6 Character PassWord';
    } else {
      return null;
    }
}


checkPassWordValidation
    (String? value,String? text,String textMatch) {
  if (value == null || value.isEmpty) {
    return 'Enter Your PassWord';
  } else if (text !=
      textMatch) {
    return 'Incorrect Password';
  } else if (textMatch.length <= 5) {
    return 'Incorrect Password';
  } else {
    return null;
  }
}

String? loginEmailValidation(String? value) {
  String pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regex = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return 'Enter Email Address';
  }
  else if (!regex.hasMatch(value)) {
    return 'Enter Valid Email Address';
  }
  else {
    return null;
  }
}


String? loginPasswordValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter Your Password';
  } else if (value.length <= 5) {
   // return 'Min 6 character PassWord';
    return 'Incorrect Password';
  }
  else {
    return null;
  }
}

//
// TabBarView(
// physics: const ScrollPhysics(),
// dragStartBehavior: DragStartBehavior.down,
// children: [
// RegisterScreen(userModel: widget.userModel,),
// // ignore: prefer_const_constructors
// FillDataScreen(
// // userModel: widget.userModel,
// // listIndex: widget.index,
// ),
// const ShowDataScreen(),
// ],
// controller: tabController,
// );
