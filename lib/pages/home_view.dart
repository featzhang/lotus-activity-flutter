import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:lotus_activity/components/dashboard_card.dart';
import 'package:lotus_activity/consts/all_consts.dart';
import 'package:lotus_activity/consts/work_state_name.dart';
import 'package:lotus_activity/controller/main_controller.dart';
import 'package:lotus_activity/entity/all_entities.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeViewState();
}

class HomeViewState extends State<StatefulWidget> {
  double _currentValue = 10;

  final TaskEntity currentTask = const TaskEntity("this is the first task!");
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
    var onWorkStateChanged = () => {
          setState(() {
            _stateName = mainController.getStateInfo().left;
          })
        };
    VoidCallback onWorkTimeOut = () => _doShowWorkTimeOutDialog();
    VoidCallback onRestTimeOut = () => _doShowRestTimeDialog();
    mainController =
        MainController(onWorkStateChanged, onWorkTimeOut, onRestTimeOut);
    _startTimer();
  }

  _startTimer() {
    const period = Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      mainController.onTimeCutDown();
      var newProcess = mainController.getProcess();
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
    developer.log("new slider value : " + _currentValue.round().toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotus Activity'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.yard),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
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
                        currentTask.name,
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
                children: [
                  // _buildTipCard("new card title", "30", 2),
                  const DashboardCard(
                    title: "单次最长工作",
                    body: "30",
                  ),
                  const DashboardCard(
                    title: "今日番茄数目",
                    body: "30",
                  ),
                  const DashboardCard(
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
                      onChanged: _onSliderChange,
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
                      "run",
                      Icons.double_arrow,
                      Colors.red,
                      () => _onStartButtonPressed(),
                    ),
                    _createTextButton(
                      "break",
                      Icons.power_settings_new,
                      Colors.lightGreen,
                      () => _onWeekButtonPressed(),
                    ),
                    _createTextButton(
                      "finished",
                      Icons.done,
                      Colors.lightGreen,
                      () => _onFinishButtonPressed(),
                    ),
                  ],
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

  _onSliderChange(double value) {
    setState(() {
      _currentValue = value;
    });
  }

  _onStartButtonPressed() {
    mainController.startNewTask();
  }

  _onWeekButtonPressed() {
    mainController.stopCurrentTask();
  }

  ElevatedButton _createTextButton(@required String buttonContent,
          IconData iconData, MaterialColor color, VoidCallback? callback) =>
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
    Future<Null> then = showDialog<Null>(
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
            new FlatButton(
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

  _doShowRestTimeDialog() {}
}
