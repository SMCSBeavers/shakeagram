import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakeagram/models/authentication.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffb2e01),
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView(
        children: [
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
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text("Password")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<AuthenticationService>()
                    .signIn(emailController.text, passwordController.text);
              },
              child: const Text("Submit"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xfffb2e01)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
