import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aube Rêve',
      home: DiceRoller(),
    );
  }
}

class DiceRollerState extends State<DiceRoller> {
  final _diceCount = 5;
  final _successThreshold = 4;
  final _currentResult = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lancer de dés Aube Rêve"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Counter("Caractéristique", _diceCount),
              Counter("Compétence", _successThreshold),
              new Expanded(
                child: Center(
                  child: Text('$_currentResult',
                    style: Theme.of(context).textTheme.display4,
                    textAlign: TextAlign.center),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DiceRoller extends StatefulWidget {
  @override
  DiceRollerState createState() => DiceRollerState();
}

class Counter extends StatelessWidget {
  final title;
  final currentValue;

  Counter(@required this.title, @required this.currentValue);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: <Widget>[
      Text('$title'),
      Text(
        '$currentValue',
        style: Theme.of(context).textTheme.display2,
      ),
    ]);
  }
}
