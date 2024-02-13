// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/services/auth/auth_exceptions.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/auth/bloc/auth_state.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Password Needs more proteins");
          } else if (state.exception is EmailAlreadyInUserAuthException) {
            await showErrorDialog(context,
                "Email is used by a double-person. A person that is not you, but then again, kinda is");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context,
                "Those are some nice letters. They do not make an E-mail, but they are pretty.");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
                context, "An error is here, that I did not see coming...");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp("[a-zA-Z0-9!@#\$%^&*(),.?\":{}|<>]")),
                  ],
                  decoration: const InputDecoration(
                      labelText: "Email Field",
                      hintText: "Enter your E-mail here"),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp("[a-zA-Z0-9!@#\$%^&*(),.?\":{}|<>]")),
                  ],
                  decoration: const InputDecoration(
                      labelText: "Password Field",
                      hintText: "Enter your password here"),
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(
                          AuthEventReister(
                            email: email,
                            password: password,
                          ),
                        );
                  },
                  child: const Text("Register"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text("Already registered yet? Login here"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
