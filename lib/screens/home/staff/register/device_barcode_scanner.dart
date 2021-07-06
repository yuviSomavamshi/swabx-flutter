import 'package:flutter_svg/flutter_svg.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:toast/toast.dart';
import './summary_page.dart';

class ScanDeviceBarcode extends StatelessWidget {
  static String routeName = "/scanDeviceBarCode";
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
          title: Text("Scan Swab Kit Barcode",
              style: TextStyle(color: Colors.white)),
        ),
        body: ScanDeviceBarcodeForm());
  }
}

class ScanDeviceBarcodeForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanDeviceBarcodeFormState();
}

class _ScanDeviceBarcodeFormState extends State<ScanDeviceBarcodeForm> {
  String barcode = "";
  bool showDetails = false;
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'Barcode');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller.resumeCamera();
  }

  String _defaultValue(String input) {
    if (input == null || input.isEmpty) {
      input = "SG";
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: <Widget>[
          if (showDetails)
            Expanded(
                flex: 1,
                child: DetailsCard(
                  barcode: barcode,
                ))
          else
            SizedBox(),
          Expanded(flex: 3, child: _buildQrView(context)),
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
                          onPressed: barcode == null || barcode.isEmpty
                              ? null
                              : () async {
                                  await controller?.stopCamera();
                                  await SharedPreferencesHelper.setString(
                                      "device_barcode", barcode);

                                  APIService apiService = new APIService();
                                  var id = _defaultValue(
                                      await SharedPreferencesHelper.getString(
                                          "patient_id"));
                                  var name = _defaultValue(
                                      await SharedPreferencesHelper.getString(
                                          "patient_name"));
                                  var dob = _defaultValue(
                                      await SharedPreferencesHelper.getString(
                                          "patient_dob"));
                                  var nationality = _defaultValue(
                                      await SharedPreferencesHelper.getString(
                                          "patient_nationality"));
                                  barcode = _defaultValue(
                                      await SharedPreferencesHelper.getString(
                                          "device_barcode"));
                                  var code = new QRCode(
                                      id: id,
                                      name: name,
                                      dob: dob,
                                      nationality: nationality,
                                      confirmation: true,
                                      relationship: barcode);
                                  apiService
                                      .registerPatient(code)
                                      .then((value) {
                                    if (value.statusCode == 409) {
                                      Toast.show(
                                          "Swab Kit is already assigned to a patient",
                                          context,
                                          duration: kToastDuration,
                                          gravity: Toast.BOTTOM);
                                    } else if (value.statusCode == 404) {
                                      Toast.show(
                                          "Please scan different device, this device is not yet ready for the use.\nBarcode scanned in not whitelisted in the system.",
                                          context,
                                          duration: kToastDuration,
                                          gravity: Toast.BOTTOM);
                                    } else if (value.statusCode == 201 ||
                                        value.statusCode == 200 &&
                                            value.message == "success") {
                                      Toast.show(
                                          "Device paired successfully", context,
                                          duration: kToastDuration,
                                          gravity: Toast.BOTTOM);
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          ScanSummaryScreen.routeName,
                                          (route) => false);
                                    } else {
                                      if (value.message != null) {
                                        Toast.show(value.message, context,
                                            duration: kToastDuration,
                                            gravity: Toast.BOTTOM);
                                      } else {
                                        Toast.show(
                                            "Service is not reachable at the moment.\nPlease try after sometime.",
                                            context,
                                            duration: kToastDuration,
                                            gravity: Toast.BOTTOM);
                                      }
                                    }
                                  });
                                },
                          child: Text('Pair'),
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
        if (result.format.formatName == "CODE_128" && result.code != null) {
          barcode = result.code;
          controller.pauseCamera();
          showDetails = true;
        } else {
          showDetails = false;
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

class DetailsCard extends StatelessWidget {
  const DetailsCard({Key key, @required this.barcode}) : super(key: key);

  final String barcode;

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
                      child: SvgPicture.asset('assets/images/swabkit.svg',
                          width: 45, height: 45)),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 5),
                          Text(barcode,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getProportionateScreenWidth(16),
                                  fontWeight: FontWeight.bold))
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
