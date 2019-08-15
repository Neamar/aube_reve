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
      var random = Random();
      for (int i = 0; i < attributeValue; i++) {
        int roll = random.nextInt(10) + 1;
        if (roll > 10 - skillValue) {
          currentResult++;
        }
        if (roll == 10) {
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
          child: Text(currentResult != -1 ? '$currentResult' : '',
              textAlign: TextAlign.center),
        ))),
        Text(
            currentResult != -1 && tenCount >= 2
                ? ('($tenCount dix)' + (tenCount >= 3 ? ' CRITIQUE' : ''))
                : '',
            style: TextStyle(
              color: tenCount >= 3 ? Colors.purpleAccent : Colors.black,
            )),
      ]);
    } else {
      tree.add(SimpleBarChart.withSampleData());
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

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return new SimpleBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
            child: new charts.BarChart(
              seriesList,
              animate: animate,
           ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
