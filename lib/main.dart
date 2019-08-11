import 'dart:math';

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
  int attributeValue = 5;
  int skillValue = 4;
  int currentResult = -1;
  bool valueJustUpdated = false;
  int tenCount = 0;

  incrementDiceCount() {
    setState(() {
      attributeValue++;
    });
  }

  decrementDiceCount() {
    setState(() {
      if (attributeValue > 0) {
        attributeValue--;
      }
    });
  }

  incrementThreshold() {
    setState(() {
      if (skillValue < 10) {
        skillValue++;
      }
    });
  }

  decrementThreshold() {
    setState(() {
      if (skillValue > 0) {
        skillValue--;
      }
    });
  }

  doRoll() {
    setState(() {
      currentResult = 0;
      tenCount = 0;
      var random = Random();
      for (int i = 0; i < attributeValue; i++) {
        int roll = random.nextInt(10) + 1;
        if (roll > 10 - skillValue) {
          currentResult++;
        }
        if(roll == 10) {
          tenCount++;
        }
        valueJustUpdated = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        valueJustUpdated = false;
      });
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
                  currentValue: attributeValue,
                  incrementFn: incrementDiceCount,
                  decrementFn: decrementDiceCount),
              Counter(
                  title: "Compétence",
                  currentValue: skillValue,
                  incrementFn: incrementThreshold,
                  decrementFn: decrementThreshold,
                  maximum: 10),
              Row(children: <Widget>[
                Expanded(
                    child: RaisedButton(
                  color: Theme.of(context).backgroundColor,
                  child: Text("Roll"),
                  onPressed: doRoll,
                ))
              ]),
              new Expanded(
                  child: Center(
                      child: AnimatedDefaultTextStyle(
                duration: new Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.display1.copyWith(
                    fontSize:
                        valueJustUpdated ? 135 : 100,
                    color: tenCount >= 3 ? Colors.green : Colors.black),
                child: Text(currentResult != -1 ? '$currentResult' : '',
                    textAlign: TextAlign.center),
              ))),
              Text(
                currentResult != -1 ? '($tenCount dix)' : '',
              ),
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
