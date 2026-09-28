import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEmailEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginEmailEvent({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object> get props => [identifier, password];
}

class SendOTPEvent extends AuthEvent {
  final String phoneNumber;

  const SendOTPEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOTPEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOTPEvent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object> get props => [phoneNumber, otp];
}

class RegisterUserEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final String location;
  final String role;
  final String? dealerName;

  const RegisterUserEvent({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.location,
    required this.role,
    this.dealerName,
  });

  @override
  List<Object> get props => [
        fullName,
        email,
        password,
        phoneNumber,
        location,
        role,
        dealerName ?? ''
      ];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
