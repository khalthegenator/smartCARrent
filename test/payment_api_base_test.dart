import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_car_rent/core/constants/app_constants.dart';

void main() {
  test('uses emulator host for Android and localhost for other platforms', () {
    expect(
      AppConstants.getPaymentApiBase(TargetPlatform.android),
      'http://10.0.2.2:5000/api/payments',
    );
    expect(
      AppConstants.getPaymentApiBase(TargetPlatform.iOS),
      'http://localhost:5000/api/payments',
    );
    expect(
      AppConstants.getPaymentApiBase(TargetPlatform.windows),
      'http://localhost:5000/api/payments',
    );
  });
}
