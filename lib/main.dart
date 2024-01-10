import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/helpters/loading/loading_screen.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/auth/bloc/auth_state.dart';
import 'package:seven_x_c/services/auth/firebase_auth_provider.dart';
import 'package:seven_x_c/views/admin/admin_view.dart';
import 'package:seven_x_c/views/auth_user/forgot_password_view.dart';
import 'package:seven_x_c/views/auth_user/login_view.dart';
import 'package:seven_x_c/views/auth_user/register_view.dart';
import 'package:seven_x_c/views/auth_user/verify_email_view.dart';
import 'package:seven_x_c/views/boulder/gym_view.dart';
import 'package:seven_x_c/views/boulder/ranking_view.dart';
import 'package:seven_x_c/views/missing_views/profile_view.dart';
import 'package:seven_x_c/views/notes/create_update_note_view.dart';
// import 'package:seven_x_c/views/notes/notes_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocConsumer, BlocProvider, ReadContext;
import 'package:seven_x_c/views/admin/profile_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: "DTU Climbing",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNote: (context) => const CreateUpdateNoteView(),
        profileSettings: (context) => const ProfileSettingsView(),
        adminPanel: (context) => const AdminPanelView(),
        gymView: (context) => const GymView(),
        rankView: (context) => const RankView(),
        profileView: (context) => const ProfileView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingSCreen().show(
          context: context,
          text: state.loadingText ?? "This is taking forever...",
        );
      } else {
        LoadingSCreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const GymView();
      } else if (state is AuthStateNeedsVerifications) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthEventForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const ReisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}


