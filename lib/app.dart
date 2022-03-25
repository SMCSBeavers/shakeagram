import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakeagram/models/authentication.dart';
import 'package:provider/provider.dart';
import 'package:shakeagram/models/user_object.dart';
import 'package:shakeagram/screens/home_page.dart';
import 'package:shakeagram/screens/sign_in.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  final String _title = 'Shakeagram';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null,
          )
        ],
        child: (MaterialApp(
          debugShowCheckedModeBanner: false,
          title: _title,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: AuthenticationWrapper(
            title: _title,
          ),
        )));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return HomePage(
        title: title,
      );
    }
    return SignInPage(title: title);
  }
}
