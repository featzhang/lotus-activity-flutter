import 'package:lotus_activity/entity/triple.dart';

class TimeUtil {
  static String toFormattedTime(int second) {
    String s = "";
    if (second > 3600) {
      int hour = second ~/ 3600;
      s += hour.toString() + "时\n";
    }
    if (second > 60) {
      int minute = second % 3600 ~/ 60;
      // if (minute < 10) {
      //   s += "0";
      // }
      s += minute.toString() + "分\n";
    }
    int ss = second % 60;
    if (ss < 10) {
      s += "0";
    }
    s += ss.toString() + "秒";
    return s;
  }

  static Triple<int,int,int> secondToTriple(int second) {
    int hour = 0;
    int min = 0;
    int sec = 0;
    if (second > 3600) {
      hour = second ~/ 3600;
    }
    if (second > 60) {
      min = second % 3600 ~/ 60;
    }
    sec = second % 60;
    return Triple(hour, min, sec);
  }
}
