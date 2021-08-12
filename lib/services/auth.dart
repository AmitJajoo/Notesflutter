import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:message/helperfunction/sharedpref.dart';
import 'package:message/services/database.dart';
import 'package:message/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;
    // ignore: unnecessary_null_comparison
    if (result != null) {
      var email2 = userDetails!.email;
      SharedPreferenceHelper().saveUserEmail(email2!);
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      var displayName2 = userDetails.displayName;
      SharedPreferenceHelper().saveDisplayName(displayName2!);
      var photoURL = userDetails.photoURL;
      SharedPreferenceHelper().saveUserProfile(photoURL!);
      SharedPreferenceHelper()
          .saveUserName(userDetails.email!.replaceAll("@gmail.com", ""));
      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL
      };

      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    return await auth.signOut();
  }
}
