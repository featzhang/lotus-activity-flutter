import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'package:timelines/timelines.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lotus_activity/components/dashboard_card.dart';
import 'package:lotus_activity/consts/all_consts.dart';
import 'package:lotus_activity/consts/work_state_name.dart';
import 'package:lotus_activity/controller/main_controller.dart';
import 'package:lotus_activity/entity/all_entities.dart';
import 'package:system_tray/system_tray.dart';

class PomodoroView extends StatefulWidget {
  const PomodoroView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PomodoroViewState();
}

class PomodoroViewState extends State<StatefulWidget> {
  double _currentValue = 10;

  final TaskEntity currentTask = TaskEntity(
      "this is the first task!", DateTime.now().millisecondsSinceEpoch);
  List<TaskEntity> taskList = List.empty(growable: true);
  late String _stateName = WorkStateUtils.getName(WorkState.notStart);
  late String _stateTimeInCard = "";

  late Timer _timer;

  /// 上次休息时间
  late int lastWeakUpTime;
  late MainController mainController;
  late bool taskNameEditEnable = true;

  @override
  void initState() {
    super.initState();
    onWorkStateChanged() => {
          setState(() {
            _stateName = mainController.getStateInfo().left;
          })
        };
    onWorkTimeOut() => _doShowWorkTimeOutDialog();
    onRestTimeOut() => _doShowRestTimeDialog();
    mainController =
        MainController(onWorkStateChanged, onWorkTimeOut, onRestTimeOut);
    _startTimer();
    initSystemTray();
  }

  _startTimer() {
    const period = Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      mainController.countdown();
      double newProcess = mainController.getProcess();
      if (newProcess != _currentValue) {
        developer.log("sliderValue: " +
            _currentValue.toString() +
            "=>" +
            newProcess.toString());
        setState(() {
          _currentValue = mainController.getProcess();
        });
      }
      var stateInfo = mainController.getStateInfo();
      var newStateName = stateInfo.left;

      if (newStateName != _stateName) {
        setState(() {
          _stateName = newStateName;
        });
      }
      //
      String newStateTimeInCard = mainController.getStateInfoMinimalism();
      String newStateTimeDetail = mainController.getStateInfoFormatted();
      //
      if (newStateTimeInCard != _stateTimeInCard) {
        setState(() {
          _stateTimeInCard = newStateTimeInCard;
        });
        developer.log(
            "matchedState: " + newStateTimeInCard + "\t" + newStateTimeDetail);
        if (newStateTimeDetail != _stateTime) {
          setState(() {
            _stateTime = newStateTimeDetail;
          });
        }
      }
    });
  }

  late String _stateTime = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotus Activity'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.yard),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'This is a snackbar, which is used to show tap message!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Next page'),
                    ),
                    body: Center(
                      child: Text(
                        currentTask.title,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.lightGreenAccent,
          child: Column(
            children: <Widget>[
              Wrap(
                children: const [
                  // _buildTipCard("new card title", "30", 2),
                  DashboardCard(
                    title: "单次最长工作",
                    body: "30",
                  ),
                  DashboardCard(
                    title: "今日番茄数目",
                    body: "30",
                  ),
                  DashboardCard(
                    title: "今日计划代办",
                    body: "30",
                  ),
                  // _buildTipCard(_stateName, _stateTimeInCard, 3),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'work content',
                    enabled: taskNameEditEnable,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(_stateName),
                  Expanded(
                    child: Slider(
                      value: _currentValue,
                      max: 200,
                      min: 0,
                      label: _currentValue.round().toString(),
                      onChanged: (d) => {},
                      // do nothing
                      activeColor: Colors.red,
                      divisions: 200,
                    ),
                  ),
                  Text(
                    _stateTime,
                  ),
                ],
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _createTextButton(
                      "Start",
                      Icons.double_arrow,
                      Colors.red,
                      () => _onStartButtonPressed(),
                    ),
                    _createTextButton(
                      "Break",
                      Icons.power_settings_new,
                      Colors.lightGreen,
                      () => _onRestButtonPressed(),
                    ),
                    _createTextButton(
                      "Done",
                      Icons.done,
                      Colors.lightGreen,
                      () => _onFinishButtonPressed(),
                    ),
                  ],
                ),
              ),
              Row(
                children: const [
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
              Center(
                child: SizedBox(
                  height: 400,
                  child: Timeline.tileBuilder(
                    builder: TimelineTileBuilder.fromStyle(
                      contentsAlign: ContentsAlign.basic,
                      indicatorStyle: IndicatorStyle.outlined,
                      connectorStyle: ConnectorStyle.dashedLine,
                      addSemanticIndexes: false,
                      addRepaintBoundaries: false,
                      oppositeContentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text("Catalog"),
                            Text(
                              taskList[index].createTimeInMillis.toString(),
                            ),
                          ],
                        ),
                      ),
                      contentsBuilder: (context, index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(taskList[index].title),
                        ),
                      ),
                      itemCount: taskList.length,
                    ),
                  ),
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  _onStartButtonPressed() {
    mainController.startNewTask();
  }

  _onRestButtonPressed() {
    mainController.stopCurrentTask();
  }

  ElevatedButton _createTextButton(String buttonContent, IconData iconData,
          MaterialColor color, VoidCallback? callback) =>
      ElevatedButton(
        onPressed: callback,
        child: Column(
          children: <Widget>[
            Icon(
              iconData,
              size: 40,
            ),
            Text(
              buttonContent,
              // style: TextStyle(color: color),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  _onFinishButtonPressed() {
    mainController.finishedCurrentTask();
  }

  void _doShowWorkTimeOutDialog() {
    setState(() {
      developer.log("add new task to list start...");
      taskList.add(currentTask);
      developer.log("add new task to list done...");
    });
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '工作时间到!',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('内容 1'),
                new Text('内容 2'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: new Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app.png';

    final AppWindow appWindow = AppWindow();
    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      MenuSeparator(),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  _doShowRestTimeDialog() {}
}
