import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'album.dart';

String sensorName = "";
double toggleCounter = 0;
List<Data> chartData = [];
List<String> toggle = ["True", "False"];
late Timer timer;

Future<List<Album>> fetchAlbum(String SensorName) async {
  String url = 'http://192.168.167.223:8000/api/readings/' + SensorName;
  final response = await http.get(Uri.parse(url));

  sensorName = SensorName;

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var responseData = json.decode(response.body);
    List<Album> reads = [];
    for (var singleRead in responseData) {
      Album read = Album(
          sensor: singleRead["sensor"],
          value: singleRead["value"].toDouble(),
          timestamp: singleRead["timestamp"].toDouble());
      //Adding reads to the list.
      reads.add(read);
    }
    return reads;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

void main() => runApp(const MyApp());

TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum("temp");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TASK0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TASK0'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                chartData = [];
                for (var i = 0; i < snapshot.data!.length; i++) {
                  chartData.add(Data(
                      snapshot.data![i].value, snapshot.data![i].timestamp));
                }
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: SfCartesianChart(
                                title: ChartTitle(text: sensorName),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: _tooltipBehavior,
                                series: <ChartSeries>[
                                  LineSeries<Data, double>(
                                    // List _charData of type Data which holdes variables of type double
                                    dataSource: chartData,
                                    xValueMapper: (Data xaxis, _) =>
                                        xaxis.xaxis,
                                    yValueMapper: (Data xaxis, _) =>
                                        xaxis.yaxis,
                                    name:
                                        sensorName, // Change this variable for the sensor name
                                    enableTooltip: true,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              //Toggle Sensors button
                              margin: EdgeInsets.all(20.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    toggleCounter++;
                                    if (toggleCounter % 2 == 0) {
                                      setState(() {
                                        timer.cancel();
                                        timer = Timer.periodic(
                                            Duration(seconds: 2), (timer) {
                                          futureAlbum = fetchAlbum("temp");
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        timer.cancel();
                                        timer = Timer.periodic(
                                            Duration(seconds: 2), (timer) {
                                          futureAlbum = fetchAlbum("LT");
                                        });
                                      });
                                    }
                                  },
                                  child: Text('Toggle Sensors')),
                            ),
                            Container(
                              // Toggle LED button
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 150.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    toggleCounter++;
                                    http.post(Uri.parse(
                                        'http://192.168.167.223:8000/api/toggle/' +
                                            toggle[
                                                (toggleCounter % 2).toInt()]));
                                    print("toggled");
                                  },
                                  child: Text('Toggle LED')),
                            ),
                          ]),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class Data {
  Data(this.yaxis, this.xaxis);
  double xaxis, yaxis;
}
