import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfileKey = "USERPROFILEKEY";

  //save data
  Future<bool> saveUserName(String getUername) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userNameKey, getUername);
  }

  Future<bool> saveUserEmail(String getUerEmail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userEmailKey, getUerEmail);
  }

  Future<bool> saveUserId(String getUerId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userIdKey, getUerId);
  }

  Future<bool> saveDisplayName(String getDisplayName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveUserProfile(String getUserProfile) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(userProfileKey, getUserProfile);
  }

  //get data
  Future<String?> getUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userEmailKey);
  }

  Future<String?> getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userIdKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(displayNameKey);
  }

  Future<String?> getUserProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(userProfileKey);
  }
}
