import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
    Timer(Duration(seconds: 3), () async {
      try {
        bool isAuthenticated = await SharedPreferencesHelper.isAuthenticated();
        if (isAuthenticated) {
          bool bioMetrics = await _authenticateMe();
          if (bioMetrics) {
            String role = await SharedPreferencesHelper.getUserRole();

            if (role == "Patient" || role == "Customer" || role == "Staff") {
              Navigator.pushNamedAndRemoveUntil(
                  context, MyHomeScreen.routeName, (route) => false);
            }
          } else {
            SharedPreferencesHelper.clearSession();
            Navigator.pushNamedAndRemoveUntil(
                context, SignInScreen.routeName, (route) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, SignInScreen.routeName, (route) => false);
        }
      } on Exception catch (e) {
        print(e);
      }
    });
  }

  Future<bool> _authenticateMe() async {
    bool authenticated = false;
    try {
      bool hasFingerPrintSupport =
          await _localAuthentication.canCheckBiometrics;
      if (hasFingerPrintSupport) {
        authenticated = await _localAuthentication.authenticate(
          biometricOnly: true,
          localizedReason: "Please authenticate to unlock " + kAppName,
          useErrorDialogs: true,
          stickyAuth: true,
        );
      } else {
        authenticated = true;
      }
    } catch (e) {
      print(e);
    }
    if (!mounted) return false;
    return authenticated;
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(
                  children: <Widget>[
                    Spacer(
                      flex: 2,
                    ),
                    SvgPicture.asset("assets/images/splash-screen.svg",
                        height: screenHeight * 0.16),
                    SizedBox(
                      height: 20,
                    ),
                    homeScreenAppTitle(40, kPrimaryColor),
                    Text("Healthcare made simple!",
                        textAlign: TextAlign.center),
                    Spacer(flex: 2),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image:
                                  AssetImage('assets/images/certis-logo.png'),
                              width: getProportionateScreenWidth(130),
                              height: getProportionateScreenHeight(30),
                            )
                          ]),
                    ),
                    SizedBox(height: 5),
                    Text("powered by healthxchain solution.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: getProportionateScreenWidth(13))),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
