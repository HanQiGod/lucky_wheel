import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/lucky_wheel_controller.dart';
import 'controllers/lucky_wheel_history_manager.dart';
import 'utils/lucky_wheel_painter.dart';
import 'utils/lucky_wheel_record.dart';
import 'utils/lucky_wheel_theme.dart';
import 'utils/multi_curve_animation.dart';

//
// 使用示例：
// // 自定义抽奖控制器示例
// class CustomLuckyWheelController implements LuckyWheelController {
//   @override
//   Future<int> selectPrize(List<PrizeConfig> prizes) async {
//     // 这里可以实现特殊的抽奖逻辑，例如根据用户积分、时间等
//     // 暂停1秒模拟网络请求
//     await Future.delayed(Duration(seconds: 1));
//
//     // 实现特殊逻辑，例如某些用户固定中奖
//     return 0; // 固定返回第一个奖品
//   }
//
//   @override
//   void onResult(int prizeIndex, PrizeConfig prize) {
//     // 自定义结果处理逻辑，例如发送数据到服务器
//     print("用户中奖: ${prize.name}");
//   }
// }
//
// LuckyWheelWidget(
//         dailySpinLimit: 10,
//         enableWheelHighlight: false,
//         prizeConfigs: [
//           PrizeConfig(name: "一等奖", color: Colors.red, probability: 0.1),
//           PrizeConfig(name: "二等奖", color: Colors.blue, probability: 0.2),
//           PrizeConfig(name: "三等奖", color: Colors.black87, probability: 0.3),
//           PrizeConfig(name: "四等奖", color: Colors.green, probability: 0.2),
//           PrizeConfig(name: "谢谢惠顾", color: Colors.orange, probability: 0.1),
//           PrizeConfig(name: "五等奖", color: Colors.purple, probability: 0.2),
//         ],
//         controller: CustomLuckyWheelController(), // 使用自定义控制器
//         onResult: (index) {
//           print("抽奖结果: $index");
//         },
//       )
//

/// 大转盘
/// 幸运大转盘抽奖组件的状态管理类，主要功能包括：
// 1.动画控制：管理转盘旋转动画、预旋转动画和多阶段动画效果
// 2.状态管理：处理空闲、旋转、暂停、完成等不同状态
// 3.抽奖逻辑：实现奖品选择、次数限制、历史记录等功能
// 4.交互功能：支持倒计时、震动反馈、音效播放、结果分享等
// 5.UI更新：动态显示抽奖次数、错误信息和结果弹窗
class LuckyWheelWidget extends StatefulWidget {
  /// 每日抽奖次数限制
  final int? dailySpinLimit;

  /// 主题配置
  final LuckyWheelTheme theme;

  /// 奖品配置列表
  final List<PrizeConfig> prizeConfigs;

  /// 额外旋转圈数
  final int extraRotation;

  /// 动画时长
  final Duration animationDuration;

  /// 转盘尺寸
  final double wheelSize;

  /// 中心按钮尺寸
  final double centerButtonSize;

  /// 中心按钮颜色
  final Color centerButtonColor;

  /// 中心按钮图标
  final IconData centerButtonIcon;

  /// 动画曲线
  final Curve animationCurve;

  /// 结果回调
  final Function(int)? onResult;

  /// 页面标题
  final String? title;

  /// 按钮文本
  final String? buttonText;

  /// 旋转中按钮文本
  final String? spinningText;

  /// 结果对话框标题
  final String? resultDialogTitle;

  /// 结果对话框内容前缀
  final String? resultDialogContentPrefix;

  /// 自定义抽奖控制器
  final LuckyWheelController? controller;

  /// 触摸反馈
  /// 是否启用触觉反馈
  final bool enableHapticFeedback;

  /// 状态管理配置
  final LLoadingStatusConfig? statusConfig;

  /// UI自定义配置
  final LUIConfig? uiConfig;

  /// 动画效果配置
  final AnimationCurveConfig? animationCurveConfig;

  /// 音效配置
  final SoundConfig? soundConfig;

  /// 分享配置
  final ShareConfig? shareConfig;

  /// 是否显示新手引导
  final bool showTutorial;

  /// 转盘高亮动画持续时间
  final Duration highlightDuration;

  /// 是否启用转盘高亮效果
  final bool enableWheelHighlight;

  /// 是否启用奖品区域高亮
  final bool enablePrizeHighlight;

  /// 预旋转动画时长
  final Duration preSpinDuration;

  /// 是否启用预旋转动画
  final bool enablePreSpin;

