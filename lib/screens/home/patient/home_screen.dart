import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/Appointment.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/screens/default_test_location/default_test_location_screen.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/home/patient/screens/add_patient.dart';
import 'package:swabx/screens/home/patient/screens/book_appointment.dart';
import 'package:swabx/screens/home/patient/screens/my_appointments.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

APIService apiService = new APIService();

class PatientDashboardScreen extends StatefulWidget {
  @override
  _PatientDashboardScreenState createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  QRCode myCode;
  Appointment _upcomingAppointment;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getMyQR().then((value) => {
          if (value != null)
            {
              this.setState(() {
                myCode = value;
              })
            }
        });
    apiService.getMyUpcomingAppointments().then((value) {
      if (value != null) {
        setState(() {
          _upcomingAppointment = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: CustomAppBar(),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            buildPatientHeader(screenHeight, myCode, context),
            buildTogether(screenHeight, 0.14),
            buildPreventionTips(screenHeight, 0.14),
            _MyGrid(),
            _MyUpcomingAppointment(_upcomingAppointment)
          ],
        ));
  }
}

class _MyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        sliver: SliverToBoxAdapter(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    _buildCard('my_staff', 'Register', context, 1),
                    _buildCard(
                        'my_locations', 'Book an Appointment', context, 2),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  Expanded _buildCard(
      String image, String title, BuildContext context, int path) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0)),
        child: GestureDetector(
            onTap: () async {
              if (path == 1) {
                Navigator.pushNamedAndRemoveUntil(
                    context, RegisterPatient.routeName, (route) => true);
              } else {
                String locationId = await SharedPreferencesHelper.getString(
                    "DefaultTestLocationId");

                if (locationId == null || locationId == "-1") {
                  Toast.show("Please select the Default Test Location", context,
                      duration: kToastDuration, gravity: Toast.BOTTOM);
                  Timer(Duration(seconds: kToastDuration), () {
                    Navigator.pushNamed(context, DefaultTestLocation.routeName);
                  });
                } else {
                  Navigator.pushNamed(context, BookAnAppointment.routeName);
                }
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/' + image + '.png',
                    height: getProportionateScreenHeight(50),
                    width: getProportionateScreenWidth(50)),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(13),
                        color: kPrimaryColor))
              ],
            )),
      ),
    );
  }
}

class _MyUpcomingAppointment extends StatelessWidget {
  final Appointment appointment;
  _MyUpcomingAppointment(this.appointment);
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        sliver: SliverToBoxAdapter(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    Text("Upcoming Appointment",
                        style: TextStyle(
                            fontSize: getProportionateScreenWidth(12),
                            color: Colors.black)),
                    Spacer(),
                    GestureDetector(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PatientHomeScreen(nextScreen: 2),
                            ))
                      },
                      child: Text(
                        "view more",
                        style: TextStyle(
                            fontSize: getProportionateScreenWidth(12),
                            color: kPrimaryColor),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (appointment != null && appointment.location != null)
                AppointmentCard(appointment: appointment)
              else
                Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No Scheduled Appointment",
                        style: TextStyle(color: Colors.black)))
            ],
          ),
        )));
  }
}
