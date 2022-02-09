import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonTextButton extends StatelessWidget {

  final GestureTapCallback? onPressed;
  final Widget? icon;
  final Widget? lable;

  const CommonTextButton({ this.onPressed, this.icon, this.lable}) ;


  @override
  Widget build(BuildContext context) {
    return TextButton.icon(onPressed: onPressed!, icon: icon!, label: lable!);
  }
}
