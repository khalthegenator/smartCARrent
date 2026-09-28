import 'package:flutter_test/flutter_test.dart';
import 'package:smart_car_rent/features/home/screens/payment_test_screen.dart';

void main() {
  test('buildReceiptSummary includes the payment details for customer receipt',
      () {
    final receipt = buildReceiptSummary(
      amount: 50000,
      provider: 'Airtel',
      phoneNumber: '0755123456',
      listingType: 'rental',
      transactionId: 'tx-123',
    );

    expect(receipt, contains('Airtel'));
    expect(receipt, contains('0755123456'));
    expect(receipt, contains('tx-123'));
    expect(receipt, contains('Rental'));
  });
}
