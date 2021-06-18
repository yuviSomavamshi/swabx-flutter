import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> showQRCodeDialog(
    BuildContext context, String title, String data) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        title: Center(child: Text(title)),
        content: Container(
          width: 250.0,
          height: 250.0,
          alignment: Alignment.center,
          child: QrImage(
              data: data,
              version: QrVersions.auto,
              padding: const EdgeInsets.only(top: 5)),
        ),
        actions: <Widget>[],
      );
    },
  );
}
