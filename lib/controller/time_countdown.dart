import 'package:lotus_activity/controller/time_mode.dart';

import 'countdown_observer.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// 计时
class TimeCountdown {
  TimeCountdown(this.countDownObserver);

  static const Duration period = Duration(seconds: 1);

  late Timer _timer;
  late TimeMode timeMode;
  late bool _isRunning = false;
  late int _secondsRemaining;

  CountDownObserver countDownObserver;

  // 初始化
  void init(TimeMode timeMode) {
    this.timeMode = timeMode;
    this._isRunning = false;
    this._secondsRemaining = timeMode.timeInSecs;
    if (!_isRunning && _secondsRemaining != 0) {
      _isRunning = true;
      start();
    } else {
      developer.debugger(message: "Already running");
    }
  }

  /// 开始计时
  void start() {
    this._isRunning = true;
    _timer = Timer(period, () {
      _secondsRemaining -= 1;
      countDownObserver.update(_secondsRemaining);
      if (_secondsRemaining <= 0) {
        countDownObserver.onTimeout();
      }
      this._isRunning = false;
      _timer.cancel();
    });
  }

  // 停止计时
  void stop() {
    if (_isRunning) {
      _isRunning = false;
      _timer.cancel();
    }
  }

  // 重新计时
  void reset() {
    _secondsRemaining = timeMode.timeInSecs;
    countDownObserver.update(_secondsRemaining);
  }

  // 取消
  void close() {
    _isRunning = false;
    _timer.cancel();
  }
}
