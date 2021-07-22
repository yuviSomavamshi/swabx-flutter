import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:swabx/constants.dart';
import 'package:swabx/models/QRCode.dart';
import 'package:swabx/models/Result.dart';
import 'package:swabx/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

EncryptedSharedPreferences encryptedSharedPreferences =
    EncryptedSharedPreferences();

class SharedPreferencesHelper {
  SharedPreferencesHelper._privateConstructor();

  static SharedPreferencesHelper instance =
      SharedPreferencesHelper._privateConstructor();

  static final String _kPatientQRCode = "patientQRS";
  static final String _kPatientResultsCode = "patientResults";

  static String _prefix = "-";
  static Future<List<QRCode>> getQRCodes() async {
    List<QRCode> qrCodes = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var result = prefs.getStringList(_prefix + "-" + _kPatientQRCode);
    if (result != null) {
      qrCodes =
          result.map<QRCode>((e) => QRCode.fromJson(json.decode(e))).toList();
    }
    return qrCodes;
  }

  static Future<bool> setQRCodes(List<QRCode> value) async {
    List<String> codes = value.map((e) => json.encode(e)).toList();
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.setStringList(_prefix + "-" + _kPatientQRCode, codes);
  }

  static Future<String> addQRCode(QRCode code) async {
    List<QRCode> qrCodes = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var value = prefs.getStringList(_prefix + "-" + _kPatientQRCode);
    if (value != null) {
      qrCodes =
          value.map<QRCode>((e) => QRCode.fromJson(json.decode(e))).toList();
    } else {
      qrCodes = [];
    }
    if (code.relationship == "Self") {
      var result = qrCodes.where((e) => e.relationship == "Self");
      if (result != null && result.isNotEmpty) {
        return "Self registration is already done";
      }
    }
    var result = qrCodes.where((e) => e.id == code.id);
    if (result != null && result.isNotEmpty) {
      return "IC/Passport already registered";
    }
    qrCodes.add(code);
    List<String> codes = qrCodes.map((e) => json.encode(e)).toList();

    return await prefs.setStringList(_prefix + "-" + _kPatientQRCode, codes)
        ? "Registered"
        : null;
  }

  static Future<dynamic> removeString(String key) async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.remove(_prefix + "-" + key);
  }

  static Future<dynamic> setString(String key, String value) async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.setString(_prefix + "-" + key, value);
  }

  static Future<dynamic> getString(String key) async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.getString(_prefix + "-" + key);
  }

  static Future<QRCode> getMyQR() async {
    List<QRCode> qrCodes = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var value = prefs.getStringList(_prefix + "-" + _kPatientQRCode);
    if (value != null) {
      qrCodes =
          value.map<QRCode>((e) => QRCode.fromJson(json.decode(e))).toList();
    } else {
      qrCodes = [];
    }
    var result = qrCodes.where((e) => e.relationship == "Self");
    return result != null && result.length > 0 ? result.first : null;
  }

  static Future<bool> removeQRCode(QRCode code) async {
    List<QRCode> qrCodes = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var value = prefs.getStringList(_prefix + "-" + _kPatientQRCode);
    if (value != null) {
      qrCodes =
          value.map<QRCode>((e) => QRCode.fromJson(json.decode(e))).toList();
    } else {
      qrCodes = [];
    }
    qrCodes.removeWhere((c) => c.id == code.id);
    List<String> codes = qrCodes.map((e) => json.encode(e)).toList();
    return prefs.setStringList(_prefix + "-" + _kPatientQRCode, codes);
  }

  static void clearSession() async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    prefs.remove(kId);
    prefs.remove(kName);
    prefs.remove(kToken);
    prefs.remove(kEmail);
    prefs.remove(kRole);
    prefs.remove(kAuthorized);
    _prefix = "-";
  }

  static void loadSession() async {
    _prefix = await getUserEmail();
  }

  static void saveSession(User value) async {
    try {
      final SharedPreferences prefs =
          await encryptedSharedPreferences.getInstance();
      _prefix = value.email;
      prefs.setString(kId, value.id);
      prefs.setString(kName, value.name);
      prefs.setString(kToken, value.jwtToken);
      prefs.setString(kEmail, value.email);
      prefs.setString(kRole, value.role);
      prefs.setBool(kAuthorized, true);
      prefs.setString(
          kRefreshToken, "refreshToken=" + value.refreshToken + ";");
      prefs.setString(kCSRFToken, value.csrfToken);
      prefs.setString(kSessionToken, value.session + ";");
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    _prefix = prefs.getString(kEmail);
    var isAuthenticated = prefs.getBool(kAuthorized);
    if (isAuthenticated == null) isAuthenticated = false;
    return isAuthenticated;
  }

  static Future<String> getUserName() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kName);
  }

  static Future<String> getUserId() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kId);
  }

  static Future<String> getUserRole() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kRole);
  }

  static Future<String> getUserEmail() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kEmail);
  }

  static Future<String> getUserToken() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kToken);
  }

  static Future<String> getRefreshToken() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kRefreshToken);
  }

  static Future<String> getCSRFToken() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kCSRFToken);
  }

  static Future<String> getSessionToken() async {
    SharedPreferences prefs = await encryptedSharedPreferences.getInstance();
    return prefs.getString(kSessionToken);
  }

  static Future<dynamic> setEmail(String value) async {
    _prefix = value;
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.setString(kEmail, value);
  }

  static Future<dynamic> setToken(String value) async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.setString(kToken, value);
  }

  static Future<dynamic> unsetToken() async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    return prefs.remove(kToken);
  }

  static Future<String> addPatient(Result code) async {
    List<Result> results = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var value = prefs.getStringList(_prefix + "-" + _kPatientResultsCode);
    if (value != null) {
      results =
          value.map<Result>((e) => Result.fromJson(json.decode(e))).toList();
    } else {
      results = [];
    }
    results.add(code);
    List<String> codes = results.map((e) => json.encode(e)).toList();
    return await prefs.setStringList(
            _prefix + "-" + _kPatientResultsCode, codes)
        ? "Registered"
        : null;
  }

  static Future<bool> removePatient(Result code) async {
    List<Result> patients = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var value = prefs.getStringList(_prefix + "-" + _kPatientResultsCode);
    if (value != null) {
      patients =
          value.map<Result>((e) => Result.fromJson(json.decode(e))).toList();
    } else {
      patients = [];
    }
    patients.removeWhere((c) => c.id == code.id && c.barcode == code.barcode);
    List<String> codes = patients.map((e) => json.encode(e)).toList();
    return prefs.setStringList(_prefix + "-" + _kPatientResultsCode, codes);
  }

  static Future<List<Result>> getResults() async {
    List<Result> patients = [];
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    var result = prefs.getStringList(_prefix + "-" + _kPatientResultsCode);
    if (result != null) {
      patients =
          result.map<Result>((e) => Result.fromJson(json.decode(e))).toList();
    }
    return patients;
  }

  static Future<bool> persistResults(List<Result> results) async {
    final SharedPreferences prefs =
        await encryptedSharedPreferences.getInstance();
    List<String> codes = results.map((e) => json.encode(e)).toList();
    return prefs.setStringList(_prefix + "-" + _kPatientResultsCode, codes);
  }
}
