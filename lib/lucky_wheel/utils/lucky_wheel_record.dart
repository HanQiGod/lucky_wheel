import 'package:flutter/material.dart'
    show Widget, TextStyle, Color, AnimationController, Curve;

/// 状态
enum LuckyWheelStatus {
  idle, // 空闲状态
  spinning, // 旋转中
  loading, // 加载中（抽奖计算）
  paused, // 暂停
  completed, // 完成
  error, // 错误状态
  countingDown, // 倒计时状态
}

/// 奖品
class PrizeConfig {
  final String name;
  final Color color;
  final double probability; // 中奖概率
  final bool isWinning; // 是否为中奖项

  PrizeConfig({
    required this.name,
    required this.color,
    this.probability = 0.0, // 默认概率为0
    this.isWinning = false,
  });
}

/// 抽奖历史记录数据模型
class LuckyWheelRecord {
  final int prizeIndex;
  final String prizeName;
  final DateTime timestamp;
  final bool isWinning;

  LuckyWheelRecord({
    required this.prizeIndex,
    required this.prizeName,
    required this.timestamp,
    required this.isWinning,
  });

  // 转换为JSON格式，用于持久化存储
  Map<String, dynamic> toJson() {
    return {
      'prizeIndex': prizeIndex,
      'prizeName': prizeName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isWinning': isWinning,
    };
  }

  // 从JSON格式转换
  factory LuckyWheelRecord.fromJson(Map<String, dynamic> json) {
    return LuckyWheelRecord(
      prizeIndex: json['prizeIndex'] as int,
      prizeName: json['prizeName'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isWinning: json['isWinning'] as bool,
    );
  }
}

/// 状态管理
class LLoadingStatusConfig {
  // 状态变化回调
  Function(LuckyWheelStatus)? onStatusChanged;

  // 加载中按钮文本
  String? loadingText;

  // 暂停中按钮文本
  String? pausedText;

  // 错误按钮文本
  String? errorText;

  LLoadingStatusConfig({
    this.onStatusChanged,
    this.loadingText = "加载中...",
    this.pausedText = "暂停",
    this.errorText = "错误，点击重试",
  });
}

/// UI自定义
class LUIConfig {
  // 自定义指针Widget
  Widget? pointerWidget;

  // 指针颜色（当使用默认指针时）
  Color? pointerColor;

  // 指针大小（当使用默认指针时）
  double? pointerSize;

  // 自定义中心按钮
  Widget? centerButton;

  // 扇形边框颜色
  Color? sectionBorderColor;

  // 扇形边框宽度
  double? sectionBorderWidth;

  // 文字样式
  TextStyle? textStyle;

  LUIConfig({
    this.pointerWidget,
    this.pointerColor,
    this.pointerSize,
    this.centerButton,
    this.sectionBorderColor,
    this.sectionBorderWidth,
    this.textStyle,
  });
}

/// 动画效果扩展参数
class AnimationCurveConfig {
  // 开始动画曲线
  Curve? startAnimationCurve;

  // 中间动画曲线
  Curve? middleAnimationCurve;

  // 结束动画曲线
  Curve? endAnimationCurve;

  // 开始动画时长
  Duration? startAnimationDuration;

  // 结束动画时长
  Duration? endAnimationDuration;

  // 自定义动画控制器
  AnimationController? customAnimationController;

  AnimationCurveConfig({
    this.startAnimationCurve,
    this.middleAnimationCurve,
    this.endAnimationCurve,
    this.startAnimationDuration,
    this.endAnimationDuration,
    this.customAnimationController,
  });
}

/// 音效
class SoundConfig {
  // 是否启用音效
  bool enableSound;

  // 旋转音效资源路径
  String? spinSoundAsset;

  // 结果音效资源路径
  String? resultSoundAsset;

  SoundConfig({
    this.enableSound = false,
    this.spinSoundAsset,
    this.resultSoundAsset,
  });
}

/// 分享功能
class ShareConfig {
  // 分享标题
  String? shareTitle;

  // 分享描述
  String? shareDescription;

  // 分享主题
  String? shareSubject;

  ShareConfig({
    this.shareTitle = "我的抽奖结果",
    this.shareDescription = "我在活动中获得了",
    this.shareSubject = "分享我的抽奖结果",
  });
}
