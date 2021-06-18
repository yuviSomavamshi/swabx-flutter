import 'package:swabx/constants.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/home/customer/bottom_nav_screen.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/patient/bottom_nav_screen.dart';
import 'package:swabx/screens/home/staff/bottom_nav_screen.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomeScreen extends StatefulWidget {
  static String routeName = "/myHome";
  MyHomeScreen({Key key}) : super(key: key);
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    //_authenticateMe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: downloadData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else if (snapshot.data == "Patient") {
            return PatientHomeScreen(nextScreen: 0);
          } else if (snapshot.data == "Customer") {
            return CustomerHomeScreen(nextScreen: 0);
          } else if (snapshot.data == "Staff") {
            return StaffHomeScreen(nextScreen: 0);
          } else {
            return SignInScreen();
          }
        }
      },
    );
  }

  Future<String> downloadData() async {
    return Future.value(
        await SharedPreferencesHelper.getUserRole()); // return your response
  }
}

// ignore: must_be_immutable
class CustomerHomeScreen extends StatelessWidget {
  static String routeName = "/customerHome";
  int nextScreen;
  CustomerHomeScreen({Key key, @required this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar:
            CustomerBottomNavScreen(nextScreen: this.nextScreen));
  }
}

// ignore: must_be_immutable
class PatientHomeScreen extends StatelessWidget {
  static String routeName = "/patientHome";
  int nextScreen;
  PatientHomeScreen({Key key, @required this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar:
            PatientBottomNavScreen(nextScreen: this.nextScreen));
  }
}

// ignore: must_be_immutable
class StaffHomeScreen extends StatelessWidget {
  static String routeName = "/staffHome";
  int nextScreen;
  StaffHomeScreen({Key key, @required this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar: StaffBottomNavScreen(nextScreen: this.nextScreen));
  }
}
