// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocListener, ReadContext;
import 'package:seven_x_c/services/auth/auth_exceptions.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/auth/bloc/auth_state.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
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
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, "My database shows no info, for letters in the order");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, "YOU TYPED SOMETHING WRONG!!!");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
                context, "That is not an E-mail... try again");
          } else if (state.exception is InvalidCredentialAuthException) {
            await showErrorDialog(context,
                "Those are some Invalided Credential you got there...");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Generic Error!!!");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
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
                        RegExp("[a-zA-Z0-9@._-]")),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your E-mail here",
                  ),
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
                    labelText: "Password",
                    hintText: "Enter your password here",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(AuthEventLogIn(
                          email,
                          password,
                        ));
                  },
                  child: const Text("Login"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: const Text(
                    "Not registered yet? Register here",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final email = _email.text.trim(); // Get the entered email
                        if (email.isEmpty) {

      showErrorDialog(context, "Please enter your email before resetting.");
      return; // Stop if no email is entered
    }

                    context.read<AuthBloc>().add(
                          AuthEventForgotPassword(email: email),
                        );
                  },
                  child: const Text(
                    "Forgot your password?",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
