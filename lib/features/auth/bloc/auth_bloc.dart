import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<LoginEmailEvent>(_onLoginEmail);
    on<SendOTPEvent>(_onSendOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
    on<RegisterUserEvent>(_onRegisterUser);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginEmail(
      LoginEmailEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await AuthService.loginWithEmailPassword(
        identifier: event.identifier,
        password: event.password,
      );
      emit(AuthAuthenticated(user: result['user']));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      // Error state will be handled by UI - no notifications shown
    }
  }

  Future<void> _onSendOTP(SendOTPEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await AuthService.sendOTP(event.phoneNumber);
      emit(OTPSent(phoneNumber: event.phoneNumber));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
      VerifyOTPEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await AuthService.verifyOTP(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      emit(AuthAuthenticated(user: result['user']));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterUser(
      RegisterUserEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await AuthService.registerUser(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
        location: event.location,
        role: event.role,
        dealerName: event.dealerName,
      );
      emit(AuthRegistered(user: result['user']));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await AuthService.logout();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
