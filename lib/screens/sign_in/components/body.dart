import 'package:flutter/material.dart';
import 'package:swabx/components/no_account_text.dart';
import 'package:swabx/size_config.dart';
import 'package:swabx/constants.dart';
import 'sign_form.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.06),
                Image.asset(
                  "assets/images/FlashScreenLogo.png",
                  height: getProportionateScreenHeight(265),
                  width: getProportionateScreenWidth(235),
                ),
                homeScreenAppTitle(30, kPrimaryColor),
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                SignForm(),
                SizedBox(height: SizeConfig.screenHeight * 0.01),
                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
