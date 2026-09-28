import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'booking_history_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'car_details_screen.dart';
import '../../../core/services/database_service.dart';
import 'settings_screen.dart';
import '../../../core/services/support_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/localization_service.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openScreen(BuildContext context, Widget screen,
      {bool closeDrawer = false}) {
    if (closeDrawer) {
      // Safely close drawer if open; maybePop will only pop if there is
      // something to pop (drawer or route) and won't throw when no Scaffold.
      Navigator.of(context).maybePop();
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showFeature(BuildContext context, String feature) {
    switch (feature) {
      case 'Search vehicles':
        _selectTab(1);
        return;
      case 'Rent vehicles':
        _openScreen(
          context,
          const BookingHistoryScreen(),
        );
        return;
      case 'Buy vehicles':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Buy Vehicles',
            subtitle: 'Shop vehicles for purchase',
            content:
                'Browse dealer listings, compare prices, and make a secure purchase through the app.',
            actionLabel: 'Browse for Purchase',
          ),
        );
        return;
      case 'Message dealers':
        _openScreen(context, const MessagesScreen());
        return;
      case 'Favorites':
        _openScreen(context, const FavoritesScreen());
        return;
      case 'Reviews':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Reviews',
            subtitle: 'Share your feedback',
            content:
                'Write reviews for dealers and vehicles after your rental or purchase experience.',
          ),
        );
        return;
      case 'My transactions':
        _openScreen(context, const BookingHistoryScreen());
        return;
      case 'My profile':
        _openScreen(context, const ProfileScreen());
        return;
      default:
        _openScreen(
          context,
          FeatureScreen(
            title: feature,
            subtitle: 'Quick access to $feature',
            content: 'This section helps you manage $feature from one place.',
          ),
        );
    }
  }

  void _handleDrawerSelection(BuildContext context, String title) {
    switch (title) {
      case 'Home':
        _selectTab(0);
        break;
      case 'Search Cars':
        _selectTab(1);
        break;
      case 'Saved Cars':
        _openScreen(context, const FavoritesScreen(), closeDrawer: true);
        break;
      case 'My Bookings':
        _openScreen(context, const BookingHistoryScreen(), closeDrawer: true);
        break;
      case 'Active Rentals':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Active Rentals',
            subtitle: 'Current rentals in progress',
            content:
                'Track your active vehicle rentals and see pickup, return, and status information in one place.',
          ),
          closeDrawer: true,
        );
        break;
      case 'Purchase History':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Purchase History',
            subtitle: 'Review your completed purchases',
            content:
                'See all the vehicles you have purchased and manage payment details and receipts.',
          ),
          closeDrawer: true,
        );
        break;
      case 'Messages':
        _openScreen(context, const MessagesScreen(), closeDrawer: true);
        break;
      case 'Notifications':
        _openScreen(context, const NotificationsScreen(), closeDrawer: true);
        break;
      case 'My Profile':
      case 'Edit Profile':
        _openScreen(context, const ProfileScreen(), closeDrawer: true);
        break;
      case 'Uploaded Documents':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Uploaded Documents',
            subtitle: 'Manage your uploaded files',
            content:
                'View all your identity, license, and verification documents submitted for rentals and purchases.',
          ),
          closeDrawer: true,
        );
        break;
      case 'Change Password':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Change Password',
            subtitle: 'Keep your account secure',
            content:
                'Update your account password and configure stronger authentication settings directly in the app.',
          ),
          closeDrawer: true,
        );
        break;
      case 'Payment Methods':
        _openScreen(
          context,
          const FeatureScreen(
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            content:
                'Add, remove, or update your saved cards and mobile payment methods for faster checkout.',
          ),
          closeDrawer: true,
        );
        break;
      // 'Language' handled in Settings -> Language (removed duplicate)
      case 'Help Center':
        _openScreen(context, const HelpCenterScreen(), closeDrawer: true);
        break;
      case 'Contact Support':
        _openScreen(context, const ContactSupportScreen(), closeDrawer: true);
        break;
      case 'Rate App':
        _openScreen(context, const RateAppScreen(), closeDrawer: true);
        break;
      case 'Terms & Conditions':
        _openScreen(context, const TermsScreen(), closeDrawer: true);
        break;
      case 'Privacy Policy':
        _openScreen(context, const PrivacyPolicyScreen(), closeDrawer: true);
        break;
      case 'Dark Mode':
      case 'Notification Settings':
      case 'Location Settings':
      case 'Language Settings':
        _openScreen(context, const SettingsScreen(), closeDrawer: true);
        break;
      case 'Logout':
        context.go('/login');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user['full_name'] as String? ?? 'Customer'
        : 'Customer';
    final userEmail = authState is AuthAuthenticated
        ? authState.user['email'] as String? ?? 'customer@example.com'
        : 'customer@example.com';

    final pages = [
      DashboardHomeTab(onFeatureTap: _showFeature, userName: userName),
      DashboardSearchTab(onNavigateToSearch: () => _selectTab(1)),
      DashboardProfileOverview(onOpenProfile: () {
        _openScreen(context, const ProfileScreen());
      }),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('SmartCARrent'),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              _openScreen(context, const NotificationsScreen());
            },
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryColor),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                otherAccountsPictures: const [],
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(LocalizationService().t('action.view_profile')),
                onTap: () => _handleDrawerSelection(context, 'My Profile'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Main Menu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
              _DrawerItem(
                icon: Icons.home_outlined,
                title: LocalizationService().t('drawer.home'),
                onTap: () => _handleDrawerSelection(context, 'Home'),
              ),
              _DrawerItem(
                icon: Icons.search,
                title: LocalizationService().t('drawer.search'),
                onTap: () => _handleDrawerSelection(context, 'Search Cars'),
              ),
              _DrawerItem(
                icon: Icons.favorite_border,
                title: LocalizationService().t('drawer.saved'),
                onTap: () => _handleDrawerSelection(context, 'Saved Cars'),
              ),
              _DrawerItem(
                icon: Icons.calendar_today_outlined,
                title: LocalizationService().t('drawer.bookings'),
                onTap: () => _handleDrawerSelection(context, 'My Bookings'),
              ),
              _DrawerItem(
                icon: Icons.directions_car_outlined,
                title: LocalizationService().t('drawer.active_rentals'),
                onTap: () => _handleDrawerSelection(context, 'Active Rentals'),
              ),
              _DrawerItem(
                icon: Icons.shopping_bag_outlined,
                title: LocalizationService().t('drawer.purchases'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Purchase History'),
              ),
              _DrawerItem(
                icon: Icons.message_outlined,
                title: LocalizationService().t('drawer.messages'),
                onTap: () => _handleDrawerSelection(context, 'Messages'),
              ),
              _DrawerItem(
                icon: Icons.notifications_none,
                title: LocalizationService().t('drawer.notifications'),
                onTap: () => _handleDrawerSelection(context, 'Notifications'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Account',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
              _DrawerItem(
                icon: Icons.person_outline,
                title: LocalizationService().t('drawer.profile'),
                onTap: () => _handleDrawerSelection(context, 'My Profile'),
              ),
              _DrawerItem(
                icon: Icons.edit_note_outlined,
                title: LocalizationService().t('drawer.edit_profile'),
                onTap: () => _handleDrawerSelection(context, 'Edit Profile'),
              ),
              _DrawerItem(
                icon: Icons.description_outlined,
                title: LocalizationService().t('drawer.documents'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Uploaded Documents'),
              ),
              _DrawerItem(
                icon: Icons.lock_outline,
                title: LocalizationService().t('drawer.change_password'),
                onTap: () => _handleDrawerSelection(context, 'Change Password'),
              ),
              _DrawerItem(
                icon: Icons.credit_card_outlined,
                title: LocalizationService().t('drawer.payment_methods'),
                onTap: () => _handleDrawerSelection(context, 'Payment Methods'),
              ),
              // Removed duplicate 'Language' entry (use Settings -> Language)
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Support',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
              _DrawerItem(
                icon: Icons.help_outline,
                title: LocalizationService().t('drawer.help_center'),
                onTap: () => _handleDrawerSelection(context, 'Help Center'),
              ),
              _DrawerItem(
                icon: Icons.phone_outlined,
                title: LocalizationService().t('drawer.contact_support'),
                onTap: () => _handleDrawerSelection(context, 'Contact Support'),
              ),
              _DrawerItem(
                icon: Icons.star_outline,
                title: LocalizationService().t('drawer.rate_app'),
                onTap: () => _handleDrawerSelection(context, 'Rate App'),
              ),
              _DrawerItem(
                icon: Icons.description_outlined,
                title: LocalizationService().t('drawer.terms'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Terms & Conditions'),
              ),
              _DrawerItem(
                icon: Icons.privacy_tip_outlined,
                title: LocalizationService().t('drawer.privacy'),
                onTap: () => _handleDrawerSelection(context, 'Privacy Policy'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
              _DrawerItem(
                icon: Icons.dark_mode_outlined,
                title: LocalizationService().t('menu.settings'),
                onTap: () => _handleDrawerSelection(context, 'Dark Mode'),
              ),
              _DrawerItem(
                icon: Icons.notifications_none,
                title: LocalizationService().t('drawer.notifications'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Notification Settings'),
              ),
              _DrawerItem(
                icon: Icons.location_on_outlined,
                title: LocalizationService().t('drawer.search'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Location Settings'),
              ),
              _DrawerItem(
                icon: Icons.language_outlined,
                title: LocalizationService().t('drawer.settings'),
                onTap: () =>
                    _handleDrawerSelection(context, 'Language Settings'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text(LocalizationService().t('drawer.logout'),
                    style: const TextStyle(color: Colors.redAccent)),
                onTap: () => _handleDrawerSelection(context, 'Logout'),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppTheme.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(178),
        elevation: 8,
        onTap: _selectTab,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: LocalizationService().t('drawer.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            label: LocalizationService().t('drawer.search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: LocalizationService().t('drawer.profile'),
          ),
        ],
      ),
    );
  }
}

class DashboardHomeTab extends StatefulWidget {
  final void Function(BuildContext context, String feature) onFeatureTap;
  final String userName;

  const DashboardHomeTab(
      {super.key, required this.onFeatureTap, required this.userName});

  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  late Future<List<Map<String, dynamic>>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = DatabaseService.getAllCars();
    LocalizationService().addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    LocalizationService().removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${widget.userName.split(' ').first}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rent vehicles, buy vehicles, contact dealers, leave reviews, and manage your rentals from one simple place.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your SmartCARrent Journey Starts Here',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover top dealer listings, compare prices, and make secure bookings through the app. Every vehicle is shown with a clear price, status, dealer name, and rich details so you can make confident choices fast.',
                  style: TextStyle(fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _FeatureChip(label: 'Fast search'),
                    _FeatureChip(label: 'Verified dealer info'),
                    _FeatureChip(label: 'Live pricing'),
                    _FeatureChip(label: 'Secure checkout'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Latest listings from dealerships',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _carsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Failed to load listings: ${snapshot.error}');
              }
              final cars = snapshot.data ?? [];
              if (cars.isEmpty) {
                return const Text('No listings available yet.');
              }
              return Column(
                children: cars.map((car) {
                  final images = (car['images'] is List)
                      ? car['images'] as List
                      : (car['images'] ?? []);
                  final firstImage =
                      images.isNotEmpty ? images.first.toString() : null;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CarDetailsScreen(car: car),
                      ));
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14)),
                            child: Container(
                              width: 120,
                              height: 88,
                              color: Colors.grey.shade100,
                              child: firstImage != null
                                  ? (firstImage.startsWith('http')
                                      ? Image.network(firstImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.directions_car))
                                      : Image.file(File(firstImage),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.directions_car)))
                                  : const Icon(Icons.directions_car, size: 40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      car['title'] ?? car['model'] ?? 'Vehicle',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    car['model'] ?? '',
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dealer: ${car['dealer_name'] ?? car['dealer_full_name'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${car['listing_type']?.toString() ?? 'Rental'} • ${car['status']?.toString().toUpperCase() ?? 'ACTIVE'}',
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('TSh ${car['price'] ?? ''}/day',
                                      style: const TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
      labelStyle: const TextStyle(color: AppTheme.primaryColor),
    );
  }
}

class DashboardSearchTab extends StatefulWidget {
  final VoidCallback onNavigateToSearch;

  const DashboardSearchTab({super.key, required this.onNavigateToSearch});

  @override
  State<DashboardSearchTab> createState() => _DashboardSearchTabState();
}

class _DashboardSearchTabState extends State<DashboardSearchTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find your next ride',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search cars, brands, or locations',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onSubmitted: (_) => widget.onNavigateToSearch(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.location_on,
                  title: 'Nearby cars',
                  color: AppTheme.primaryColor,
                  onTap: widget.onNavigateToSearch,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: Icons.filter_alt_outlined,
                  title: 'Add filters',
                  color: Colors.orange,
                  onTap: widget.onNavigateToSearch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.calendar_today,
                  title: 'Rental dates',
                  color: Colors.teal,
                  onTap: widget.onNavigateToSearch,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: Icons.star_border,
                  title: 'Top rated',
                  color: Colors.indigo,
                  onTap: widget.onNavigateToSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardBookingsTab extends StatelessWidget {
  final VoidCallback onViewBookings;

  const DashboardBookingsTab({super.key, required this.onViewBookings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookings overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Active rentals',
            subtitle: 'Continue your current trips and see return details.',
            icon: Icons.directions_car,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Past bookings',
            subtitle: 'Review completed trips and invoices.',
            icon: Icons.history,
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Pending pickups',
            subtitle: 'See cars that are ready for pickup soon.',
            icon: Icons.schedule,
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onViewBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('View full booking history'),
          ),
        ],
      ),
    );
  }
}

class DashboardProfileOverview extends StatefulWidget {
  final VoidCallback onOpenProfile;

  const DashboardProfileOverview({super.key, required this.onOpenProfile});

  @override
  State<DashboardProfileOverview> createState() =>
      _DashboardProfileOverviewState();
}

class _DashboardProfileOverviewState extends State<DashboardProfileOverview> {
  String _name = 'Customer User';
  String _email = 'customer@example.com';
  String? _phone;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _name = user?['full_name'] ?? user?['name'] ?? _name;
      _email = user?['email'] ?? _email;
      _phone = user?['phone_number'] ?? user?['phone'];
      _profileImage = user?['profile_image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quick access to your account details, bookings, and preferred settings.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primaryColor.withAlpha(31),
                      backgroundImage: _profileImage != null
                          ? NetworkImage(_profileImage!) as ImageProvider
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          if (_phone != null) ...[
                            const SizedBox(height: 4),
                            Text(_phone!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick links',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActionListTile(
            icon: Icons.person,
            title: 'View profile',
            subtitle: 'Edit your account details',
            onTap: widget.onOpenProfile,
          ),
          _ActionListTile(
            icon: Icons.calendar_today,
            title: 'My bookings',
            subtitle: 'See current and past reservations',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const BookingHistoryScreen(),
              ));
            },
          ),
          _ActionListTile(
            icon: Icons.favorite_border,
            title: 'Saved cars',
            subtitle: 'Browse your favorites list',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FavoritesScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withAlpha(31),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(31),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class FeatureScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;
  final String? actionLabel;
  final VoidCallback? action;

  const FeatureScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.actionLabel,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            if (actionLabel != null && action != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = [
      {
        'name': 'Dealer A',
        'message': 'Your rental is confirmed.',
        'time': '2m'
      },
      {
        'name': 'Support Team',
        'message': 'We replied to your request.',
        'time': '1h'
      },
      {
        'name': 'Dealer B',
        'message': 'New vehicle options available.',
        'time': 'Yesterday'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(38),
                child: Text(conversation['name']![0]),
              ),
              title: Text(conversation['name'] as String),
              subtitle: Text(conversation['message'] as String),
              trailing: Text(
                conversation['time'] as String,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messaging is coming soon.')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a star rating')));
      return;
    }
    setState(() => _sending = true);
    final user = await AuthService.getCurrentUser();
    final payload = {
      'userId': user?['id'] ?? 'anonymous',
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    await SupportService.submitRating(payload);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks — your rating was submitted')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate App'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Love CarHub Tanzania?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap a star rating and let us know how we did. Your feedback helps us improve the app experience.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Optional comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _sending ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _sending
                  ? const CircularProgressIndicator()
                  : const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
