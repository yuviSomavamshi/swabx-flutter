import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/Result.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/patient/screens/add_patient.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/components/default_button.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:swabx/helper/QRCodeAlert.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/results_screen.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

class MyRegisteredQrCodes extends StatefulWidget {
  MyRegisteredQrCodes({Key key}) : super(key: key);
  @override
  _MyRegisteredQrCodesState createState() => _MyRegisteredQrCodesState();
}

class _MyRegisteredQrCodesState extends State<MyRegisteredQrCodes> {
  List<QRCode> qrCodes = [];
  QRCode myCode;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getQRCodes().then((value) {
      setState(() {
        qrCodes = value;
      });
    });
    SharedPreferencesHelper.getMyQR().then((value) => {
          this.setState(() {
            myCode = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    if (qrCodes != null && qrCodes.length > 0) {
      screen = Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
        child: PatientList(qrCodes: qrCodes),
      );
    } else {
      screen = Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Image.asset(
                "assets/images/HomeScreen.png",
                height: getProportionateScreenHeight(265),
                width: getProportionateScreenWidth(235),
              ),
              SizedBox(height: getProportionateScreenHeight(30)),
              DefaultButton(
                text: "Register",
                press: () => Navigator.pushNamedAndRemoveUntil(
                    context, RegisterPatient.routeName, (route) => true),
              )
            ],
          ));
    }
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: CustomAppBar(),
        body: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              buildPatientHeader(screenHeight, myCode, context),
              SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  sliver: SliverToBoxAdapter(child: screen))
            ]),
        floatingActionButton: (qrCodes != null && qrCodes.length > 0)
            ? new FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterPatient.routeName);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 29,
                ),
                backgroundColor: kPrimaryColor,
                tooltip: 'Register User',
                elevation: 5,
                splashColor: Colors.grey,
              )
            : null);
  }
}

// ignore: must_be_immutable
class PatientList extends StatelessWidget {
  PatientList({Key key, @required this.qrCodes}) : super(key: key);

  List<QRCode> qrCodes;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text("Registered QR Codes",
            style: TextStyle(
                fontSize: getProportionateScreenWidth(20),
                color: kPrimaryColor,
                fontWeight: FontWeight.w800)),
        SizedBox(height: 30),
        ...List.generate(
          qrCodes.length,
          (index) {
            if (qrCodes[index] != null && qrCodes[index].name != null) {
              return PatientCard(qrCode: qrCodes[index]);
            }
            return Text("Empty");
            // here by default width and height is 0
          },
        ).reversed.toList(),
        SizedBox(width: getProportionateScreenWidth(20)),
      ],
    );
  }
}

class PatientCard extends StatelessWidget {
  const PatientCard({
    Key key,
    @required this.qrCode,
  }) : super(key: key);

  final QRCode qrCode;

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text("Delete"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
        onPressed: () async {
          bool value = await SharedPreferencesHelper.removeQRCode(qrCode);
          if (value) {
            Toast.show("Record deleted successfully.", context,
                duration: kToastDuration, gravity: Toast.BOTTOM);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PatientHomeScreen(nextScreen: 1)));
          } else {
            Toast.show("Not deleted.", context,
                duration: 3, gravity: Toast.BOTTOM);
          }
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        content: Text("Are you sure you want to delete this?"),
        actions: [continueButton, cancelButton]);

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ResultScreen(hash: qrCode.getHash(), patient: qrCode.name)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0XFFDADADA), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () => showQRCodeDialog(
                        context, qrCode.name, qrCode.getHash()),
                    minWidth: getProportionateScreenWidth(40),
                    padding: EdgeInsets.all(0.0),
                    child: Image.asset('assets/images/qrcode.png',
                        width: getProportionateScreenWidth(40),
                        height: getProportionateScreenHeight(40))),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: getProportionateScreenWidth(170),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(
                        qrCode.name,
                        maxLines: 10,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getProportionateScreenWidth(16)),
                        overflow: TextOverflow.ellipsis,
                      )),
                      Text(
                        qrCode.relationship,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0XFF8C92A4),
                            fontSize: getProportionateScreenWidth(14)),
                        maxLines: 2,
                      ),
                      Text(
                        qrCode.created != null
                            ? "Added " +
                                formatTime(DateTime.parse(qrCode.created)
                                    .millisecondsSinceEpoch)
                            : "-",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0XFF8C92A4),
                            fontSize: getProportionateScreenWidth(14)),
                        maxLines: 2,
                      )
                    ],
                  ),
                ),
                Spacer(flex: 1),
                Row(
                  children: [
                    // ignore: deprecated_member_use
                    FlatButton(
                        onPressed: () {
                          showAlertDialog(context);
                        },
                        minWidth: 10,
                        padding: EdgeInsets.all(0.0),
                        child: getTrashIcon()),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  static String routeName = "/result";
  final String hash;
  final String patient;
  ResultScreen({this.hash, this.patient});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<Result>>(
        future: downloadData(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<List<Result>> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading();
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return new Scaffold(
                  appBar: CustomAppBar(),
                  body: CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      slivers: <Widget>[
                        buildHeader(screenHeight),
                        SliverPadding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            sliver: SliverToBoxAdapter(
                                child: RegisteredPatientsList(
                                    patient: patient, items: snapshot.data)))
                      ]));
          }
        });
  }

  Future<List<Result>> downloadData() async {
    APIService apiService = new APIService();
    return Future.value(apiService.patientReport(hash)); // return your response
  }
}
