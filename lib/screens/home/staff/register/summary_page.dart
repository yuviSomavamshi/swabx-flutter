import 'package:flutter_svg/svg.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/models/Result.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:swabx/components/default_button.dart';

import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';

import 'device_barcode_scanner.dart';

class ScanSummaryScreen extends StatelessWidget {
  static String routeName = "/scanSummary";
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: CustomAppBar(),
        body: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              buildHeader(screenHeight),
              SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                      child: Column(children: [
                    SizedBox(height: 20),
                    Text("Patient Summary",
                        style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 20),
                    ScanSummaryScreenBody()
                  ])))
            ]));
  }
}

class ScanSummaryScreenBody extends StatefulWidget {
  ScanSummaryScreenBody({Key key}) : super(key: key);
  @override
  _ScanSummaryScreenBodyState createState() => _ScanSummaryScreenBodyState();
}

class _ScanSummaryScreenBodyState extends State<ScanSummaryScreenBody> {
  bool paired;
  String barcode;
  QRCode code;
  bool showStartWatch = false;
  bool showConfirmation = false;
  @override
  void initState() {
    super.initState();
  }

  String _defaultValue(String input) {
    if (input == null || input.isEmpty) {
      input = "SG";
    }
    return input;
  }

  Future<String> downloadData() async {
    var id =
        _defaultValue(await SharedPreferencesHelper.getString("patient_id"));
    var name =
        _defaultValue(await SharedPreferencesHelper.getString("patient_name"));
    var dob =
        _defaultValue(await SharedPreferencesHelper.getString("patient_dob"));
    var nationality = _defaultValue(
        await SharedPreferencesHelper.getString("patient_nationality"));
    barcode = _defaultValue(
        await SharedPreferencesHelper.getString("device_barcode"));
    code = new QRCode(
        id: id,
        name: name,
        dob: dob,
        nationality: nationality,
        confirmation: true,
        relationship: "Patient");
    return Future.value(""); // return your response
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit the App?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await SharedPreferencesHelper.addPatient(new Result(
                      id: code.id,
                      name: code.name,
                      dob: code.dob,
                      barcode: barcode,
                      result: "Pending",
                      nationality: code.nationality));
                  Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    paired = true;
    return FutureBuilder<String>(
        future: downloadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading();
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return new WillPopScope(
                  onWillPop: _onWillPop,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          PatientSummaryCard(code: code),
                          SizedBox(height: getProportionateScreenHeight(15)),
                          BarcodeSummaryCard(barcode: barcode, paired: paired),
                          SizedBox(height: getProportionateScreenHeight(15)),
                          DefaultButton(
                            text: "Complete",
                            press: () async {
                              await SharedPreferencesHelper.addPatient(
                                  new Result(
                                      id: code.id,
                                      name: code.name,
                                      dob: code.dob,
                                      barcode: barcode,
                                      result: "Pending",
                                      nationality: code.nationality));
                              setState(() {
                                showConfirmation = true;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StaffHomeScreen(nextScreen: 1),
                                  ));
                            },
                          ),
                        ],
                      )));
          }
        });
  }
}

const Widget spaceBetweenWidgets = SizedBox(width: 10);

class PatientSummaryCard extends StatelessWidget {
  const PatientSummaryCard({Key key, @required this.code}) : super(key: key);
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
                  SizedBox(width: 15),
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
                          spaceBetweenWidgets,
                          Text(code.name,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/details_id.png",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          spaceBetweenWidgets,
                          Text(code.id,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/details_dob.png",
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          spaceBetweenWidgets,
                          Text(code.dob,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14))
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          new Image.asset(
                              "icons/flags/png/" +
                                  code.nationality.toLowerCase() +
                                  ".png",
                              height: getProportionateScreenHeight(20),
                              width: getProportionateScreenWidth(20),
                              package: 'country_icons'),
                          spaceBetweenWidgets,
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
                  ),
                  Spacer(),
                  // ignore: deprecated_member_use
                  FlatButton(
                      onPressed: () => null,
                      minWidth: 40,
                      padding: EdgeInsets.all(10),
                      child: Image.asset('assets/images/qrcode.png',
                          width: 45, height: 45))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarcodeSummaryCard extends StatelessWidget {
  const BarcodeSummaryCard({Key key, this.barcode, this.paired})
      : super(key: key);

  final String barcode;
  final bool paired;

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
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/swabkit.svg',
                            height: getProportionateScreenHeight(20),
                            width: getProportionateScreenWidth(20),
                          ),
                          spaceBetweenWidgets,
                          Text(barcode,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12))
                        ],
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                          height: 20,
                          minWidth: 100,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () => null,
                          color: paired ? Colors.green : Colors.grey,
                          child: Text(
                            paired ? "Paired" : "Pairing",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ))
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                          onPressed: () => null,
                          minWidth: 40,
                          child: Image.asset('assets/images/barcode.png',
                              width: 45)),
                      // ignore: deprecated_member_use
                      FlatButton(
                          color: paired ? kPrimaryColor : kSecondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          height: 20,
                          child: Text(paired ? "Issue new Kit" : "",
                              style:
                                  TextStyle(fontSize: 8, color: Colors.white)),
                          onPressed: () async {
                            APIService apiService = new APIService();
                            apiService.scrapDevice(barcode);

                            Navigator.pushNamedAndRemoveUntil(context,
                                ScanDeviceBarcode.routeName, (route) => true);
                          })
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
