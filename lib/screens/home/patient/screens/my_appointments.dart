import 'dart:async';

import 'package:swabx/components/default_button.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/Appointment.dart';
import 'package:swabx/screens/default_test_location/default_test_location_screen.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/home/patient/screens/book_appointment.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

APIService apiService = new APIService();

class MyAppointments extends StatefulWidget {
  MyAppointments({Key key}) : super(key: key);
  @override
  _MyAppointmentsState createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  List<AppointmentCard> appointments = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<Appointment>>(
      future: getMyAppointments(), // function where you call your api
      builder:
          (BuildContext context, AsyncSnapshot<List<Appointment>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            return Scaffold(
                appBar: CustomAppBar(),
                body: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: <Widget>[
                    buildHeader(screenHeight),
                    SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        sliver: SliverToBoxAdapter(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(children: [
                                  SizedBox(height: 20),
                                  Text("My Appointments",
                                      style: TextStyle(
                                          fontSize:
                                              getProportionateScreenWidth(20),
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(height: 30),
                                  if (snapshot.hasData &&
                                      snapshot.data.length > 0)
                                    ...List.generate(
                                      snapshot.data.length,
                                      (index) {
                                        return AppointmentCard(
                                            appointment: snapshot.data[index]);
                                      },
                                    ).toList()
                                  else
                                    noRecords("No records found")
                                ]))))
                  ],
                ),
                floatingActionButton: new FloatingActionButton(
                  onPressed: () async {
                    String locationId = await SharedPreferencesHelper.getString(
                        "DefaultTestLocationId");

                    if (locationId == null || locationId == "-1") {
                      Toast.show(
                          "Please select the Default Test Location", context,
                          duration: kToastDuration, gravity: Toast.BOTTOM);
                      Timer(Duration(seconds: kToastDuration), () {
                        Navigator.pushNamed(
                            context, DefaultTestLocation.routeName);
                      });
                    } else {
                      Navigator.pushNamed(context, BookAnAppointment.routeName);
                    }
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 29,
                  ),
                  backgroundColor: kPrimaryColor,
                  tooltip: 'Book A Swab Test Appointment',
                  elevation: 5,
                  splashColor: Colors.grey,
                ));
          }
        }
      },
    );
  }

  Future<List<Appointment>> getMyAppointments() async {
    return Future.value(
        await apiService.getMyAppointments()); // return your response
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    Color cl = Colors.grey;
    String message;

    message = appointment.status;
    switch (message) {
      case "Upcoming":
        break;
      case "Finished":
        cl = Colors.green;
        break;
      case "Missed":
        cl = Colors.orange;
        break;
      case "Cancelled":
        cl = Colors.red;
        break;
      default:
        cl = Color(0XFFF9696);
        break;
    }

    return GestureDetector(
        onTap: () {
          if (appointment.status == "Upcoming")
            _showCancelConfirmation(context, appointment);
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
                      onPressed: () => null,
                      minWidth: 40,
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                          'assets/images/appointment_confirmation.png',
                          width: 45,
                          height: 45)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.location,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getProportionateScreenWidth(16))),
                      Text(
                        appointment.date,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0XFF8C92A4),
                            fontSize: getProportionateScreenWidth(14)),
                        maxLines: 2,
                      ),
                      Text(
                        appointment.time,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0XFF8C92A4),
                            fontSize: getProportionateScreenWidth(14)),
                        maxLines: 2,
                      )
                    ],
                  )),
                  Spacer(),
                  // ignore: deprecated_member_use
                  FlatButton(
                      height: 30,
                      minWidth: 80,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      onPressed: () => null,
                      color: cl,
                      child: Text(
                        message,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: getProportionateScreenWidth(12),
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ));
  }

  Future<void> _showCancelConfirmation(
      BuildContext context, Appointment appointment) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Center(child: Text("Appointment Cancellation")),
          content: Container(
            height: 180.0,
            alignment: Alignment.center,
            child: Column(
              children: [
                Image.asset('assets/images/appointment_confirmation.png',
                    width: 100, height: 80),
                Image.asset('assets/images/close_button.png'),
                SizedBox(height: 5),
                Text("Wish to cancel?")
              ],
            ),
          ),
          actions: <Widget>[
            DefaultButton(
              text: "OK",
              press: () async {
                apiService.cancelAppointment(appointment.id).then((value) {
                  if (value.statusCode == 200) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PatientHomeScreen(nextScreen: 2),
                        ));
                  } else {
                    Navigator.pop(context);
                    Toast.show(value.message, context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                  }
                });
              },
            )
          ],
        );
      },
    );
  }
}
