import 'package:flutter/material.dart';
import 'package:message/services/auth.dart';

class SignIN extends StatefulWidget {
  const SignIN({Key? key}) : super(key: key);

  @override
  _SignINState createState() => _SignINState();
}

class _SignINState extends State<SignIN> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messenger Clone"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            AuthMethods().signInWithGoogle(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffDB4437),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Sign in with Google",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
