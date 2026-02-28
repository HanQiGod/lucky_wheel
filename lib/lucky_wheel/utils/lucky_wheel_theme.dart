import 'package:flutter/material.dart';

/// 主题配置
class LuckyWheelTheme {
  /// 深色模式主题
  static const LuckyWheelTheme darkTheme = LuckyWheelTheme._(
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarColor: Color(0xFF1E1E1E),
    appBarTextColor: Colors.white,
    cardFrontColor: Color(0xFF2D2D2D),
    cardFrontBorderColor: Color(0xFF404040),
    cardFrontGradientColors: [Color(0xFF2D2D2D), Color(0xFF121212)],
    cardBackColor: Color(0xFF2D2D2D),
    cardBackBorderColor: Color(0xFF2D2D2D),
    cardBackGradientColors: [Color(0xFF2D2D2D), Color(0xFF121212)],
    textColor: Colors.white,
    buttonColor: Colors.blue,
    buttonTextTheme: ButtonTextTheme.primary,
    recordBackgroundColor: Color(0xFF2D2D2D),
    recordTextColor: Colors.white,
    recordBorderColor: Color(0xFF404040),
  );

  /// 浅色模式主题
  static const LuckyWheelTheme lightTheme = LuckyWheelTheme._(
    scaffoldBackgroundColor: Colors.white,
    appBarColor: Colors.blue,
    appBarTextColor: Colors.white,
    cardFrontColor: Colors.blue,
    cardFrontBorderColor: Colors.blue,
    cardFrontGradientColors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
    cardBackColor: Colors.orange,
    cardBackBorderColor: Colors.orange,
    cardBackGradientColors: [Color(0xFFFF9800), Color(0xFFF44336)],
    textColor: Colors.white,
    buttonColor: Colors.blue,
    buttonTextTheme: ButtonTextTheme.normal,
    recordBackgroundColor: Colors.white,
    recordTextColor: Colors.black,
    recordBorderColor: Colors.grey,
  );

  /// 通用主题配置
  final Color scaffoldBackgroundColor;
  final Color appBarColor;
  final Color appBarTextColor;
  final Color cardFrontColor;
  final Color cardFrontBorderColor;
  final List<Color> cardFrontGradientColors;
  final Color cardBackColor;
  final Color cardBackBorderColor;
  final List<Color> cardBackGradientColors;
  final Color textColor;
  final Color buttonColor;
  final ButtonTextTheme buttonTextTheme;
  final Color recordBackgroundColor;
  final Color recordTextColor;
  final Color recordBorderColor;

  const LuckyWheelTheme._({
    required this.scaffoldBackgroundColor,
    required this.appBarColor,
    required this.appBarTextColor,
    required this.cardFrontColor,
    required this.cardFrontBorderColor,
    required this.cardFrontGradientColors,
    required this.cardBackColor,
    required this.cardBackBorderColor,
    required this.cardBackGradientColors,
    required this.textColor,
    required this.buttonColor,
    required this.buttonTextTheme,
    required this.recordBackgroundColor,
    required this.recordTextColor,
    required this.recordBorderColor,
  });

  /// 便捷创建方法（非const）
  factory LuckyWheelTheme({
    Color? scaffoldBackgroundColor,
    Color? appBarColor,
    Color? appBarTextColor,
    Color? cardFrontColor,
    Color? cardFrontBorderColor,
    List<Color>? cardFrontGradientColors,
    Color? cardBackColor,
    Color? cardBackBorderColor,
    List<Color>? cardBackGradientColors,
    Color? textColor,
    Color? buttonColor,
    ButtonTextTheme? buttonTextTheme,
    Color? recordBackgroundColor,
    Color? recordTextColor,
    Color? recordBorderColor,
  }) {
    return LuckyWheelTheme._(
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? Colors.white,
      appBarColor: appBarColor ?? Colors.blue,
      appBarTextColor: appBarTextColor ?? Colors.white,
      cardFrontColor: cardFrontColor ?? Colors.blue,
      cardFrontBorderColor: cardFrontBorderColor ?? Colors.blue,
      cardFrontGradientColors:
      cardFrontGradientColors ?? [Colors.blue, Colors.purple],
      cardBackColor: cardBackColor ?? Colors.orange,
      cardBackBorderColor: cardBackBorderColor ?? Colors.orange,
      cardBackGradientColors:
      cardBackGradientColors ?? [Colors.orange, Colors.red],
      textColor: textColor ?? Colors.white,
      buttonColor: buttonColor ?? Colors.blue,
      buttonTextTheme: buttonTextTheme ?? ButtonTextTheme.normal,
      recordBackgroundColor: recordBackgroundColor ?? Colors.white,
      recordTextColor: recordTextColor ?? Colors.black,
      recordBorderColor: recordBorderColor ?? Colors.grey,
    );
  }
}