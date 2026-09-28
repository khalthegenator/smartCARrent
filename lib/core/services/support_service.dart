import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SupportService {
  static const _ticketsKey = 'support_tickets';
  static const _ratingsKey = 'app_ratings';

  // Submit a support ticket. ticket should contain: id, userId, subject, message, createdAt, status
  static Future<void> submitTicket(Map<String, dynamic> ticket) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ticketsKey);
    final List<Map<String, dynamic>> list = raw == null
        ? []
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(ticket);
    await prefs.setString(_ticketsKey, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ticketsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // Submit app rating: {userId, rating, comment, createdAt}
  static Future<void> submitRating(Map<String, dynamic> rating) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ratingsKey);
    final List<Map<String, dynamic>> list = raw == null
        ? []
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(rating);
    await prefs.setString(_ratingsKey, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ratingsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }
}
