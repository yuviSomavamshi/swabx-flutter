import 'dart:convert';
import 'package:swabx/size_config.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:toast/toast.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:swabx/helper/connection.dart';
import 'package:swabx/screens/home/staff/pair_devices/pair_web_timer.dart';

class ScanWebTimeQRCode extends StatelessWidget {
  static String routeName = "/scanWebTimeQR";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text("Scan QR Code", style: TextStyle(color: Colors.white)),
        ),
        body: ScanWebTimerQRCodeForm());
  }
}

class ScanWebTimerQRCodeForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanWebTimerQRCodeFormState();
}

class _ScanWebTimerQRCodeFormState extends State<ScanWebTimerQRCodeForm> {
  QRCode code;
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  void initState() {
    initSocketIO();
    super.initState();
  }

  initSocketIO() {
    //subscribe event
    con.subscribe("SCAN_QR_CODE_RESP", _getMessage);
  }

  void _getMessage(dynamic data) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map = json.decode(data);
    setState(() async {
      if (map['status'] == "success") {
        await SharedPreferencesHelper.setString(
            "RECEIVER", map['receiverName']);
        Toast.show("Successfully Paired Device", context,
            duration: kToastDuration, gravity: Toast.BOTTOM);
        Navigator.pushNamedAndRemoveUntil(
            context, WebTimeScreen.routeName, (route) => false);
      } else {
        Toast.show(map['message'], context,
            duration: kToastDuration, gravity: Toast.BOTTOM);
      }
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Text("To use " +
                  kAppName +
                  " Web, goto web " +
                  kWebsite +
                  "/webtimer on your computer.")),
          Expanded(flex: 3, child: _buildQrView(context))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? getProportionateScreenWidth(250)
        : getProportionateScreenWidth(350);
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      overlayMargin: EdgeInsets.all(10),
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: kPrimaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
          cutOutBottomOffset: 10),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;

      if (result.format.formatName == "QR_CODE") {
        try {
          String email = await SharedPreferencesHelper.getUserEmail();
          controller.pauseCamera();
          String jsonData = '{senderName: "' +
              email +
              '",receiverName: "' +
              result.code +
              '"}';
          con.sendMessage("SCAN_QR_CODE", jsonData);
          setState(() {});
        } on Exception catch (e) {
          print(e);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
