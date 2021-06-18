import 'package:swabx/constants.dart';
import 'package:swabx/models/Result.dart';
import 'package:swabx/size_config.dart';
import 'package:flutter/material.dart';

/// This is the stateful widget that the main application instantiates.
class RegisteredPatientsList extends StatefulWidget {
  RegisteredPatientsList({Key key, this.patient, this.items}) : super(key: key);

  final String patient;
  final List<Result> items;

  @override
  _RegisteredPatientsListState createState() =>
      _RegisteredPatientsListState(patient: patient, items: items);
}

/// This is the private State class that goes with RegisteredPatientsList.
class _RegisteredPatientsListState extends State<RegisteredPatientsList> {
  final String patient;
  final List<Result> items;
  _RegisteredPatientsListState({this.patient, @required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(height: 20),
      Text(patient == null ? "Recent scans" : "Test Results of " + patient,
          style: TextStyle(
              fontSize: getProportionateScreenWidth(16),
              color: kPrimaryColor,
              fontWeight: FontWeight.w800)),
      SizedBox(height: 30),
      if (items.length > 0)
        Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (BuildContext context, int index) {
                if (patient == null)
                  return Dismissible(
                    child: resultCard(index),
                    background: Container(
                      color: Colors.red,
                    ),
                    key: ValueKey<Result>(items[index]),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        items.removeAt(index);
                      });
                    },
                  );
                else
                  return resultCard(index);
              },
            ))
      else
        noRecords("No records found")
    ]);
  }

  Widget resultCard(int index) {
    var cl = Colors.grey;
    if (items[index].result == "Negative") {
      cl = Colors.green;
    } else if (items[index].result == "Positive") {
      cl = Colors.red;
    } else if (items[index].result == "Invalid") {
      cl = Colors.deepOrange;
    } else if (items[index].result == "Scrapped") {
      cl = Colors.deepPurple;
    }

    return Container(
        decoration: BoxDecoration(
          color: index % 2 == 0 ? kSecondaryColor : Colors.white70,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(10),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (patient == null)
              Row(
                children: [
                  Image.asset(
                    "assets/images/details_user.png",
                    height: getProportionateScreenHeight(20),
                    width: getProportionateScreenWidth(20),
                  ),
                  spaceBetweenWidgets,
                  customTextWidget(items[index].name)
                ],
              )
            else if (items[index].location != "Unknown")
              Row(
                children: [
                  Image.asset(
                    "assets/images/details_id.png",
                    height: getProportionateScreenHeight(20),
                    width: getProportionateScreenWidth(20),
                  ),
                  spaceBetweenWidgets,
                  customTextWidget(items[index].location)
                ],
              ),
            SizedBox(height: 3),
            if (patient == null)
              Row(
                children: [
                  Image.asset(
                    "assets/images/details_id.png",
                    height: getProportionateScreenHeight(20),
                    width: getProportionateScreenWidth(20),
                  ),
                  spaceBetweenWidgets,
                  customTextWidget("id")
                ],
              )
            else
              Row(
                children: [
                  Image.asset(
                    "assets/images/details_clock.png",
                    height: getProportionateScreenHeight(20),
                    width: getProportionateScreenWidth(20),
                  ),
                  spaceBetweenWidgets,
                  customTextWidget(items[index].date + " " + items[index].time)
                ],
              ),
            SizedBox(height: 10),
          ]),
          Spacer(),
          // ignore: deprecated_member_use
          FlatButton(
              height: 30,
              minWidth: 100,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              onPressed: () => null,
              color: cl,
              child: Text(
                items[index].result,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ))
        ]));
  }
}
