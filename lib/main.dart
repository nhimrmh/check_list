import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:checklist/taskDetail.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddTask();
  }
}

class AddTask extends State<MyApp>{
  List<String> _products = [];
  TextEditingController _inputTask;
  final navigatorKey = GlobalKey<NavigatorState>();

  void moveToDetail(){
    navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => taskDetailScene()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputTask = new TextEditingController();
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
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    showDialog(context: context, child: new Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(20),
                            child: TextField(
                              decoration: InputDecoration(hintText: "Enter task name"),
                              controller: _inputTask,
                            ),
                          ),
                          RaisedButton.icon(
                              onPressed: (){
                                setState(() {
                                  Navigator.of(context).pop();
                                  _products.add(_inputTask.text);
                                });
                              },
                              icon: Icon(Icons.add),
                              label: Text("Add"))
                        ],
                      ),
                    ));
                  },
                )
              ],
            ),
            body: ListView(
                children: <Widget>[
                  Container(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20, top: 20),
                        child: RaisedButton.icon(
                            onPressed: (){
                              showDialog(context: context, child: new Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(20),
                                      child: TextField(
                                        decoration: InputDecoration(hintText: "Enter task name"),
                                        controller: _inputTask,
                                      ),
                                    ),
                                    RaisedButton.icon(
                                        onPressed: (){
                                          setState(() {
                                            Navigator.of(context).pop();
                                            _products.add(_inputTask.text);
                                          });
                                        },
                                        icon: Icon(Icons.add),
                                        label: Text("Add"))
                                  ],
                                ),
                              ));
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add new task")
                        ),
                      )
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 150,
                    child: ListView(
                      children: _products.asMap().map(
                            (id, e) => MapEntry(id, GestureDetector(
                              child: Card(
                                  margin: EdgeInsets.all(20),
                                  color: Colors.white,
                                  elevation: 5,
                                  child:
                                  Container(
                                      width: double.infinity,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                            child: LinearPercentIndicator(
                                              width: MediaQuery.of(context).size.width - 80,
                                              progressColor: Colors.green,
                                              backgroundColor: Colors.blueGrey[200],
                                              animationDuration: 2500,
                                              animation: true,
                                              percent: 0.6,
                                              center: Text("60%", style: TextStyle(color: Colors.white, fontSize: 12),),
                                              lineHeight: 16.0,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(20),
                                            child: Text(e,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.blueGrey,
                                                  fontWeight: FontWeight.w500,)
                                            ),
                                          )
                                        ],
                                      )
                                  )),
                              onTapDown: (isTapped){
                                moveToDetail();
                              },
                            ))).values.toList(),
                    ),
                  ),
                ],
              )
          );
        },
      )
    );
  }
}
