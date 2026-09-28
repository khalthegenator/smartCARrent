import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class BookingService {
  static const String _bookingsKey = 'user_bookings';
  static const String _favoritesKey = 'user_favorites';
  static const String _notificationsKey = 'user_notifications';

  // Get user's booking history
  static Future<List<Map<String, dynamic>>> getBookingHistory() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return [];

      // In a real app, this would fetch from your database
      // For now, we'll use mock data from local storage
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey);
      
      if (bookingsJson != null) {
        final List<dynamic> bookings = jsonDecode(bookingsJson);
        return bookings.cast<Map<String, dynamic>>();
      }

      // Return mock booking history
      return _getMockBookingHistory();
    } catch (e) {
      throw Exception('Failed to get booking history: $e');
    }
  }

  // Get user's favorite cars
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson != null) {
        final List<dynamic> favorites = jsonDecode(favoritesJson);
        return favorites.cast<Map<String, dynamic>>();
      }

      // Return mock favorites
      return _getMockFavorites();
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Add car to favorites
  static Future<void> addToFavorites(Map<String, dynamic> car) async {
    try {
      final favorites = await getFavorites();
      final prefs = await SharedPreferences.getInstance();
      
      // Check if already in favorites
      if (!favorites.any((fav) => fav['id'] == car['id'])) {
        favorites.add({
          ...car,
          'added_at': DateTime.now().toIso8601String(),
        });
        
        await prefs.setString(_favoritesKey, jsonEncode(favorites));
      }
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove car from favorites
  static Future<void> removeFromFavorites(String carId) async {
    try {
      final favorites = await getFavorites();
      final prefs = await SharedPreferences.getInstance();
      
      favorites.removeWhere((fav) => fav['id'] == carId);
      
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Get user notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        return notifications.cast<Map<String, dynamic>>();
      }

      // Return mock notifications
      return _getMockNotifications();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final prefs = await SharedPreferences.getInstance();
      
      final notificationIndex = notifications.indexWhere((n) => n['id'] == notificationId);
      if (notificationIndex != -1) {
        notifications[notificationIndex]['read'] = true;
        await prefs.setString(_notificationsKey, jsonEncode(notifications));
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required String carId,
    required String startDate,
    required String endDate,
    required double totalPrice,
  }) async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      final booking = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': user['id'],
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice,
        'status': 'pending', // pending, confirmed, cancelled, completed
        'created_at': DateTime.now().toIso8601String(),
      };

      // In a real app, save to database
      final prefs = await SharedPreferences.getInstance();
      final bookings = await getBookingHistory();
      bookings.add(booking);
      await prefs.setString(_bookingsKey, jsonEncode(bookings));

      return booking;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Mock data for development
  static List<Map<String, dynamic>> _getMockBookingHistory() {
    return [
      {
        'id': '1',
        'car_id': 'car1',
        'car_title': 'Toyota Land Cruiser',
        'car_model': '2022',
        'start_date': '2024-01-15',
        'end_date': '2024-01-18',
        'total_price': 450000.0,
        'status': 'completed',
        'created_at': '2024-01-10T10:00:00Z',
        'car_image': 'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Land+Cruiser',
      },
      {
        'id': '2',
        'car_id': 'car2',
        'car_title': 'Honda CR-V',
        'car_model': '2023',
        'start_date': '2024-02-20',
        'end_date': '2024-02-22',
        'total_price': 280000.0,
        'status': 'confirmed',
        'created_at': '2024-02-15T14:30:00Z',
        'car_image': 'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Honda+CRV',
      },
      {
        'id': '3',
        'car_id': 'car3',
        'car_title': 'Nissan X-Trail',
        'car_model': '2021',
        'start_date': '2024-03-10',
        'end_date': '2024-03-12',
        'total_price': 240000.0,
        'status': 'cancelled',
        'created_at': '2024-03-05T09:15:00Z',
        'car_image': 'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Nissan+XTrail',
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockFavorites() {
    return [
      {
        'id': 'fav1',
        'car_id': 'car4',
        'title': 'Mitsubishi Pajero',
        'model': '2022',
        'price': '350,000 TZS/day',
        'type': 'SUV',
        'transmission': 'Automatic',
        'fuel': 'Diesel',
        'location': 'Dar es Salaam',
        'image_url': 'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Pajero',
        'added_at': '2024-01-20T10:00:00Z',
      },
      {
        'id': 'fav2',
        'car_id': 'car5',
        'title': 'Toyota Hilux',
        'model': '2023',
        'price': '280,000 TZS/day',
        'type': 'Pickup',
        'transmission': 'Manual',
        'fuel': 'Diesel',
        'location': 'Arusha',
        'image_url': 'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Hilux',
        'added_at': '2024-02-10T15:30:00Z',
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'id': 'notif1',
        'title': 'Booking Confirmed',
        'message': 'Your booking for Honda CR-V has been confirmed for Feb 20-22, 2024',
        'type': 'success',
        'read': false,
        'created_at': '2024-02-15T14:30:00Z',
      },
      {
        'id': 'notif2',
        'title': 'New Car Available',
        'message': 'A new Toyota Prado is now available for rent in your area',
        'type': 'info',
        'read': false,
        'created_at': '2024-02-18T10:00:00Z',
      },
      {
        'id': 'notif3',
        'title': 'Payment Reminder',
        'message': 'Your booking payment is due in 2 days',
        'type': 'warning',
        'read': true,
        'created_at': '2024-02-16T09:00:00Z',
      },
      {
        'id': 'notif4',
        'title': 'Booking Completed',
        'message': 'Thank you for using SmartCARrent! Please rate your experience',
        'type': 'success',
        'read': true,
        'created_at': '2024-01-19T16:00:00Z',
      },
    ];
  }
}
