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
import 'package:weekday_selector/weekday_selector.dart';

APIService apiService = new APIService();

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
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
  double _windowTimeInterval = 3;
  double _slotInterval = 30;
  DateTime _startDate = new DateTime.now();
  DateTime _endDate = new DateTime.now();

  TimeOfDay _dayStartTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _dayEndTime = TimeOfDay(hour: 0, minute: 0);

  bool confirmation = false;
  bool buttonEnabled = false;
  List<bool> isSelected = [true, false];
  List<Map<String, TimeOfDay>> _breaks = [];
  final _weekdays = List.filled(7, true);

  @override
  void initState() {
    super.initState();
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
              _buildLocationNameFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              Row(children: [
                _buildStartDateFormField(),
                Spacer(),
                _buildEndDateFormField()
              ]),
              SizedBox(height: getProportionateScreenHeight(40)),
              _buildWeeklyConfig(),
              SizedBox(height: getProportionateScreenHeight(30)),
              _buildDayTimeField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              _buildIntervalFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              _buildPerSlotFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              _buildWinSlotFormField(),
              SizedBox(height: getProportionateScreenHeight(20)),
              _addBreakTime(),
              SizedBox(height: 20),
              ...List.generate(_breaks.length, (index) {
                return _buildBreakTimeBlock(index);
              }).toList(),
              SizedBox(height: 20),
              DefaultButton(
                text: "Register",
                press: () async {
                  final now = new DateTime.now();
                  KeyboardUtil.hideKeyboard(context);
                  List<Map<String, dynamic>> breaks = [];

                  for (var i = 0; i < _breaks.length; i++) {
                    var start = _breaks[i]["start"];
                    var end = _breaks[i]["end"];

                    final dts = DateTime(now.year, now.month, now.day,
                        start.hour, start.minute, 0);
                    final dte = DateTime(
                        now.year, now.month, now.day, end.hour, end.minute, 0);
                    breaks.add({
                      "startTime": timeFormat.format(dts),
                      "endTime": timeFormat.format(dte)
                    });
                  }

                  List<Map<String, dynamic>> days = [];
                  for (var i = 0; i < _weekdays.length; i++) {
                    if (_weekdays[i]) {
                      var day;
                      switch (i) {
                        case 0:
                          day = "Sunday";
                          break;
                        case 1:
                          day = "Monday";
                          break;
                        case 2:
                          day = "Tuesday";
                          break;
                        case 3:
                          day = "Wednesday";
                          break;
                        case 4:
                          day = "Thursday";
                          break;
                        case 5:
                          day = "Friday";
                          break;
                        case 6:
                          day = "Saturday";
                          break;
                      }

                      final dts = DateTime(now.year, now.month, now.day,
                          _dayStartTime.hour, _dayStartTime.minute, 0);
                      final dte = DateTime(now.year, now.month, now.day,
                          _dayEndTime.hour, _dayEndTime.minute, 0);

                      days.add({
                        "day": day,
                        "slotStart": timeFormat.format(dts),
                        "slotEnd": timeFormat.format(dte),
                        "slotTime": _slotInterval.toStringAsFixed(0),
                        "max_slots": _maxPerSlot.toStringAsFixed(0),
                        "test_interval": _windowTimeInterval.toStringAsFixed(0),
                        "breaks": breaks
                      });
                    }
                  }

                  Map<String, dynamic> payload = {
                    "location": _name,
                    "startDate": dateFormat.format(_startDate),
                    "endDate": dateFormat.format(_endDate),
                    "days": days
                  };

                  if (_formKey.currentState.validate()) {
                    setState(() {
                      buttonEnabled = false;
                    });
                    apiService.createLocation(payload).then((value) {
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

  Widget _addBreakTime() {
    return ElevatedButton(
        onPressed: _breaks.length < 5
            ? () {
                Map map = Map<String, TimeOfDay>.from({
                  "start": TimeOfDay(hour: 0, minute: 0),
                  "end": TimeOfDay(hour: 0, minute: 0)
                });

                setState(() {
                  _breaks.add(map);
                });
              }
            : null,
        child: Text(
          "Add Break Time",
          style: TextStyle(fontSize: getProportionateScreenWidth(20)),
        ),
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor)));
  }

  Widget _buildBreakTimeBlock(int index) {
    Map<String, TimeOfDay> map = _breaks[index];
    TimeOfDay startTime = (map != null && map["start"] != null)
            ? map["start"]
            : TimeOfDay(hour: 0, minute: 0),
        endTime = (map != null && map["end"] != null)
            ? map["end"]
            : TimeOfDay(hour: 0, minute: 0);

    TextEditingController intialStartTimeValue = TextEditingController();
    intialStartTimeValue.text = startTime.format(context);
    TextEditingController intialEndTimeValue = TextEditingController();
    intialEndTimeValue.text = endTime.format(context);
    void _selectStartTime() async {
      final TimeOfDay newTime = await showTimePicker(
          context: context,
          helpText: "Test Start Time",
          initialTime: startTime);
      if (newTime != null) {
        KeyboardUtil.hideKeyboard(context);
        setState(() {
          startTime = newTime;
          endTime = newTime;
          map["start"] = newTime;
          map["end"] = newTime;
          _breaks[index] = map;
          intialStartTimeValue.text = startTime.format(context);
        });
      }
    }

    void _selectEndTime() async {
      final TimeOfDay newTime = await showTimePicker(
          context: context, helpText: "Test End Time", initialTime: endTime);
      if (newTime != null) {
        KeyboardUtil.hideKeyboard(context);
        if ((newTime.hour.toDouble() + (newTime.minute.toDouble() / 60)) <
            (startTime.hour.toDouble() + (startTime.minute.toDouble() / 60))) {
          Toast.show("End time cannot be lesser than Start time", context,
              duration: kToastDuration, gravity: Toast.BOTTOM);
          setState(() {
            endTime = startTime;
            intialEndTimeValue.text = startTime.format(context);
          });
          return;
        }

        setState(() {
          endTime = newTime;
          map["end"] = newTime;
          _breaks[index] = map;
          intialEndTimeValue.text = endTime.format(context);
        });
      }
    }

    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
              width: getProportionateScreenWidth(140),
              child: TextFormField(
                  showCursor: false,
                  readOnly: true,
                  controller: intialStartTimeValue,
                  onSaved: (newValue) async {},
                  onTap: () => _selectStartTime(),
                  maxLines: 1,
                  validator: (value) {
                    if (value.isEmpty || value.length < 1) {
                      return "Please select break start time";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: getProportionateScreenHeight(15)),
                  decoration: InputDecoration(
                    labelText: 'Break Start Time',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      ),
                      onPressed: null,
                      padding: EdgeInsets.all(0),
                    ),
                    labelStyle:
                        TextStyle(decorationStyle: TextDecorationStyle.solid),
                  ))),
          Spacer(),
          Container(
              width: getProportionateScreenWidth(140),
              child: TextFormField(
                  showCursor: false,
                  readOnly: true,
                  controller: intialEndTimeValue,
                  onSaved: (newValue) async {},
                  onTap: () => _selectEndTime(),
                  maxLines: 1,
                  validator: (value) {
                    if (value.isEmpty || value.length < 1) {
                      return "Please select break end time";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: getProportionateScreenHeight(15)),
                  decoration: InputDecoration(
                    labelText: 'Break End Time',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      ),
                      onPressed: null,
                      padding: EdgeInsets.all(0),
                    ),
                    labelStyle:
                        TextStyle(decorationStyle: TextDecorationStyle.solid),
                  ))),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _breaks.removeAt(index);
              });
            },
            padding: EdgeInsets.all(0),
          )
        ]));
  }

  Widget _buildWeeklyConfig() {
    return WeekdaySelector(
      selectedFillColor: kPrimaryColor,
      selectedElevation: 10,
      elevation: 7,
      disabledElevation: 0,
      onChanged: (int day) {
        setState(() {
          // Use module % 7 as Sunday's index in the array is 0 and
          // DateTime.sunday constant integer value is 7.
          final index = day % 7;
          // We "flip" the value in this example, but you may also
          // perform validation, a DB write, an HTTP call or anything
          // else before you actually flip the value,
          // it's up to your app's needs.
          _weekdays[index] = !_weekdays[index];
        });
      },
      values: _weekdays,
    );
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
        suffixIcon: IconButton(
          icon: Icon(
            Icons.location_pin,
            color: Colors.grey,
          ),
          onPressed: null,
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  Widget _buildStartDateFormField() {
    TextEditingController intialDateValue = TextEditingController();
    intialDateValue.text = dateFormat.format(_startDate);
    Future<void> _selectDate() async {
      DateTime now = DateTime.now();

      DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: new DateTime.now(),
          lastDate: DateTime(now.year + 1, now.month, now.day));
      if (pickedDate != null && pickedDate != now)
        setState(() {
          _startDate = pickedDate;
          _endDate = _startDate;
          intialDateValue.text = dateFormat.format(_startDate);
        });
    }

    return Container(
        width: getProportionateScreenWidth(155),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          autocorrect: false,
          controller: intialDateValue,
          onSaved: (newValue) async {},
          onTap: () => _selectDate(),
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty || value.length < 1) {
              return "Please select start date";
            }
            return null;
          },
          style: TextStyle(fontSize: getProportionateScreenHeight(15)),
          decoration: InputDecoration(
            labelText: 'Start Date',
            suffixIcon: IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.grey,
              ),
              onPressed: null,
              padding: EdgeInsets.all(0),
            ),
            labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
          ),
        ));
  }

  Widget _buildEndDateFormField() {
    TextEditingController intialDateValue = TextEditingController();
    intialDateValue.text = dateFormat.format(_endDate);

    Future<void> _selectDate() async {
      DateTime now = DateTime.now();
      DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: _endDate,
          firstDate: _startDate,
          lastDate: DateTime(now.year + 10, now.month, now.day));
      if (pickedDate != null && pickedDate != now) {
        setState(() {
          _endDate = pickedDate;
          intialDateValue.text = dateFormat.format(_endDate);
        });
      }
    }

    return Container(
        width: getProportionateScreenWidth(155),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          autocorrect: false,
          controller: intialDateValue,
          onSaved: (newValue) async {},
          onTap: () => _selectDate(),
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty || value.length < 1) {
              return "Please select end date";
            }
            return null;
          },
          style: TextStyle(fontSize: getProportionateScreenHeight(15)),
          decoration: InputDecoration(
            labelText: 'End Date',
            suffixIcon: IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.grey,
              ),
              onPressed: null,
              padding: EdgeInsets.all(0),
            ),
            labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
          ),
        ));
  }

  Widget _buildDayTimeField() {
    TextEditingController intialDateValue = TextEditingController();
    TextEditingController intialEnd = TextEditingController();
    intialDateValue.text = _dayStartTime.format(context);
    intialEnd.text = _dayEndTime.format(context);

    void _selectStartTime() async {
      final TimeOfDay newTime = await showTimePicker(
          context: context,
          helpText: "Test Start Time",
          initialTime: _dayStartTime);
      if (newTime != null) {
        setState(() {
          _dayStartTime = newTime;
          _dayEndTime = _dayStartTime;
        });
      }
    }

    void _selectEndTime() async {
      final TimeOfDay newTime = await showTimePicker(
          context: context,
          helpText: "Test End Time",
          initialTime: _dayEndTime);
      if (newTime != null && _dayStartTime != null) {
        if ((newTime.hour.toDouble() + (newTime.minute.toDouble() / 60)) <
            (_dayStartTime.hour.toDouble() +
                (_dayStartTime.minute.toDouble() / 60))) {
          Toast.show("End time cannot be lesser than Start time", context,
              duration: kToastDuration, gravity: Toast.BOTTOM);
          setState(() {
            _dayEndTime = _dayStartTime;
          });
          return;
        }
        setState(() {
          _dayEndTime = newTime;
        });
      }
    }

    return Row(children: [
      Container(
          width: getProportionateScreenWidth(155),
          child: TextFormField(
            controller: intialDateValue,
            onSaved: (newValue) async {},
            onTap: () => _selectStartTime(),
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty || value.length < 1) {
                return "Please select test start time";
              }
              return null;
            },
            style: TextStyle(fontSize: getProportionateScreenHeight(15)),
            decoration: InputDecoration(
              labelText: 'Test Start Time',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
                onPressed: null,
                padding: EdgeInsets.all(0),
              ),
              labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
            ),
          )),
      Spacer(),
      Container(
          width: getProportionateScreenWidth(155),
          child: TextFormField(
            controller: intialEnd,
            onSaved: (newValue) async {},
            onTap: () => _selectEndTime(),
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty || value.length < 1) {
                return "Please select test end time";
              }
              return null;
            },
            style: TextStyle(fontSize: getProportionateScreenHeight(15)),
            decoration: InputDecoration(
              labelText: 'Test End Time',
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
                onPressed: null,
                padding: EdgeInsets.all(0),
              ),
              labelStyle: TextStyle(decorationStyle: TextDecorationStyle.solid),
            ),
          ))
    ]);
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
            return "Minimum one User is required per slot";
          }

          if (double.parse(value) > 100) {
            return "Exceeding maximum number of Users per slot\nlimit. Allowed limit is 100";
          }
        } catch (e) {}

        return null;
      },
      decoration: InputDecoration(
        labelText: "Maximum Users Per Slot",
        hintText: "Number of Users Per Interval",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.people,
            color: Colors.grey,
          ),
          onPressed: null,
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  TextFormField _buildWinSlotFormField() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))],
      onSaved: (value) => _windowTimeInterval = double.parse(value),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _windowTimeInterval = double.parse(value);
        }
        return null;
      },
      validator: (value) {
        try {
          if (double.parse(value) < 0) {
            return "Minimum time period within this days\nUser cannot book an appointment";
          }

          if (double.parse(value) > 100) {
            return "Exceeding maximum number limit. Allowed limit is 100";
          }
        } catch (e) {}
        return null;
      },
      decoration: InputDecoration(
        labelText: "Appointment Interval(in days)",
        hintText: "Days between appointments",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.view_day,
            color: Colors.grey,
          ),
          onPressed: null,
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }

  TextFormField _buildIntervalFormField() {
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))],
      onSaved: (value) => _slotInterval = double.parse(value),
      onChanged: (value) {
        if (value.isNotEmpty) {
          _slotInterval = double.parse(value);
        }
        return null;
      },
      validator: (value) {
        try {
          if (value.trim().length == 0 || double.parse(value) < 5) {
            return "Minimum 5 minutes interval";
          }

          if (double.parse(value) > 4 * 60) {
            return "Exceeding maximum number of minutes per slot\nlimit. Allowed limit is ${4 * 60}";
          }
        } catch (e) {}

        return null;
      },
      decoration: InputDecoration(
        labelText: "Slot interval",
        hintText: "Slot interval in minutes. Max:240",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.access_time,
            color: Colors.grey,
          ),
          onPressed: null,
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }
}
