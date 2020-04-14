import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      home: Builder(
        builder: (context){
          return Scaffold(
              body: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height - 100,
                    child: ListView(
                      children: _products.map((e) => Card(
                          margin: EdgeInsets.only(top: 15, bottom: 15),
                          color: Colors.white,
                          elevation: 10,
                          child:
                          Container(
                            width: double.infinity,
                            child: Row(
                              //mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 0, top: 15, right: 0, bottom: 15),
                                  child: Icon(Icons.alarm, size: 30, color: Colors.blueGrey[200],),
                                ),
                                Text(e,
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,)
                                ),
                                Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.red,
                                ),

                              ],
                            ),
                          )),).toList(),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.all(20),
                    child: RaisedButton.icon(
                        onPressed: (){
                          setState(() {
                            _products.add("nhan");
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text("Add new task")
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
