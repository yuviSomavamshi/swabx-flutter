import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swabx/size_config.dart';
import 'package:swabx/styles.dart';
import 'helper/QRCodeAlert.dart';
import 'models/QRCode.dart';
import 'package:intl/intl.dart';

const kAppName = "SwabX";
const kAppTitleText = "Swab";
const kWebsite = "https://swabx.healthx.global";
//const kWebsite = "http://192.168.0.101";
const kPrimaryColor = Color(0xFF112855);
const kPrimaryCustomColor = Color(0XFFF58C29);
const kTracieFontFamily = "Kaushan Script";
const kPrimaryLightColor = Color(0xFFFFECDF);
const kToastDuration = 4;
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFFEAF4FE);
const kSecondaryColor1 = Color(0xFFDBF3FD);
const kSecondaryColor2 = Colors.grey;
const kTextColor = Color(0xFF757575);
const NAME_REGEX = r"^[a-zA-Z0-9_ ]{4,25}$";
const PASSWORD_REGEX =
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{8,})";
const kAnimationDuration = Duration(milliseconds: 100);
DateFormat dateFormat = DateFormat('yyyy-MM-dd');
DateFormat timeFormat = DateFormat('HH:mm:ss');
String validateName(String value) {
  if (value.isEmpty) {
    return kNamelNullError;
  }
  return RegExp(NAME_REGEX).hasMatch(value) ? null : kNamelValid;
}

String validatePassword(String value) {
  if (value.isEmpty) {
    return kPassNullError;
  } else if (value.length < 8) {
    return kShortPassError;
  }

  return RegExp(PASSWORD_REGEX).hasMatch(value) ? null : kPassValid;
}

final prevention = [
  {'assets/images/1.svg': 'Avoid close\ncontact'},
  {'assets/images/2.svg': 'Clean your\nhands often'},
  {'assets/images/3.svg': 'Wear a\nfacemask'},
];

SliverToBoxAdapter buildPreventionTips(double screenHeight, double percent) {
  return SliverToBoxAdapter(
    child: Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Safety Tips',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prevention
                .map((e) => Column(
                      children: <Widget>[
                        SvgPicture.asset(
                          e.keys.first,
                          height: screenHeight * percent,
                        ),
                        Text(
                          e.values.first,
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  );
}

SliverToBoxAdapter buildTogether(double screenHeight, double percentage) {
  return SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
      padding: const EdgeInsets.all(10.0),
      height: screenHeight * percentage,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAD9FE4), kPrimaryColor],
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Stay Home!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Lets beat this Pandemic Together.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
                maxLines: 2,
              ),
            ],
          ),
          Image.asset('assets/images/masked_lady.png')
        ],
      ),
    ),
  );
}

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(26),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

SliverPadding buildStatsHeader(String title) {
  return SliverPadding(
    padding: const EdgeInsets.only(left: 20, bottom: 5),
    sliver: SliverToBoxAdapter(
        child: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    )),
  );
}

SliverPadding buildStatsTabBar(
    Function(String startDate, String endDate) onChanged) {
  return SliverPadding(
    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
    sliver: SliverToBoxAdapter(
      child: DefaultTabController(
        length: 3,
        child: TabBar(
          indicatorColor: Colors.transparent,
          labelStyle: Styles.tabTextStyle,
          labelColor: kPrimaryColor,
          unselectedLabelColor: Colors.black45,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.grey.shade200),
          tabs: <Widget>[
            Tab(
                child: Align(
              alignment: Alignment.center,
              child: Text("Today", style: TextStyle(fontSize: 14)),
            )),
            Tab(
                child: Align(
              alignment: Alignment.center,
              child: Text("Yesterday", style: TextStyle(fontSize: 14)),
            )),
            Tab(
                child: Align(
              alignment: Alignment.center,
              child: Text("Last 7 Days", style: TextStyle(fontSize: 14)),
            )),
          ],
          onTap: (index) {
            final now = DateTime.now();
            String startDate, endDate;
            switch (index) {
              case 0:
                startDate = dateFormat.format(now);
                endDate = startDate;
                break;
              case 1:
                final yesterday = DateTime(now.year, now.month, now.day - 1);
                startDate = dateFormat.format(yesterday);
                endDate = startDate;
                break;
              case 2:
                final lastWeek = DateTime(now.year, now.month, now.day - 7);
                startDate = dateFormat.format(lastWeek);
                endDate = dateFormat.format(now);
                break;
            }
            onChanged(startDate, endDate);
          },
        ),
      ),
    ),
  );
}

