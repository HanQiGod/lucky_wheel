import 'package:flutter/cupertino.dart';

/// 多阶段曲线动画类
class MultiCurveAnimation extends Animation<double> {
  final AnimationController controller;
  final Duration startDuration;
  final Duration middleDuration;
  final Duration endDuration;
  final Curve startCurve;
  final Curve middleCurve;
  final Curve endCurve;
  final double startAngleRatio;
  final double middleAngleRatio;
  final double endAngleRatio;
  final double targetValue; // 目标值，通过构造函数传入

  MultiCurveAnimation({
    required this.controller,
    required this.startDuration,
    required this.middleDuration,
    required this.endDuration,
    required this.startCurve,
    required this.middleCurve,
    required this.endCurve,
    required this.startAngleRatio,
    required this.middleAngleRatio,
    required this.endAngleRatio,
    required this.targetValue,
  });

  @override
  AnimationStatus get status => controller.status;

  @override
  double get value {
    Duration totalDuration = controller.duration!;
    double controllerValue = controller.value;

    double startRatio =
        startDuration.inMilliseconds / totalDuration.inMilliseconds;
    double middleRatio =
        middleDuration.inMilliseconds / totalDuration.inMilliseconds;
    double endRatio = endDuration.inMilliseconds / totalDuration.inMilliseconds;

    if (controllerValue <= startRatio) {
      // 开始阶段
      if (startRatio == 0) return controller.value;
      double phaseProgress = controllerValue / startRatio;
      double curvedProgress = startCurve.transform(phaseProgress);
      return controller.value +
          (targetValue - controller.value) * curvedProgress * startAngleRatio;
    } else if (controllerValue <= startRatio + middleRatio) {
      // 中间阶段
      double phaseProgress = (controllerValue - startRatio) / middleRatio;
      double curvedProgress = middleCurve.transform(phaseProgress);
      double startValue = startRatio == 0
          ? controller.value
          : controller.value +
              (targetValue - controller.value) *
                  startCurve.transform(1.0) *
                  startAngleRatio;
      return startValue +
          (targetValue - startValue) * curvedProgress * middleAngleRatio;
    } else {
      // 结束阶段
      double phaseProgress =
          (controllerValue - startRatio - middleRatio) / endRatio;
      double curvedProgress = endCurve.transform(phaseProgress);
      double middleValue = startRatio == 0 && middleRatio == 0
          ? controller.value
          : controller.value +
              (targetValue - controller.value) *
                  (startCurve.transform(1.0) * startAngleRatio +
                      middleCurve.transform(1.0) * middleAngleRatio);
      return middleValue +
          (targetValue - middleValue) * curvedProgress * endAngleRatio;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    controller.removeListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    controller.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    controller.removeStatusListener(listener);
  }
}
