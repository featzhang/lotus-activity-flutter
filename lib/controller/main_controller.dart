import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:lotus_activity/consts/all_consts.dart';
import 'package:lotus_activity/consts/la_consts.dart';
import 'package:lotus_activity/consts/work_state_name.dart';
import 'package:lotus_activity/entity/pair.dart';
import 'package:lotus_activity/entity/triple.dart';
import 'package:lotus_activity/service/work_service.dart';
import 'package:lotus_activity/utils/time_util.dart';

class MainController {
  //
  late int lastRestTimeInMillis;

  //
  late int _currentTimeCount = 0;

  //
  final double max_process = 200.0;

  //
  late WorkState _state = WorkState.notStart;

  //
  late WorkService workService;
  final VoidCallback _onWorkStateChanged;
  final VoidCallback _onWorkTimeOut;
  final VoidCallback _onRestTimeOut;

  MainController(
    this._onWorkStateChanged,
    this._onWorkTimeOut,
    this._onRestTimeOut,
  ) {
    // 上次休息时间初始化为
    lastRestTimeInMillis = DateTime.now().millisecondsSinceEpoch;
    workService = WorkService();
  }

  // 时间跳过1秒
  void onTimeCutDown() {
    if (_state == WorkState.working) {
      if (_currentTimeCount + 1 > LaConsts.maxWorkTimeInSecs) {
        _currentTimeCount = 0;
        _state = WorkState.waitRest;
        this._onWorkTimeOut();
      } else {
        _currentTimeCount += 1;
      }
    }
    if (_state == WorkState.resting) {
      if (_currentTimeCount + 1 > LaConsts.maxRestTimeInSecs) {
        _currentTimeCount = 0;
        _state = WorkState.waitRest;
        this._onRestTimeOut();
      } else {
        _currentTimeCount += 1;
      }
    }
  }

  /*
   * 时间转换为进度条process
   */
  double timeToProcess(int time) {
    if (time == 0) {
      return 0;
    }
    if (_state == WorkState.working) {
      return time / LaConsts.maxWorkTimeInSecs * max_process;
    } else if (_state == WorkState.resting) {
      return time / LaConsts.maxRestTimeInSecs * max_process;
    }
    return max_process / 2;
  }

  void startNewTask() {
    developer.log("start new task!");
    _state = WorkState.working;
    this._currentTimeCount = 0;
    this._onWorkStateChanged();
  }

  WorkState getState() {
    return _state;
  }

  Pair<String, Triple<int, int, int>> getStateInfo() {
    if (_state == WorkState.working || _state == WorkState.resting) {
      return Pair(WorkStateUtils.getName(_state),
          TimeUtil.secondToTriple(_currentTimeCount));
    }

    return Pair(WorkStateUtils.getName(_state), Triple(0, 0, 0));
  }

  String getStateInfoMinimalism() {
    Pair<String, Triple<int, int, int>> stateInfo = getStateInfo();
    var triple = stateInfo.right;
    int hour = triple.left;
    int minute = triple.middle;
    int second = triple.right;
    if (hour > 0) {
      return hour.toString() + "时";
    }
    if (minute > 0) {
      return minute.toString() + "分";
    }
    if (second > 0) {
      return second.toString() + "秒";
    }
    return "";
  }

  String getStateInfoFormatted() {
    Pair<String, Triple<int, int, int>> stateInfo = getStateInfo();
    var triple = stateInfo.right;
    String s = "";
    int hour = triple.left;
    int minute = triple.middle;
    int second = triple.right;
    if (hour > 0) {
      s += hour.toString() + "时";
    }
    if (minute > 0) {
      s += minute.toString() + "分";
    }
    if (second > 0) {
      s += second.toString() + "秒";
    }
    return s;
  }

  void stopCurrentTask() {
    developer.log("stop current task!");
    _state = WorkState.waitNewTask;
    this._onWorkStateChanged();
  }

  void finishedCurrentTask() {
    developer.log("finished current task!");
    _state = WorkState.resting;
    this._onWorkStateChanged();
  }

  double getProcess() {
    return timeToProcess(_currentTimeCount);
  }
}
