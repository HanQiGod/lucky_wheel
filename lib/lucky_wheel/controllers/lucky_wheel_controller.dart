import 'dart:math';

import 'package:flutter/services.dart';

import '../utils/lucky_wheel_record.dart';

/// 抽奖控制器抽象类
abstract class LuckyWheelController {
  /// 选择奖品，返回奖品索引
  Future<int> selectPrize(List<PrizeConfig> prizes);

  /// 处理抽奖结果
  void onResult(int prizeIndex, PrizeConfig prize);
}

/// 默认抽奖控制器实现
class DefaultLuckyWheelController implements LuckyWheelController {
  @override
  Future<int> selectPrize(List<PrizeConfig> prizes) async {
    // 检查是否所有奖品都有有效的概率配置
    bool hasValidProbabilities = prizes.every((p) => p.probability != null && p.probability! > 0);

    if (hasValidProbabilities) {
      return _weightedRandomSelection(prizes);
    } else {
      // 如果没有有效的概率配置，随机选择
      return Random().nextInt(prizes.length);
    }
  }

  // 加权随机选择
  int _weightedRandomSelection(List<PrizeConfig> prizes) {
    // 过滤出有效概率的奖品
    List<PrizeConfig> validPrizes = prizes.where((p) => p.probability != null && p.probability! > 0).toList();

    if (validPrizes.isEmpty) {
      // 如果没有有效概率的奖品，随机选择
      return Random().nextInt(prizes.length);
    }

    // 计算总概率
    double totalProbability = validPrizes.fold(0.0, (sum, p) => sum + p.probability!);

    if (totalProbability <= 0) {
      // 如果总概率无效，随机选择
      return Random().nextInt(prizes.length);
    }

    // 生成随机值
    double randomValue = Random().nextDouble() * totalProbability;

    // 累积概率匹配
    double cumulativeProbability = 0.0;
    for (int i = 0; i < validPrizes.length; i++) {
      cumulativeProbability += validPrizes[i].probability!;
      if (randomValue <= cumulativeProbability) {
        // 返回原始列表中的索引
        return prizes.indexOf(validPrizes[i]);
      }
    }

    // 理论上不会到达这里，但为了安全返回随机索引
    return Random().nextInt(prizes.length);
  }


  @override
  void onResult(int prizeIndex, PrizeConfig prize) {
    print("抽奖结果: ${prize.name}");
  }
}

/// 音效控制器
class LuckyWheelSoundController {
  static const platform = MethodChannel('lucky_wheel_sound');

  static Future<void> playSpinSound() async {
    try {
      await platform.invokeMethod('playSpinSound');
    } catch (e) {
      print("音效播放失败: $e");
    }
  }

  static Future<void> playResultSound() async {
    try {
      await platform.invokeMethod('playResultSound');
    } catch (e) {
      print("音效播放失败: $e");
    }
  }
}
