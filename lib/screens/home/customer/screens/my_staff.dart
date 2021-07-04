import 'package:flutter_svg/svg.dart';
import 'package:swabx/helper/APIService.dart';
import 'package:swabx/models/user.dart';
import 'package:flutter/material.dart';
import 'package:swabx/constants.dart';
import './add_staff.dart';
import 'package:swabx/screens/home/custom_app_bar.dart';
import 'package:swabx/size_config.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:toast/toast.dart';

import '../../home_screen.dart';

class MyStaffList extends StatefulWidget {
  MyStaffList({Key key}) : super(key: key);
  @override
  _MyStaffListState createState() => _MyStaffListState();
}

class _MyStaffListState extends State<MyStaffList> {
  List<User> staffs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<User>>(
      future: getMyStaffList(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        sliver: SliverToBoxAdapter(
                            child: (snapshot.data.length > 0)
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(children: [
                                      SizedBox(height: 20),
                                      Text("My Staff",
                                          style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenWidth(
                                                      20),
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.w800)),
                                      SizedBox(height: 30),
                                      ...List.generate(
                                        snapshot.data.length,
                                        (index) {
                                          if (snapshot.data[index] != null &&
                                              snapshot.data[index].name !=
                                                  null) {
                                            return StaffCard(
                                                member: snapshot.data[index]);
                                          }
                                          return Text("Empty");
                                          // here by default width and height is 0
                                        },
                                      ).toList()
                                    ]))
                                : noRecords("No records found")))
                  ],
                ),
                floatingActionButton: new FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterStaff.routeName);
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 29,
                  ),
                  backgroundColor: kPrimaryColor,
                  tooltip: 'Create my staff',
                  elevation: 5,
                  splashColor: Colors.grey,
                ));
          }
        }
      },
    );
  }

  Future<List<User>> getMyStaffList() async {
    APIService apiService = new APIService();
    return Future.value(await apiService.getMyStaffs()); // return your response
  }
}

class StaffCard extends StatelessWidget {
  const StaffCard({
    Key key,
    @required this.member,
  }) : super(key: key);

  final User member;

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
        apiService.deleteStaff(member.id).then((value) {
          if (value != null &&
              value.message != null &&
              value.message.isNotEmpty) {
            Toast.show(value.message, context,
                duration: kToastDuration, gravity: Toast.BOTTOM);

            if (value.statusCode == 200) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerHomeScreen(nextScreen: 1),
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
                  onPressed: () => null,
                  minWidth: 40,
                  padding: EdgeInsets.all(0.0),
                  child: SvgPicture.asset('assets/images/staff_member.svg',
                      width: 45, height: 45)),
              SizedBox(
                width: 10,
              ),
              Container(
                  width: getProportionateScreenWidth(200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      Text(
                        member.email,
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(color: Color(0XFF8C92A4), fontSize: 14),
                        maxLines: 2,
                      ),
                      Text(
                        member.created != null
                            ? "Added " +
                                formatTime(DateTime.parse(member.created)
                                    .millisecondsSinceEpoch)
                            : "-",
                        textAlign: TextAlign.left,
                        style:
                            TextStyle(color: Color(0XFF8C92A4), fontSize: 12),
                        maxLines: 2,
                      )
                    ],
                  )),
              Spacer(),
              Row(
                children: [
                  // ignore: deprecated_member_use
                  FlatButton(
                      onPressed: () {
                        showAlertDialog(context);
                      },
                      minWidth: 10,
                      padding: EdgeInsets.all(0.0),
                      child: getTrashIcon())
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
