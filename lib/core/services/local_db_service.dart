import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  static Database? _database;

  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_car_rent.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await _insertDefaultAdminUser(db);
    await _repairLegacySchema(db);
  }

  Future<void> _repairLegacySchema(Database db) async {
    await _ensureBookingColumns(db);
    await _ensureUserColumns(db);
    await _ensureDealerAuthorizationTable(db);
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<void> _ensureBookingColumns(Database db) async {
    if (!await _tableExists(db, 'bookings')) {
      return;
    }

    final existingColumns = (await db.rawQuery("PRAGMA table_info('bookings')"))
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();

    final columnsToAdd = {
      'car_title': 'TEXT',
      'car_model': 'TEXT',
      'dealer_id': 'TEXT',
      'customer_phone': 'TEXT',
      'payment_provider': 'TEXT',
      'payment_note': 'TEXT',
      'updated_at': 'TEXT',
    };

    for (final entry in columnsToAdd.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
            'ALTER TABLE bookings ADD COLUMN ${entry.key} ${entry.value}');
      }
    }
  }

  Future<void> _ensureUserColumns(Database db) async {
    if (!await _tableExists(db, 'users')) {
      return;
    }

    final existingColumns = (await db.rawQuery("PRAGMA table_info('users')"))
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();

    final columnsToAdd = {
      'role': 'TEXT NOT NULL DEFAULT "customer"',
      'dealer_name': 'TEXT',
      'dealer_status': 'TEXT DEFAULT "pending"',
      'business_name': 'TEXT',
      'business_license': 'TEXT',
      'business_tax_id': 'TEXT',
      'business_address': 'TEXT',
      'business_phone': 'TEXT',
      'business_email': 'TEXT',
      'business_notes': 'TEXT',
      'authorized_at': 'TEXT',
      'authorized_by': 'TEXT',
    };

    for (final entry in columnsToAdd.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
            'ALTER TABLE users ADD COLUMN ${entry.key} ${entry.value}');
      }
    }
  }

  Future<void> _ensureDealerAuthorizationTable(Database db) async {
    if (await _tableExists(db, 'dealer_authorizations')) {
      return;
    }

    await db.execute('''
      CREATE TABLE dealer_authorizations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        business_name TEXT,
        license_number TEXT,
        tax_id TEXT,
        business_address TEXT,
        business_phone TEXT,
        business_email TEXT,
        business_notes TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        reviewed_by TEXT,
        review_notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _insertDefaultAdminUser(Database db) async {
    final defaultEmail = _normalizeEmail('Admin@admin2026.com');
    final defaultPhone = _normalizePhone('0789123456');

    // Try to find any existing admin-like user (previous seed without .com or same phone)
    final likeResult = await db.query(
      'users',
      where: 'email LIKE ? OR phone_number = ?',
      whereArgs: ['%admin2026%', defaultPhone],
    );

    final now = DateTime.now().toIso8601String();

    if (likeResult.isNotEmpty) {
      // Update the first matching user to the canonical admin email/password/role
      final existing = Map<String, dynamic>.from(likeResult.first);
      final userId = existing['id'];

      await db.update(
        'users',
        {
          'email': defaultEmail,
          'password': '12345admin',
          'role': 'super_admin',
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Ensure auth token exists for that user
      final tokenResult = await db.query(
        'auth_tokens',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (tokenResult.isEmpty) {
        await db.insert('auth_tokens', {
          'id': 'token_admin_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': userId,
          'token': 'token_admin_default',
          'created_at': now,
          'expires_at':
              DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        });
      }

      return;
    }

    // Insert new default admin if none found
    await db.insert('users', {
      'id': 'user_admin_default',
      'full_name': 'Super Admin',
      'email': defaultEmail,
      'password': '12345admin',
      'phone_number': defaultPhone,
      'location': 'Dar es Salaam',
      'role': 'super_admin',
      'dealer_name': null,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('auth_tokens', {
      'id': 'token_admin_default',
      'user_id': 'user_admin_default',
      'token': 'token_admin_default',
      'created_at': now,
      'expires_at':
          DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        location TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        dealer_name TEXT,
        registration_number TEXT,
        profile_image TEXT,
        bio TEXT,
        rating REAL DEFAULT 0,
        total_ratings INTEGER DEFAULT 0,
        dealer_status TEXT DEFAULT 'pending',
        business_name TEXT,
        business_license TEXT,
        business_tax_id TEXT,
        business_address TEXT,
        business_phone TEXT,
        business_email TEXT,
        business_notes TEXT,
        authorized_at TEXT,
        authorized_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Cars table
    await db.execute('''
      CREATE TABLE cars (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        model TEXT NOT NULL,
        year TEXT NOT NULL,
        price TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        transmission TEXT,
        fuel TEXT,
        condition TEXT,
        location TEXT NOT NULL,
        color TEXT,
        mileage TEXT,
        images TEXT,
        listing_type TEXT,
        rental_duration TEXT,
        status TEXT DEFAULT 'active',
        views INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        car_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        total_price REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        car_title TEXT,
        car_model TEXT,
        dealer_id TEXT,
        customer_phone TEXT,
        payment_provider TEXT,
        payment_note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (car_id) REFERENCES cars(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Auth tokens table
    await db.execute('''
      CREATE TABLE auth_tokens (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        expires_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    // Dealer authorization applications table
    await db.execute('''
      CREATE TABLE dealer_authorizations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        business_name TEXT,
        license_number TEXT,
        tax_id TEXT,
        business_address TEXT,
        business_phone TEXT,
        business_email TEXT,
        business_notes TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        reviewed_by TEXT,
        review_notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN car_title TEXT
      ''');
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN car_model TEXT
      ''');
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN dealer_id TEXT
      ''');
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN customer_phone TEXT
      ''');
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN payment_provider TEXT
      ''');
      await db.execute('''
        ALTER TABLE bookings ADD COLUMN payment_note TEXT
      ''');
    }

    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT "customer"');
      await db.execute('ALTER TABLE users ADD COLUMN dealer_name TEXT');
    }

    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN dealer_status TEXT DEFAULT "pending"');
      await db.execute('ALTER TABLE users ADD COLUMN business_name TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_license TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_tax_id TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_address TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_phone TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN business_notes TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN authorized_at TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN authorized_by TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dealer_authorizations (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          business_name TEXT,
          license_number TEXT,
          tax_id TEXT,
          business_address TEXT,
          business_phone TEXT,
          business_email TEXT,
          business_notes TEXT,
          status TEXT DEFAULT 'pending',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          reviewed_by TEXT,
          review_notes TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');
    }
  }

  String _normalizeEmail(String value) => value.trim().toLowerCase();

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('0')) {
      return '+255${digits.substring(1)}';
    }
    if (digits.startsWith('255')) {
      return '+$digits';
    }
    return '+$digits';
  }

  // User Registration
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String role,
    String? dealerName,
  }) async {
    final db = await database;

    try {
      final normalizedEmail = _normalizeEmail(email);
      final normalizedPhone = _normalizePhone(phoneNumber);
      final normalizedRole = role.trim().toLowerCase();
      final normalizedFullName = fullName.trim();
      final normalizedDealerName =
          dealerName?.trim().isNotEmpty == true ? dealerName!.trim() : null;

      // Validate
      if (normalizedEmail.isEmpty ||
          password.isEmpty ||
          normalizedFullName.isEmpty ||
          normalizedPhone.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (!normalizedEmail.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      const allowedRoles = [
        'customer',
        'dealer',
        'admin',
        'super_admin',
        'finance_manager',
        'support_officer',
        'vehicle_moderator',
      ];
      if (!allowedRoles.contains(normalizedRole)) {
        throw Exception('Invalid user role');
      }

      final allUsers = await db.query('users');
      final existingUsers = allUsers.where((user) {
        final storedEmail = _normalizeEmail(
          (user['email'] ?? '').toString(),
        );
        final storedPhone = _normalizePhone(
          (user['phone_number'] ?? '').toString(),
        );

        return storedEmail == normalizedEmail || storedPhone == normalizedPhone;
      }).toList();

      if (existingUsers.isNotEmpty) {
        throw Exception(
            'This email or phone number is already registered. Please use a different one.');
      }

      // Create user
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      await db.insert('users', {
        'id': userId,
        'full_name': normalizedFullName,
        'email': normalizedEmail,
        'password': password, // In production, hash this!
        'phone_number': normalizedPhone,
        'location': location.trim(),
        'role': normalizedRole,
        'dealer_name': normalizedDealerName,
        'created_at': now,
        'updated_at': now,
      });

      // Create auth token
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      await db.insert('auth_tokens', {
        'id': 'token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'token': token,
        'created_at': now,
        'expires_at':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      return {
        'status': 'success',
        'message': 'User registered successfully',
        'user': {
          'id': userId,
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'location': location.trim(),
          'role': normalizedRole,
          'dealer_name': normalizedDealerName,
          'created_at': now,
        },
        'token': token,
      };
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception(
            'This email or phone number is already registered. Please use a different one.');
      }
      throw Exception('Registration failed: ${e.toString()}');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // User Login
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String identifier,
    required String password,
  }) async {
    final db = await database;

    try {
      if (identifier.isEmpty || password.isEmpty) {
        throw Exception('Email/Phone and password are required');
      }

      final normalizedIdentifier = identifier.contains('@')
          ? _normalizeEmail(identifier)
          : _normalizePhone(identifier);

      final result = await db.query(
        'users',
        where: '(email = ? OR phone_number = ?) AND password = ?',
        whereArgs: [normalizedIdentifier, normalizedIdentifier, password],
      );

      if (result.isEmpty) {
        throw Exception('Invalid email or password');
      }

      final user = result.first;
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      // Create auth token
      await db.insert('auth_tokens', {
        'id': 'token_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user['id'],
        'token': token,
        'created_at': now,
        'expires_at':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      return {
        'status': 'success',
        'message': 'Login successful',
        'user': user,
        'token': token,
      };
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    final db = await database;

    try {
      final tokenResult = await db.query(
        'auth_tokens',
        where: 'token = ?',
        whereArgs: [token],
      );

      if (tokenResult.isEmpty) {
        return null;
      }

      final userId = tokenResult.first['user_id'];
      final userResult = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) {
        return null;
      }

      return userResult.first as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<int> getUserCount({String? role}) async {
    final db = await database;
    if (role == null) {
      final result = await db.rawQuery('SELECT COUNT(*) AS count FROM users');
      return Sqflite.firstIntValue(result) ?? 0;
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM users WHERE role = ?',
      [role],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingDealerApprovalCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM dealer_authorizations WHERE status = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getActiveVehicleCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM cars WHERE status = ?',
      ['active'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalBookingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM bookings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalBookingRevenue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_price), 0) AS revenue FROM bookings',
    );
    final revenue = result.first['revenue'];
    if (revenue is num) {
      return revenue.toDouble();
    }
    return double.tryParse(revenue?.toString() ?? '0') ?? 0;
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final updates = Map<String, dynamic>.from(userData);
    updates['updated_at'] = now;

    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );

    final updatedRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (updatedRows.isEmpty) {
      throw Exception('User not found');
    }

    return Map<String, dynamic>.from(updatedRows.first);
  }

  Future<List<Map<String, dynamic>>> getDealerCustomers(String dealerId) async {
    final db = await database;
    final dealerCars = await db.query(
      'cars',
      columns: ['id'],
      where: 'user_id = ?',
      whereArgs: [dealerId],
    );
    final carIds = dealerCars.map((c) => c['id'].toString()).toList();

    if (carIds.isEmpty) {
      return [];
    }

    final placeholders = List.filled(carIds.length, '?').join(',');
    final bookings = await db.rawQuery(
      'SELECT * FROM bookings WHERE car_id IN ($placeholders) ORDER BY created_at DESC',
      carIds,
    );

    final userIds =
        bookings.map((b) => b['user_id'].toString()).toSet().toList();
    if (userIds.isEmpty) {
      return [];
    }

    final users = await db.query(
      'users',
      where: 'id IN (${List.filled(userIds.length, '?').join(',')})',
      whereArgs: userIds,
    );

    final userMap = {for (final user in users) user['id'].toString(): user};
    final results = <Map<String, dynamic>>[];

    for (final booking in bookings) {
      final userId = booking['user_id'].toString();
      final user = userMap[userId];
      if (user == null) continue;
      final carId = booking['car_id'].toString();
      final car = await db.query('cars', where: 'id = ?', whereArgs: [carId]);
      final carInfo = car.isNotEmpty ? car.first : null;
      results.add({
        'id': user['id'],
        'full_name': user['full_name'],
        'email': user['email'],
        'phone_number': user['phone_number'],
        'location': user['location'],
        'booking_status': booking['status'],
        'booking_start': booking['start_date'],
        'booking_end': booking['end_date'],
        'booking_total': booking['total_price'],
        'car_title': carInfo?['title'],
        'car_status': carInfo?['status'],
      });
    }

    return results.toSet().toList();
  }

  Future<Map<String, dynamic>> submitDealerAuthorization({
    required String userId,
    required String businessName,
    required String licenseNumber,
    required String taxId,
    required String address,
    required String phone,
    required String email,
    required String notes,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final id = 'auth_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('dealer_authorizations', {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'license_number': licenseNumber,
      'tax_id': taxId,
      'business_address': address,
      'business_phone': phone,
      'business_email': email,
      'business_notes': notes,
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    });

    await db.update(
      'users',
      {
        'business_name': businessName,
        'business_license': licenseNumber,
        'business_tax_id': taxId,
        'business_address': address,
        'business_phone': phone,
        'business_email': email,
        'business_notes': notes,
        'dealer_status': 'pending',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return {
      'status': 'success',
      'message': 'Authorization request submitted successfully',
    };
  }

  Future<List<Map<String, dynamic>>>
      getDealerAuthorizationApplications() async {
    final db = await database;
    final rows = await db.query(
      'dealer_authorizations',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<Map<String, dynamic>> updateDealerAuthorizationStatus({
    required String applicationId,
    required String status,
    required String adminUserId,
    String? reviewNotes,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'dealer_authorizations',
      {
        'status': status,
        'reviewed_by': adminUserId,
        'review_notes': reviewNotes ?? '',
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [applicationId],
    );

    final apps = await db.query(
      'dealer_authorizations',
      where: 'id = ?',
      whereArgs: [applicationId],
    );
    if (apps.isEmpty) {
      return {'status': 'error', 'message': 'Application not found'};
    }

    final app = apps.first;
    final userId = app['user_id'].toString();
    await db.update(
      'users',
      {
        'dealer_status': status == 'approved' ? 'approved' : 'rejected',
        'authorized_at': now,
        'authorized_by': adminUserId,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return {'status': 'success', 'message': 'Authorization updated'};
  }

  // Post a car
  Future<Map<String, dynamic>> postCar({
    required String userId,
    required String title,
    required String model,
    required String year,
    required String price,
    required String description,
    required String type,
    required String transmission,
    required String fuel,
    required String condition,
    required String location,
    required String color,
    required String mileage,
    required List<String> images,
    required String listingType,
    required String rentalDuration,
  }) async {
    final db = await database;

    try {
      final carId = 'car_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      await db.insert('cars', {
        'id': carId,
        'user_id': userId,
        'title': title,
        'model': model,
        'year': year,
        'price': price,
        'description': description,
        'type': type,
        'transmission': transmission,
        'fuel': fuel,
        'condition': condition,
        'location': location,
        'color': color,
        'mileage': mileage,
        'images': jsonEncode(images),
        'listing_type': listingType,
        'rental_duration': rentalDuration,
        'status': 'active',
        'views': 0,
        'created_at': now,
        'updated_at': now,
      });

      return {
        'status': 'success',
        'message': 'Car posted successfully',
        'car': {
          'id': carId,
          'user_id': userId,
          'title': title,
          'model': model,
          'year': year,
          'price': price,
          'description': description,
          'type': type,
          'transmission': transmission,
          'fuel': fuel,
          'condition': condition,
          'location': location,
          'color': color,
          'mileage': mileage,
          'images': images,
          'listing_type': listingType,
          'created_at': now,
        },
      };
    } catch (e) {
      throw Exception('Failed to post car: ${e.toString()}');
    }
  }

  // Get user's cars
  Future<List<Map<String, dynamic>>> getUserCars(String userId) async {
    final db = await database;

    try {
      final result = await db.query(
        'cars',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return result.map((car) {
        final mutableCar = Map<String, dynamic>.from(car);
        if (mutableCar['images'] is String) {
          try {
            mutableCar['images'] = jsonDecode(mutableCar['images'] as String);
          } catch (e) {
            mutableCar['images'] = [];
          }
        }
        return mutableCar;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user cars: ${e.toString()}');
    }
  }

  // Get all cars
  Future<List<Map<String, dynamic>>> getAllCars() async {
    final db = await database;

    try {
      final result = await db.query(
        'cars',
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: 'created_at DESC',
      );

      return result.map((car) {
        final mutableCar = Map<String, dynamic>.from(car);
        if (mutableCar['images'] is String) {
          try {
            mutableCar['images'] = jsonDecode(mutableCar['images'] as String);
          } catch (e) {
            mutableCar['images'] = [];
          }
        }
        return mutableCar;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cars: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;

    try {
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return Map<String, dynamic>.from(result.first);
    } catch (e) {
      throw Exception('Failed to load user: ${e.toString()}');
    }
  }

  // Get car by ID
  Future<Map<String, dynamic>?> getCarById(String carId) async {
    final db = await database;

    try {
      final result = await db.query(
        'cars',
        where: 'id = ?',
        whereArgs: [carId],
      );

      if (result.isEmpty) {
        return null;
      }

      final car = result.first;
      final mutableCar = Map<String, dynamic>.from(car);
      if (mutableCar['images'] is String) {
        try {
          mutableCar['images'] = jsonDecode(mutableCar['images'] as String);
        } catch (e) {
          mutableCar['images'] = [];
        }
      }
      return mutableCar;
    } catch (e) {
      return null;
    }
  }

  // Delete car
  Future<void> deleteCar(String carId) async {
    final db = await database;
    await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [carId],
    );
  }

  // Update car
  Future<void> updateCar(String carId, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();

    if (updates.containsKey('images') && updates['images'] is List) {
      updates['images'] = jsonEncode(updates['images']);
    }

    await db.update(
      'cars',
      updates,
      where: 'id = ?',
      whereArgs: [carId],
    );
  }

  // Create booking
  Future<Map<String, dynamic>> createBooking({
    required String carId,
    required String userId,
    required String startDate,
    required String endDate,
    required double totalPrice,
    String? carTitle,
    String? carModel,
    String? dealerId,
    String? customerPhone,
    String? paymentProvider,
    String? paymentNote,
  }) async {
    final db = await database;

    try {
      final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final carResult =
          await db.query('cars', where: 'id = ?', whereArgs: [carId], limit: 1);
      final car = carResult.isNotEmpty
          ? Map<String, dynamic>.from(carResult.first)
          : {};

      await db.insert('bookings', {
        'id': bookingId,
        'car_id': carId,
        'user_id': userId,
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice,
        'status': 'pending',
        'car_title': carTitle ?? car['title'] ?? '',
        'car_model': carModel ?? car['model'] ?? '',
        'dealer_id': dealerId ?? car['user_id'] ?? '',
        'customer_phone': customerPhone ?? '',
        'payment_provider': paymentProvider ?? '',
        'payment_note': paymentNote ?? '',
        'created_at': now,
        'updated_at': now,
      });

      return {
        'status': 'success',
        'message': 'Booking created successfully',
        'booking': {
          'id': bookingId,
          'car_id': carId,
          'user_id': userId,
          'start_date': startDate,
          'end_date': endDate,
          'total_price': totalPrice,
          'status': 'pending',
          'created_at': now,
        },
      };
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  // Get user bookings
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final db = await database;

    try {
      final result = await db.query(
        'bookings',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get bookings: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await database;

    try {
      final result = await db.query('bookings', orderBy: 'created_at DESC');
      return result
          .map((booking) => Map<String, dynamic>.from(booking))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getWallets() async {
    final db = await database;

    try {
      final bookings = await db.query('bookings');
      final totalRevenue = bookings.fold<double>(0.0, (sum, booking) {
        final amount = booking['total_price'];
        return sum + (amount is num ? amount.toDouble() : 0.0);
      });
      final totalCommission = bookings.fold<double>(0.0, (sum, booking) {
        final amount = booking['total_price'];
        final amountValue = amount is num ? amount.toDouble() : 0.0;
        return sum + (amountValue * 0.05);
      });

      return {
        'admin': {
          'balance': totalCommission,
          'currency': 'TZS',
        },
        'dealer': {
          'balance': totalRevenue - totalCommission,
          'currency': 'TZS',
        },
      };
    } catch (e) {
      throw Exception('Failed to get wallets: ${e.toString()}');
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('bookings');
    await db.delete('auth_tokens');
    await db.delete('cars');
    await db.delete('users');
  }
}
