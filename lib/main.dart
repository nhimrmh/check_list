import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:appchecklist/taskDetail.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'LocalFile.dart';
import 'taskDetailFile.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String listItems;
List<int> checkCount, totalCount;
List<ItemList> tempListMain, allList, _itemsList_temp;
TaskList listTask;
bool isEmpty;
TextEditingController _inputTask;
AnimationController controller;
Animation<Offset> offset, freezeOffset;
List<bool> isClicked = [];

List<String> choices = [
  'Rename',
  'Delete'
];

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddTask();
  }
}

enum DraggingMode {
  iOS,
  Android,
}

class AddTask extends State<MyApp> with SingleTickerProviderStateMixin {
  ItemList _itemsList;
  static int index = 0;
  String app_bar_main = "Remaining";
  int doneCount = 0, remainCount = 0;
  bool isShowAll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputTask = new TextEditingController();
    //updateDataWithSetState();
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
  }

  int _indexOfKey(Key key) {
    return listTask.list.indexWhere((ItemList d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = listTask.list[draggingIndex];
    setState(() {
      debugPrint("Reordering $item -> $newPosition");
      listTask.list.removeAt(draggingIndex);
      listTask.list.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = listTask.list[_indexOfKey(item)];
    debugPrint("Reordering finished for ${draggedItem.title}}");
    saveList();
  }

  void saveList() async {
    var json = jsonEncode(listTask.toJson());
    await taskDetailFile.writeContent(json.toString());
    updateData();
  }

  DraggingMode _draggingMode = DraggingMode.iOS;

  void addData() async {
    _itemsList = new ItemList(
        title: _inputTask.text,
        date: DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString(),
        percent: 0,
        list: []
    );

    if(isEmpty == false) {
      listTask.list.add(_itemsList);
      //await updateData();
    }
    else {
      if(tempListMain != null) {
        tempListMain.clear();
        tempListMain.add(_itemsList);
      }
      else {
        tempListMain = new List<ItemList>();
        tempListMain.add(_itemsList);
      }
      listTask = new TaskList(list: tempListMain);
    }

    var json = jsonEncode(listTask.toJson());
    await taskDetailFile.writeContent(json.toString());
    updateData();
  }

  void setStateFunction() {
    setState(() {

    });
  }

  Future updateData() async {
    projectIdx = 0;
    tempIdx = 0;
    isEmpty = false;
    _inputTask = new TextEditingController();

    tempListMain = new List<ItemList>();
    _itemsList_temp = new List<ItemList>();
    allList = new List<ItemList>();
    checkCount = new List<int>();
    totalCount = new List<int>();

    doneCount = 0;
    remainCount = 0;

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

          if(element["taskPercent"] == 1){
            doneCount++;
          }
          else{
            remainCount++;
          }

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
          tempIdx++;
          checkCount.add(tempCount);
          totalCount.add(data.length);
        });

        for(int i = 0; i < _itemsList_temp.length; i++){
          allList.add(_itemsList_temp.elementAt(i));
        }

        setState(() {
          listTask = new TaskList(list: allList);
          for(int i = 0; i < listTask.list.length; i++){
            isClicked.add(false);
          }
        });
        return;
      }
      else {
        isEmpty = true;
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context){
            return Scaffold(
                appBar: AppBar(
                  title: Text(app_bar_main),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: (){
                        _inputTask = new TextEditingController();
                        _inputTask.text = "";
                        showDialog(context: context, child: new Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                  child: Text(
                                    "Add new project",
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
                                margin: EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLength: null,
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: "Enter project name",
                                    contentPadding: EdgeInsets.only(bottom: 5),
                                    isDense: true,
                                  ),
                                  controller: _inputTask,
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
                                elevation: 0,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ));
                      },
                    )
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.blue[700],
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white70,
                  currentIndex: index,
                  onTap: (value) => setState(() {
                    index = value;
                    app_bar_main = (index == 0 ? "Remaining" : "Done");
                  }),
                  items: [
                    BottomNavigationBarItem(
                        icon: new Icon(Icons.home),
                        title: new Text("Remaining")
                    ),
                    BottomNavigationBarItem(
                        icon: new Icon(Icons.assignment),
                        title: new Text("Done")
                    ),
                  ],
                ),
                body: _getBody(context, index),
            );
          },
        )
    );
  }

  Widget _getBody(BuildContext context, int index){
    switch(index){
      case 0: return remainPage(context);
      case 1: return donePage();
      default: return remainPage(context);
    }
  }

  Widget remainPage(BuildContext context){
    return Stack(
      children: <Widget>[
        Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.blueGrey[50],
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5, top: 5, left: 10),
                        child: RaisedButton.icon(
                          onPressed: (){
                            _inputTask = new TextEditingController();
                            _inputTask.text = "";
                            showDialog(context: context, child: new Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                      child: Text(
                                        "Add new project",
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
                                    margin: EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
                                    child: TextField(
                                      keyboardType: TextInputType.multiline,
                                      maxLength: null,
                                      maxLines: null,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        hintText: "Enter project name",
                                        contentPadding: EdgeInsets.only(bottom: 5),
                                        isDense: true,
                                      ),
                                      controller: _inputTask,
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
                                    elevation: 0,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ));
                          },
                          icon: Icon(Icons.add, color: Colors.teal[700]),
                          label: Text("Add new project", style: TextStyle(fontSize: 18),),
                          color: Colors.blueGrey[50],
                          elevation: 0,
                        ),
                      )
                  ),
                ),
                (isShowAll == true && (remainCount > 0 || doneCount > 0)) ?
                Expanded(
                  child: ReorderableList(
                    onReorder: this._reorderCallback,
                    onReorderDone: this._reorderDone,
                    child: CustomScrollView(
                      // cacheExtent: 3000,
                      slivers: <Widget>[
                        SliverPadding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(navigatorKey.currentContext).padding.bottom),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Item(
                                        data: listTask.list[index],
                                        // first and last attributes affect border drawn during dragging
                                        isFirst: index == 0,
                                        isLast: index == listTask.list.length - 1,
                                        draggingMode: _draggingMode,
                                        index: index,
                                        function: updateData,
                                        setStateFunction: setStateFunction,
                                      );
                                },
                                childCount: listTask != null ? listTask.list != null ? listTask.list.length : 0: 0,
                              ),
                            )),
                      ],
                    ),
                  ),
                ) :
                remainCount > 0 ?
                Expanded(
                  child: ReorderableList(
                    onReorder: this._reorderCallback,
                    onReorderDone: this._reorderDone,
                    child: CustomScrollView(
                      // cacheExtent: 3000,
                      slivers: <Widget>[
                        SliverPadding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(navigatorKey.currentContext).padding.bottom),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  if(listTask.list[index].percent < 1) return Item(
                                    data: listTask.list[index],
                                    // first and last attributes affect border drawn during dragging
                                    isFirst: index == 0,
                                    isLast: index == listTask.list.length - 1,
                                    draggingMode: _draggingMode,
                                    index: index,
                                    function: updateData,
                                    setStateFunction: setStateFunction,
                                  );
                                  else return Container(
                                    width: 0,
                                    height: 0,
                                  );
                                },
                                childCount: listTask != null ? listTask.list != null ? listTask.list.length : 0: 0,
                              ),
                            )),
                      ],
                    ),
                  ),
                ) :
                Expanded(
                    child: Center(
                        child: Container(
                            transform: Matrix4.translationValues(0, -29, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.event_busy,
                                  color: Colors.blueGrey[200],
                                  size: 100,
                                ),
                                Text(
                                  "Nothing here",
                                  style: TextStyle(
                                      color: Colors.blueGrey[200],
                                      fontSize: 30
                                  ),
                                ),
                              ],
                            )
                        )
                    )
                )
              ],
            )
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: 5, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  transform: Matrix4.translationValues(5, 0, 0),
                  child: Text(
                    "View all",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 16),
                  ),
                ),
                Checkbox(
                  value: isShowAll,
                  activeColor: Colors.green,
                  onChanged: (isChecked){
                    setState(() {
                      isShowAll = isChecked;
                    });
                  },
                ),
              ],
            )
          )
        )
      ],
    );
  }

  Widget donePage(){
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blueGrey[50],
        child: Column(
          children: <Widget>[
            doneCount > 0 ?
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ReorderableList(
                  onReorder: this._reorderCallback,
                  onReorderDone: this._reorderDone,
                  child: CustomScrollView(
                    // cacheExtent: 3000,
                    slivers: <Widget>[
                      SliverPadding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(navigatorKey.currentContext).padding.bottom),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                if(listTask.list[index].percent == 1) return Item(
                                  data: listTask.list[index],
                                  // first and last attributes affect border drawn during dragging
                                  isFirst: index == 0,
                                  isLast: index == listTask.list.length - 1,
                                  draggingMode: _draggingMode,
                                  index: index,
                                  function: updateData,
                                  setStateFunction: setStateFunction,
                                );
                                else return Container(
                                  width: 0,
                                  height: 0,
                                );
                              },
                              childCount: listTask != null ? listTask.list != null ? listTask.list.length : 0: 0,
                            ),
                          )),
                    ],
                  ),
                )
              )
            ) :
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.event_busy,
                      color: Colors.blueGrey[200],
                      size: 100,
                    ),
                    Text(
                      "Nothing here",
                      style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontSize: 30
                      ),
                    ),
                  ],
                )
              )
            )
          ],
        )
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

  final ItemList data;
  final bool isFirst;
  final bool isLast;
  final DraggingMode draggingMode;
  int index;
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

    Widget content = GestureDetector(
      onTap: () async {
        await navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => taskDetailScene(data.title, index)));
        function();
      },
      child: Container(
        child: SlideTransition(
          position: isClicked.length > index ? isClicked.elementAt(index) == true ? offset : freezeOffset : freezeOffset,
          child: Opacity(
              opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 2,
                      child: SafeArea(
                          top: false,
                          bottom: false,
                          child: Column(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 0, left: 20, right: 10),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              child: Container(
                                                child: Text(data.title, style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500
                                                ),),
                                              )
                                          ),
                                          Center(
                                              child: GestureDetector(
                                                  onTap: (){
                                                    _inputTask.text = data.title;
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
                                                                hintText: "Enter project name",
                                                                contentPadding: EdgeInsets.only(bottom: 5),
                                                                isDense: true,
                                                              ),
                                                              controller: _inputTask,
                                                            ),
                                                          ),
                                                          RaisedButton.icon(
                                                            onPressed: () async {
                                                              listTask.list.elementAt(index).title = _inputTask.text;
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
                                                  child: Padding(
                                                      padding: EdgeInsets.only(right: 10, left: 10),
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                      )
                                                  )
                                              )
                                          )
                                        ],
                                      ),
                                    )
                                  )
                              ),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 0, left: 20, right: 10, bottom: 0),
                                child: Row(
                                  children: <Widget>[
                                    Text(data.date + " - ", style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey[300]
                                    ),),
                                    Text(data.list.length.toString() + " task(s)", style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey[300]
                                    ),),
                                  ],
                                )
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5, bottom: 15),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20, right: 20),
                                        child: LinearPercentIndicator(
                                          progressColor: listTask.list.elementAt(index).percent != null ? listTask.list.elementAt(index).percent == 1 ?
                                          Colors.green : Colors.redAccent : Colors.redAccent,
                                          backgroundColor: Colors.blueGrey[100],
                                          animation: false,
                                          percent: listTask.list.elementAt(index).percent != null ? listTask.list.elementAt(index).percent : 0,
                                          center: Text(
                                            listTask.list.elementAt(index).percent != null ? (listTask.list.elementAt(index).percent * 100).round().toString() + "%" : "0%",
                                            style: TextStyle(color: Colors.white, fontSize: 12),),
                                          lineHeight: 16.0,
                                        ),
                                      ),
                                    ),
                                    dragHandle,
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 20, right: 0, top: 0, bottom: 5),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            transform: Matrix4.translationValues(0, 0, 0),
                            child: Container(
                                margin: EdgeInsets.only(left: 0, right: 10, top: 0, bottom: 15),
                                child: GestureDetector(
                                    onTap: () {
                                      isClicked[index] = true;
                                      setStateFunction();
                                      controller.forward();
                                      Future.delayed(Duration(milliseconds: 700), () async {
                                        controller.reset();
                                        isClicked[index] = false;
                                        setStateFunction();
                                        listTask.list.removeAt(index);
                                        var json = jsonEncode(listTask.toJson());
                                        await taskDetailFile.writeContent(json.toString());
                                        function();
                                      });
                                    },
                                    child: Container(
                                      child: Container(
                                        margin: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.close, color: Color(0xFF888888), size: 20,
                                        ),
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
                      )
                  )
                ],
              )
          )
        )
      ),
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
