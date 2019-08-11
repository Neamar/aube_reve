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
  int diceCount = 5;
  int successThreshold = 4;
  int currentResult = -1;

  incrementDiceCount() {
    setState(() {
      diceCount++;
    });
  }

  decrementDiceCount() {
    setState(() {
      if (diceCount > 0) {
        diceCount--;
      }
    });
  }

  incrementThreshold() {
    setState(() {
      if (successThreshold < 10) {
        successThreshold++;
      }
    });
  }

  decrementThreshold() {
    setState(() {
      if (successThreshold > 0) {
        successThreshold--;
      }
    });
  }

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
              Counter(
                  title: "Caractéristique",
                  currentValue: diceCount,
                  incrementFn: incrementDiceCount,
                  decrementFn: decrementDiceCount),
              Counter(
                  title: "Compétence",
                  currentValue: successThreshold,
                  incrementFn: incrementThreshold,
                  decrementFn: decrementThreshold,
                  maximum: 10),
              new Expanded(
                  child: Center(
                child: Text('$currentResult',
                    style: Theme.of(context).textTheme.display4,
                    textAlign: TextAlign.center),
              ))
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
  final incrementFn;
  final decrementFn;
  final title;
  final currentValue;
  final maximum;

  Counter(
      {@required this.title,
      @required this.currentValue,
      @required this.incrementFn,
      @required this.decrementFn,
      this.maximum = 50});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(
        '$title',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.75),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            onPressed: currentValue > 0 ? decrementFn : null,
            child: const Text('-'),
          ),
          Text(
            '$currentValue',
            textWidthBasis: ,
            style: Theme.of(context).textTheme.display2,
          ),
          RaisedButton(
            onPressed: currentValue < maximum ? incrementFn : null,
            child: const Text('+', style: TextStyle(fontSize: 20)),
          ),
        ],
      )
    ]);
  }
}