class StatsGrid extends StatelessWidget {
  final String total;
  final String used;
  final String scrapped;

  const StatsGrid({Key key, this.total, this.used, this.scrapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        sliver: SliverToBoxAdapter(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.11,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Row(
                  children: <Widget>[
                    _buildStatCard('Total Kits', total, kPrimaryColor),
                    _buildStatCard('Used', used, Colors.green),
                    _buildStatCard('Scrapped', scrapped, kPrimaryCustomColor),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  Expanded _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Widget spaceBetweenWidgets = SizedBox(width: 10);

Widget customTextWidget(String text) {
  return Text(text,
      overflow: TextOverflow.clip,
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
}

SliverToBoxAdapter buildHeader(double screenHeight) {
  return SliverToBoxAdapter(
    child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        child: homeScreenAppTitle(30, Colors.white)),
  );
}

SliverToBoxAdapter buildPatientHeader(
    double screenHeight, QRCode code, BuildContext context) {
  return SliverToBoxAdapter(
    child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        child: Row(children: [
          Text("Hi App ", style: TextStyle(color: kPrimaryColor)),
          Spacer(),
          homeScreenAppTitle(30, Colors.white),
          Spacer(),
          // ignore: deprecated_member_use
          FlatButton(
            minWidth: 10,
            child: code != null
                ? Image.asset(
                    'assets/images/qrcode.png',
                    width: 25,
                    height: 25,
                    color: Colors.white,
                  )
                : null,
            onPressed: () {
              showQRCodeDialog(context, code.name, code.getHash());
            },
          )
        ])),
  );
}

Widget noRecords(String title) {
  return Center(
      child: Column(
    children: [
      Image.asset(
        "assets/images/diagnosis 1.png",
        height: getProportionateScreenHeight(300),
        width: getProportionateScreenWidth(300),
      ),
      Text(title, style: TextStyle(color: Colors.black))
    ],
  ));
}

Widget homeScreenAppTitle(double size, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        kAppTitleText,
        style: TextStyle(
            fontSize: getProportionateScreenWidth(size),
            color: color != null ? color : kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: kTracieFontFamily),
      ),
      Text(
        "X",
        style: TextStyle(
            fontSize: getProportionateScreenWidth(size),
            color: kPrimaryCustomColor,
            fontWeight: FontWeight.bold,
            fontFamily: kTracieFontFamily),
      )
    ],
  );
}

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kPassValid =
    "Secure Password Tips:\t\n\t\t* Use at least 8 characters, a combination of\nnumbers, special characters and letters\n\t\t* at least one lowercase letter.\n\t\t* at least one uppercase letter.\n\t\t* at least one number.\n\t\t* at least one of these special characters \n !@#\$%^&";
const String kShortPassError = "Password is too short, minimum of 8 characters";
const String kMatchPassError = "Passwords don't match";
const String kICPassportNullError = "Please Enter your IC/Passport details";
const String kNamelValid =
    "Name can contain\n*. 1 or more lowercase/uppercase \n\talphabetical characters.\n*. 1 or more numeric characters.\n*. Allowed special characters are underscore\n\t and Space";
const String kLocationNameNullError = "Please enter location name";
const String kNamelNullError = "Please Enter your name";
const String kNameFNullError = "Please Enter name field";
const String kDobNullError = "Please select Date of Birth";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";
const String kAuthorized = "authorized";
const String kEmail = "email";
const String kToken = "token";
const String kRefreshToken = "refreshToken";
const String kName = "name";
const String kId = "id";
const String kRole = "role";
const List<String> AllowedRoles = ["Customer", "Staff", "Patient"];
const String CIPHER_SALT = '4290bcb154173531f314af57f3be3b50';

const List RelationshipTypes = [
  {
    "display": "Self",
    "value": "Self",
  },
  {
    "display": "Parent",
    "value": "Parent",
  },
  {
    "display": "Spouse",
    "value": "Spouse",
  },
  {
    "display": "Grand Parent",
    "value": "Grand Parent",
  },
  {
    "display": "Guardian",
    "value": "Guardian",
  },
  {
    "display": "Friend",
    "value": "Friend",
  },
  {
    "display": "Child",
    "value": "Child",
  },
  {
    "display": "Other",
    "value": "Other",
  }
];

const List SlotIntervals = [
  {"display": "5 minutes", "value": 5},
  {"display": "10 minutes", "value": 10},
  {"display": "15 minutes", "value": 15},
  {"display": "30 minutes", "value": 30},
  {"display": "45 minutes", "value": 45},
  {"display": "1 hour", "value": 60},
  {"display": "2 hours", "value": 120}
];

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}

SpinKitWave loading() {
  return SpinKitWave(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(color: kPrimaryColor),
      );
    },
  );
}

