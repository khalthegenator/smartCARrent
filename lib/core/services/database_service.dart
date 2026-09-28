import 'local_db_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // User Management Functions

  // User Registration - SQLite
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String role,
    String? dealerName,
  }) async {
    return LocalDbService().registerUser(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      location: location,
      role: role,
      dealerName: dealerName,
    );
  }

  // User Login - SQLite
  static Future<Map<String, dynamic>> loginWithEmailPassword({
    required String identifier,
    required String password,
  }) async {
    return LocalDbService().loginWithEmailPassword(
      identifier: identifier,
      password: password,
    );
  }

  // Send OTP - SQLite (mock)
  static Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
  }) async {
    // Mock OTP generation for SQLite
    await Future.delayed(const Duration(seconds: 1));

    final otp =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    return {
      'status': 'success',
      'message': 'OTP sent successfully',
      'otp': otp,
      'expires_at':
          DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    };
  }

  // Verify OTP - SQLite (mock)
  static Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'status': 'success',
      'message': 'OTP verified successfully',
      'user': {
        'id': 'user_${phoneNumber.replaceAll('+255', '')}',
        'full_name': 'User $phoneNumber',
        'email': 'user$phoneNumber@example.com',
        'phone_number': phoneNumber,
        'location': 'Dar es Salaam',
        'created_at': DateTime.now().toIso8601String(),
      },
      'token': 'token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    // This is called from SharedPreferences in auth_service
    return null;
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return LocalDbService().getUserCars(userId).then((cars) => {
          'status': 'success',
          'user': {
            'id': userId,
            'cars': cars,
          },
        });
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    final updatedUser = await LocalDbService().updateUserProfile(
      userId: userId,
      userData: userData,
    );

    return {
      'status': 'success',
      'message': 'Profile updated successfully',
      'user': updatedUser,
    };
  }

  // Car Management Functions

  // Post a car - SQLite
  static Future<Map<String, dynamic>> postCar({
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
    return LocalDbService().postCar(
      userId: userId,
      title: title,
      model: model,
      year: year,
      price: price,
      description: description,
      type: type,
      transmission: transmission,
      fuel: fuel,
      condition: condition,
      location: location,
      color: color,
      mileage: mileage,
      images: images,
      listingType: listingType,
      rentalDuration: rentalDuration,
    );
  }

  // Get user's cars - SQLite
  static Future<List<Map<String, dynamic>>> getUserCars(String userId) async {
    return LocalDbService().getUserCars(userId);
  }

  // Get all cars - SQLite
  static Future<List<Map<String, dynamic>>> getAllCars({
    String? type,
    String? transmission,
    String? location,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    var cars = await LocalDbService().getAllCars();

    // Apply filters
    if (type != null) {
      cars = cars.where((car) => car['type'] == type).toList();
    }
    if (transmission != null) {
      cars = cars.where((car) => car['transmission'] == transmission).toList();
    }
    if (location != null) {
      cars = cars.where((car) => car['location'] == location).toList();
    }
    if (search != null) {
      final searchLower = search.toLowerCase();
      cars = cars.where((car) {
        final title = (car['title'] ?? '').toString().toLowerCase();
        final model = (car['model'] ?? '').toString().toLowerCase();
        return title.contains(searchLower) || model.contains(searchLower);
      }).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, cars.length);

    return cars.sublist(startIndex, endIndex.clamp(0, cars.length));
  }

  // Get car by ID - SQLite
  static Future<Map<String, dynamic>?> getCarById(String carId) async {
    return LocalDbService().getCarById(carId);
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    return LocalDbService().getUserById(userId);
  }

  // Update car - SQLite
  static Future<Map<String, dynamic>> updateCar({
    required String carId,
    required Map<String, dynamic> updates,
  }) async {
    await LocalDbService().updateCar(carId, updates);
    return {
      'status': 'success',
      'message': 'Car updated successfully',
    };
  }

  // Delete car - SQLite
  static Future<Map<String, dynamic>> deleteCar(String carId) async {
    await LocalDbService().deleteCar(carId);
    return {
      'status': 'success',
      'message': 'Car deleted successfully',
    };
  }

  static Future<Map<String, dynamic>> submitDealerAuthorization({
    required String userId,
    required String businessName,
    required String licenseNumber,
    required String taxId,
    required String address,
    required String phone,
    required String email,
    required String notes,
  }) async {
    return LocalDbService().submitDealerAuthorization(
      userId: userId,
      businessName: businessName,
      licenseNumber: licenseNumber,
      taxId: taxId,
      address: address,
      phone: phone,
      email: email,
      notes: notes,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getDealerAuthorizationApplications() async {
    return LocalDbService().getDealerAuthorizationApplications();
  }

  static Future<Map<String, dynamic>> updateDealerAuthorizationStatus({
    required String applicationId,
    required String status,
    required String adminUserId,
    String? reviewNotes,
  }) async {
    return LocalDbService().updateDealerAuthorizationStatus(
      applicationId: applicationId,
      status: status,
      adminUserId: adminUserId,
      reviewNotes: reviewNotes,
    );
  }

  // Search cars
  static Future<List<Map<String, dynamic>>> searchCars(String query) async {
    final allCars = await LocalDbService().getAllCars();

    return allCars.where((car) {
      final title = (car['title'] ?? '').toString().toLowerCase();
      final model = (car['model'] ?? '').toString().toLowerCase();
      final location = (car['location'] ?? '').toString().toLowerCase();
      final queryLower = query.toLowerCase();

      return title.contains(queryLower) ||
          model.contains(queryLower) ||
          location.contains(queryLower);
    }).toList();
  }

  // Increment car views
  static Future<Map<String, dynamic>> incrementCarViews(String carId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'status': 'success',
      'message': 'Car views incremented',
    };
  }

  // Booking Management
  static Future<Map<String, dynamic>> createBooking({
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
    return LocalDbService().createBooking(
      carId: carId,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      carTitle: carTitle,
      carModel: carModel,
      dealerId: dealerId,
      customerPhone: customerPhone,
      paymentProvider: paymentProvider,
      paymentNote: paymentNote,
    );
  }

  // Get user bookings - SQLite
  static Future<List<Map<String, dynamic>>> getUserBookings(
      String userId) async {
    return LocalDbService().getUserBookings(userId);
  }

  // Upload image (mock - no actual upload)
  static Future<Map<String, dynamic>> uploadImage(String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'success',
      'message': 'Image processed (local storage)',
      'image_url': filePath,
    };
  }

  // Check API connectivity (always true for local)
  static Future<bool> checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    await LocalDbService().clearAllData();
  }
}
