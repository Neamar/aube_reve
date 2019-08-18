import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

void main() => runApp(AubeReveApp());

class AubeReveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Aube Rêve',
        home: DiceRoller(),
        theme: ThemeData(
            primaryColor: Colors.purple, backgroundColor: Colors.purpleAccent));
  }
}

class DiceRollerState extends State<DiceRoller> {
  int attributeValue = 5;
  int skillValue = 4;
  int currentResult = -1;
  bool valueJustUpdated = false;
  int tenCount = 0;
  String rollDetails = "";

  incrementDiceCount() {
    setState(() {
      attributeValue++;
      currentResult = -1;
    });
  }

  decrementDiceCount() {
    setState(() {
      if (attributeValue > 0) {
        attributeValue--;
        currentResult = -1;
      }
    });
  }

  incrementThreshold() {
    setState(() {
      if (skillValue < 10) {
        skillValue++;
        currentResult = -1;
      }
    });
  }

  decrementThreshold() {
    setState(() {
      if (skillValue > 0) {
        skillValue--;
        currentResult = -1;
      }
    });
  }

  doRoll() {
    setState(() {
      currentResult = 0;
      tenCount = 0;
      rollDetails = "";
      var random = Random();
      for (int i = 0; i < attributeValue; i++) {
        int roll = random.nextInt(10) + 1;
        if (roll > 10 - skillValue) {
          currentResult++;
        }
        if (roll == 10) {
          tenCount++;
        }

        rollDetails += roll.toString() + ", ";
      }

      valueJustUpdated = true;
      rollDetails = rollDetails.substring(0, rollDetails.length - 2);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        valueJustUpdated = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var tree = <Widget>[
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
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Text("Roll"),
          onPressed: doRoll,
        ))
      ]),
    ];

    if (currentResult != -1) {
      tree.addAll(<Widget>[
        Expanded(
            child: Center(
                child: AnimatedDefaultTextStyle(
          duration: new Duration(milliseconds: 200),
          style: Theme.of(context).textTheme.display1.copyWith(
              fontSize: valueJustUpdated ? 135 : 100,
              color: tenCount >= 3 ? Colors.purpleAccent : Colors.black),
          child: Text('$currentResult', textAlign: TextAlign.center),
        ))),
        Text((tenCount >= 3 ? ' CRITIQUE' : ''),
            style: TextStyle(
              color: Colors.purpleAccent,
            )),
        Text(rollDetails,
            style: TextStyle(
              fontSize: 8,
            )),
      ]);
    } else {
      tree.add(SimpleBarChart(
        DiceRollStat.createDiceData(attributeValue, skillValue / 10),
        animate: true,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Lancer de dés Aube Rêve"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: tree),
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
        children: <Widget>[
          RaisedButton(
            onPressed: currentValue > 0 ? decrementFn : null,
            child: const Text('-'),
          ),
          Expanded(
            child: Text(
              '$currentValue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display2,
            ),
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

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: new charts.BarChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec: charts.BasicNumericTickProviderSpec(
              desiredTickCount: 5,
            ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec((n) => n.round().toString() + "%"),
        viewport: charts.NumericExtents(0, 100)
      ),
    ));
  }
}

/// Sample ordinal data type.
class DiceRollStat {
  static int factorial(int n) {
    return n == 0 ? 1 : n * factorial(n - 1);
  }

  static double getStats(
      int diceCount, double successProbability, int expectedSuccess) {
    return factorial(diceCount) /
        (factorial(expectedSuccess) * factorial(diceCount - expectedSuccess)) *
        pow(successProbability, expectedSuccess) *
        pow(1 - successProbability, diceCount - expectedSuccess);
  }

  static List<charts.Series<DiceRollStat, String>> createDiceData(
      int diceCount, double successProbability) {
    final List<DiceRollStat> data = [];
    for (int i = 0; i <= diceCount; i++) {
      data.add(new DiceRollStat(
          i.toString(), getStats(diceCount, successProbability, i)));
    }

    return [
      new charts.Series<DiceRollStat, String>(
        id: 'Stats',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (DiceRollStat diceStat, _) => diceStat.success,
        measureFn: (DiceRollStat diceStat, _) => 100 * diceStat.proba,
        data: data,
      )
    ];
  }

  final String success;
  final double proba;

  DiceRollStat(this.success, this.proba);
}
