import 'package:flutter/material.dart';

class AppColors {
  static const appColors = Color(0xff09cc26);
  static const white = Colors.white;
  static const transparent = Colors.transparent;
  static const black = Colors.black;
  static const grey = Colors.grey;
  static const amber = Colors.amber;
  static const red = Colors.red;
  static const green = Colors.green;
  static final grey500 = Colors.grey[500]!;

  static const lightWhite70 = Colors.white70;
  static const white54 = Colors.white54;
  static const white24 = Colors.white24;
  static const white12 = Colors.white12;
  static const white10 = Colors.white10;

  static const black54 = Colors.black54;
  static const black87 = Colors.black87;
  static final grey800 = Colors.grey[800];


  static final lightBlack = Colors.black12.withOpacity(.1);
  // Opacity variants for specific UI elements
  static final blackOpacity70 = Colors.black.withValues(alpha: 0.7 * 255);
  static final blackOpacity60 = Colors.black.withValues(alpha: 0.6 * 255);
  static final blackOpacity50 = Colors.black.withValues(alpha: 0.5 * 255);
  static final blackOpacity30 = Colors.black.withValues(alpha: 0.3 * 255);
  static final blackOpacity10 = Colors.black.withValues(alpha: 0.1 * 255);
  static final whiteOpacity80 = Colors.white.withValues(alpha: 0.8 * 255);
  static final whiteOpacity50 = Colors.white.withValues(alpha: 0.5 * 255);
  static final whiteOpacity30 = Colors.white.withValues(alpha: 0.3 * 255);
  static final whiteOpacity20 = Colors.white.withValues(alpha: 0.2 * 255);
  static final amberOpacity20 = Colors.amber.withValues(alpha: 0.2 * 255);
}