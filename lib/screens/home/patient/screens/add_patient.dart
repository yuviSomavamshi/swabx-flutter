import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/helper/keyboard.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

class RegisterPatient extends StatelessWidget {
  static String routeName = "/registerPatient";
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                      child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text("User Registration",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 30),
                      PatientRegForm()
                    ],
                  )))
            ]));
  }
}

class PatientRegForm extends StatefulWidget {
  @override
  _PatientRegFormState createState() => _PatientRegFormState();
}

class _PatientRegFormState extends State<PatientRegForm> {
  final _formKey = GlobalKey<FormState>();
  String id;
  String name;
  DateTime _selectedDate = new DateTime.now();
  String nationality = "SG";
  String relationship = "Self";
  bool confirmation = false;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getUserName().then((value) {
      setState(() {
        name = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: Column(
          children: [
            buildPassportFormField(),
            SizedBox(height: getProportionateScreenHeight(5)),
            buildNameFormField(),
            SizedBox(height: getProportionateScreenHeight(5)),
            buildDobFormField(),
            SizedBox(height: getProportionateScreenHeight(25)),
            buildRTFormField(),
            SizedBox(height: getProportionateScreenHeight(25)),
            buildNationFormField(),
            SizedBox(height: getProportionateScreenHeight(20)),
            Text(
              "I voluntarily consent to take part in this research study. I have fully discussed and understood the purpose and procedures of this study. This study has been explained to me in a language that I understand. I have been given enough time to ask any questions that I have about the study, and all my questions have been answered to my satisfaction. I have also been informed and understood the procedures available and their possible benefits and risks.",
              textAlign: TextAlign.left,
              softWrap: true,
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(12),
                  color: Colors.black),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            Text(
              "By agreeing to participate in this study, I agree to provide breath samples and access to my test results and other respiratory diseases as long as the results are used only in this study.",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(12),
                  color: Colors.black),
            ),
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
              enabled: confirmation,
              press: () async {
                KeyboardUtil.hideKeyboard(context);
                if (_formKey.currentState.validate() && confirmation) {
                  String status = await SharedPreferencesHelper.addQRCode(
                      QRCode(
                          id: id,
                          name: name,
                          dob: dateFormat.format(_selectedDate),
                          relationship: relationship,
                          nationality: nationality,
                          confirmation: confirmation,
                          created: DateTime.now().toString()));
                  if (status == "Registered") {
                    Toast.show("Successfully Registered User details.", context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PatientHomeScreen(nextScreen: 1)));
                  } else {
                    Toast.show(status, context,
                        duration: kToastDuration, gravity: Toast.BOTTOM);
                  }
                }
              },
            ),
            SizedBox(height: getProportionateScreenHeight(20))
          ],
        ),
      ),
    );
  }

  TextFormField buildPassportFormField() {
    return TextFormField(
      maxLength: 20,
      onSaved: (newValue) => id = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          id = value;
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty || value.length < 1) {
          return kICPassportNullError;
        }
        if (value.isNotEmpty && value.length < 8) {
          return "Minimum 8 alphanumeric characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "IC/Passport",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  TextFormField buildNameFormField() {
    TextEditingController intialValue = TextEditingController();
    intialValue.text = name;
    return TextFormField(
      controller: intialValue,
      maxLength: 25,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          name = value;
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty || value.length < 1) {
          return kNameFNullError;
        }
        if (value.isNotEmpty && value.length < 4) {
          return "Minimum 4 alphanumeric characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Name",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  TextFormField buildDobFormField() {
    TextEditingController intialDateValue = TextEditingController();
    intialDateValue.text = dateFormat.format(_selectedDate);
    Future _selectDate() async {
      DateTime picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: new DateTime(1900),
          lastDate: new DateTime.now());
      if (picked != null)
        setState(() {
          _selectedDate = picked;
          intialDateValue.text = dateFormat.format(_selectedDate);
        });
    }

    return TextFormField(
      keyboardType: TextInputType.phone,
      autocorrect: false,
      // autofocus: false,
      controller: intialDateValue,
      onSaved: (newValue) async {},
      onTap: () {
        _selectDate();
        //FocusScope.of(context).requestFocus(new FocusNode());
      },
      maxLines: 1,
      validator: (value) {
        if (value.isEmpty || value.length < 1) {
          return kDobNullError;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        suffixIcon: const Icon(Icons.calendar_today),
        labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
      ),
    );
  }

  DropDownFormField buildRTFormField() {
    return DropDownFormField(
      titleText: 'Relationship',
      value: relationship,
      onSaved: (value) {
        setState(() {
          relationship = value;
        });
      },
      onChanged: (value) {
        setState(() {
          relationship = value;
        });
      },
      dataSource: RelationshipTypes,
      textField: 'display',
      valueField: 'value',
    );
  }

  DropDownFormField buildNationFormField() {
    return DropDownFormField(
      titleText: 'Nationality',
      value: nationality,
      onSaved: (value) {
        setState(() {
          nationality = value;
        });
      },
      onChanged: (value) {
        setState(() {
          nationality = value;
        });
      },
      dataSource: CountryList,
      textField: 'name',
      valueField: 'code',
    );
  }
}
