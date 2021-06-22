import 'package:swabx/constants.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/change_password/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/screens/default_test_location/default_test_location_screen.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/size_config.dart';
import '../../sign_in/sign_in_screen.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';

// ignore: must_be_immutable
class Body extends StatelessWidget {
  String name = "";
  String email = "";
  String role = "";

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<String>(
      future: downloadData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return new Scaffold(
                appBar: CustomAppBar(),
                body:
                    CustomScrollView(physics: ClampingScrollPhysics(), slivers: <
                        Widget>[
                  buildHeader(screenHeight),
                  SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      sliver: SliverToBoxAdapter(
                          child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text("My Profile",
                              style: TextStyle(
                                  fontSize: getProportionateScreenWidth(20),
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 30)
                        ],
                      ))),
                  SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      sliver: SliverToBoxAdapter(
                          child: Column(
                        children: [
                          ProfilePic(),
                          SizedBox(height: 20),
                          ProfileMenu(
                              text: name,
                              icon: "assets/icons/User Icon.svg",
                              press: () => {},
                              showLeading: false),
                          ProfileMenu(
                              text: email,
                              icon: "assets/icons/Mail.svg",
                              press: () => {},
                              showLeading: false),
                          ProfileMenu(
                            text: "Change Password",
                            icon: "assets/icons/Settings.svg",
                            press: () {
                              Navigator.of(context)
                                  .pushNamed(ChangePasswordScreen.routeName);
                            },
                          ),
                          if (role == "Staff" || role == "Patient")
                            ProfileMenu(
                              text: "Default Test Location",
                              icon: "assets/icons/Discover.svg",
                              press: () {
                                Navigator.of(context)
                                    .pushNamed(DefaultTestLocation.routeName);
                              },
                            ),
                          ProfileMenu(
                            text: "Sign Out",
                            icon: "assets/icons/Log out.svg",
                            press: () async {
                              SharedPreferencesHelper.clearSession();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  SignInScreen.routeName, (route) => false);
                            },
                          ),
                        ],
                      )))
                ])); // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
  }

  Future<String> downloadData() async {
    name = await SharedPreferencesHelper.getUserName();
    email = await SharedPreferencesHelper.getUserEmail();
    role = await SharedPreferencesHelper.getUserRole();
    return Future.value(""); // return your response
  }
}
