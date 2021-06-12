import 'package:flutter/material.dart';
import 'package:lotus_activity/utils/color_util.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key? key,
    @required this.title = "DashTitle",
    @required this.body = "DashBody",
  }) : super(key: key);

  final String title;
  final String body;
  double adaptFontSizeByText(String body) {
    double fontSize = 20;
    int fontCnt = body.length;
    if (fontCnt == 3) {
      fontSize = 40;
    } else if (fontCnt == 2) {
      fontSize = 50;
    } else if (fontCnt == 1) {
      fontSize = 60;
    }
    return fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
          color: ColorsUtil.hexColor(0xFFFFCC),
          border: Border.all(
            color: ColorsUtil.hexColor(0x6666CC),
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            //卡片阴影
            BoxShadow(
                color: ColorsUtil.hexColor(0x999966),
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0)
          ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurpleAccent),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  body,
                  style: TextStyle(
                      fontSize: adaptFontSizeByText(body),
                      fontWeight: FontWeight.w200,
                      color: ColorsUtil.hexColor(0xFF9966)),
                )
              ],
            ),
          ),
        ],
      ),
      transform: Matrix4.rotationZ(.01), //卡片倾斜变换
    );
  }
}
