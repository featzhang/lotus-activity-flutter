/*
 * 状态切换: not_start -> wait_new_task -> working -> breakup -> wait_rest -> resting
 */
enum WorkState {
  // 未开始，初始状态
  notStart,
  // 等待新任务：
  waitNewTask,
  // 工作中
  working,
  // 被打断
  breaking,
  // 等待休息确认
  waitRest,
  // 休息中
  resting,
}
