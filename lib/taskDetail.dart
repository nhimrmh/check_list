import 'package:appchecklist/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'taskDetailFile.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'dart:convert';
import 'taskNote.dart';

String listItems;
String jsonTaskList;
List<ItemList> tempListMain, allList, _itemsList_temp;
TaskList listTask;
ItemList _itemsList;
int projectIdx, tempIdx;
bool isExist, isEmpty, isEnabled = true;
List<int> checkCount, totalCount;
AnimationController controller;
Animation<Offset> offset, freezeOffset;
Animation marginAnimation;
List<bool> isClicked = [];
TextEditingController _inputTaskDetail;

class taskDetailScene extends StatefulWidget{
  String project;
  int idx;

  taskDetailScene(this.project, this.idx);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TaskDetail(project, idx);
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

class _TaskDetail extends State<taskDetailScene> with SingleTickerProviderStateMixin {
  List<bool> checkValue = [];
  int count = 0;
  String project;
  int idx;
  bool isScrolling = false;

  _TaskDetail(this.project, this.idx);

  int _indexOfKey(Key key) {
    return listTask.list.elementAt(projectIdx).list.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = listTask.list.elementAt(projectIdx).list[draggingIndex];
    setState(() {
      debugPrint("Reordering $item -> $newPosition");
      listTask.list[projectIdx].list.removeAt(draggingIndex);
      listTask.list[projectIdx].list.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = listTask.list.elementAt(projectIdx).list[_indexOfKey(item)];
    debugPrint("Reordering finished for ${draggedItem.title}}");
    saveList();
  }

  void saveList() async {
    var json = jsonEncode(listTask.toJson());
    await taskDetailFile.writeContent(json.toString());
    updateData();
  }

  DraggingMode _draggingMode = DraggingMode.iOS;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateData();

    controller = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(-2.0, 0.0))
        .animate(CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut
    ));

