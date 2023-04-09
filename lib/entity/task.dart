import 'dart:ffi';

class TaskEntity {
  int _id = -1;
  String _title = "";
  int _createTimeInMillis = -1;
  List<String> _tags = List.empty();
  String _desc = "";

  TaskEntity(this._title, this._createTimeInMillis);

  TaskEntity.withId(this._id, this._title, this._createTimeInMillis);

  int get id => _id;

  String get title => _title;

  List<String> get tags => _tags;

  int get createTimeInMillis => _createTimeInMillis;

  void addTag(String tag) {
    _tags.add(tag);
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['createTime'] = _createTimeInMillis;
    map['tags'] = _tags;
    map['desc'] = _desc;

    return map;
  }

  // Extract a Note object from a Map object
  TaskEntity.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._createTimeInMillis = map['createTimeInMillis'];
    this._tags = map['tags'];
    this._desc = map['desc'];
  }
}
