import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class CustomTextStyle {
  static const lightGray30 = TextStyle(fontSize: 30, color: AppColors.gray500);
  static const lightGray20 = TextStyle(fontSize: 20, color: AppColors.gray900);
  static const primaryPurple14 =
      TextStyle(fontSize: 14, color: AppColors.primaryPurple);

  static TextStyle googleInter(
      {Color color = AppColors.primaryPurple,
      double fontSize = 20,
      FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.inter(
        color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  static TextStyle appBarTitle(
      {Color color = AppColors.white,
      double fontSize = 20,
      FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.inter(
        color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  static TextStyle header(
      {Color color = AppColors.primaryPurple,
      double fontSize = 17,
      FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.inter(
        color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  static TextStyle simpleTitle(
      {Color color = AppColors.white,
      double fontSize = 15,
      FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.inter(
        color: color, fontSize: fontSize, fontWeight: fontWeight);
  }
}
