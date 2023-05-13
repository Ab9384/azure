import 'package:flutter/material.dart';

class BrandColors {
  static const Color backgroundColor = Color(0xFF212426);
  static const Color primaryColor = Color(0xFF96CFCC);
  static const Color primaryTextColor = Color(0xFFD1D3D6);
  static const Color orangeColor = Color(0xFFF19F5D);
  static Color secondaryTextColor = const Color(0xFFEAEAEC).withOpacity(0.4);
  //linear gradient button
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF545454)],
    begin: Alignment.topLeft,
    end: Alignment.bottomLeft,
  );
}
