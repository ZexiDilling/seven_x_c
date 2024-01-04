import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/helpters/loading/loading_screen.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/auth/bloc/auth_state.dart';
import 'package:seven_x_c/services/auth/firebase_auth_provider.dart';
import 'package:seven_x_c/views/auth_user/forgot_password_view.dart';
import 'package:seven_x_c/views/auth_user/login_view.dart';
import 'package:seven_x_c/views/auth_user/register_view.dart';
import 'package:seven_x_c/views/auth_user/verify_email_view.dart';
import 'package:seven_x_c/views/boulder/gym_view.dart';
import 'package:seven_x_c/views/notes/create_update_note_view.dart';
// import 'package:seven_x_c/views/notes/notes_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocConsumer, BlocProvider, ReadContext;
import 'package:seven_x_c/views/settings/profile_view.dart';

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
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>
    (listener: (context, state) {
      if (state.isLoading) {
       LoadingSCreen().show(context: context, text: state.loadingText ?? "This is taking forever...",);
      } else {
        LoadingSCreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        // return const NotesView();
        return const GymView();
      } else if (state is AuthStateNeedsVerifications) {
        return const VerifyEmailView();
        // return const NotesView();
        // return const GymView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthEventForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const ReisterView();
      }
      else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    } );
  }
}



// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (Context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Counter bloc"),
//         ),
//         body:
//             BlocConsumer<CounterBloc, CounterState>(builder: (context, state) {
//           final invalidValue =
//               (state is CounterStateInvalidNumber) ? state.invalidValue : "";
//           return Column(
//             children: [
//               Text("Current value => ${state.value}"),
//               Visibility(
//                 child: Text("Invalid input: $invalidValue"),
//                 visible: state is CounterStateInvalidNumber,
//               ),
//               TextField(
//                 controller: _controller,
//                 decoration:
//                     const InputDecoration(hintText: "Enter a number here"),
//                 keyboardType: TextInputType.number,
//               ),
//               Row(
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(DecrementEvent(_controller.text));
//                     },
//                     child: const Text("-"),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(IncrementEvent(_controller.text));
//                     },
//                     child: const Text("+"),
//                   )
//                 ],
//               )
//             ],
//           );
//         }, listener: (context, state) {
//           _controller.clear();
//         }),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });
//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
// }
