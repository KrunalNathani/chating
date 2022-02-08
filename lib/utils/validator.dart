import 'package:chating/constants/string_constant.dart';
import 'package:flutter/material.dart';

String? nameValidation(String? value) {
  RegExp regex = RegExp(r'^[a-zA-Z]+$');
  if (value == null || value.isEmpty) {
    return '${enterFirstName}';
  } else if (!regex.hasMatch(value)) {
    return '${onlyAlphabetAllow}';
  } else {
    return null;
  }
}

String? emailValidation(String? value) {
  String pattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regex = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return '${enterEmail}';
  }
  else if (!regex.hasMatch(value)) {
    return '${errorEmail}';
  }
  else {
    return null;
  }
}

String? passwordValidation(String? value,String? text) {
  if (value == null || value.isEmpty) {
    return '${enterPassword}';
  } else if (text!.length <= 5) {
    return '${errorPasswordLength}';
  }
  else {
    return null;
  }
}

confirmPassWordValidation
      (String? value,String? text,String textMatch) {
    if (value == null || value.isEmpty) {
      return '${enterConfirmPassword}';
    } else if (text !=
        textMatch) {
      return '${confirmPasswordNotMatch}';
    } else if (textMatch.length <= 5) {
      return '${errorPasswordLength}';
    } else {
      return null;
    }
}


checkPassWordValidation
    (String? value,String? text,String textMatch) {
  if (value == null || value.isEmpty) {
    return '${enterPassword}';
  } else if (text !=
      textMatch) {
    return '${passwordNotMatch}';
  } else if (textMatch.length <= 5) {
    return '${wrongPassword}';
  } else {
    return null;
  }
}

