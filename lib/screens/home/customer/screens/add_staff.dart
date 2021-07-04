import 'package:flutter/material.dart';

import 'package:swabx/components/custom_surfix_icon.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/keyboard.dart';
import 'package:swabx/helper/random_password_generator.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

final password = RandomPasswordGenerator();

class RegisterStaff extends StatelessWidget {
  static String routeName = "/registerStaff";
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
                      Text("Create a New Staff",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 30),
                      StaffRegForm()
                    ],
                  )))
            ]));
  }
}

class StaffRegForm extends StatefulWidget {
  @override
  _StaffRegFormState createState() => _StaffRegFormState();
}

class _StaffRegFormState extends State<StaffRegForm> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _name;
  bool confirmation = false;
  bool buttonEnabled = false;
  String _password = password.randomPassword(
      letters: true,
      uppercase: true,
      numbers: true,
      specialChar: true,
      passwordLength: 10);

  // Initially password is obscure
  bool _obscurePassText = true;

  // Toggles the password show status
  void _togglePassField() {
    setState(() {
      _obscurePassText = !_obscurePassText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
        child: Column(
          children: [
            buildFirstNameFormField(),
            buildEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(20)),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(10)),
            Row(children: [
              Checkbox(
                value: confirmation,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  if (value) {
                    KeyboardUtil.hideKeyboard(context);
                  }
                  setState(() {
                    confirmation = value;
                    buttonEnabled = value;
                  });
                },
              ),
              Text(
                "I Agree to Terms & Conditions",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: getProportionateScreenWidth(16),
                    color: kPrimaryColor),
              )
            ]),
            SizedBox(height: getProportionateScreenHeight(10)),
            DefaultButton(
              text: "Register",
              enabled: confirmation && buttonEnabled,
              press: () async {
                KeyboardUtil.hideKeyboard(context);
                if (_formKey.currentState.validate() && confirmation) {
                  setState(() {
                    buttonEnabled = false;
                  });
                  APIService apiService = new APIService();
                  apiService
                      .createStaff(
                          name: _name, email: _email, password: _password)
                      .then((value) {
                    if (value != null) {
                      // if all are valid then go to success screen
                      if (value.statusCode == 200) {
                        Toast.show(
                            "Registered the staff successfully.", context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomerHomeScreen(nextScreen: 1),
                            ));
                      } else if (value.message != null &&
                          value.message.isNotEmpty) {
                        setState(() {
                          buttonEnabled = true;
                        });
                        Toast.show(value.message, context,
                            duration: kToastDuration, gravity: Toast.BOTTOM);
                      }
                    }
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => _email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && emailValidatorRegExp.hasMatch(value)) {
          _email = value;
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !emailValidatorRegExp.hasMatch(value)) {
          return kInvalidEmailError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Staff Email",
        hintText: "Enter staff email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      maxLength: 25,
      onSaved: (newValue) => _name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          _name = value;
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          return kNamelNullError;
        }
        if (value.isNotEmpty && value.length < 4) {
          return "Minimum 4 alphanumeric characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Staff name",
        hintText: "Enter staff name",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscurePassText,
      maxLength: 15,
      initialValue: _password,
      onSaved: (newValue) => _password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          _password = value;
        }
      },
      validator: (value) {
        return validatePassword(value);
      },
      decoration: InputDecoration(
        labelText: "Default password",
        hintText: "Enter default password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscurePassText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _togglePassField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }
}
