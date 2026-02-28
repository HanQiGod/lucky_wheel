import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lucky_wheel_record.dart';
import '../utils/lucky_wheel_statistics.dart';

/// 抽奖历史记录管理器
class LuckyWheelHistoryManager {
  static const String _prefsKey = 'lucky_wheel_history';
  static const String _statsKey = 'lucky_wheel_stats';
  static const String _limitsKey = 'lucky_wheel_limits';

  // 获取所有历史记录
  static Future<List<LuckyWheelRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey) ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => LuckyWheelRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // 添加新的历史记录
  static Future<void> addRecord(LuckyWheelRecord record) async {
    final records = await getHistory();
    records.add(record);
    await saveHistory(records);
  }

  // 保存历史记录
  static Future<void> saveHistory(List<LuckyWheelRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        json.encode(records.map((record) => record.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  // 清空历史记录
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  // 获取统计信息
  static Future<LuckyWheelStatistics> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statsKey);
    if (jsonString == null) {
      return LuckyWheelStatistics();
    }
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return LuckyWheelStatistics.fromJson(jsonMap);
  }

  // 更新统计信息
  static Future<void> updateStatistics({
    required int prizeIndex,
    required PrizeConfig prize,
    required bool isWinning,
  }) async {
    final stats = await getStatistics();
    final newTotalSpins = stats.totalSpins + 1;
    final newTotalWins = isWinning ? stats.totalWins + 1 : stats.totalWins;

    // 更新奖品获奖次数
    final newPrizeCounts = Map<String, int>.from(stats.prizeCounts);
    newPrizeCounts[prize.name] = (newPrizeCounts[prize.name] ?? 0) + 1;

    // 更新最后抽奖时间
    final newLastSpinTime = Map<String, DateTime>.from(stats.lastSpinTime);
    newLastSpinTime[prize.name] = DateTime.now();

    // 更新连续中奖次数
    final newCurrentConsecutiveWins =
        isWinning ? stats.currentConsecutiveWins + 1 : 0;
    final newMaxConsecutiveWins =
        newCurrentConsecutiveWins > stats.maxConsecutiveWins
            ? newCurrentConsecutiveWins
            : stats.maxConsecutiveWins;

    final updatedStats = LuckyWheelStatistics(
      totalSpins: newTotalSpins,
      totalWins: newTotalWins,
      prizeCounts: newPrizeCounts,
      lastSpinTime: newLastSpinTime,
      maxConsecutiveWins: newMaxConsecutiveWins,
      currentConsecutiveWins: newCurrentConsecutiveWins,
    );

    await saveStatistics(updatedStats);
  }

  // 保存统计信息
  static Future<void> saveStatistics(LuckyWheelStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(stats.toJson());
    await prefs.setString(_statsKey, jsonString);
  }

  // 清空统计信息
  static Future<void> clearStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }

  // 获取抽奖次数限制
  static Future<int> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_limitsKey) ?? 0; // 0表示无限制
  }

  // 设置每日抽奖次数限制
  static Future<void> setDailyLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_limitsKey, limit);
  }

  // 获取今日抽奖次数
  static Future<int> getTodaySpins() async {
    final records = await getHistory();
    final today = DateTime.now();

    return records.where((record) {
      return record.timestamp.day == today.day &&
          record.timestamp.month == today.month &&
          record.timestamp.year == today.year;
    }).length;
  }

  // 检查是否已达到今日抽奖次数限制
  static Future<bool> isDailyLimitReached() async {
    final dailyLimit = await getDailyLimit();
    if (dailyLimit == 0) return false; // 无限制

    final todaySpins = await getTodaySpins();
    return todaySpins >= dailyLimit;
  }
}
