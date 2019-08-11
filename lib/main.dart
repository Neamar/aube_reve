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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(children: <Widget>[
              Text('Caractéristique'),
              Text(
                '$_diceCount',
                style: Theme.of(context).textTheme.display2,
              ),
            ]),
            Column(children: <Widget>[
              Text('Compétence'),
              Text(
                '$_successThreshold',
                style: Theme.of(context).textTheme.display2,
              ),
            ]),
            Text(
              '$_currentResult',
              style: Theme.of(context).textTheme.display4,
            ),
          ],
        ),
      ),
    );
  }
}

class DiceRoller extends StatefulWidget {
  @override
  DiceRollerState createState() => DiceRollerState();
}
