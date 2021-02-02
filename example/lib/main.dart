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
  int _selectedIndex = 0;
  List<bool> isSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Fortune Wheel'),
      ),
      body: _selectedIndex == 0 ? getStandardWheel() : getRollingWheel(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_to_queue),
            label: 'Base',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rotate_left),
            label: 'Rotate',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int item) {
          setState(() {
            _selectedIndex = item;
          });
        },
      ),
    );
  }

  Widget getStandardWheel() {
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

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = Random().nextInt(items.length);
        });
      },
      child: Column(
        children: [
          Expanded(
            child: FortuneWheel(
              selected: selected,
              items: [
                for (var it in items) FortuneItem(child: Text(it)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getRollingWheel() {
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

    return Column(
      children: [
        Expanded(
          child: RollingFortuneWheel(
            selected: selected,
            items: [
              for (var it in items)
                FortuneItem(
                    style: FortuneItemStyle(
                        textStyle: TextStyle(fontWeight: FontWeight.normal),
                        color: Colors.deepPurpleAccent),
                    child: Text(it)),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.all(20),
            child: FlatButton(
                color: Colors.amber,
                onPressed: () {
                  setState(() {
                    selected = Random().nextInt(items.length);
                  });
                },
                child: Text(
                  "Launch Again",
                ))),
      ],
    );
  }
}
