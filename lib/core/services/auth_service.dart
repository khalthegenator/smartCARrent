import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'local_db_service.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // MySQL-based authentication methods

  // Register new user
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String role,
    String? dealerName,
  }) async {
    try {
      final result = await DatabaseService.registerUser(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        location: location,
        role: role,
        dealerName: dealerName,
      );

      // Save user data locally
      await _saveUserSession(result['user'], result['token']);

      return result;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already exists') ||
          message.contains('duplicate')) {
        throw Exception(
            'This email or phone number is already registered. Please use a different one.');
      }

      throw Exception(e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Registration failed: ', '')
          .trim());
    }
  }

  // Login with email or phone number and password
  static Future<Map<String, dynamic>> loginWithEmailPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final result = await DatabaseService.loginWithEmailPassword(
        identifier: identifier,
        password: password,
      );

      // Save user data locally
      await _saveUserSession(result['user'], result['token']);

      return result;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Create staff user without changing the current session
  static Future<Map<String, dynamic>> createStaffUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String location,
    required String role,
  }) async {
    try {
      final result = await DatabaseService.registerUser(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        location: location,
        role: role,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to create staff user: $e');
    }
  }

  // Send OTP for phone verification (MySQL)
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      final result = await DatabaseService.sendOTP(phoneNumber: phoneNumber);
      return result;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP and login (MySQL)
  static Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final result = await DatabaseService.verifyOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      // Save user data locally
      await _saveUserSession(result['user'], result['token']);

      return result;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Get current user from local storage
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);

      if (userJson == null || token == null) {
        return null;
      }

      final storedUser = jsonDecode(userJson);
      final dbUser = await LocalDbService().getCurrentUser(token);
      if (dbUser != null) {
        await _saveUserSession(dbUser, token);
        return dbUser;
      }

      // Fall back to cached user session if DB lookup fails
      return storedUser as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Save user session locally
  static Future<void> _saveUserSession(
      Map<String, dynamic> user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save user session: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('No user logged in');
      }

      final result = await DatabaseService.updateUserProfile(
        userId: user['id'].toString(),
        userData: userData,
      );

      // Update local user data
      await _saveUserSession(result['user'], await getAuthToken() ?? '');

      return result;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user's cars
  static Future<List<Map<String, dynamic>>> getUserCars() async {
    try {
      print('Auth.getUserCars: Getting current user...');
      final user = await getCurrentUser();
      if (user == null) {
        print('Auth.getUserCars: No user logged in!');
        throw Exception('No user logged in');
      }

      print('Auth.getUserCars: User found: ${user['id']}');
      final cars = await DatabaseService.getUserCars(user['id'].toString());
      print('Auth.getUserCars: Got ${cars.length} cars');
      return cars;
    } catch (e) {
      print('Auth.getUserCars: Error: $e');
      throw Exception('Failed to get user cars: $e');
    }
  }

  static Future<Map<String, dynamic>> getDealerAuthorizationStatus() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return {'status': 'error', 'message': 'No user logged in'};
      }
      return {
        'status': 'success',
        'authorized':
            (user['dealer_status'] ?? 'pending').toString() == 'approved',
        'dealerStatus': user['dealer_status'] ?? 'pending',
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Post a new car
  static Future<Map<String, dynamic>> postCar({
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
    required String listingType, // New: Rental or Sell
    required String rentalDuration, // New: Daily, Weekly, Monthly, Custom
  }) async {
    try {
      print('AuthService.postCar: Getting current user...');
      final user = await getCurrentUser();
      if (user == null) {
        print('AuthService.postCar: No user logged in!');
        throw Exception('No user logged in');
      }

      print('AuthService.postCar: User found: ${user['id']}');
      if ((user['role'] ?? '').toString().toLowerCase() == 'dealer' &&
          (user['dealer_status'] ?? 'pending').toString() != 'approved') {
        throw Exception(
            'Dealer authorization is pending. Please submit your dealership details for admin approval first.');
      }
      final result = await DatabaseService.postCar(
        userId: user['id'].toString(),
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
        rentalDuration: rentalDuration, // Add rental duration
      );

      return result;
    } catch (e) {
      throw Exception('Failed to post car: $e');
    }
  }

  // Update car
  static Future<Map<String, dynamic>> updateCar({
    required String carId,
    required Map<String, dynamic> carData,
  }) async {
    try {
      final result = await DatabaseService.updateCar(
        carId: carId,
        updates: carData,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  // Delete car
  static Future<Map<String, dynamic>> deleteCar(String carId) async {
    try {
      print('Auth.deleteCar: Deleting car: $carId');
      final result = await DatabaseService.deleteCar(carId);
      print('Auth.deleteCar: Car deleted successfully');
      return result;
    } catch (e) {
      print('Auth.deleteCar: Error: $e');
      throw Exception('Failed to delete car: $e');
    }
  }

  // Get all cars for browsing
  static Future<List<Map<String, dynamic>>> getAllCars({
    String? type,
    String? transmission,
    String? location,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cars = await DatabaseService.getAllCars(
        type: type,
        transmission: transmission,
        location: location,
        search: search,
        page: page,
        limit: limit,
      );

      return cars;
    } catch (e) {
      throw Exception('Failed to get cars: $e');
    }
  }

  // Increment car views
  static Future<Map<String, dynamic>> incrementCarViews(String carId) async {
    try {
      final result = await DatabaseService.incrementCarViews(carId);
      return result;
    } catch (e) {
      throw Exception('Failed to increment views: $e');
    }
  }

  // Check database connectivity
  static Future<bool> checkDatabaseConnectivity() async {
    try {
      return await DatabaseService.checkConnectivity();
    } catch (e) {
      return false;
    }
  }
}
