import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/patient/screens/my_appointments.dart';
import 'package:swabx/screens/home/patient/screens/my_qrcodes.dart';
import 'package:swabx/screens/profile/profile_screen.dart';

import 'home_screen.dart';

// ignore: must_be_immutable
class PatientBottomNavScreen extends StatefulWidget {
  int nextScreen;
  PatientBottomNavScreen({Key key, @required this.nextScreen})
      : super(key: key);

  @override
  _PatientBottomNavScreenState createState() =>
      _PatientBottomNavScreenState(nextScreen: this.nextScreen);
}

class _PatientBottomNavScreenState extends State<PatientBottomNavScreen> {
  int nextScreen;

  _PatientBottomNavScreenState({@required this.nextScreen});

  final List _screens = [
    PatientDashboardScreen(),
    MyRegisteredQrCodes(),
    MyAppointments(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[nextScreen],
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nextScreen,
        onTap: (index) => setState(() => nextScreen = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: kPrimaryColor,
        elevation: 0.0,
        items: [Icons.home, Icons.qr_code, Icons.calendar_today, Icons.person]
            .asMap()
            .map((key, value) => MapEntry(
                  key,
                  BottomNavigationBarItem(
                    label: '',
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: nextScreen == key ? kPrimaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Icon(value),
                    ),
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }
}
