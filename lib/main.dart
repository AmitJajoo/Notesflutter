import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:message/services/auth.dart';
import 'package:message/views/home.dart';
import 'package:message/views/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: AuthMethods().getCurrentUser(),
          builder: (context, AsyncSnapshot<dynamic> snaphot) {
            if (snaphot.hasData) {
              return Home();
            } else {
              return SignIN();
            }
          },
        ));
  }
}
