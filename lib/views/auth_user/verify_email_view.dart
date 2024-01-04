import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify your E-mail"),
      ),
      body: Column(children: [
        const Text(
            "We've send your an E-mail, please click the link in the E-mail."),
        const Text(
            "Have you not recive and E-mail, please click the button below"),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification(),
                );
          },
          child: const Text("Send E-mail Verification"),
        ),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventLogOut(),
                );
          },
          child: const Text("Restart"),
        ),
      ]),
    );
  }
}
