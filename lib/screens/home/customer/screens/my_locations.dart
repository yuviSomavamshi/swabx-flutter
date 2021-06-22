import 'package:time_formatter/time_formatter.dart';
import 'package:swabx/helper/SharedPreferencesHelper.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/models/Location.dart';
import 'package:swabx/screens/home/home_screen.dart';
import './add_location.dart';
import 'package:flutter/material.dart';
import 'package:swabx/helper/QRCodeAlert.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/size_config.dart';
import 'package:toast/toast.dart';

class LocationHomeScreenBody extends StatefulWidget {
  static String routeName = "/locationHome";

  LocationHomeScreenBody({Key key}) : super(key: key);
  @override
  _LocationHomeScreenBodyState createState() => _LocationHomeScreenBodyState();
}

class _LocationHomeScreenBodyState extends State<LocationHomeScreenBody>
    with TickerProviderStateMixin {
  String customerId;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<Location>>(
      future: getLocations(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<List<Location>> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            return Scaffold(
                appBar: CustomAppBar(),
                body: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: <Widget>[
                    buildHeader(screenHeight),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Text("My Locations",
                                    style: TextStyle(
                                        fontSize:
                                            getProportionateScreenWidth(20),
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.w800)),
                                SizedBox(height: 30),
                                LocationQRCodes(
                                  locations: snapshot.data,
                                  customerId: customerId,
                                ),
                                SizedBox(
                                    height: getProportionateScreenHeight(20))
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: new FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterLocation.routeName);
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 29,
                  ),
                  backgroundColor: kPrimaryColor,
                  tooltip: 'Create location',
                  elevation: 5,
                  splashColor: Colors.grey,
                ));
          }
        }
      },
    );
  }

  Future<List<Location>> getLocations() async {
    customerId = await SharedPreferencesHelper.getUserId();
    APIService apiService = new APIService();
    return Future.value(await apiService.getMyLocations());
  }
}

// ignore: must_be_immutable
class LocationQRCodes extends StatelessWidget {
  LocationQRCodes({Key key, @required customerId, @required this.locations})
      : super(key: key);

  String customerId;
  List<Location> locations;
  @override
  Widget build(BuildContext context) {
    if (locations.length > 0) {
      return Column(
        children: [
          SizedBox(height: 20),
          ...List.generate(
            locations.length,
            (index) {
              if (locations[index] != null &&
                  locations[index].location != null) {
                return LocationQRCodeCard(
                  loc: locations[index],
                  customerId: customerId,
                );
              }
              return Text("Empty");
              // here by default width and height is 0
            },
          ).toList(),
          SizedBox(width: getProportionateScreenWidth(20)),
        ],
      );
    } else {
      return noRecords("No records found");
    }
  }
}

class LocationQRCodeCard extends StatelessWidget {
  const LocationQRCodeCard({
    Key key,
    @required this.customerId,
    @required this.loc,
  }) : super(key: key);

  final String customerId;
  final Location loc;

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Delete"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
      onPressed: () async {
        APIService apiService = new APIService();
        apiService.deleteLocation(loc.id).then((value) {
          if (value != null &&
              value.message != null &&
              value.message.isNotEmpty) {
            Toast.show(value.message, context,
                duration: kToastDuration, gravity: Toast.BOTTOM);
            if (value.statusCode == 200) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerHomeScreen(nextScreen: 2),
                  ));
            }
          }
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Are you sure you want to delete this?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String qr = kWebsite +
        "/patient-registration.html?staffId=$customerId&location=${loc.location}&locationId=${loc.id}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0XFFDADADA), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // ignore: deprecated_member_use
              FlatButton(
                  onPressed: () => showQRCodeDialog(context, loc.location, qr),
                  minWidth: 40,
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset('assets/images/qrcode.png',
                      width: 45, height: 45)),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.location,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  Text(
                    loc.created != null
                        ? "Added " +
                            formatTime(DateTime.parse(loc.created)
                                .millisecondsSinceEpoch)
                        : "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Color(0XFF8C92A4), fontSize: 14),
                    maxLines: 2,
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
