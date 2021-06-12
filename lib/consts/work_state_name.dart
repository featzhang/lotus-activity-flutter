import 'package:lotus_activity/consts/work_state.dart';

class WorkStateUtils {
  static String getName(WorkState workState) {
    switch (workState) {
      case WorkState.notStart:
        return "未开始行动";
      case WorkState.waitNewTask:
        return "等待新任务";
      case WorkState.resting:
        return "休息中";
      case WorkState.working:
        return "工作中";
      case WorkState.breaking:
        return "被打断";
      case WorkState.waitRest:
        return "等待休息";
      default:
        return "未知";
    }
  }
}
