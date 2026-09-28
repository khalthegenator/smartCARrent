import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OTPSent extends AuthState {
  final String phoneNumber;

  const OTPSent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthRegistered extends AuthState {
  final Map<String, dynamic> user;

  const AuthRegistered({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
