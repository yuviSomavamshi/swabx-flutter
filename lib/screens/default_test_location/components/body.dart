import 'package:flutter_svg/svg.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/models/Location.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/home/patient/screens/location_dropdown.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

import 'package:swabx/helper/APIService.dart';

APIService apiService = new APIService();

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
          child: Column(
            children: [
              SvgPicture.asset(
                "assets/images/swabkit1.svg",
                width: 60,
              ),
              Text("Default Test Location", style: headingStyle),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              Text(
                "Please select the Swab test location",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.02),
              ChangeLocation()
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeLocation extends StatefulWidget {
  @override
  _ChangeLocationState createState() => _ChangeLocationState();
}

class _ChangeLocationState extends State<ChangeLocation> {
  String _location = "-1";
  List<Location> _locations = [
    Location.fromJson({"id": "-1", "location": "Select"})
  ];
  @override
  void initState() {
    super.initState();
    _getLocations();
  }

  void _getLocations() async {
    apiService.getAllLocations().then((value) {
      setState(() {
        _locations = value;
      });
    });
    String id =
        await SharedPreferencesHelper.getString("DefaultTestLocationId");
    _location = (id != null) ? id : "-1";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          LocationDropDown(
              locations: _locations,
              location: _location,
              onChanged: (String loc) {
                this.setState(() {
                  _location = loc;
                });
              }),
          SizedBox(height: getProportionateScreenHeight(15)),
          DefaultButton(
            text: "Set Location",
            press: () async {
              if (_location == "-1") {
                Toast.show("Please select location", context);
              } else {
                Location selected =
                    _locations.firstWhere((element) => element.id == _location);

                await SharedPreferencesHelper.setString(
                    "DefaultTestLocationId", _location);
                await SharedPreferencesHelper.setString(
                    "DefaultTestLocationName", selected.location);
                String role = await SharedPreferencesHelper.getUserRole();
                if (role == "Staff") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaffHomeScreen(nextScreen: 2),
                      ));
                } else if (role == "Patient") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientHomeScreen(nextScreen: 2),
                      ));
                }
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02)
        ],
      ),
    );
  }
}
