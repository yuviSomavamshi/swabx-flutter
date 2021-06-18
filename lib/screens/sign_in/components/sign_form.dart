import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/components/custom_surfix_icon.dart';
import 'package:swabx/helper/keyboard.dart';
import 'package:swabx/screens/forgot_password/forgot_password_screen.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:toast/toast.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String email;

// Initially password is obscure
  bool _obscureText = true;
  String _password;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: getProportionateScreenWidth(16),
                      color: kPrimaryColor),
                ),
              )
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "Sign In",
            press: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                APIService apiService = new APIService();
                apiService
                    .authenticate(email: email, password: _password)
                    .then((value) async {
                  // if all are valid then go to success screen
                  if (value != null) {
                    if (value.statusCode == 200 && value.jwtToken.isNotEmpty) {
                      if (AllowedRoles.contains(value.role)) {
                        if (value.isVerified) {
                          SharedPreferencesHelper.saveSession(value);
                          KeyboardUtil.hideKeyboard(context);
                          if (value.role == "Patient") {
                            Navigator.pushNamedAndRemoveUntil(context,
                                PatientHomeScreen.routeName, (route) => false);
                          } else if (value.role == "Customer") {
                            Navigator.pushNamedAndRemoveUntil(context,
                                CustomerHomeScreen.routeName, (route) => false);
                          } else if (value.role == "Staff") {
                            Navigator.pushNamedAndRemoveUntil(context,
                                StaffHomeScreen.routeName, (route) => false);
                          }
                        } else {
                          Toast.show(
                              "Email is not Verified. Please activate your account.",
                              context,
                              duration: kToastDuration,
                              gravity: Toast.BOTTOM);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pushNamed(
                              context, ForgotPasswordScreen.routeName);
                        }
                      } else {
                        Toast.show(
                            "Sorry! You are not authorized to Access", context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                      }
                    } else {
                      Toast.show(value.message, context,
                          duration: kToastDuration, gravity: Toast.BOTTOM);
                    }
                  }
                }).catchError((error) {
                  print(error);
                  Toast.show(
                      "Something went wrong please try after sometime", context,
                      duration: kToastDuration, gravity: Toast.BOTTOM);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscureText,
      onSaved: (newValue) => _password = newValue,
      validator: (value) {
        if (value.isEmpty) {
          return kPassNullError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _toggle,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      validator: (value) {
        if (value.isEmpty) {
          return kEmailNullError;
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          return kInvalidEmailError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }
}
