import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReisterView extends StatefulWidget {
  const ReisterView({super.key});

  @override
  State<ReisterView> createState() => _ReisterViewState();
}

class _ReisterViewState extends State<ReisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: "Enter your E-mail here"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter your password here"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final UserCredential = FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
              } on FirebaseAuthException catch (e) {
                if (e.code == "email-already-in-use") {
                  print("User already exist");
                } else if (e.code == "invalid-email") {
                  print("Not an E-mail");
                } else if (e.code == "weak-password") {
                  print("E-mail needs to eat more proteins ");
                }
              }
            },
            child: const Text("Register"),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              "/login/",
              (route) => false,
            );
          },
          child: const Text("Already registered yet? Login here"),
        )
        ],
      ),
    );
  }
}
