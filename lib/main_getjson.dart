import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('JSON Demo'),
        ),
        body: Center(
          child: FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString('assets/taxis-roads.json'),
            builder: (context, snapshot) {
              var data = json.decode(snapshot.data.toString());

              return ListView.builder(
                itemCount: data['itineraires'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Itinéraire: ${data['itineraires'][index]['nom']}",
                      ),
                      Text(
                        "Description: ${data['itineraires'][index]['description']}",
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                        data['itineraires'][index]['sous_itineraires'].length,
                        itemBuilder: (BuildContext context, int index2) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Nom: ${data['itineraires'][index]['sous_itineraires'][index2]['nom']}",
                              ),
                              Text(
                                "Tricycle: ${data['itineraires'][index]['sous_itineraires'][index2]['tricycle']}",
                              ),
                              SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: data['itineraires'][index]
                                ['sous_itineraires'][index2]['terminus']
                                    .length,
                                itemBuilder: (BuildContext context, int index3) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Nom: ${data['itineraires'][index]['sous_itineraires'][index2]['terminus'][index3]['nom']}",
                                      ),
                                      Text(
                                        "Latitude: ${data['itineraires'][index]['sous_itineraires'][index2]['terminus'][index3]['latitude']}",
                                      ),
                                      Text(
                                        "Longitude: ${data['itineraires'][index]['sous_itineraires'][index2]['terminus'][index3]['longitude']}",
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: data['itineraires'][index]
                                ['sous_itineraires'][index2]['zones']
                                    .length,
                                itemBuilder: (BuildContext context, int index4) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Nom: ${data['itineraires'][index]['sous_itineraires'][index2]['zones'][index4]['nom']}",
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
