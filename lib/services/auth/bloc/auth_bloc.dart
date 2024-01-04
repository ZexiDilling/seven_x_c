import 'package:bloc/bloc.dart';
import 'package:seven_x_c/services/auth/auth_provider.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialzed(
          isLoading: true,
        )) {
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return;
      }
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));
      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }
      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );
    on<AuthEventReister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerifications(
            isLoading: false,
          ));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    },);
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerifications(
          isLoading: false,
        ));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
            exception: null,  
            isLoading: false,
            loadingText:
                "Trying to gain access to the software. It is harder than I thought..."),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthStateNeedsVerifications(
            isLoading: false,
          ));
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateUninitialzed(
        isLoading: false,
      ));
      try {
        await provider.logout();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
  }
}
