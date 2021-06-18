import 'package:swabx/screens/default_test_location/default_test_location_screen.dart';
import 'package:swabx/screens/home/customer/screens/my_locations.dart';
import 'package:swabx/screens/home/patient/screens/book_appointment.dart';
import 'package:swabx/screens/home/patient/screens/my_qrcodes.dart';
import 'package:swabx/screens/home/staff/register/patient_qr_scanner.dart';
import 'package:swabx/screens/home/staff/register/device_barcode_scanner.dart';
import 'package:swabx/screens/home/staff/register/summary_page.dart';
import 'package:flutter/widgets.dart';
import 'package:swabx/screens/change_password/change_password_screen.dart';
import 'package:swabx/screens/home/customer/screens/add_location.dart';
import 'package:swabx/screens/home/customer/screens/add_staff.dart';
import 'package:swabx/screens/home/staff/pair_devices/pair_web_timer.dart';
import 'package:swabx/screens/home/staff/pair_devices/web_timer_qr_scanner.dart';
import 'package:swabx/screens/home/patient/screens/add_patient.dart';
import 'package:swabx/screens/reset_password/reset_password_screen.dart';
import 'package:swabx/screens/forgot_password/forgot_password_screen.dart';
import 'package:swabx/screens/home/home_screen.dart';
import 'package:swabx/screens/otp/otp_screen.dart';
import 'package:swabx/screens/profile/profile_screen.dart';
import 'package:swabx/screens/sign_in/sign_in_screen.dart';
import 'package:swabx/screens/splash/splash_screen.dart';
import 'package:swabx/screens/sign_up/sign_up_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  ResetPasswordScreen.routeName: (context) => ResetPasswordScreen(),
  ChangePasswordScreen.routeName: (context) => ChangePasswordScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  OtpScreen.routeName: (context) => OtpScreen(
        email: null,
      ),
  PatientHomeScreen.routeName: (context) => PatientHomeScreen(nextScreen: 0),
  CustomerHomeScreen.routeName: (context) => CustomerHomeScreen(nextScreen: 0),
  StaffHomeScreen.routeName: (context) => StaffHomeScreen(nextScreen: 0),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  RegisterPatient.routeName: (context) => RegisterPatient(),
  RegisterStaff.routeName: (context) => RegisterStaff(),
  RegisterLocation.routeName: (context) => RegisterLocation(),
  MyHomeScreen.routeName: (context) => MyHomeScreen(),
  ScanPatientQRCode.routeName: (context) => ScanPatientQRCode(),
  ScanDeviceBarcode.routeName: (context) => ScanDeviceBarcode(),
  ScanSummaryScreen.routeName: (context) => ScanSummaryScreen(),
  ResultScreen.routeName: (context) => ResultScreen(),
  WebTimeScreen.routeName: (context) => WebTimeScreen(),
  ScanWebTimeQRCode.routeName: (context) => ScanWebTimeQRCode(),
  LocationHomeScreenBody.routeName: (context) => LocationHomeScreenBody(),
  BookAnAppointment.routeName: (context) => BookAnAppointment(),
  DefaultTestLocation.routeName: (context) => DefaultTestLocation()
};
