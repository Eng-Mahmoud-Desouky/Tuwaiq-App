import 'package:flutter/material.dart';

class AppTextStyles {
  static const String headingFontFamily = 'Plus Jakarta Sans';
  static const String bodyFontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 48,
    height: 56 / 48,
    letterSpacing: -0.02,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.01,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.02,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.05,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleSm = titleMd;
  static const TextStyle headlineMd = headlineLgMobile;
  static const TextStyle displayLgMobile = headlineLgMobile;

  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
  );
}