  /// 是否启用连续震动反馈
  final bool enableContinuousHaptic;

  /// 是否显示抽奖倒计时
  final bool showCountdown;

  /// 倒计时持续时间
  final Duration countdownDuration;

  const LuckyWheelWidget({
    super.key,

    /// 抽奖次数限制
    this.dailySpinLimit,

    this.theme = LuckyWheelTheme.lightTheme, // 使用常量实例

    /// 奖品配置列表
    required this.prizeConfigs,
    this.extraRotation = 5,
    this.animationDuration = const Duration(seconds: 5),
    this.wheelSize = 300,
    this.centerButtonSize = 60,
    this.centerButtonColor = Colors.orange,
    this.centerButtonIcon = Icons.play_arrow,
    this.animationCurve = Curves.elasticOut,
    this.onResult,
    this.title = "大转盘活动",
    this.buttonText = "开始抽奖",
    this.spinningText = "抽奖中...",
    this.resultDialogTitle = "恭喜中奖！",
    this.resultDialogContentPrefix = "获得: ",
    this.controller,

    /// 触摸反馈参数
    this.enableHapticFeedback = false,

    /// 状态管理扩展参数
    this.statusConfig,

    /// UI自定义参数
    this.uiConfig,

    /// 动画效果扩展参数
    this.animationCurveConfig,

    /// 音效参数
    this.soundConfig,

    /// 分享功能参数
    this.shareConfig,

    /// 新增参数
    this.showTutorial = true,
    this.highlightDuration = const Duration(milliseconds: 150),
    this.enableWheelHighlight = true,
    this.enablePrizeHighlight = true,
    this.preSpinDuration = const Duration(milliseconds: 500),
    this.enablePreSpin = true,
    this.enableContinuousHaptic = false,
    this.showCountdown = false,
    this.countdownDuration = const Duration(seconds: 3),
  });

  @override
  _LuckyWheelWidgetState createState() => _LuckyWheelWidgetState();
}

