import 'package:appchecklist/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'taskDetailFile.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'dart:convert';

String listItems;
String jsonTaskList;
List<ItemList> tempListMain, allList, _itemsList_temp;
TaskList listTask;
int tempIdx;
bool isExist, isEmpty;
List<int> checkCount, totalCount;
TextEditingController _inputTaskDetail;

class taskNoteScene extends StatefulWidget{
  String project;
  int idx, projectIdx;
  taskNoteScene(this.project, this.idx, this.projectIdx);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TaskNote(project, idx, projectIdx);
  }
}

class ItemData {
  ItemData({this.title, this.key, this.isChecked, this.createdDate, this.note});
  String title;
  bool isChecked;
  String createdDate;
  String note;
  final Key key;

  Map<String, dynamic> toJson() =>
      {
        'task': title,
        'isChecked': isChecked,
        'taskDate': createdDate,
        'taskNote': note,
      };

  factory ItemData.fromJson(Map<String, dynamic> json){
    return new ItemData(
        title: json['task'],
        isChecked: json['isChecked'],
        createdDate: json['taskDate'],
        note: json['taskNote']
    );
  }
}

enum DraggingMode {
  iOS,
  Android,
}

class _TaskNote extends State<taskNoteScene> {
  List<bool> checkValue = [];
  int count = 0;
  String project;
  int idx, projectIdx;
  double topMargin = 145;

  bool isEditing = false;

  TextEditingController _inputNote;

  _TaskNote(this.project, this.idx, this.projectIdx);

  void saveList() async {
    var json = jsonEncode(listTask.toJson());
    await taskDetailFile.writeContent(json.toString());
    updateData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputNote = new TextEditingController();
    _inputNote.text = listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ?
      listTask.list.elementAt(projectIdx).list.elementAt(idx).note : "" : "";
    updateData();
  }

  Future updateData() async {
    tempIdx = 0;
    isExist = false;
    isEmpty = false;
    _inputTaskDetail = new TextEditingController();

    tempListMain = new List<ItemList>();
    _itemsList_temp = new List<ItemList>();
    allList = new List<ItemList>();
    checkCount = new List<int>();
    totalCount = new List<int>();
    taskDetailFile.readContent().then((String value) {
      if(value != null && value.trim() != ""){
        listItems = value;
        var json = jsonDecode(listItems);
        final data = json["projectList"];
        List<dynamic> jsonList = data;

        jsonList.forEach((element) {
          int tempCount = 0;
          final data = element["taskList"];

          ItemList temp = ItemList.fromJson(element as Map<String,dynamic>);

          _itemsList_temp.add(new ItemList(title: element["taskTitle"], date: element["taskDate"], list: [], key: UniqueKey(), percent: element["taskPercent"]));

          for(int i = 0; i < data.length; i++){
            _itemsList_temp.elementAt(tempIdx).list.add(
              new ItemData(
                title: temp.list.elementAt(i).title,
                key: UniqueKey(),
                isChecked: temp.list.elementAt(i).isChecked,
                createdDate: temp.list.elementAt(i).createdDate,
                note: temp.list.elementAt(i).note
              )
            );
            if(temp.list.elementAt(i).isChecked == true) tempCount++;
          }
          checkCount.add(tempCount);
          totalCount.add(data.length);

          if(tempIdx == idx){
            isExist = true;
          }
          tempIdx++;
        });

        for(int i = 0; i < _itemsList_temp.length; i++){
          allList.add(_itemsList_temp.elementAt(i));
        }

        setState(() {
          listTask = new TaskList(list: allList);
          isEditing = false;
        });
        return;
      }
      else {
        isExist = false;
        isEmpty = true;
        return;
      }
    });
  }

