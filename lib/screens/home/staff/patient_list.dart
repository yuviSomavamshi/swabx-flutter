import 'package:swabx/screens/home/patient/home_screen.dart';
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
    SharedPreferencesHelper.getResults().then((r) {
      this.setState(() {
        results = r;
      });
    });
    if (_poller == null) {
      _poller = new Poller(
          seconds: 10,
          callback: () async {
            APIService apiService = new APIService();
            for (var i = 0; i < results.length; i++) {
              var p = results[i];
              if (p.result == "Pending") {
                apiService.patientReport(p.getHash()).then((result) {
                  try {
                    var r = result.firstWhere((e) => e.barcode == p.barcode,
                        orElse: () => null);
                    if (r != null) {
                      p.result = r.result;
                      setState(() {
                        results[i] = p;
                      });
                      SharedPreferencesHelper.persistResults(results);
                    }
                  } on Exception catch (e) {
                    print(e);
                  }
                });
              }
            }
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
          onPressed: () {
            Navigator.pushNamed(context, ScanPatientQRCode.routeName);
          },
          child: Icon(
            Icons.qr_code_scanner_sharp,
            color: Colors.white,
            size: 29,
          ),
          backgroundColor: kPrimaryColor,
          tooltip: 'Scan patient QR and device barcode',
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
                          print(filtered[index].getHash());
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
            : noRecords("No Appointment Scheduled"));
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
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              location: report.location,
                              diagnosis: "Negative")
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
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              location: report.location,
                              diagnosis: "Positive")
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
                      apiService
                          .uploadDiagnosisReport(
                              barcode: report.barcode,
                              date: dateFormat.format(now),
                              time: timeFormat.format(now),
                              location: report.location,
                              diagnosis: "Invalid")
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
          if (report.result == "Pending") {
            print("Tap");
            _showConfirmation(context);
          }
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
