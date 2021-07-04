import 'dart:async';

import 'package:swabx/components/default_button.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/models/Slot.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/home/patient/screens/add_patient.dart';
import 'package:swabx/size_config.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

APIService apiService = new APIService();

class BookAnAppointment extends StatelessWidget {
  static String routeName = "/bookAppointment";
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
                      child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text("Book Appointment",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 30),
                      AppointmentTime()
                    ],
                  )))
            ]));
  }
}

class AppointmentTime extends StatefulWidget {
  AppointmentTime({Key key}) : super(key: key);
  @override
  _AppointmentTimeState createState() => _AppointmentTimeState();
}

class _AppointmentTimeState extends State<AppointmentTime> {
  DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  DateFormat _dateFormatYMD = DateFormat('yyyy-MM-dd');
  DateTime _selectedDate;
  String _location = "-1";
  String _locationName = "";
  List<Slot> _earlySlots = [];

  @override
  void initState() {
    super.initState();
    this.setState(() {
      _selectedDate = DateTime.now();
    });

    downloadData();
  }

  Future<String> downloadData() async {
    _location =
        await SharedPreferencesHelper.getString("DefaultTestLocationId");
    _locationName =
        await SharedPreferencesHelper.getString("DefaultTestLocationName");
    apiService
        .getAvailableSlots(_dateFormatYMD.format(_selectedDate), _location)
        .then((value) {
      setState(() {
        _earlySlots = value["earlySlots"];
      });
    });
    return Future.value(""); // return your response
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_selectedDate != null)
            Text(_dateFormat.format(_selectedDate),
                style: TextStyle(fontSize: 18, color: Colors.black)),
          SizedBox(height: 20),
          _buildDatePicker(),
          SizedBox(height: 10),
          Text("Available Slots: " + _locationName,
              style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  color: Colors.black)),
          if (_location != "-1" && _earlySlots.length > 0)
            _buildSlotsCard(_earlySlots)
          else
            noRecords("No Slots Available")
        ]));
  }

  Future<void> _showConfirmation(int status, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Center(child: Text("Appointment Confirmation")),
          content: Container(
            height: 180.0,
            alignment: Alignment.center,
            child: Column(
              children: [
                Image.asset('assets/images/appointment_confirmation.png',
                    width: 100, height: 100),
                Image.asset('assets/images/checked.png'),
                SizedBox(height: 5),
                Text(message)
              ],
            ),
          ),
          actions: <Widget>[
            DefaultButton(
              text: "OK",
              press: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHomeScreen(nextScreen: 2),
                    ));
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _selectSlot(Slot slot) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Center(child: Text("Appointment Details")),
          content: Container(
            height: 155.0,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Location",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    Spacer(),
                    Text(_locationName,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Service Type",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    Spacer(),
                    Text("Swab Test",
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Date",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    Spacer(),
                    Text(_dateFormat.format(_selectedDate),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Time",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    Spacer(),
                    Text(slot.slotStart + " - " + slot.slotEnd,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            DefaultButton(
              text: "Confirm",
              press: () async {
                QRCode code = await SharedPreferencesHelper.getMyQR();
                if (code == null) {
                  Toast.show(
                      "Please fill registration form before booking an Appointment",
                      context,
                      duration: kToastDuration,
                      gravity: Toast.BOTTOM);
                  Timer(Duration(seconds: kToastDuration), () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegisterPatient.routeName, (route) => false);
                  });
                } else {
                  apiService
                      .bookAnAppointment(_location, slot.slotStart,
                          _dateFormatYMD.format(_selectedDate), code.getHash())
                      .then((value) {
                    Navigator.pop(context);

                    if (value.statusCode == 200) {
                      _showConfirmation(1, "Appointment Booked Successfully");
                    } else {
                      Toast.show(value.message, context,
                          duration: kToastDuration, gravity: Toast.BOTTOM);
                    }
                  });
                }
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildSlotsCard(List<Slot> earlySlots) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 10),
      if (earlySlots.length > 0) SizedBox(height: 10),
      ...earlySlots.map((e) => _buildCard(e)).toList()
    ]);
  }

  Widget _buildDatePicker() {
    return DatePicker(DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: kPrimaryColor,
        selectedTextColor: Colors.white, onDateChange: (dt) {
      this.setState(() {
        _selectedDate = dt;
        _earlySlots = [];
      });
      if (_location != "-1")
        apiService
            .getAvailableSlots(_dateFormatYMD.format(dt), _location)
            .then((value) {
          print(value);
          setState(() {
            _earlySlots = value["earlySlots"];
          });
        });
    }, height: 85);
  }

  Widget _buildCard(Slot slot) {
    bool disable = slot.count == 0 ||
        DateTime.parse(dateFormat.format(_selectedDate) + " " + slot.slotEnd)
            .isBefore(DateTime.now());
    return GestureDetector(
        onTap: () => disable ? null : _selectSlot(slot),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: disable ? Colors.grey : Colors.white,
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
                      child: Image.asset('assets/images/appointment.png',
                          width: 45, height: 45)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      width: getProportionateScreenWidth(200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(slot.slotStart + " - " + slot.slotEnd,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(slot.count.toString() + " slots",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: slot.count > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16))
                        ],
                      )),
                  Spacer(),
                  Row(
                    children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                          onPressed: () => null,
                          minWidth: 10,
                          padding: EdgeInsets.all(0.0),
                          child: Image.asset('assets/images/next.png',
                              width: 40, height: 40))
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ));
  }
}
