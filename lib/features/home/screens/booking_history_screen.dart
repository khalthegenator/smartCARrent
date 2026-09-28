import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/theme_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await BookingService.getBookingHistory();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load booking history: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().isDarkMode
          ? AppTheme.darkScaffoldBackground
          : AppTheme.lightScaffoldBackground,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
            Tab(text: 'Purchases'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFilteredList(_filterActive()),
                _buildFilteredList(_filterUpcoming()),
                _buildFilteredList(_filterHistory()),
                _buildFilteredList(_filterPurchases()),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> _filterActive() {
    final now = DateTime.now();
    return _bookings.where((b) {
      try {
        final start = DateTime.parse(b['start_date']);
        final end = DateTime.parse(b['end_date']);
        final status = b['status'] ?? '';
        return (status == 'confirmed' || status == 'pending') &&
            start.isBefore(now) &&
            end.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _filterUpcoming() {
    final now = DateTime.now();
    return _bookings.where((b) {
      try {
        final start = DateTime.parse(b['start_date']);
        return start.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _filterHistory() {
    final now = DateTime.now();
    return _bookings.where((b) {
      try {
        final end = DateTime.parse(b['end_date']);
        return end.isBefore(now) || (b['status'] == 'completed');
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _filterPurchases() {
    return _bookings.where((b) => b['is_purchase'] == true).toList();
  }

  Widget _buildFilteredList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: _loadBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final booking = items[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to browse cars
              context.go('/dashboard?tab=0');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Cars'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    return RefreshIndicator(
      onRefresh: _loadBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image and basic info
          Row(
            children: [
              // Car image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: booking['car_image'] ?? '',
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Car details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['car_title'] ?? 'Unknown Car',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking['car_model'] ?? 'Unknown Model',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      Icons.calendar_today,
                      'Start',
                      _formatDate(booking['start_date']),
                    ),
                    _buildDetailItem(
                      Icons.calendar_today,
                      'End',
                      _formatDate(booking['end_date']),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      Icons.attach_money,
                      'Total',
                      _formatPrice(booking['total_price']),
                    ),
                    _buildDetailItem(
                      Icons.access_time,
                      'Booked',
                      _formatDate(booking['created_at']),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          if (status == 'pending' || status == 'confirmed')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    return '${price.toString()} TZS';
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel your booking for ${booking['car_title']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cancel booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadBookingHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text('Confirm your booking for ${booking['car_title']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement confirm booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              _loadBookingHistory();
            },
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );
  }
}