    freezeOffset = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut
    ));

    marginAnimation = Tween(
      begin: 150,
      end: 85,
    ).animate(controller);

  }

  void addData() async {
    String tempDate = DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString();
    _itemsList = new ItemList(title: project, list: listTask.list.elementAt(projectIdx).list);
    if(tempListMain != null) tempListMain.clear();
    tempListMain.add(_itemsList);

    if(isExist == true){
      listTask.list.elementAt(projectIdx).list.add(ItemData(title: _inputTaskDetail.text, key: UniqueKey(), isChecked: false, createdDate: tempDate));
    }
    else{
      if(isEmpty == false) {
        listTask.list.add(_itemsList);
      }
      else{
        listTask = new TaskList(list: tempListMain);
      }
    }
    listTask.list.elementAt(projectIdx).percent = (checkCount.elementAt(projectIdx) != null && totalCount[projectIdx] != null) ? checkCount.elementAt(projectIdx)/(totalCount[projectIdx] + 1) : 0;
    var json = jsonEncode(listTask.toJson());
    await taskDetailFile.writeContent(json.toString());
    updateData();
  }

  void setStateFunction(){
    setState(() {
      isEnabled = false;
    });
  }

  Future updateData() async {
    projectIdx = 0;
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
            projectIdx = tempIdx;
          }
          tempIdx++;
        });

        for(int i = 0; i < _itemsList_temp.length; i++){
          allList.add(_itemsList_temp.elementAt(i));
        }

        setState(() {
          listTask = new TaskList(list: allList);
          for(int i = 0; i < listTask.list.elementAt(projectIdx).list.length; i++){
            isClicked.add(false);
          }
          isEnabled = true;
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
              _inputTaskDetail = new TextEditingController();
              _inputTaskDetail.text = "";
              showDialog(context: context, child: new Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        child: Text(
                          "Add new task",
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
                      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
                      onPressed: () {
                        addData();
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text("Add"),
                      color: Colors.white,
                      elevation: 0,
                    )
                  ],
                ),
              ));
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: 140),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Container(
                            child: RaisedButton.icon(
                              onPressed: (){
                                _inputTaskDetail = new TextEditingController();
                                _inputTaskDetail.text = "";
                                showDialog(context: context, child: new Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                          child: Text(
                                            "Add new task",
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
                                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
                                        onPressed: () {
                                          if(isEnabled == true){
                                            addData();
                                            setState(() {
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.add),
                                        label: Text("Add"),
                                        color: Colors.white,
                                        elevation: 0,
                                      )
                                    ],
                                  ),
                                ));
                              },
                              icon: Icon(Icons.add, color: isEnabled == true ? Colors.teal[700] : Colors.blueGrey[50], size: isEnabled == true ? 25 : 0,),
                              label: Text(isEnabled == true ? "Add new task" : "...", style: TextStyle(fontSize: 18),),
                              color: Colors.white,
                              elevation: 0,
                            ),
                          )
                      ),
                      Expanded(
                        child: ReorderableList(
                          onReorder: this._reorderCallback,
                          onReorderDone: this._reorderDone,
                          child: CustomScrollView(
                            // cacheExtent: 3000,
                            slivers: <Widget>[
                              SliverPadding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        return Item(
                                          data: listTask.list.elementAt(projectIdx).list[index],
                                          // first and last attributes affect border drawn during dragging
                                          isFirst: index == 0,
                                          isLast: index == listTask.list.elementAt(projectIdx).list.length - 1,
                                          draggingMode: _draggingMode,
                                          index: index,
                                          function: updateData,
                                          setStateFunction: setStateFunction,
                                        );
                                      },
                                      childCount: listTask?.list?.elementAt(projectIdx)?.list?.length ?? 0,
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Container(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: CircularPercentIndicator(
                              radius: 60.0,
                              lineWidth: 10.0,
                              animation: true,
                              backgroundColor: Colors.blueGrey[100],
                              progressColor: (
                                  checkCount.length > projectIdx && totalCount.length > projectIdx ? checkCount[projectIdx]/totalCount[projectIdx] == 1 ? Colors.green : Colors.redAccent : Colors.redAccent
                              ),
                              center: Container(
                                child: Text(
                                  (checkCount.length > projectIdx && totalCount.length > projectIdx ?
                                  totalCount[projectIdx] > 0 ? ((checkCount[projectIdx]/totalCount[projectIdx])*100).round().toString() + "%" :
                                  "0%" : "0%"),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                transform: Matrix4.translationValues(1, 0, 0),
                              ),
                              percent: (checkCount.length > projectIdx && totalCount.length > projectIdx ? totalCount[projectIdx] > 0 ? checkCount[projectIdx]/totalCount[projectIdx] : 0 : 0),
                            ),
                            margin: EdgeInsets.only(right: 20, top: 10),
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
                                              _inputTaskDetail.text = listTask.list.elementAt(projectIdx).title;
                                              showDialog(context: context, child: new Dialog(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      width: double.infinity,
                                                      child: Container(
                                                        margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                                        child: Text(
                                                          "Change project name",
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
                                                        listTask.list.elementAt(projectIdx).title = _inputTaskDetail.text;
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
                                      child: Text(listTask != null ? listTask.list.elementAt(projectIdx).date.toString() : "", style: TextStyle(fontSize: 14, color: Colors.blueGrey[300]),),
                                    ),
                                  )
                                ],
                              )
                          )
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 0, bottom: 0),
                          child: Divider(
                              thickness: 3,
                              color: Colors.blueGrey[50]
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text("Number of task", style: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),),
                                      ),
                                      Text(
                                          (totalCount.length > projectIdx) ? totalCount[projectIdx].toString() : "0",
                                          style: TextStyle(
                                              fontSize: 14
                                          )
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text("Done", style: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),),
                                      ),
                                      Text(
                                          (checkCount.length > projectIdx) ? checkCount[projectIdx].toString() : "0",
                                          style: TextStyle(
                                              fontSize: 14
                                          )
                                      ),
                                    ],
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text("Remaining", style: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),),
                                      ),
                                      Text(
                                          (checkCount.length > projectIdx && totalCount.length > projectIdx) ? (totalCount[projectIdx]-checkCount[projectIdx]).toString() : "0",
                                          style: TextStyle(
                                              fontSize: 14
                                          )
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          )
                      )
                    ],
                  )
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1,
                        spreadRadius: 0,
                        offset: Offset(
                            1,
                            1
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
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

class Item extends StatelessWidget {

  Item({
    this.data,
    this.isFirst,
    this.isLast,
    this.draggingMode,
    this.index,
    this.function,
    this.setStateFunction
  });

  final ItemData data;
  final bool isFirst;
  final bool isLast;
  final DraggingMode draggingMode;
  final int index;
  Function function, setStateFunction;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {

    Widget dragHandle = draggingMode == DraggingMode.iOS
        ? ReorderableListener(
            child: Container(
              padding: EdgeInsets.only(right: 18.0, left: 0.0),
              color: Colors.white,
              child: Center(
                child: Icon(Icons.reorder, color: Color(0xFF888888)),
              ),
            ),
          )
        : Container();

    Widget content = Container(
      margin: EdgeInsets.only(top: index == 0 ? 10 : 0, bottom: index == listTask.list.elementAt(projectIdx).list.length - 1 ? 10 : 0),
      child: SlideTransition(
            position: isClicked.length > index ? isClicked.elementAt(index) == true ? offset : freezeOffset : freezeOffset,
            child: Opacity(
                opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 2),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 1,
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => taskNoteScene(data.title, index, projectIdx)));
                                    function();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 15),
                                    color: Colors.white,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Text(listTask.list.elementAt(projectIdx).list.elementAt(index).title, style: TextStyle(fontSize: 16),),
                                                    ),
                                                    GestureDetector(
                                                        onTap: (){
                                                          _inputTaskDetail.text = listTask.list.elementAt(projectIdx).list.elementAt(index).title;
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
                                                                    listTask.list.elementAt(projectIdx).list.elementAt(index).title = _inputTaskDetail.text;
                                                                    var json = jsonEncode(listTask.toJson());
                                                                    await taskDetailFile.writeContent(json.toString());
                                                                    Navigator.pop(context);
                                                                    function();
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
                                                          margin: EdgeInsets.only(left: 5, right: 10),
                                                          child: Icon(Icons.edit, size: 15,),
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(top: 5),
                                                  width: double.infinity,
                                                  child: Text(listTask.list.elementAt(projectIdx).list.elementAt(index).createdDate?.toString()??"No date yet", style: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),),
                                                )
                                              ],
                                            )
                                          )
                                        ),
                                        SizedBox(
                                          width: 30,
                                          height: 48,
                                          child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            child: Checkbox(
                                              activeColor: Colors.green,
                                              onChanged: (isChecked) async {
                                                listTask.list.elementAt(projectIdx).list.elementAt(index).isChecked = isChecked;
                                                if(isChecked == true) listTask.list.elementAt(projectIdx).percent += 1/listTask.list.elementAt(projectIdx).list.length;
                                                else listTask.list.elementAt(projectIdx).percent -= 1/listTask.list.elementAt(projectIdx).list.length;
                                                //listTask = new TaskList(list: _itemsList_temp);
                                                var json = jsonEncode(listTask.toJson());
                                                await taskDetailFile.writeContent(json.toString());
                                                function();
                                              },
                                              value: listTask.list.elementAt(projectIdx).list.elementAt(index).isChecked,
                                            ),
                                          )
                                        )
                                      ],
                                    )
                                  ),
                                )
                              ),
                              dragHandle,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20, right: 10, top: 3, bottom: 2),
                        child: GestureDetector(
                            onTap: () {
                              isClicked[index] = true;
                              setStateFunction();
                              controller.forward();
                              Future.delayed(Duration(milliseconds: 700), () async {
                                controller.reset();
                                isClicked[index] = false;
                                setStateFunction();
                                bool isChecked = listTask.list.elementAt(projectIdx).list.elementAt(index).isChecked;
                                listTask.list.elementAt(projectIdx).list.removeAt(index);
                                totalCount[projectIdx]--;
                                if(isChecked == true) checkCount[projectIdx]--;

                                listTask.list.elementAt(projectIdx).percent = totalCount[projectIdx] != 0 ? checkCount[projectIdx]/totalCount[projectIdx] : 0;
                                var json = jsonEncode(listTask.toJson());
                                await taskDetailFile.writeContent(json.toString());
                                function();
                              });
                            },
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  child: Container(
                                    margin: EdgeInsets.all(3),
                                    child: Icon(Icons.close, color: Color(0xFF888888), size: 18,),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Color(0xFF888888), width: 1.5),
                                      shape: BoxShape.circle
                                  ),
                                )
                            )
                        )
                    )
                  ],
                )
            )
        )
    );

    if (draggingMode == DraggingMode.Android) {
      content = DelayedReorderableListener(
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: data.key, //
        childBuilder: _buildChild);
  }
}