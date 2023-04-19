import 'dart:convert';

import 'package:flutter/services.dart';



class MyJsonData {
  Future<Map<String, dynamic>> getData() async {
    final String jsonString = await rootBundle.loadString('assets/taxis-roads.json');
    print(jsonString);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  }
}
