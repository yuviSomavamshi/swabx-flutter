import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';

import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';

class SignInText extends StatelessWidget {
  const SignInText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Go back to Sign In page? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(16)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, SignInScreen.routeName),
          child: Text(
            "Sign In",
            style: TextStyle(
                fontSize: getProportionateScreenWidth(16),
                color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
