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

  List<Choice> history = <Choice>[];

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
		//if skill == 3; 7, 8, 9 and 10 are successes. 1 is always a failure
        if (roll >= 10 - skillValue && roll != 1) {
          currentResult++;
        }
		//10 counts for critics. if skillvalue = 11, 9 counts too
        if (roll == 10 || (skillValue > 10 && roll >= 20 - skillValue)) {
          tenCount++;
        }

        rollDetails += roll.toString() + ", ";
      }

      valueJustUpdated = true;
      rollDetails = rollDetails.substring(0, rollDetails.length - 2);

      // Add to history
      history.insert(0, Choice(attributeValue: attributeValue, skillValue: skillValue, result: currentResult));
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
        Text((tenCount >= 3 ? ' CRITIQUE ($tenCount)' : ''),
            style: TextStyle(
              color: Colors.purpleAccent,
            )),
        Text(rollDetails,
            style: TextStyle(
              fontSize: 8,
            )),
      ]);
    } else {
      List<charts.Series> seriesValues =
          DiceRollStat.createDiceData(attributeValue, skillValue / 10);
      double critProba = 1;
      if (attributeValue < 3) {
        critProba = 0;
      } else {
        for (int i = 0; i < 3; i++) {
          critProba -= DiceRollStat.getStats(attributeValue, 1 / 10, i);
        }
      }

      tree.add(SimpleBarChart(
        seriesValues,
        critProba,
      ));
    }

    List<Widget> actions = [];
    if(history.length > 0) {
      actions = [
        PopupMenuButton<Choice>(
          icon: Icon(Icons.history),
          onSelected: _selectOldChoice,
          itemBuilder: (BuildContext context) {
            return history.map((Choice choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: Theme.of(context).textTheme.body1,
                    children: <TextSpan>[
                      TextSpan(text: choice.getName()),
                      TextSpan(text: ' '),
                      new TextSpan(text: choice.getResult(), style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12, color: Colors.black26)),
                    ],
                  ),
                )
              );
            }).toList();
          },
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Lancer de dés Aube Rêve"),
        actions: actions,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: tree),
        ),
      ),
    );
  }

  void _selectOldChoice(Choice choice) {
    setState(() {
      attributeValue = choice.attributeValue;
      skillValue = choice.skillValue;
      currentResult = -1;
    });
  }
}


class Choice {
  const Choice({this.attributeValue, this.skillValue, this.result});

  final int attributeValue;
  final int skillValue;

  final int result;

  String getName() {
    return attributeValue.toString() + ' / ' + skillValue.toString();
  }

  String getResult() {
    return '(' + result.toString() + ')';
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
  final double critProba;

  SimpleBarChart(this.seriesList, this.critProba);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: new charts.BarChart(
      seriesList,
      animate: true,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: 5,
          ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
              (n) => n == 100 ? '100' : (n.round().toString() + "%")),
          viewport: charts.NumericExtents(0, 100)),
      behaviors: [
        new charts.ChartTitle(
            'Critique : ' + (100 * critProba).toStringAsFixed(2) + '%',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleStyleSpec: charts.TextStyleSpec(fontSize: 8),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
      ],
    ));
  }
}

/// Sample ordinal data type.
class DiceRollStat {
  // Recursive and slow implementation
  // Overflows for n >= 21
  static int factorial(int n) {
    return n <= 0 ? 1 : n * factorial(n - 1);
  }

  // https://math.stackexchange.com/questions/202554/how-do-i-compute-binomial-coefficients-efficiently

  static int combine(int n, int k) {
    if (k == 0) return 1;
    if (k > n / 2) return combine(n, n - k);
    return (n * combine(n - 1, k - 1) / k).round();
  }

  static double getStats(
      int diceCount, double successProbability, int expectedSuccess) {
    return combine(diceCount, expectedSuccess) *
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
