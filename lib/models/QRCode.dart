import 'dart:convert';

import 'package:swabx/helper/Convertor.dart';
import 'package:flutter/material.dart';

class QRCode {
  final String id;
  final String name;
  final String dob;
  final String relationship;
  final String nationality;
  final bool confirmation;
  final String created;

  QRCode(
      {@required this.id,
      @required this.name,
      @required this.dob,
      @required this.relationship,
      @required this.nationality,
      @required this.confirmation,
      this.created});

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "dob": dob,
        "relationship": relationship,
        "nationality": nationality,
        "confirmation": confirmation,
        "created": created
      };

  Map<String, dynamic> toQRJson() =>
      {"id": id, "name": name, "dob": dob, "nationality": nationality};

  String getHash() {
    var json = this.toQRJson();
    var stringify = jsonEncode(json);
    var c = new Convertor();
    return c.encrypt(stringify);
  }

  factory QRCode.fromJson(Map<String, dynamic> jsonData) {
    return QRCode(
        id: jsonData['id'],
        name: jsonData['name'],
        dob: jsonData['dob'],
        relationship: jsonData['relationship'],
        nationality: jsonData['nationality'],
        confirmation: jsonData['confirmation'],
        created: jsonData['created'] == null
            ? null
            : DateTime.parse(jsonData['created'].toString()).toString());
  }
}
