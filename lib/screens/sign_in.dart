import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakeagram/models/authentication.dart';
import 'package:shakeagram/screens/sign_up.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView(children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: FlutterLogo(size: 125.0),
        ),
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Welcome to Shakeagram!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            )),
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Please login or signup',
              textAlign: TextAlign.center,
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text("Email")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text("Password")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<AuthenticationService>()
                  .signIn(emailController.text, passwordController.text);
            },
            child: const Text("Submit"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 1, 68, 251)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()));
              },
              child:
                  const Text('Sign Up', style: TextStyle(color: Colors.blue))),
        ),
      ]),
    );
  }
}
