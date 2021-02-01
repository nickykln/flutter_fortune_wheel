import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune Wheel Example',
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      'Grogu',
      'Mace Windu',
      'Obi-Wan Kenobi',
      'Han Solo',
      'Luke Skywalker',
      'Darth Vader',
      'Yoda',
      'Ahsoka Tano',
      'Luke Skywalker',
      'Darth Vader',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Fortune Wheel'),
      ),
      body: Column(
        children: [
          FlatButton(
              onPressed: () {
                setState(() {
                  selected = Random().nextInt(items.length);
                });
              },
              child: Text(
                "restart",
              )),
          Expanded(
            child: RollingFortuneWheel(
              selected: selected,
              items: [
                for (var it in items)
                  FortuneItem(
                      style: FortuneItemStyle(
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          color: Colors.deepPurpleAccent),
                      child: Text(it)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
