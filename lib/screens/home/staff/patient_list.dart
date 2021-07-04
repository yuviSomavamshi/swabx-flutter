import 'dart:async';

import 'package:swabx/screens/default_test_location/default_test_location_screen.dart';
import 'package:toast/toast.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/Result.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/staff/register/patient_qr_scanner.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/material.dart';
import 'package:poller/poller.dart';

import '../home_screen.dart';

APIService apiService = new APIService();

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());
}

class RecentScans extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RecentScansState();
  }
}

class _RecentScansState extends State<RecentScans> {
  List<Result> results;
  String _search;
  bool _searchPressed;
  Poller _poller;
  @override
  void initState() {
    super.initState();
    _search = "";
    _searchPressed = false;
    apiService.patients().then((r) {
      this.setState(() {
        results = r;
      });
    });
    if (_poller == null) {
      _poller = new Poller(
          seconds: 5,
          callback: () async {
            apiService.patients().then((r) {
              this.setState(() {
                results = r;
              });
            });
          },
          logging: false);
      _poller.start();
    }
  }

  @override
  void dispose() {
    if (_poller != null) {
      _poller.stop();
    }
    super.dispose();
  }

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
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  sliver: SliverToBoxAdapter(
                      child: Column(children: [
                    SizedBox(height: 20),
                    Text("Recent Scans",
                        style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w800)),
                    if (results != null && results.length > 0)
                      _buildSearchBox(),
                    SizedBox(height: 5),
                    _buildResportsList(results)
                  ])))
            ]),
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            String locationId = await SharedPreferencesHelper.getString(
                "DefaultTestLocationId");

            if (locationId == null || locationId == "-1") {
              Toast.show("Please select the Default Test Location", context,
                  duration: kToastDuration, gravity: Toast.BOTTOM);
              Timer(Duration(seconds: kToastDuration), () {
                Navigator.pushNamed(context, DefaultTestLocation.routeName);
              });
            } else {
              Navigator.pushNamed(context, ScanPatientQRCode.routeName);
            }
          },
          child: Icon(
            Icons.qr_code_scanner_sharp,
            color: Colors.white,
            size: 29,
          ),
          backgroundColor: kPrimaryColor,
          tooltip: 'Scan User QR and device barcode',
          elevation: 5,
          splashColor: Colors.grey,
        ));
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
          keyboardType: TextInputType.text,
          controller: TextEditingController()..text = _search,
          onChanged: (value) {
            _search = value;
          },
          style: TextStyle(fontSize: 18, color: Colors.black45),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              prefixIcon: Icon(Icons.people),
              suffixIcon: IconButton(
                icon: !_searchPressed ? Icon(Icons.search) : Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    if (_searchPressed) {
                      _search = "";
                    }
                    _searchPressed = !_searchPressed;
                  });
                },
              ),
              hintText: "Search",
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0)))),
    );
  }

  Widget _buildResportsList(List<Result> results) {
    List<Result> filtered = [];
    if (results != null)
      results.forEach((element) {
        print(_search + ":" + element.name);

        if (element.name.containsIgnoreCase(_search) ||
            element.id.containsIgnoreCase(_search) ||
            element.barcode.containsIgnoreCase(_search)) {
          filtered.add(element);
        }
      });
    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: filtered.length > 0
            ? ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        if (filtered[index].result == "Pending") {
                          Toast.show("You cannot delete this record", context,
                              duration: kToastDuration, gravity: Toast.BOTTOM);
                          return null;
                        }

                        final bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Are you sure you want to delete?\n\nIC: ${filtered[index].id}\nName: ${filtered[index].name}"),
                                actions: <Widget>[
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        apiService
                                            .checkOutPatient(
                                                filtered[index].getHash(),
                                                filtered[index].barcode)
                                            .then((value) => print);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StaffHomeScreen(
                                                      nextScreen: 1),
                                            ));
                                      }),
                                ],
                              );
                            });
                        return res;
                      } else {
                        return null;
                      }
                    },
                    secondaryBackground: Container(
                      child: Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      color: Colors.red,
                    ),
                    background: Container(),
                    child: ReportCard(report: filtered[index]),
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                  );
                },
              )
            : noRecords("No Records Found"));
  }

  Future<List<Result>> downloadData() async {
    results = await SharedPreferencesHelper.getResults();
    return Future.value(results); // return your response
  }
}

class ReportCard extends StatelessWidget {
  final Result report;

  ReportCard({this.report});

  Future<void> _showConfirmation(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Center(
              child: Text(
            "Upload diagnosis report",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          content: Container(
              height: 180.0,
              alignment: Alignment.center,
              child: Column(children: [
                SizedBox(height: 5),
                // ignore: deprecated_member_use
                FlatButton(
                    height: 40,
                    minWidth: 100,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      DateTime now = DateTime.now();
                      now = now.toUtc().add(Duration(hours: 8));
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              diagnosis: "Negative",
                              patientId: report.getHash())
                          .then((value) {
                        Toast.show(value.message, context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                        Navigator.of(context).pop();
                      });
                    },
                    color: Colors.green,
                    child: Text(
                      "Negative",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
                SizedBox(height: 5),
                // ignore: deprecated_member_use
                FlatButton(
                    height: 40,
                    minWidth: 100,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      DateTime now = DateTime.now();
                      now = now.toUtc().add(Duration(hours: 8));
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              diagnosis: "Positive",
                              patientId: report.getHash())
                          .then((value) {
                        Toast.show(value.message, context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                        Navigator.of(context).pop();
                      });
                    },
                    color: Colors.red,
                    child: Text(
                      "Positive",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
                SizedBox(height: 5),
                // ignore: deprecated_member_use
                FlatButton(
                    height: 40,
                    minWidth: 100,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      DateTime now = DateTime.now();
                      now = now.toUtc().add(Duration(hours: 8));
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              diagnosis: "Invalid",
                              patientId: report.getHash())
                          .then((value) {
                        Toast.show(value.message, context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                        Navigator.of(context).pop();
                      });
                    },
                    color: Colors.deepOrange,
                    child: Text(
                      "Invalid",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ))
              ])),
          actions: <Widget>[],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var cl = Colors.grey;
    if (report.result == "Negative") {
      cl = Colors.green;
    } else if (report.result == "Positive") {
      cl = Colors.red;
    } else if (report.result == "Invalid") {
      cl = Colors.deepOrange;
    } else if (report.result == "Scrapped") {
      cl = Colors.deepPurple;
    }

    return GestureDetector(
        onTap: () {
          _showConfirmation(context);
        },
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Image.asset(
                  "assets/images/details_user.png",
                  height: getProportionateScreenHeight(40),
                  width: getProportionateScreenWidth(40),
                ),
                title: Text(report.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("IC: ${report.id}"),
                    Text("Kit: ${report.barcode}")
                  ],
                ),
                // ignore: deprecated_member_use
                trailing: FlatButton(
                    height: 30,
                    minWidth: 90,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () => null,
                    color: cl,
                    child: Text(
                      report.result,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
        ));
  }
}
