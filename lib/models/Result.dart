import 'dart:convert';

import 'package:swabx/helper/Convertor.dart';
import 'package:flutter/material.dart';

class Result {
  final String id;
  final String name;
  final String dob;
  final String nationality;
  String barcode;
  String result;
  final String location;
  final String date;
  final String time;

  Result(
      {@required this.id,
      @required this.name,
      @required this.result,
      @required this.nationality,
      this.dob,
      this.location,
      this.date,
      this.time,
      this.barcode});

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "dob": dob,
        "barcode": barcode,
        "result": result,
        "nationality": nationality,
        "location": location,
        "date": date,
        "time": time
      };
  Map<String, dynamic> toQRJson() =>
      {"id": id, "name": name, "dob": dob, "nationality": nationality};

  String getHash() {
    var json = this.toQRJson();
    var stringify = jsonEncode(json);
    var c = new Convertor();
    return c.encrypt(stringify);
  }

  factory Result.fromJson(Map<String, dynamic> jsonData) {
    return new Result(
        id: jsonData['id'] != null ? jsonData['id'] : jsonData['subject_id'],
        name: jsonData['name'] != null ? jsonData['name'] : "Unknown",
        dob: jsonData['dob'] != null ? jsonData['dob'] : jsonData['date'],
        barcode: jsonData['subject_id'] != null
            ? jsonData['subject_id']
            : jsonData['barcode'],
        result: jsonData['result'] != null
            ? jsonData['result']
            : jsonData['diagnosis'],
        nationality: jsonData['nationality'] != null
            ? jsonData['nationality']
            : "Unknown",
        location:
            jsonData['location'] != null ? jsonData['location'] : "Unknown",
        date: jsonData['date'],
        time: jsonData['time']);
  }
}
