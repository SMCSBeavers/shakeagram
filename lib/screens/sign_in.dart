import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shakeagram/models/authentication.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(label: Text("Email")),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(label: Text("Password")),
          ),
          ElevatedButton(
              onPressed: () {
                context
                    .read<AuthenticationService>()
                    .signIn(emailController.text, passwordController.text);
              },
              child: const Text("Submit"))
        ],
      ),
    );
  }
}