  Future updateData_noSetState() async {
    tempIdx = 0;
    isExist = false;
    isEmpty = false;
    _inputTaskDetail = new TextEditingController();
    _inputNote = new TextEditingController();
    tempListMain = new List<ItemList>();
    _itemsList_temp = new List<ItemList>();
    allList = new List<ItemList>();
    checkCount = new List<int>();
    totalCount = new List<int>();
    taskDetailFile.readContent().then((String value) {
      if(value != null && value.trim() != ""){
        listItems = value;
        var json = jsonDecode(listItems);
        final data = json["projectList"];
        List<dynamic> jsonList = data;

        jsonList.forEach((element) {
          int tempCount = 0;
          final data = element["taskList"];

          ItemList temp = ItemList.fromJson(element as Map<String,dynamic>);

          _itemsList_temp.add(new ItemList(title: element["taskTitle"], date: element["taskDate"], list: [], key: UniqueKey(), percent: element["taskPercent"]));

          for(int i = 0; i < data.length; i++){
            _itemsList_temp.elementAt(tempIdx).list.add(
                new ItemData(
                    title: temp.list.elementAt(i).title,
                    key: UniqueKey(),
                    isChecked: temp.list.elementAt(i).isChecked,
                    createdDate: temp.list.elementAt(i).createdDate,
                    note: temp.list.elementAt(i).note
                )
            );
            if(temp.list.elementAt(i).isChecked == true) tempCount++;
          }
          checkCount.add(tempCount);
          totalCount.add(data.length);

          if(tempIdx == idx){
            isExist = true;
          }
          tempIdx++;
        });

        for(int i = 0; i < _itemsList_temp.length; i++){
          allList.add(_itemsList_temp.elementAt(i));
        }

        listTask = new TaskList(list: allList);
        _inputNote.text = listTask.list.elementAt(projectIdx).list.length > idx ? listTask?.list?.elementAt(projectIdx)?.list?.elementAt(idx)?.note ?? "" : "";
        isEditing = false;
        return;
      }
      else {
        isExist = false;
        isEmpty = true;
        return;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(project),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){

            },
          )
        ],
      ),
      body: isEditing == true
      ? Container(
        height: double.infinity,
        width: double.infinity,
        child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Checkbox(
                            activeColor: Colors.green,
                            value: listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ? listTask.list.elementAt(projectIdx).list.elementAt(idx).isChecked : false : false,
                            onChanged: (isChecked) async {
                              listTask.list.elementAt(projectIdx).list.elementAt(idx).isChecked = isChecked;
                              if(isChecked == true) listTask.list.elementAt(projectIdx).percent += 1/listTask.list.elementAt(projectIdx).list.length;
                              else listTask.list.elementAt(projectIdx).percent -= 1/listTask.list.elementAt(projectIdx).list.length;
                              var json = jsonEncode(listTask.toJson());
                              await taskDetailFile.writeContent(json.toString());
                              updateData();
                            }
                        ),
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Text(project, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        _inputTaskDetail.text = listTask.list.elementAt(projectIdx).list.elementAt(idx).title;
                                        showDialog(context: context, child: new Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                width: double.infinity,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                                  child: Text(
                                                    "Change task name",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.blueGrey[700]
                                                    ),
                                                  ),
                                                ),
                                                color: Colors.blueGrey[200],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
                                                child: TextField(
                                                  keyboardType: TextInputType.multiline,
                                                  maxLength: null,
                                                  maxLines: null,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  decoration: InputDecoration(
                                                    hintText: "Enter task name",
                                                    contentPadding: EdgeInsets.only(bottom: 5),
                                                    isDense: true,
                                                  ),
                                                  controller: _inputTaskDetail,
                                                ),
                                              ),
                                              RaisedButton.icon(
                                                onPressed: () async {
                                                  project = _inputTaskDetail.text;
                                                  listTask.list.elementAt(projectIdx).list.elementAt(idx).title = _inputTaskDetail.text;
                                                  var json = jsonEncode(listTask.toJson());
                                                  await taskDetailFile.writeContent(json.toString());
                                                  Navigator.pop(context);
                                                  updateData();
                                                },
                                                icon: Icon(Icons.edit),
                                                label: Text("Change"),
                                                color: Colors.white,
                                                elevation: 0,
                                              ),
                                            ],
                                          ),
                                        ));
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Icon(
                                            Icons.edit, size: 20,
                                          )
                                      )
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                transform: Matrix4.translationValues(0, -5, 0),
                                child: Text(listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ? listTask.list.elementAt(projectIdx).list.elementAt(idx).createdDate
                                    : "No date yet" : "No date yet", style: TextStyle(fontSize: 14, color: Colors.blueGrey[300]),),
                              ),
                            )
                          ],
                        )
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: TextField(
                        controller: _inputNote,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        maxLength: null,
                        decoration: InputDecoration(
                          labelText: "Task note",
                          hintText: "Enter you note",
                          contentPadding: EdgeInsets.only(bottom: 5),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton.icon(
                          elevation: 0,
                          color: Colors.blueGrey[50],
                          onPressed: (){
                            setState(() {
                              isEditing = false;
                            });
                          },
                          icon: Icon(Icons.close, color: Colors.redAccent),
                          label: Text("Cancel", style: TextStyle(fontSize: 18),)
                      ),
                      RaisedButton.icon(
                          elevation: 0,
                          color: Colors.blueGrey[50],
                          onPressed: (){
                            listTask.list.elementAt(projectIdx).list.elementAt(idx).note = _inputNote.text;
                            saveList();
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Your note have been saved!"),
                                  duration: Duration(seconds: 2),
                                )
                            );
                          },
                          icon: Icon(Icons.save, color: Colors.teal[700]),
                          label: Text("Save", style: TextStyle(fontSize: 18),)
                      )
                    ],
                  ),
                )
              ],
            )
        ),
        color: Colors.blueGrey[50],
      )
      : Container(
        height: double.infinity,
        width: double.infinity,
        child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Checkbox(
                            activeColor: Colors.green,
                            value: listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ? listTask.list.elementAt(projectIdx).list.elementAt(idx).isChecked : false : false,
                            onChanged: (isChecked) async {
                              listTask.list.elementAt(projectIdx).list.elementAt(idx).isChecked = isChecked;
                              if(isChecked == true) listTask.list.elementAt(projectIdx).percent += 1/listTask.list.elementAt(projectIdx).list.length;
                              else listTask.list.elementAt(projectIdx).percent -= 1/listTask.list.elementAt(projectIdx).list.length;
                              var json = jsonEncode(listTask.toJson());
                              await taskDetailFile.writeContent(json.toString());
                              updateData();
                            }
                        ),
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Text(project, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        _inputTaskDetail.text = listTask.list.elementAt(projectIdx).list.elementAt(idx).title;
                                        showDialog(context: context, child: new Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                width: double.infinity,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                                  child: Text(
                                                    "Change task name",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.blueGrey[700]
                                                    ),
                                                  ),
                                                ),
                                                color: Colors.blueGrey[200],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
                                                child: TextField(
                                                  keyboardType: TextInputType.multiline,
                                                  maxLength: null,
                                                  maxLines: null,
                                                  textCapitalization: TextCapitalization.sentences,
                                                  decoration: InputDecoration(
                                                    hintText: "Enter task name",
                                                    contentPadding: EdgeInsets.only(bottom: 5),
                                                    isDense: true,
                                                  ),
                                                  controller: _inputTaskDetail,
                                                ),
                                              ),
                                              RaisedButton.icon(
                                                onPressed: () async {
                                                  project = _inputTaskDetail.text;
                                                  listTask.list.elementAt(projectIdx).list.elementAt(idx).title = _inputTaskDetail.text;
                                                  var json = jsonEncode(listTask.toJson());
                                                  await taskDetailFile.writeContent(json.toString());
                                                  Navigator.pop(context);
                                                  updateData();
                                                },
                                                icon: Icon(Icons.edit),
                                                label: Text("Change"),
                                                color: Colors.white,
                                                elevation: 0,
                                              ),
                                            ],
                                          ),
                                        ));
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Icon(
                                            Icons.edit, size: 20,
                                          )
                                      )
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                transform: Matrix4.translationValues(0, -5, 0),
                                child: Text(listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ? listTask.list.elementAt(projectIdx).list.elementAt(idx).createdDate
                                    : "No date yet" : "No date yet", style: TextStyle(fontSize: 14, color: Colors.blueGrey[300]),),
                              ),
                            )
                          ],
                        )
                    )
                  ],
                ),
                Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: listTask != null ? listTask.list.elementAt(projectIdx).list.length > idx ? (listTask.list.elementAt(projectIdx).list.elementAt(idx).note != null && listTask.list.elementAt(projectIdx).list.elementAt(idx).note.trim() != "")
                          ? Container(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.note,
                                    color: Colors.blueGrey[200],
                                    size: 50,
                                  ),
                                  Divider(
                                    thickness: 2,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                      listTask.list.elementAt(projectIdx).list.elementAt(idx).note,
                                      style: TextStyle(fontSize: 16),
                                    )
                                  )
                                ],
                              )
                          ),
                        ),
                      )
                          : Container(
                          width: double.infinity,
                          child: Container(
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.block,
                                            color: Colors.blueGrey[200],
                                            size: 50,
                                          ),
                                          Divider(
                                            thickness: 2,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Nothing here",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                        ],
                                      )
                                  )
                              )
                          )
                      )
                          : Container(
                          width: double.infinity,
                          child: Container(
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.block,
                                            color: Colors.blueGrey[200],
                                            size: 50,
                                          ),
                                          Divider(
                                            thickness: 2,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Nothing here",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                        ],
                                      )
                                  )
                              )
                          )
                      )
                          : Container(
                          width: double.infinity,
                          child: Container(
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.block,
                                            color: Colors.blueGrey[200],
                                            size: 50,
                                          ),
                                          Divider(
                                            thickness: 2,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Nothing here",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                        ],
                                      )
                                  )
                              )
                          )
                      ),
                    )
                ),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton.icon(
                            elevation: 0,
                            color: Colors.blueGrey[50],
                            onPressed: (){
                              listTask.list.elementAt(projectIdx).list.elementAt(idx).note = "";
                              saveList();
                            },
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            label: Text("Clear", style: TextStyle(fontSize: 18),)
                        ),
                        RaisedButton.icon(
                            elevation: 0,
                            color: Colors.blueGrey[50],
                            onPressed: (){
                              setState(() {
                                isEditing = true;
                              });
                            },
                            icon: Icon(Icons.edit, color: Colors.teal[700]),
                            label: Text("Edit", style: TextStyle(fontSize: 18),)
                        )
                      ],
                    )
                )
              ],
            )
        ),
        color: Colors.blueGrey[50],
      ),
    );
  }
}

class TaskList {
  final List<ItemList> list;
  TaskList({this.list});

  Map<String, dynamic> toJson() =>
      {
        'projectList': list,
      };

  factory TaskList.fromJson(Map<String, dynamic> json){
    List<ItemList> entireList = new List<ItemList>();
    entireList = json['projectList'].map((i)=>ItemList.fromJson(i)).toList();
    return TaskList(
      list: entireList,
    );
  }
}

class ItemList {
  String title;
  final String date;
  final List<ItemData> list;
  double percent;
  Key key;

  ItemList({this.title, this.list, this.date, this.key, this.percent});

  Map<String, dynamic> toJson() =>
      {
        'taskTitle': title,
        'taskDate': date,
        'taskList': list,
        'taskPercent': percent,
      };

  factory ItemList.fromJson(Map<String, dynamic> json){
    List<ItemData> entireList = new List<ItemData>();
    List<dynamic> temp = json['taskList'];
    entireList = temp.map((i)=>ItemData.fromJson(i)).toList();
    return ItemList(
      title: json['taskTitle'],
      date: json['taskDate'],
      percent: json['taskPercent'],
      list: entireList,
    );
  }
}
