import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class taskDetailScene extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TaskDetail();
  }
}

class _TaskDetail extends State<taskDetailScene>{
  TextEditingController _inputTaskDetail;
  List<String> _taskDetail = [];
  List<bool> checkValue = [];
  int count = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputTaskDetail = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                        decoration: InputDecoration(hintText: "Enter detail"),
                        controller: _inputTaskDetail,
                      ),
                    ),
                    RaisedButton.icon(
                        onPressed: (){
                          setState(() {
                            Navigator.of(context).pop();
                            _taskDetail.add(_inputTaskDetail.text);
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: ListView(
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
                                  decoration: InputDecoration(hintText: "Enter detail name"),
                                  controller: _inputTaskDetail,
                                ),
                              ),
                              RaisedButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      Navigator.of(context).pop();
                                      _taskDetail.add(_inputTaskDetail.text);
                                      checkValue.add(false);
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("Add"))
                            ],
                          ),
                        ));
                      },
                      icon: Icon(Icons.add),
                      label: Text("Add new detail")
                  ),
                )
            ),
            Container(
              height: MediaQuery.of(context).size.height - 150,
              child: ListView(
                children: _taskDetail.asMap().map(
                      (id, e) => MapEntry(id, GestureDetector(
                        child: Card(
                            margin: EdgeInsets.all(20),
                            color: Colors.white,
                            elevation: 5,
                            child:
                            Container(
                                width: double.infinity,
                                child: CheckboxListTile(
                                  onChanged: (isChecked){
                                    setState(() {
                                      checkValue[id] = isChecked;
                                    });
                                  },
                                  title: Text(e),
                                  value: checkValue.elementAt(id),
                                )
                            )),
                        onTapDown: (isTapped){},
                      ))).values.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}