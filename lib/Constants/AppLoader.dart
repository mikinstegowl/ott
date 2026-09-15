import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';



class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: double.maxFinite,
        width: double.maxFinite,
        color: AppColors.blackOpacity30,
        child:  Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CircularProgressIndicator()
              Platform.isIOS? CupertinoActivityIndicator(
                color: AppColors.appColors,
              ):
              CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color?>(AppColors.appColors),
              )
            ]));
  }
}
