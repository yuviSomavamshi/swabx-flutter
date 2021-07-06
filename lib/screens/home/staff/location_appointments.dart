import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/Convertor.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/Schedule.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'dart:convert';

APIService apiService = new APIService();

class LocationAppointments extends StatefulWidget {
  LocationAppointments({Key key}) : super(key: key);
  @override
  _LocationAppointmentsState createState() => _LocationAppointmentsState();
}

class _LocationAppointmentsState extends State<LocationAppointments> {
  List<Schedule> appointments = [];
  String _location = "-1";
  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getString("DefaultTestLocationId").then((loc) {
      apiService.getLocationAppointments(loc).then((value) {
        this.setState(() {
          _location = loc;
          appointments = value;
        });
      });
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
            buildHeader(screenHeight),
            SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                sliver: SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(children: [
                          SizedBox(height: 20),
                          Text("Today's Appointments",
                              style: TextStyle(
                                  fontSize: getProportionateScreenWidth(20),
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w800)),
                          if (_location != null &&
                              _location != "-1" &&
                              appointments.length == 0)
                            noRecords("No Appointment Scheduled")
                          else if (_location == null || _location == "-1")
                            noRecords("Default Test Location is not set")
                          else
                            ...List.generate(
                              appointments.length,
                              (index) {
                                return AppointmentCard(
                                    appointment: appointments[index]);
                              },
                            ).toList()
                        ]))))
          ],
        ));
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  final Schedule appointment;

  @override
  Widget build(BuildContext context) {
    Color cl = Colors.grey;
    String message = appointment.status;
    switch (message) {
      case "Upcoming":
      case "Pending":
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

    Convertor c = new Convertor();
    var json = (appointment.patientHash != null)
        ? jsonDecode(c.decrypt(appointment.patientHash))
        : {"name": null};
    String name = json["name"] != null ? json["name"] : appointment.patientName;
    return GestureDetector(
        onTap: () {
          _showConfirmVisited(context, appointment);
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
                      if (json["id"] != null)
                        Text("IC: " + json["id"],
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: getProportionateScreenWidth(16),
                                fontWeight: FontWeight.bold)),
                      Text("Name: " + name,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getProportionateScreenWidth(16))),
                      Text(appointment.date + " " + appointment.time,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(14)))
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

  Future<void> _showConfirmVisited(BuildContext context, Schedule appointment) {
    Convertor c = new Convertor();
    var json = (appointment.patientHash != null)
        ? jsonDecode(c.decrypt(appointment.patientHash))
        : {"name": null};

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 30),
          title: Center(child: Text("User Details")),
          content: Container(
            height: 120.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/details_user.png",
                      height: getProportionateScreenHeight(20),
                      width: getProportionateScreenWidth(20),
                    ),
                    spaceBetweenWidgets,
                    Text(json["name"],
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getProportionateScreenWidth(16),
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/details_id.png",
                      height: getProportionateScreenHeight(20),
                      width: getProportionateScreenWidth(20),
                    ),
                    spaceBetweenWidgets,
                    Text(json["id"],
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: getProportionateScreenWidth(16),
                          fontWeight: FontWeight.bold,
                        ))
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/details_dob.png",
                      height: getProportionateScreenHeight(20),
                      width: getProportionateScreenWidth(20),
                    ),
                    spaceBetweenWidgets,
                    Text(json["dob"],
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getProportionateScreenWidth(16)))
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    new Image.asset(
                        "icons/flags/png/" +
                            json["nationality"].toLowerCase() +
                            ".png",
                        height: getProportionateScreenHeight(20),
                        width: getProportionateScreenWidth(20),
                        package: 'country_icons'),
                    spaceBetweenWidgets,
                    Text(getCountryNameByCode(json["nationality"]),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getProportionateScreenWidth(16)))
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }
}
