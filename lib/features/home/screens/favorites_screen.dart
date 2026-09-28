import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/booking_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await BookingService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load favorites: $e'),
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
        title: const Text('My Favorites'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _showClearAllDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save your favorite cars for quick access',
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

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildFavoriteCard(favorite, index);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite, int index) {
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
          // Car image and favorite button
          Stack(
            children: [
              // Car image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: favorite['image_url'] ?? '',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.grey[400],
                      size: 60,
                    ),
                  ),
                ),
              ),

              // Favorite button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeFavorite(favorite),
                  ),
                ),
              ),

              // Price badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    favorite['price'] ?? 'Price not available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Car details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite['title'] ?? 'Unknown Car',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${favorite['model'] ?? 'Unknown Model'} • ${favorite['type'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Features
                Row(
                  children: [
                    _buildFeatureChip(
                      Icons.settings,
                      favorite['transmission'] ?? 'Manual',
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      Icons.local_gas_station,
                      favorite['fuel'] ?? 'Petrol',
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      Icons.location_on,
                      favorite['location'] ?? 'Unknown',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to car details
                          context.go('/dashboard?tab=0');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to booking
                          _showBookingDialog(favorite);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(Map<String, dynamic> favorite) async {
    try {
      await BookingService.removeFromFavorites(favorite['car_id']);
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove from favorites: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
            'Are you sure you want to remove all cars from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllFavorites();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _clearAllFavorites() async {
    try {
      // Remove each favorite one by one
      for (final favorite in _favorites) {
        await BookingService.removeFromFavorites(favorite['car_id']);
      }
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All favorites cleared'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear favorites: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showBookingDialog(Map<String, dynamic> favorite) {
    DateTimeRange? pickedRange;

    Future<void> pickRange() async {
      final now = DateTime.now();
      final start = await showDatePicker(
        context: context,
        initialDate: now.add(const Duration(days: 1)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );
      if (start == null) return;
      final end = await showDatePicker(
        context: context,
        initialDate: start.add(const Duration(days: 1)),
        firstDate: start,
        lastDate: now.add(const Duration(days: 366)),
      );
      if (end == null) return;
      pickedRange = DateTimeRange(start: start, end: end);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Book ${favorite['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pickedRange == null
                  ? 'Select booking dates'
                  : '${pickedRange!.start.day}/${pickedRange!.start.month}/${pickedRange!.start.year} - ${pickedRange!.end.day}/${pickedRange!.end.month}/${pickedRange!.end.year}'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await pickRange();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Pick Dates'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: pickedRange == null
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      // parse price if available
                      double totalPrice = 0.0;
                      try {
                        final priceStr = (favorite['price'] ?? '').toString();
                        final digits =
                            priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
                        final perDay = double.tryParse(digits) ?? 0.0;
                        final days = pickedRange!.duration.inDays;
                        totalPrice = perDay * (days == 0 ? 1 : days);
                      } catch (_) {}

                      try {
                        await BookingService.createBooking(
                          carId: favorite['car_id'] ?? favorite['id'] ?? '',
                          startDate: pickedRange!.start.toIso8601String(),
                          endDate: pickedRange!.end.toIso8601String(),
                          totalPrice: totalPrice,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking created'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create booking: $e'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              child: const Text('Book'),
            ),
          ],
        );
      }),
    );
  }
}
