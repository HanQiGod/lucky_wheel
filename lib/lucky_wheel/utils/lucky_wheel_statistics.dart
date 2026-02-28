/// 抽奖统计信息
class LuckyWheelStatistics {
  final int totalSpins; // 总抽奖次数
  final int totalWins; // 总中奖次数
  final Map<String, int> prizeCounts; // 各奖品获奖次数
  final Map<String, DateTime> lastSpinTime; // 最后抽奖时间
  final int maxConsecutiveWins; // 最大连续中奖次数
  final int currentConsecutiveWins; // 当前连续中奖次数

  LuckyWheelStatistics({
    this.totalSpins = 0,
    this.totalWins = 0,
    this.prizeCounts = const {},
    this.lastSpinTime = const {},
    this.maxConsecutiveWins = 0,
    this.currentConsecutiveWins = 0,
  });

  // 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'totalSpins': totalSpins,
      'totalWins': totalWins,
      'prizeCounts': prizeCounts,
      'lastSpinTime': lastSpinTime
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
      'maxConsecutiveWins': maxConsecutiveWins,
      'currentConsecutiveWins': currentConsecutiveWins,
    };
  }

  // 从JSON格式转换
  factory LuckyWheelStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int> prizeCounts = {};
    if (json['prizeCounts'] != null) {
      prizeCounts = Map<String, int>.from(json['prizeCounts']);
    }

    Map<String, DateTime> lastSpinTime = {};
    if (json['lastSpinTime'] != null) {
      Map<String, dynamic> lastSpinTimeJson =
          Map<String, dynamic>.from(json['lastSpinTime']);
      lastSpinTime = lastSpinTimeJson.map((key, value) =>
          MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value as int)));
    }

    return LuckyWheelStatistics(
      totalSpins: json['totalSpins'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      prizeCounts: prizeCounts,
      lastSpinTime: lastSpinTime,
      maxConsecutiveWins: json['maxConsecutiveWins'] ?? 0,
      currentConsecutiveWins: json['currentConsecutiveWins'] ?? 0,
    );
  }
}