class _LuckyWheelWidgetState extends State<LuckyWheelWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  LuckyWheelStatus _status = LuckyWheelStatus.idle;
  AnimationController? _customController;
  late LuckyWheelController _luckyWheelController;
  String? _error;
  int _todaySpins = 0;
  int _dailyLimit = 0;

  // 新增状态变量
  double _wheelScale = 1.0;
  int _currentHighlightedIndex = -1;
  Timer? _highlightTimer;
  Timer? _continuousHapticTimer;
  AnimationController? _preSpinController;
  Animation<double>? _preSpinAnimation;
  int _countdownValue = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // 使用传入的控制器或创建默认控制器
    _luckyWheelController = widget.controller ?? DefaultLuckyWheelController();

    // 使用自定义控制器或创建新的控制器
    if (widget.animationCurveConfig?.customAnimationController != null) {
      _customController =
          widget.animationCurveConfig?.customAnimationController;
      _rotationController = _customController!;
    } else {
      _rotationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    }

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: widget.animationCurve,
    ));

    // 初始化预旋转动画控制器
    if (widget.enablePreSpin) {
      _preSpinController = AnimationController(
        duration: widget.preSpinDuration,
        vsync: this,
      );
      _preSpinAnimation = Tween<double>(
        begin: 0.0,
        end: 0.1,
      ).animate(CurvedAnimation(
        parent: _preSpinController!,
        curve: Curves.easeInOut,
      ));
    }

    // 初始状态回调
    widget.statusConfig?.onStatusChanged?.call(_status);

    // 初始化抽奖限制
    _initLimits();

    // 设置初始旋转角度，使指针指向第一个奖品的中心
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if(widget.prizeConfigs.isNotEmpty) {
    //     double anglePerSection = 360 / widget.prizeConfigs.length;
    //     // 初始旋转到第一个奖品的中心位置
    //     double initialAngle = (anglePerSection / 4) / 360;
    //
    //     _rotationController.animateTo(
    //       initialAngle,
    //       duration: Duration(milliseconds: 300),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });

    // 显示新手引导
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialIfFirstTime();
      });
    }

    if (widget.enablePrizeHighlight) {
      _rotationAnimation.addListener(_highlightCurrentPrize);
    }
  }

  // 初始化抽奖限制
  Future<void> _initLimits() async {
    if (widget.dailySpinLimit != null) {
      await LuckyWheelHistoryManager.setDailyLimit(widget.dailySpinLimit!);
    }

    setState(() {
      _dailyLimit = widget.dailySpinLimit ?? 0;
    });

    _updateTodaySpins();
  }

  // 更新今日抽奖次数
  Future<void> _updateTodaySpins() async {
    final todaySpins = await LuckyWheelHistoryManager.getTodaySpins();
    setState(() {
      _todaySpins = todaySpins;
    });
  }

  // 获取当前状态
  LuckyWheelStatus get status => _status;

  // 开始旋转
  Future<void> _startSpinning() async {
    if (_status == LuckyWheelStatus.spinning ||
        _status == LuckyWheelStatus.loading ||
        _status == LuckyWheelStatus.paused ||
        _status == LuckyWheelStatus.countingDown) {
      return;
    }

    // 检查是否达到每日抽奖次数限制
    final isLimitReached = await LuckyWheelHistoryManager.isDailyLimitReached();
    if (isLimitReached) {
      setState(() {
        _status = LuckyWheelStatus.error;
        _error = "今日抽奖次数已达上限";
      });
      widget.statusConfig?.onStatusChanged?.call(_status);
      return;
    }

    // 如果启用倒计时，则先开始倒计时
    if (widget.showCountdown) {
      await _startCountdown();
    }

    // 触觉反馈
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _status = LuckyWheelStatus.loading;
      _error = null;
    });

    widget.statusConfig?.onStatusChanged?.call(_status);

    // 播放旋转音效
    if (widget.soundConfig?.enableSound ?? false) {
      LuckyWheelSoundController.playSpinSound();
    }

    try {
      // 使用控制器选择奖品
      int selectedPrize =
          await _luckyWheelController.selectPrize(widget.prizeConfigs);

      setState(() {
        _status = LuckyWheelStatus.spinning;
      });

      widget.statusConfig?.onStatusChanged?.call(_status);

      // 计算旋转角度 (随机奖品 + 多圈旋转以增加视觉效果)
      // 计算每个扇形的角度
      double anglePerSection = 360 / widget.prizeConfigs.length;
      // 计算目标奖品扇形的中心角度
      double targetAngle = widget.extraRotation * 360 + (360 - ((selectedPrize + 0.5) * anglePerSection));

      // 重置控制器
      _rotationController.reset();

      // 根据是否使用多段动画来创建旋转动画
      if (widget.animationCurveConfig?.startAnimationCurve != null ||
          widget.animationCurveConfig?.endAnimationCurve != null) {
        _rotationAnimation = _createMultiPhaseAnimation(targetAngle);
      } else {
        _rotationAnimation = Tween<double>(
          begin: _rotationController.value,
          end: _rotationController.value + targetAngle / 360,
        ).animate(CurvedAnimation(
          parent: _rotationController,
          curve: widget.animationCurve,
        ));
      }

      // 如果启用连续震动反馈
      if (widget.enableContinuousHaptic) {
        _startContinuousHaptic();
      }

      _rotationController.forward().whenComplete(() {
        if (widget.enablePrizeHighlight) {
          _rotationAnimation.removeListener(_highlightCurrentPrize);
        }

        setState(() {
          _status = LuckyWheelStatus.completed;
        });

        widget.statusConfig?.onStatusChanged?.call(_status);

        // 停止连续震动反馈
        _stopContinuousHaptic();

        // 旋转结束后可以显示中奖结果
        _showResult(selectedPrize);
      });
    } catch (e) {
      setState(() {
        _status = LuckyWheelStatus.error;
        _error = e.toString();
      });

      widget.statusConfig?.onStatusChanged?.call(_status);
    }
  }

  // 倒计时功能
  Future<void> _startCountdown() async {
    setState(() {
      _status = LuckyWheelStatus.countingDown;
      _countdownValue = widget.countdownDuration.inSeconds;
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _status = LuckyWheelStatus.idle;
        });
      }
    });

    await Future.delayed(widget.countdownDuration);
  }

  // 开始连续震动反馈
  void _startContinuousHaptic() {
    _continuousHapticTimer =
        Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_status == LuckyWheelStatus.spinning) {
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
      }
    });
  }

  // 停止连续震动反馈
  void _stopContinuousHaptic() {
    _continuousHapticTimer?.cancel();
  }

  // 暂停旋转（如果动画支持暂停）
  void _pauseSpinning() {
    if (_status == LuckyWheelStatus.spinning) {
      _rotationController.stop();
      setState(() {
        _status = LuckyWheelStatus.paused;
      });

      widget.statusConfig?.onStatusChanged?.call(_status);
    }
  }

  // 恢复旋转
  void _resumeSpinning() {
    if (_status == LuckyWheelStatus.paused) {
      _rotationController.forward();
      setState(() {
        _status = LuckyWheelStatus.spinning;
      });

      widget.statusConfig?.onStatusChanged?.call(_status);
    }
  }

  // 重置转盘
  void _resetWheel() {
    if (widget.enablePrizeHighlight) {
      _rotationAnimation.removeListener(_highlightCurrentPrize);
    }

    _rotationController.reset();
    _preSpinController?.reset();
    _stopContinuousHaptic();
    _countdownTimer?.cancel();

    setState(() {
      _status = LuckyWheelStatus.idle;
      _error = null;
      _wheelScale = 1.0;
      _currentHighlightedIndex = -1;
      _countdownValue = 0;
    });

    widget.statusConfig?.onStatusChanged?.call(_status);
  }

  // 创建多阶段动画
  Animation<double> _createMultiPhaseAnimation(double targetAngle) {
    // 计算各阶段动画时长
    Duration startDuration =
        widget.animationCurveConfig?.startAnimationDuration ??
            Duration(
                milliseconds:
                    (widget.animationDuration.inMilliseconds * 0.3).round());
    Duration endDuration = widget.animationCurveConfig?.endAnimationDuration ??
        Duration(
            milliseconds:
                (widget.animationDuration.inMilliseconds * 0.4).round());
    Duration middleDuration =
        widget.animationDuration - startDuration - endDuration;

    if (middleDuration.inMilliseconds < 0) {
      middleDuration = Duration.zero;
    }

    // 计算各阶段的角度比例
    double startAngleRatio = 0.1; // 开始阶段快速旋转
    double middleAngleRatio = 0.8; // 中间阶段快速旋转
    double endAngleRatio = 0.1; // 结束阶段减速

    double targetValue = _rotationController.value + targetAngle / 360;

    // 创建复合动画
    return MultiCurveAnimation(
      controller: _rotationController,
      startDuration: startDuration,
      middleDuration: middleDuration,
      endDuration: endDuration,
      startCurve:
          widget.animationCurveConfig?.startAnimationCurve ?? Curves.easeIn,
      middleCurve:
          widget.animationCurveConfig?.middleAnimationCurve ?? Curves.linear,
      endCurve:
          widget.animationCurveConfig?.endAnimationCurve ?? Curves.decelerate,
      startAngleRatio: startAngleRatio,
      middleAngleRatio: middleAngleRatio,
      endAngleRatio: endAngleRatio,
      targetValue: targetValue,
    );
  }

  // 高亮当前指针指向的奖品区域
  void _highlightCurrentPrize() {
    if (!widget.enablePrizeHighlight) return;

    double currentRotation = (_rotationAnimation.value * 360) % 360;
    double anglePerSection = 360 / widget.prizeConfigs.length;

    // 计算当前指针指向的区域索引
    int index = ((360 - currentRotation) / anglePerSection).floor() %
        widget.prizeConfigs.length;
    if (index < 0) index += widget.prizeConfigs.length;

    if (_currentHighlightedIndex != index) {
      setState(() {
        _currentHighlightedIndex = index;
      });

      // 清除之前的高亮计时器
      _highlightTimer?.cancel();

      // 设置新的高亮计时器
      _highlightTimer = Timer(widget.highlightDuration, () {
        if (mounted) {
          setState(() {
            _currentHighlightedIndex = -1;
          });
        }
      });
    }
  }

  // 转盘高亮动画
  void _highlightWheel() {
    if (!widget.enableWheelHighlight) return;

    setState(() {
      _wheelScale = 1.05;
    });

    Timer(widget.highlightDuration, () {
      if (mounted) {
        setState(() {
          _wheelScale = 1.0;
        });
      }
    });
  }

  // 显示新手引导
  Future<void> _showTutorialIfFirstTime() async {
    // 这里可以检查是否是第一次使用，如果是则显示引导
    // 暂时简化为直接显示示例
    // 实际应用中需要检查本地存储
    if (await _isFirstTime()) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("如何使用大转盘"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. 点击中心按钮开始抽奖"),
              Text("2. 转盘会自动旋转并随机停止在奖品区域"),
              Text("3. 查看抽奖结果并分享给朋友"),
              Text("4. 每日有一定抽奖次数限制"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("我知道了"),
            ),
          ],
        ),
      );
    }
  }

  // 检查是否是第一次使用
  Future<bool> _isFirstTime() async {
    // 实际应用中需要从本地存储检查
    // 这里简化为返回false
    return false;
  }

  void _showResult(int prizeIndex) {
    final selectedPrize = widget.prizeConfigs[prizeIndex];

    // 添加历史记录
    LuckyWheelHistoryManager.addRecord(
      LuckyWheelRecord(
        prizeIndex: prizeIndex,
        prizeName: selectedPrize.name,
        timestamp: DateTime.now(),
        isWinning: selectedPrize.isWinning,
      ),
    );

    // 更新统计数据
    LuckyWheelHistoryManager.updateStatistics(
      prizeIndex: prizeIndex,
      prize: selectedPrize,
      isWinning: selectedPrize.isWinning,
    );

    // 先更新今日抽奖次数
    _updateTodaySpins();

    // 调用控制器处理结果
    _luckyWheelController.onResult(prizeIndex, selectedPrize);

    // 调用外部回调
    widget.onResult?.call(prizeIndex);

    // 播放结果音效
    if (widget.soundConfig?.enableSound ?? false) {
      LuckyWheelSoundController.playResultSound();
    }

    // 重置状态
    setState(() {
      _status = LuckyWheelStatus.idle;
    });

    widget.statusConfig?.onStatusChanged?.call(_status);

    // 确保在下一帧渲染后再显示对话框，这样 _todaySpins 就是最新的
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 直接获取最新的今日抽奖次数
      LuckyWheelHistoryManager.getTodaySpins().then((latestTodaySpins) {
        // 再次使用 setState 确保 UI 已经更新
        if (mounted) {
          setState(() {
            // 确保 _todaySpins 是最新的
            _todaySpins = latestTodaySpins;
          });

          // 现在显示对话框，使用最新的次数
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(widget.resultDialogTitle!),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.resultDialogContentPrefix!}${selectedPrize.name}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "今日剩余抽奖次数: ${_dailyLimit - latestTodaySpins}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (selectedPrize.isWinning) ...[
                      SizedBox(height: 10),
                      Icon(Icons.star, color: Colors.orange, size: 40),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _shareResult(prizeIndex);
                    },
                    child: Text("分享"),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  // 分享结果
  Future<void> _shareResult(int prizeIndex) async {
    // 创建分享内容
    // String shareText = "${widget.shareConfig?.shareDescription} ${widget.prizeConfigs[prizeIndex].name}";

    // 尝试分享
    // await Share.share(
    //   shareText,
    //   subject: widget.shareConfig?.shareSubject,
    // );
  }

  // 创建默认指针Widget
  Widget _buildDefaultPointer() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: widget.uiConfig?.pointerSize ?? 30,
      height: widget.uiConfig?.pointerSize != null
          ? (widget.uiConfig?.pointerSize ?? 0) * 1.33
          : 40,
      decoration: BoxDecoration(
        color: widget.uiConfig?.pointerColor ?? Colors.red,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular((widget.uiConfig?.pointerSize ?? 30) / 2),
          topRight: Radius.circular((widget.uiConfig?.pointerSize ?? 30) / 2),
        ),
      ),
    );
  }

  // 获取按钮文本
  String _getButtonText() {
    if (_status == LuckyWheelStatus.countingDown) {
      return "$_countdownValue 秒后开始";
    }

    if (_status == LuckyWheelStatus.error &&
        _error != null &&
        _error!.contains("已达上限")) {
      return "抽奖次数已用完";
    }

    switch (_status) {
      case LuckyWheelStatus.idle:
        return widget.buttonText!;
      case LuckyWheelStatus.spinning:
        return widget.spinningText!;
      case LuckyWheelStatus.loading:
        return widget.statusConfig?.loadingText ?? "加载中...";
      case LuckyWheelStatus.paused:
        return widget.statusConfig?.pausedText ?? "暂停";
      case LuckyWheelStatus.error:
        return widget.statusConfig?.errorText ?? "错误，点击重试";
      case LuckyWheelStatus.completed:
        return widget.buttonText!;
      case LuckyWheelStatus.countingDown:
        return "倒计时中...";
    }
  }

  // 获取按钮是否可用
  bool _isButtonEnabled() {
    return _status != LuckyWheelStatus.spinning &&
        _status != LuckyWheelStatus.loading &&
        _status != LuckyWheelStatus.countingDown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: widget.theme.appBarColor,
        foregroundColor: widget.theme.appBarTextColor,
        title: Text(widget.title!),
        actions: [
          // 添加重置按钮
          if (_status != LuckyWheelStatus.idle)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetWheel,
            ),
          // 添加暂停/恢复按钮（仅在旋转时显示）
          if (_status == LuckyWheelStatus.spinning)
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: _pauseSpinning,
            ),
          if (_status == LuckyWheelStatus.paused)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: _resumeSpinning,
            ),
          // 添加统计信息按钮
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              _showStatistics();
            },
          ),
          // 添加历史记录按钮
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              _showHistory();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 转盘容器
            GestureDetector(
              onTapDown: (details) {
                if (_status == LuckyWheelStatus.idle) {
                  _highlightWheel();
                }
              },
              onTap: () {
                if (_status == LuckyWheelStatus.idle && _isButtonEnabled()) {
                  _startSpinning();
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                transform: Matrix4.identity()..scale(_wheelScale),
                width: widget.wheelSize,
                height: widget.wheelSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 转盘主体
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: CustomPaint(
                        size: Size(widget.wheelSize, widget.wheelSize),
                        painter: LuckyWheelPainter(
                          widget.prizeConfigs.map((e) => e.name).toList(),
                          widget.prizeConfigs.map((e) => e.color).toList(),
                          sectionBorderColor:
                              widget.uiConfig?.sectionBorderColor,
                          sectionBorderWidth:
                              widget.uiConfig?.sectionBorderWidth,
                          textStyle: widget.uiConfig?.textStyle,
                          highlightedIndex: _currentHighlightedIndex,
                        ),
                      ),
                    ),
                    // 中心按钮
                    widget.uiConfig?.centerButton ??
                        Container(
                          width: widget.centerButtonSize,
                          height: widget.centerButtonSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: widget.centerButtonColor, width: 3),
                          ),
                          child: IconButton(
                            icon: Icon(
                              widget.centerButtonIcon,
                              color: widget.centerButtonColor,
                              size: widget.centerButtonSize * 0.5,
                            ),
                            onPressed:
                                _isButtonEnabled() ? _startSpinning : null,
                          ),
                        ),
                    // 指针
                    Positioned(
                      top: widget.uiConfig?.pointerSize != null
                          ? (widget.uiConfig?.pointerSize ?? 0) / 2
                          : 15,
                      child: widget.uiConfig?.pointerWidget ??
                          _buildDefaultPointer(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // 显示抽奖次数信息
            if (_dailyLimit > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "今日已抽奖 $_todaySpins / $_dailyLimit 次",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),
            // 状态指示器
            if (_status == LuckyWheelStatus.error && _error != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "错误: $_error",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            // 倒计时指示器
            if (_status == LuckyWheelStatus.countingDown)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "倒计时: $_countdownValue 秒",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isButtonEnabled() ? _startSpinning : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.centerButtonColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                _getButtonText(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示统计信息
  Future<void> _showStatistics() async {
    final stats = await LuckyWheelHistoryManager.getStatistics();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("抽奖统计"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("总抽奖次数: ${stats.totalSpins}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text("总中奖次数: ${stats.totalWins}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                    "中奖率: ${stats.totalSpins > 0 ? ((stats.totalWins / stats.totalSpins) * 100).toStringAsFixed(2) : '0.00'}%",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text("最大连续中奖: ${stats.maxConsecutiveWins}",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Text("各奖品获奖统计:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...stats.prizeCounts.entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text("${entry.key}: ${entry.value}次",
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("确定"),
            ),
          ],
        );
      },
    );
  }

  // 显示历史记录
  Future<void> _showHistory() async {
    final records = await LuckyWheelHistoryManager.getHistory();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("抽奖历史记录"),
          content: Container(
            width: double.maxFinite,
            child: records.isEmpty
                ? Text("暂无历史记录")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record =
                          records[records.length - 1 - index]; // 倒序显示
                      return ListTile(
                        title: Text(record.prizeName),
                        subtitle: Text(
                          "${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')} "
                          "${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: record.isWinning
                            ? Icon(Icons.star, color: Colors.orange)
                            : Icon(Icons.sentiment_dissatisfied,
                                color: Colors.grey),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("确定"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.enablePrizeHighlight) {
      _rotationAnimation.removeListener(_highlightCurrentPrize);
    }

    // 只有在不是外部传入的控制器时才释放
    if (_customController == null) {
      _rotationController.dispose();
    }

    _preSpinController?.dispose();
    _highlightTimer?.cancel();
    _continuousHapticTimer?.cancel();
    _countdownTimer?.cancel();

    super.dispose();
  }
}
