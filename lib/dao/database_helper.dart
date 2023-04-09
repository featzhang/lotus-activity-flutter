import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:lotus_activity/entity/task.dart';

/// 共创建三个表:
/// 1.  task_entity: 保存记录(taskId, title, createTime, desc)
/// 2.  task_tag: 保存tag(tagId, tag)
/// 3.  task_tag_ref： 保存task与tag的关联关系(refId,tagId,taskId)
class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._internal(); // Singleton DatabaseHelper

  String taskTable = 't_task';
  String tagTable = 't_tag';
  String refTable = 't_tag_ref';
  String colId = 'id';
  String colTitle = 'title';
  String colTag = 'tag';
  String colTagId = 'tagId';
  String colTaskId = 'taskId';
  String colRef = 'ref';
  String colDescription = 'desc';
  String colDate = 'createTime';

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._internal(); // Named constructor to create instance of DatabaseHelper

  Future<Database> get database async {
    return await initializeDatabase();
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'lag.db';

    // Open/create the database at a given path
    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colDate INTEGER)');
    await db.execute(
        'CREATE TABLE $tagTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate INTEGER)');
    await db.execute(
        'CREATE TABLE $refTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTaskId INTEGER, $colTagId INTEGER, $colDate INTEGER)');
  }

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await database;

//		var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');

    String sql='''
    select 
    t.id,t.title,t.desc,t.createTime,concat(tt.tag, ';') as tags
    from t_task t 
    left join t_tag_ref tf on t.id = tf.taskId 
    left join t_tag tt left join tf.tagId = tt.id 
    group by t.id,t.title,t.desc,t.createTime
    ''';
    List<Map<String, Object?>> list = await db.rawQuery(sql);
    return list;
  }

  // Insert Operation: Insert a todo object to database
  Future<int> insertTodo(TaskEntity task) async {
    Database db = await database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateTodo(TaskEntity todo) async {
    var db = await database;
    var result = await db.update(taskTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result;
  }

  Future<int> updateTodoCompleted(TaskEntity todo) async {
    var db = await database;
    var result = await db.update(taskTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result;
  }

  // Delete Operation: Delete a todo object from database
  Future<int> deleteTodo(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $taskTable WHERE $colId = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int?> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $taskTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<TaskEntity> ]
  Future<List<TaskEntity>> getTodoList() async {
    var todoMapList = await getTodoMapList(); // Get 'Map List' from database
    int count =
        todoMapList.length; // Count the number of map entries in db table

    List<TaskEntity> todoList = List.empty(growable: true);
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(TaskEntity.fromMapObject(todoMapList[i]));
    }

    return todoList;
  }
}
