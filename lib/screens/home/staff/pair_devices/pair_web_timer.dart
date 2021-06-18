import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/helper/connection.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import './web_timer_qr_scanner.dart';

class WebTimeScreen extends StatelessWidget {
  static String routeName = "/web_timer";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, MyHomeScreen.routeName, (route) => false)),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Swab",
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(20),
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kaushan Script"),
            ),
            Text(
              "X - Web Timer",
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(20),
                  color: kPrimaryCustomColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kaushan Script"),
            )
          ],
        ),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  Future<String> downloadData() async {
    String receiver = await SharedPreferencesHelper.getString("RECEIVER");
    print(receiver);
    return Future.value(receiver); // return your response
  }

  @override
  Widget build(BuildContext context) {
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
              return SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(20)),
                    child: Column(
                      children: [
                        SizedBox(height: SizeConfig.screenHeight * 0.05),
                        Image.asset(
                          "assets/images/stopwatch.jpg",
                          height: getProportionateScreenHeight(200),
                          width: getProportionateScreenWidth(200),
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.05),
                        Text("Use " + kAppName + " timer on Web",
                            style: headingStyle),
                        SizedBox(height: SizeConfig.screenHeight * 0.05),
                        if (snapshot.data == null)
                          DefaultButton(
                            text: "Link a Device",
                            press: () {
                              Navigator.pushNamed(
                                  context, ScanWebTimeQRCode.routeName);
                            },
                          )
                        else
                          DefaultButton(
                            text: "Disconnect paired Device",
                            press: () async {
                              await SharedPreferencesHelper.removeString(
                                  "RECEIVER");
                              String receiver =
                                  await SharedPreferencesHelper.getString(
                                      "RECEIVER");
                              print(receiver);

                              Navigator.pushNamedAndRemoveUntil(context,
                                  WebTimeScreen.routeName, (route) => false);
                            },
                          ),
                        SizedBox(height: 20),
                        if (snapshot.data != null)
                          DefaultButton(
                            text: "Start Timer",
                            press: () async {
                              try {
                                String email = await SharedPreferencesHelper
                                    .getUserEmail();
                                String name =
                                    await SharedPreferencesHelper.getUserName();
                                String receiver =
                                    await SharedPreferencesHelper.getString(
                                        "RECEIVER");
                                String jsonData = '{senderName: "' +
                                    email +
                                    '",receiverName: "' +
                                    receiver +
                                    '",patientName: "' +
                                    name +
                                    '"}';
                                con.sendMessage("START_TIMER", jsonData);
                              } on Exception catch (e) {
                                print(e);
                              }

                              //showStartWatch = true;
                            },
                          )
                      ],
                    ),
                  ),
                ),
              );
          }
        });
  }
}

class ChangePassForm extends StatefulWidget {
  @override
  _ChangePassFormState createState() => _ChangePassFormState();
}

class _ChangePassFormState extends State<ChangePassForm> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword;
  String _password;
  String _confirmPassword;

  // Initially password is obscure
  bool _obscureOldPassText = true;

  // Initially password is obscure
  bool _obscurePassText = true;

  // Initially confirmPassword is obscure
  bool _obscureConfirmText = true;

  // Toggles the password show status
  void _toggleOldPassField() {
    setState(() {
      _obscureOldPassText = !_obscureOldPassText;
    });
  }

  // Toggles the password show status
  void _togglePassField() {
    setState(() {
      _obscurePassText = !_obscurePassText;
    });
  }

  // Toggles the password show status
  void _toggleConfirmField() {
    setState(() {
      _obscureConfirmText = !_obscureConfirmText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(15)),
          buildOldPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          buildConfirmPassFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState.validate()) {
                APIService apiService = new APIService();
                apiService
                    .changePassword(
                        oldPassword: _oldPassword,
                        password: _password,
                        confirmPassword: _confirmPassword)
                    .then((value) async {
                  // if all are valid then go to success screen
                  if (value != null &&
                      value.message != null &&
                      value.message.isNotEmpty) {
                    Toast.show(value.message, context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                    if (value.statusCode == 200) {
                      SharedPreferencesHelper.unsetToken();
                      Navigator.pushNamedAndRemoveUntil(
                          context, SignInScreen.routeName, (route) => false);
                    }
                  }
                });
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02)
        ],
      ),
    );
  }

  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      obscureText: _obscureConfirmText,
      maxLength: 15,
      onSaved: (newValue) => _confirmPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && _password == value) {
          _confirmPassword = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return kPassNullError;
        } else if ((_password != value)) {
          return kMatchPassError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscureConfirmText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _toggleConfirmField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscurePassText,
      maxLength: 15,
      onSaved: (newValue) => _password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          _password = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return kPassNullError;
        } else if (value.length < 8) {
          return kShortPassError;
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
            _obscurePassText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _togglePassField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }

  TextFormField buildOldPasswordFormField() {
    return TextFormField(
      obscureText: _obscureOldPassText,
      maxLength: 15,
      onSaved: (newValue) => _oldPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && value.length >= 8) {
          _oldPassword = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          return kPassNullError;
        } else if (value.length < 8) {
          return kShortPassError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Old Password",
        hintText: "Enter your old password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _obscureOldPassText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _toggleOldPassField,
          padding: EdgeInsets.only(right: 20),
        ),
      ),
    );
  }
}
