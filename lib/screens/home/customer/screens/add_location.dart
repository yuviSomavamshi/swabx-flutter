import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/helper/keyboard.dart';
import 'package:swabx/components/default_button.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

class RegisterLocation extends StatelessWidget {
  static String routeName = "/registerLocation";
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
                      Text("Location Registration",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 30),
                      LocationRegForm()
                    ],
                  )))
            ]));
  }
}

class LocationRegForm extends StatefulWidget {
  @override
  _LocationRegFormState createState() => _LocationRegFormState();
}

class _LocationRegFormState extends State<LocationRegForm> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  double _maxPerSlot = 20;
  int _slotInterval = 30;
  DateTime _startDate = new DateTime.now();
  DateTime _endDate= new DateTime.now();

  String _dayStartTime = "00:00:00";
  String _dayEndTime = "23:59:59";

  String _breakStartTime = "13:00:00";
  String _breakEndTime = "13:59:59";

  bool confirmation = false;
  bool buttonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(
            children: [
              _buildLocationNameFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              buildStartDateFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              buildEndDateFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              _buildPerSlotFormField(),
              DefaultButton(
                text: "Register",
                press: () async {
                  KeyboardUtil.hideKeyboard(context);
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      buttonEnabled = false;
                    });
                    APIService apiService = new APIService();
                    apiService
                        .createLocation(
                            _name,
                            _slotInterval,
                            _dayStartTime,
                            _dayEndTime,
                            _breakStartTime,
                            _breakEndTime,
                            _maxPerSlot)
                        .then((value) {
                      if (value != null) {
                        // if all are valid then go to success screen
                        if (value.statusCode == 200) {
                          Toast.show(
                              "Registered the Location successfully.", context,
                              duration: kToastDuration, gravity: Toast.BOTTOM);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerHomeScreen(nextScreen: 2),
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
              ),
              SizedBox(height: getProportionateScreenHeight(20))
            ],
          ),
        ));
  }

  TextFormField _buildLocationNameFormField() {
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
          return kLocationNameNullError;
        }
        if (value.isNotEmpty && value.length < 4) {
          return "Minimum 4 alphanumeric characters";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Location name",
        hintText: "Enter location name",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: Icon(Icons.location_pin),
      ),
    );
  }

  TextFormField buildStartDateFormField() {
    TextEditingController intialDateValue = TextEditingController();
    if(_startDate!=null)
    intialDateValue.text =  dateFormat.format(_startDate);
        Future<void> _selectDate(BuildContext context) async {
                DateTime now = DateTime.now();
        if(now!=null){
          DateTime picked = await showDatePicker(
            context: context,
            initialDate: _startDate,
            firstDate: DateTime(now.year, now.month, now.day + 1),
            lastDate: DateTime(now.year, now.month, now.day + 2));
        if (picked != null && picked != now)
          setState(() {
            _startDate = picked;
            intialDateValue.text = dateFormat.format(_startDate);
          });
       }
      }
    return TextFormField(
      keyboardType: TextInputType.phone,
      autocorrect: false,
      controller: intialDateValue,
      onSaved: (newValue) async {},
      onTap: ()=>_selectDate(context) ,
      maxLines: 1,
      validator: (value) {
        if (value.isEmpty || value.length < 1) {
          return "Please select start date";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Start Date',
        suffixIcon: const Icon(Icons.calendar_today),
        labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
      ),
    );
  }

  TextFormField buildEndDateFormField() {
    TextEditingController intialDateValue = TextEditingController();
    if(_endDate!=null)
    intialDateValue.text = dateFormat.format(_endDate);

Future<void> _selectDate(BuildContext context) async {
                DateTime now = DateTime.now();
        if(now!=null){
          DateTime picked = await showDatePicker(
            context: context,
            initialDate: _endDate,
            firstDate: DateTime(now.year, now.month, now.day + 1),
            lastDate: DateTime(now.year, now.month, now.day + 60)
            );
        if (picked != null && picked != now)
          setState(() {
            _endDate = picked;
            intialDateValue.text = dateFormat.format(_endDate);
          });
       }
      }
    return TextFormField(
      keyboardType: TextInputType.phone,
      autocorrect: false,
      controller: intialDateValue,
      onSaved: (newValue) async {},
      onTap: ()=>_selectDate(context) ,
      maxLines: 1,
      validator: (value) {
        if (value.isEmpty || value.length < 1) {
          return "Please select end date";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'End Date',
        suffixIcon: const Icon(Icons.calendar_today),
        labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
      ),
    );
  }

  TextFormField _buildPerSlotFormField() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))],
      onSaved: (value) => _maxPerSlot = double.parse(value),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _maxPerSlot = double.parse(value);
        }
        return null;
      },
      validator: (value) {
        try {
          if (value.trim().length == 0 || double.parse(value) < 1) {
            return "Minimum one patient is required per slot";
          }

          if (double.parse(value) > 100) {
            return "Exceeding maximum number of patients per slot\nlimit. Allowed limit is 100";
          }
        } catch (e) {}

        return null;
      },
      decoration: InputDecoration(
        labelText: "Maximum Patients Per Slot",
        hintText: "Maximum Number of Patients Per Slot",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: Icon(Icons.people),
      ),
    );
  }
}