Image getTrashIcon() {
  return Image.asset('assets/images/Delete.png',
      width: 26, height: 26, color: Colors.redAccent);
}

const List CountryList = [
  {"name": 'Afghanistan', "code": 'AF'},
  {"name": 'Åland Islands', "code": 'AX'},
  {"name": 'Albania', "code": 'AL'},
  {"name": 'Algeria', "code": 'DZ'},
  {"name": 'American Samoa', "code": 'AS'},
  {"name": 'AndorrA', "code": 'AD'},
  {"name": 'Angola', "code": 'AO'},
  {"name": 'Anguilla', "code": 'AI'},
  {"name": 'Antarctica', "code": 'AQ'},
  {"name": 'Antigua and Barbuda', "code": 'AG'},
  {"name": 'Argentina', "code": 'AR'},
  {"name": 'Armenia', "code": 'AM'},
  {"name": 'Aruba', "code": 'AW'},
  {"name": 'Australia', "code": 'AU'},
  {"name": 'Austria', "code": 'AT'},
  {"name": 'Azerbaijan', "code": 'AZ'},
  {"name": 'Bahamas', "code": 'BS'},
  {"name": 'Bahrain', "code": 'BH'},
  {"name": 'Bangladesh', "code": 'BD'},
  {"name": 'Barbados', "code": 'BB'},
  {"name": 'Belarus', "code": 'BY'},
  {"name": 'Belgium', "code": 'BE'},
  {"name": 'Belize', "code": 'BZ'},
  {"name": 'Benin', "code": 'BJ'},
  {"name": 'Bermuda', "code": 'BM'},
  {"name": 'Bhutan', "code": 'BT'},
  {"name": 'Bolivia', "code": 'BO'},
  {"name": 'Bosnia and Herzegovina', "code": 'BA'},
  {"name": 'Botswana', "code": 'BW'},
  {"name": 'Bouvet Island', "code": 'BV'},
  {"name": 'Brazil', "code": 'BR'},
  {"name": 'British Indian Ocean Territory', "code": 'IO'},
  {"name": 'Brunei Darussalam', "code": 'BN'},
  {"name": 'Bulgaria', "code": 'BG'},
  {"name": 'Burkina Faso', "code": 'BF'},
  {"name": 'Burundi', "code": 'BI'},
  {"name": 'Cambodia', "code": 'KH'},
  {"name": 'Cameroon', "code": 'CM'},
  {"name": 'Canada', "code": 'CA'},
  {"name": 'Cape Verde', "code": 'CV'},
  {"name": 'Cayman Islands', "code": 'KY'},
  {"name": 'Central African Republic', "code": 'CF'},
  {"name": 'Chad', "code": 'TD'},
  {"name": 'Chile', "code": 'CL'},
  {"name": 'China', "code": 'CN'},
  {"name": 'Christmas Island', "code": 'CX'},
  {"name": 'Cocos (Keeling) Islands', "code": 'CC'},
  {"name": 'Colombia', "code": 'CO'},
  {"name": 'Comoros', "code": 'KM'},
  {"name": 'Congo', "code": 'CG'},
  {"name": 'Congo, The Democratic Republic of the', "code": 'CD'},
  {"name": 'Cook Islands', "code": 'CK'},
  {"name": 'Costa Rica', "code": 'CR'},
  {"name": 'Cote D\'Ivoire', "code": 'CI'},
  {"name": 'Croatia', "code": 'HR'},
  {"name": 'Cuba', "code": 'CU'},
  {"name": 'Cyprus', "code": 'CY'},
  {"name": 'Czech Republic', "code": 'CZ'},
  {"name": 'Denmark', "code": 'DK'},
  {"name": 'Djibouti', "code": 'DJ'},
  {"name": 'Dominica', "code": 'DM'},
  {"name": 'Dominican Republic', "code": 'DO'},
  {"name": 'Ecuador', "code": 'EC'},
  {"name": 'Egypt', "code": 'EG'},
  {"name": 'El Salvador', "code": 'SV'},
  {"name": 'Equatorial Guinea', "code": 'GQ'},
  {"name": 'Eritrea', "code": 'ER'},
  {"name": 'Estonia', "code": 'EE'},
  {"name": 'Ethiopia', "code": 'ET'},
  {"name": 'Falkland Islands (Malvinas)', "code": 'FK'},
  {"name": 'Faroe Islands', "code": 'FO'},
  {"name": 'Fiji', "code": 'FJ'},
  {"name": 'Finland', "code": 'FI'},
  {"name": 'France', "code": 'FR'},
  {"name": 'French Guiana', "code": 'GF'},
  {"name": 'French Polynesia', "code": 'PF'},
  {"name": 'French Southern Territories', "code": 'TF'},
  {"name": 'Gabon', "code": 'GA'},
  {"name": 'Gambia', "code": 'GM'},
  {"name": 'Georgia', "code": 'GE'},
  {"name": 'Germany', "code": 'DE'},
  {"name": 'Ghana', "code": 'GH'},
  {"name": 'Gibraltar', "code": 'GI'},
  {"name": 'Greece', "code": 'GR'},
  {"name": 'Greenland', "code": 'GL'},
  {"name": 'Grenada', "code": 'GD'},
  {"name": 'Guadeloupe', "code": 'GP'},
  {"name": 'Guam', "code": 'GU'},
  {"name": 'Guatemala', "code": 'GT'},
  {"name": 'Guernsey', "code": 'GG'},
  {"name": 'Guinea', "code": 'GN'},
  {"name": 'Guinea-Bissau', "code": 'GW'},
  {"name": 'Guyana', "code": 'GY'},
  {"name": 'Haiti', "code": 'HT'},
  {"name": 'Heard Island and Mcdonald Islands', "code": 'HM'},
  {"name": 'Holy See (Vatican City State)', "code": 'VA'},
  {"name": 'Honduras', "code": 'HN'},
  {"name": 'Hong Kong', "code": 'HK'},
  {"name": 'Hungary', "code": 'HU'},
  {"name": 'Iceland', "code": 'IS'},
  {"name": 'India', "code": 'IN'},
  {"name": 'Indonesia', "code": 'ID'},
  {"name": 'Iran, Islamic Republic Of', "code": 'IR'},
  {"name": 'Iraq', "code": 'IQ'},
  {"name": 'Ireland', "code": 'IE'},
  {"name": 'Isle of Man', "code": 'IM'},
  {"name": 'Israel', "code": 'IL'},
  {"name": 'Italy', "code": 'IT'},
  {"name": 'Jamaica', "code": 'JM'},
  {"name": 'Japan', "code": 'JP'},
  {"name": 'Jersey', "code": 'JE'},
  {"name": 'Jordan', "code": 'JO'},
  {"name": 'Kazakhstan', "code": 'KZ'},
  {"name": 'Kenya', "code": 'KE'},
  {"name": 'Kiribati', "code": 'KI'},
  {"name": 'Korea, Democratic People\'S Republic of', "code": 'KP'},
  {"name": 'Korea, Republic of', "code": 'KR'},
  {"name": 'Kuwait', "code": 'KW'},
  {"name": 'Kyrgyzstan', "code": 'KG'},
  {"name": 'Lao People\'S Democratic Republic', "code": 'LA'},
  {"name": 'Latvia', "code": 'LV'},
  {"name": 'Lebanon', "code": 'LB'},
  {"name": 'Lesotho', "code": 'LS'},
  {"name": 'Liberia', "code": 'LR'},
  {"name": 'Libyan Arab Jamahiriya', "code": 'LY'},
  {"name": 'Liechtenstein', "code": 'LI'},
  {"name": 'Lithuania', "code": 'LT'},
  {"name": 'Luxembourg', "code": 'LU'},
  {"name": 'Macao', "code": 'MO'},
  {"name": 'Macedonia, The Former Yugoslav Republic of', "code": 'MK'},
  {"name": 'Madagascar', "code": 'MG'},
  {"name": 'Malawi', "code": 'MW'},
  {"name": 'Malaysia', "code": 'MY'},
  {"name": 'Maldives', "code": 'MV'},
  {"name": 'Mali', "code": 'ML'},
  {"name": 'Malta', "code": 'MT'},
  {"name": 'Marshall Islands', "code": 'MH'},
  {"name": 'Martinique', "code": 'MQ'},
  {"name": 'Mauritania', "code": 'MR'},
  {"name": 'Mauritius', "code": 'MU'},
  {"name": 'Mayotte', "code": 'YT'},
  {"name": 'Mexico', "code": 'MX'},
  {"name": 'Micronesia, Federated States of', "code": 'FM'},
  {"name": 'Moldova, Republic of', "code": 'MD'},
  {"name": 'Monaco', "code": 'MC'},
  {"name": 'Mongolia', "code": 'MN'},
  {"name": 'Montserrat', "code": 'MS'},
  {"name": 'Morocco', "code": 'MA'},
  {"name": 'Mozambique', "code": 'MZ'},
  {"name": 'Myanmar', "code": 'MM'},
  {"name": 'Namibia', "code": 'NA'},
  {"name": 'Nauru', "code": 'NR'},
  {"name": 'Nepal', "code": 'NP'},
  {"name": 'Netherlands', "code": 'NL'},
  {"name": 'Netherlands Antilles', "code": 'AN'},
  {"name": 'New Caledonia', "code": 'NC'},
  {"name": 'New Zealand', "code": 'NZ'},
  {"name": 'Nicaragua', "code": 'NI'},
  {"name": 'Niger', "code": 'NE'},
  {"name": 'Nigeria', "code": 'NG'},
  {"name": 'Niue', "code": 'NU'},
  {"name": 'Norfolk Island', "code": 'NF'},
  {"name": 'Northern Mariana Islands', "code": 'MP'},
  {"name": 'Norway', "code": 'NO'},
  {"name": 'Oman', "code": 'OM'},
  {"name": 'Pakistan', "code": 'PK'},
  {"name": 'Palau', "code": 'PW'},
  {"name": 'Palestinian Territory, Occupied', "code": 'PS'},
  {"name": 'Panama', "code": 'PA'},
  {"name": 'Papua New Guinea', "code": 'PG'},
  {"name": 'Paraguay', "code": 'PY'},
  {"name": 'Peru', "code": 'PE'},
  {"name": 'Philippines', "code": 'PH'},
  {"name": 'Pitcairn', "code": 'PN'},
  {"name": 'Poland', "code": 'PL'},
  {"name": 'Portugal', "code": 'PT'},
  {"name": 'Puerto Rico', "code": 'PR'},
  {"name": 'Qatar', "code": 'QA'},
  {"name": 'Reunion', "code": 'RE'},
  {"name": 'Romania', "code": 'RO'},
  {"name": 'Russian Federation', "code": 'RU'},
  {"name": 'RWANDA', "code": 'RW'},
  {"name": 'Saint Helena', "code": 'SH'},
  {"name": 'Saint Kitts and Nevis', "code": 'KN'},
  {"name": 'Saint Lucia', "code": 'LC'},
  {"name": 'Saint Pierre and Miquelon', "code": 'PM'},
  {"name": 'Saint Vincent and the Grenadines', "code": 'VC'},
  {"name": 'Samoa', "code": 'WS'},
  {"name": 'San Marino', "code": 'SM'},
  {"name": 'Sao Tome and Principe', "code": 'ST'},
  {"name": 'Saudi Arabia', "code": 'SA'},
  {"name": 'Senegal', "code": 'SN'},
  {"name": 'Serbia and Montenegro', "code": 'CS'},
  {"name": 'Seychelles', "code": 'SC'},
  {"name": 'Sierra Leone', "code": 'SL'},
  {"name": 'Singapore', "code": 'SG'},
  {"name": 'Slovakia', "code": 'SK'},
  {"name": 'Slovenia', "code": 'SI'},
  {"name": 'Solomon Islands', "code": 'SB'},
  {"name": 'Somalia', "code": 'SO'},
  {"name": 'South Africa', "code": 'ZA'},
  {"name": 'South Georgia and the South Sandwich Islands', "code": 'GS'},
  {"name": 'Spain', "code": 'ES'},
  {"name": 'Sri Lanka', "code": 'LK'},
  {"name": 'Sudan', "code": 'SD'},
  {"name": 'Suriname', "code": 'SR'},
  {"name": 'Svalbard and Jan Mayen', "code": 'SJ'},
  {"name": 'Swaziland', "code": 'SZ'},
  {"name": 'Sweden', "code": 'SE'},
  {"name": 'Switzerland', "code": 'CH'},
  {"name": 'Syrian Arab Republic', "code": 'SY'},
  {"name": 'Taiwan, Province of China', "code": 'TW'},
  {"name": 'Tajikistan', "code": 'TJ'},
  {"name": 'Tanzania, United Republic of', "code": 'TZ'},
  {"name": 'Thailand', "code": 'TH'},
  {"name": 'Timor-Leste', "code": 'TL'},
  {"name": 'Togo', "code": 'TG'},
  {"name": 'Tokelau', "code": 'TK'},
  {"name": 'Tonga', "code": 'TO'},
  {"name": 'Trinidad and Tobago', "code": 'TT'},
  {"name": 'Tunisia', "code": 'TN'},
  {"name": 'Turkey', "code": 'TR'},
  {"name": 'Turkmenistan', "code": 'TM'},
  {"name": 'Turks and Caicos Islands', "code": 'TC'},
  {"name": 'Tuvalu', "code": 'TV'},
  {"name": 'Uganda', "code": 'UG'},
  {"name": 'Ukraine', "code": 'UA'},
  {"name": 'United Arab Emirates', "code": 'AE'},
  {"name": 'United Kingdom', "code": 'GB'},
  {"name": 'United States', "code": 'US'},
  {"name": 'United States Minor Outlying Islands', "code": 'UM'},
  {"name": 'Uruguay', "code": 'UY'},
  {"name": 'Uzbekistan', "code": 'UZ'},
  {"name": 'Vanuatu', "code": 'VU'},
  {"name": 'Venezuela', "code": 'VE'},
  {"name": 'Viet Nam', "code": 'VN'},
  {"name": 'Virgin Islands, British', "code": 'VG'},
  {"name": 'Virgin Islands, U.S.', "code": 'VI'},
  {"name": 'Wallis and Futuna', "code": 'WF'},
  {"name": 'Western Sahara', "code": 'EH'},
  {"name": 'Yemen', "code": 'YE'},
  {"name": 'Zambia', "code": 'ZM'},
  {"name": 'Zimbabwe', "code": 'ZW'}
];

getCountryNameByCode(String code) {
  for (var item in CountryList) {
    if (item["code"] == code) {
      return item["name"];
    }
  }
  return code;
}

getCountryCodeByName(String name) {
  for (var item in CountryList) {
    if (item["name"] == name) {
      return item["code"];
    }
  }
  return name;
}
