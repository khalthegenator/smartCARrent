import 'package:flutter/foundation.dart';

class AppConstants {
  // App Info
  static const String appName = 'SmartCar Rent';
  static const String appVersion = '1.0.0';

  static String getPaymentApiBase(TargetPlatform platform) {
    if (platform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/payments';
    }
    return 'http://localhost:5000/api/payments';
  }

  // Tanzania Locations
  static const List<String> tanzanianCities = [
    'Dar es Salaam',
    'Arusha',
    'Dodoma',
    'Mwanza',
    'Zanzibar',
    'Mbeya',
    'Morogoro',
    'Tanga',
    'Kilimanjaro',
    'Iringa'
  ];

  // Car Types
  static const List<String> carTypes = [
    'Sedan',
    'SUV',
    'Prado',
    'Pickup',
    'Van',
    'Luxury',
    'Economy'
  ];

  // Mobile Money Providers
  static const List<String> mobileMoneyProviders = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'Halopesa'
  ];

  // API Endpoints
  static const String baseUrl = 'https://api.smartcarrent.co.tz';
  static const String carsEndpoint = '/cars';
  static const String bookingsEndpoint = '/bookings';
  static const String usersEndpoint = '/users';
  static const String paymentsEndpoint = '/payments';
  static const String paymentCreateEndpoint = '/create';
  static const String paymentTransactionsEndpoint = '/transactions';
  static const String paymentWalletsEndpoint = '/wallets';

  // SMS/OTP Settings
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 300; // 5 minutes

  // Price Ranges (TZS)
  static const List<int> priceRanges = [
    50000, // 50k TZS
    100000, // 100k TZS
    150000, // 150k TZS
    200000, // 200k TZS
    300000, // 300k TZS
    500000, // 500k TZS
  ];

  // Booking Settings
  static const int maxBookingDays = 30;
  static const int minBookingHours = 2;

  // Notification Settings
  static const String notificationChannelId = 'smart_car_rent_notifications';
  static const String notificationChannelName = 'SmartCar Rent Notifications';

  // Audio Settings
  static const String notificationSoundPath = 'audio/notification.mp3';
  static const String voiceNavigationPath = 'audio/voice/';
}
