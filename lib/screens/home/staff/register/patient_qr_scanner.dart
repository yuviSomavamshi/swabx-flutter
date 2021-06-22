import 'dart:convert';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/Convertor.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import './device_barcode_scanner.dart';

class ScanPatientQRCode extends StatelessWidget {
  static String routeName = "/scanPatientQR";
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
          centerTitle: true,
          title:
              Text("Scan User QR Code", style: TextStyle(color: Colors.white)),
        ),
        body: ScanPatientQRCodeForm());
  }
}

class ScanPatientQRCodeForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanPatientQRCodeFormState();
}

class _ScanPatientQRCodeFormState extends State<ScanPatientQRCodeForm> {
  QRCode code;
  bool showDetails = false;
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: <Widget>[
          if (showDetails)
            Expanded(flex: 1, child: PatientDetailsCard(code: code))
          else
            SizedBox(),
          Expanded(flex: 2, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0XFF8A8A8A))),
                          onPressed: () async {
                            showDetails = false;
                            await controller.resumeCamera();
                          },
                          child: Text('Rescan'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kPrimaryColor)),
                          onPressed: (code == null ||
                                  code != null && code.id == null ||
                                  code.id.isEmpty)
                              ? null
                              : () async {
                                  await controller?.stopCamera();
                                  await SharedPreferencesHelper.setString(
                                      "patient_id", code.id);
                                  await SharedPreferencesHelper.setString(
                                      "patient_name", code.name);
                                  await SharedPreferencesHelper.setString(
                                      "patient_dob", code.dob);
                                  await SharedPreferencesHelper.setString(
                                      "patient_nationality", code.nationality);
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      ScanDeviceBarcode.routeName,
                                      (route) => false);
                                },
                          child: Text('Confirm'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
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
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result.format.formatName == "QR_CODE") {
          try {
            print(result.code);
            var json;

            if (result.code.startsWith("{")) {
              json = jsonDecode(result.code);
            } else {
              Convertor c = new Convertor();
              json = jsonDecode(c.decrypt(result.code));
            }

            if (json != null &&
                json["id"] != null &&
                json["name"] != null &&
                json["dob"] != null &&
                json["nationality"] != null) {
              code = new QRCode(
                  id: json["id"],
                  name: json["name"],
                  dob: json["dob"],
                  nationality: json["nationality"],
                  confirmation: true,
                  relationship: "Patient");
              controller.pauseCamera();
              showDetails = true;
            } else {
              showDetails = false;
            }
          } on Exception catch (e) {
            print(e);
            showDetails = false;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class PatientDetailsCard extends StatelessWidget {
  const PatientDetailsCard({Key key, @required this.code}) : super(key: key);

  final QRCode code;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: getProportionateScreenWidth(5),
          right: getProportionateScreenWidth(5)),
      child: SizedBox(
        width: SizeConfig.screenWidth * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(getProportionateScreenWidth(10)),
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  FlatButton(
                      onPressed: () => null,
                      minWidth: 40,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset('assets/images/Profile Image.png',
                          width: 45, height: 45)),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/details_user.png",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          SizedBox(width: 5),
                          Text(code.name,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/details_id.png",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          SizedBox(width: 5),
                          Text(code.id,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/details_dob.png",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          SizedBox(width: 5),
                          Text(code.dob,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16))
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          new Image.asset(
                              "icons/flags/png/" +
                                  code.nationality.toLowerCase() +
                                  ".png",
                              height: getProportionateScreenHeight(20),
                              width: getProportionateScreenWidth(20),
                              package: 'country_icons'),
                          SizedBox(width: 5),
                          Text(getCountryNameByCode(code.nationality),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16))
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
