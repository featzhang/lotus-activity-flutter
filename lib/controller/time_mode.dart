enum TimeMode {
  work(timeInSecs: 300),
  rest(timeInSecs: 300);

  final int timeInSecs;

  const TimeMode({required this.timeInSecs});
}
