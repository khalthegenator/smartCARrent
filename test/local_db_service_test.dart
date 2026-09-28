import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_car_rent/core/services/local_db_service.dart';
import 'package:smart_car_rent/features/home/screens/admin_dashboard.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalDbService registration', () {
    test('rejects duplicate email or phone numbers with a clear error',
        () async {
      final service = LocalDbService();
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final email = 'duplicate_$suffix@example.com';
      final phone = '+255700000$suffix';

      await service.registerUser(
        fullName: 'Duplicate User',
        email: email,
        password: 'strongpassword123',
        phoneNumber: phone,
        location: 'Dar es Salaam',
        role: 'customer',
      );

      expect(
        () => service.registerUser(
          fullName: 'Duplicate User',
          email: email,
          password: 'strongpassword123',
          phoneNumber: phone,
          location: 'Dar es Salaam',
          role: 'customer',
        ),
        throwsA(
          predicate((e) =>
              e.toString().toLowerCase().contains('already registered') ||
              e.toString().toLowerCase().contains('already used')),
        ),
      );
    });

    testWidgets('shows dealer authorization requests from the database',
        (tester) async {
      final service = LocalDbService();
      final db = await service.database;
      final now = DateTime.now().toIso8601String();
      final userId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      final appId = 'app_${DateTime.now().millisecondsSinceEpoch}';

      await db.delete('dealer_authorizations');
      await db.delete('users');

      await db.insert('users', {
        'id': userId,
        'full_name': 'Test Dealer',
        'email': 'testdealer@example.com',
        'password': 'secret123',
        'phone_number': '+255700000000',
        'location': 'Dar es Salaam',
        'role': 'dealer',
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('dealer_authorizations', {
        'id': appId,
        'user_id': userId,
        'business_name': 'Contoso Motors',
        'license_number': 'L-1001',
        'tax_id': '12345',
        'business_address': 'Kivukoni',
        'business_phone': '+255700000001',
        'business_email': 'contoso@example.com',
        'business_notes': 'Pending review',
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
      });

      await tester
          .pumpWidget(const MaterialApp(home: DealerAuthorizationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Contoso Motors'), findsOneWidget);
      expect(find.textContaining('Pending review'), findsOneWidget);
    });

    testWidgets('loads customers from the database into the admin screen',
        (tester) async {
      final service = LocalDbService();
      final db = await service.database;
      final now = DateTime.now().toIso8601String();
      final userId = 'customer_${DateTime.now().millisecondsSinceEpoch}';

      await db.delete('auth_tokens');
      await db.delete('dealer_authorizations');
      await db.delete('bookings');
      await db.delete('cars');
      await db.delete('users');

      await db.insert('users', {
        'id': userId,
        'full_name': 'Ada Lovelace',
        'email': 'ada@example.com',
        'password': 'secret123',
        'phone_number': '+255700000100',
        'location': 'Dodoma',
        'role': 'customer',
        'created_at': now,
        'updated_at': now,
      });

      await tester.pumpWidget(const MaterialApp(home: AdminCustomersScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.textContaining('ada@example.com'), findsOneWidget);
    });

    testWidgets('loads staff users from the database into the admin screen',
        (tester) async {
      final service = LocalDbService();
      final db = await service.database;
      final now = DateTime.now().toIso8601String();
      final userId = 'staff_${DateTime.now().millisecondsSinceEpoch}';

      await db.delete('auth_tokens');
      await db.delete('dealer_authorizations');
      await db.delete('bookings');
      await db.delete('cars');
      await db.delete('users');

      await db.insert('users', {
        'id': userId,
        'full_name': 'Nora Staff',
        'email': 'nora@example.com',
        'password': 'secret123',
        'phone_number': '+255700000200',
        'location': 'Arusha',
        'role': 'support_officer',
        'created_at': now,
        'updated_at': now,
      });

      await tester.pumpWidget(const MaterialApp(home: AdminStaffScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Nora Staff'), findsOneWidget);
      expect(find.textContaining('Support'), findsOneWidget);
    });
  });
}
