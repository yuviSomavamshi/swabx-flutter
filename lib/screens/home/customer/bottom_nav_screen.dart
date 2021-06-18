import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/customer/screens/my_locations.dart';
import 'package:swabx/screens/home/customer/screens/my_staff.dart';
import 'package:swabx/screens/profile/profile_screen.dart';

import 'home_screen.dart';

// ignore: must_be_immutable
class CustomerBottomNavScreen extends StatefulWidget {
  int nextScreen;
  CustomerBottomNavScreen({Key key, @required this.nextScreen})
      : super(key: key);

  @override
  _CustomerBottomNavScreenState createState() =>
      _CustomerBottomNavScreenState(nextScreen: this.nextScreen);
}

class _CustomerBottomNavScreenState extends State<CustomerBottomNavScreen> {
  int nextScreen;

  _CustomerBottomNavScreenState({@required this.nextScreen});

  final List _screens = [
    HomeScreen(),
    MyStaffList(),
    LocationHomeScreenBody(),
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
        items: [Icons.home, Icons.people, Icons.location_pin, Icons.person]
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
