import 'dart:math' show Random;

import 'package:flutter/material.dart';

import 'lucky_wheel/controllers/lucky_wheel_controller.dart';
import 'lucky_wheel/lucky_wheel_widget.dart';
import 'lucky_wheel/utils/lucky_wheel_record.dart';
import 'lucky_wheel/utils/lucky_wheel_theme.dart';

class LuckyWheelPage extends StatefulWidget {
  const LuckyWheelPage({super.key});

  @override
  State<LuckyWheelPage> createState() => _FlipCardPageState();
}

class _FlipCardPageState extends State<LuckyWheelPage> {
  @override
  Widget build(BuildContext context) {
    return LuckyWheelWidget(
      dailySpinLimit: 1000,
      enableWheelHighlight: false,
      prizeConfigs: [
        PrizeConfig(name: "一等奖", color: Colors.red, probability: 0.01),
        PrizeConfig(name: "二等奖", color: Colors.blue, probability: 0.02),
        PrizeConfig(name: "三等奖", color: Colors.black87, probability: 0.3),
        PrizeConfig(name: "四等奖", color: Colors.green, probability: 0.1),
        PrizeConfig(name: "谢谢惠顾", color: Colors.orange, probability: 0.4),
        PrizeConfig(name: "五等奖", color: Colors.purple, probability: 0.36),
      ],
      theme: LuckyWheelTheme(
        textColor: Colors.black87,
        appBarTextColor: Colors.black87,
        appBarColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      controller: CustomLuckyWheelController(), // 使用自定义控制器
      onResult: (index) {
        print("抽奖结果: $index");
      },
    );
  }
}

// 自定义抽奖控制器示例
class CustomLuckyWheelController implements LuckyWheelController {
  @override
  Future<int> selectPrize(List<PrizeConfig> prizes) async {
    await Future.delayed(Duration(seconds: 1));

    // 实现加权随机选择算法（类似默认控制器的实现）
    double totalProbability = prizes.where((p) => p.probability != null && p.probability! > 0).fold(0.0, (sum, p) => sum + p.probability!);

    if (totalProbability <= 0) {
      return Random().nextInt(prizes.length);
    }

    double randomValue = Random().nextDouble() * totalProbability;
    double cumulativeProbability = 0.0;

    for (int i = 0; i < prizes.length; i++) {
      if (prizes[i].probability != null && prizes[i].probability! > 0) {
        cumulativeProbability += prizes[i].probability!;
        if (randomValue <= cumulativeProbability) {
          return i;
        }
      }
    }

    return Random().nextInt(prizes.length);
  }

  @override
  void onResult(int prizeIndex, PrizeConfig prize) {
    print("用户中奖: ${prize.name}");
  }
}

