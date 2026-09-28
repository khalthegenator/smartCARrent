import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/local_db_service.dart';
import 'settings_screen.dart';

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({super.key});

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {
  String? dealerName;
  String _dealerStatus = 'pending';
  bool _statusLoading = true;
  String _authorizationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDealerName();
    _loadDealerStatus();
  }

  Future<void> _loadDealerName() async {
    final user = await AuthService.getCurrentUser();
    final rawDealerName = user?['dealer_name']?.toString().trim();
    final rawFullName = user?['full_name']?.toString().trim();
    final name = (rawDealerName != null && rawDealerName.isNotEmpty)
        ? rawDealerName
        : (rawFullName != null && rawFullName.isNotEmpty)
            ? rawFullName
            : 'Dealer';
    if (mounted) {
      setState(() {
        dealerName = name;
      });
    }
  }

  Future<void> _loadDealerStatus() async {
    final result = await AuthService.getDealerAuthorizationStatus();
    if (!mounted) return;
    setState(() {
      _dealerStatus =
          (result['dealerStatus'] ?? 'pending').toString().toLowerCase();
      _authorizationMessage = result['message']?.toString() ?? '';
      _statusLoading = false;
    });
  }

  Future<void> _openScreen(BuildContext context, Widget screen) async {
    final scaffold = Scaffold.maybeOf(context);
    scaffold?.closeDrawer();

    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    if (result == true) {
      await _loadDealerName();
      await _loadDealerStatus();
    }
  }

  void _handleMenuSelection(BuildContext context, String selection) {
    switch (selection) {
      case 'Home':
        Scaffold.maybeOf(context)?.closeDrawer();
        break;
      case 'Profile':
        _openScreen(context, const DealerProfileScreen());
        break;
      case 'Customers':
        _openScreen(context, const DealerCustomersScreen());
        break;
      case 'Dealerships':
        _openScreen(context, const DealerDealershipsScreen());
        break;
      case 'Vehicles':
        _openScreen(context, const DealerVehiclesScreen());
        break;
      case 'Rentals':
        _openScreen(context, const DealerRentalsScreen());
        break;
      case 'Approval Status':
        _openScreen(context, const DealerAuthorizationStatusScreen());
        break;
      case 'Sales':
        _openScreen(context, const DealerSalesScreen());
        break;
      case 'Withdrawals':
        _openScreen(context, const DealerWithdrawalsScreen());
        break;
      case 'Messages':
        _openScreen(context, const DealerMessagesScreen());
        break;
      case 'Reports & Complaints':
        _openScreen(context, const DealerReportsScreen());
        break;
      case 'Settings':
        _openScreen(context, const SettingsScreen());
        break;
      case 'Logout':
        context.go('/login');
        break;
    }
  }

  Widget _buildFeatureGrid(List<_DealerFeatureItem> features) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVerticalList = constraints.maxWidth < 500;
        final crossAxisCount = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 800
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

        if (isVerticalList) {
          return Column(
            children: List.generate(features.length, (index) {
              final feature = features[index];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == features.length - 1 ? 0 : 16),
                child: _DealerPageTile(
                  icon: feature.icon,
                  title: feature.title,
                  subtitle: feature.subtitle,
                  onTap: () => _openScreen(context, feature.screen),
                ),
              );
            }),
          );
        }

        final double itemWidth = constraints.maxWidth / crossAxisCount;
        final double itemHeight = 140;
        final double childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return _DealerPageTile(
              icon: feature.icon,
              title: feature.title,
              subtitle: feature.subtitle,
              onTap: () => _openScreen(context, feature.screen),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightScaffoldBackground,
        appBar: AppBar(
          title: const Text('Dealer Operations'),
          backgroundColor: AppTheme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.store,
                            color: AppTheme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dealerName != null && dealerName!.isNotEmpty
                                  ? dealerName!
                                  : 'Dealer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Dealership Manager',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _DrawerItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Home',
                        onTap: () => _handleMenuSelection(context, 'Home'),
                      ),
                      _DrawerItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => _handleMenuSelection(context, 'Profile'),
                      ),
                      _DrawerItem(
                        icon: Icons.verified_user_outlined,
                        title: 'Approval Status',
                        onTap: () =>
                            _handleMenuSelection(context, 'Approval Status'),
                      ),
                      _DrawerItem(
                        icon: Icons.people_outline,
                        title: 'Customers',
                        onTap: () => _handleMenuSelection(context, 'Customers'),
                      ),
                      _DrawerItem(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicles',
                        onTap: () => _handleMenuSelection(context, 'Vehicles'),
                      ),
                      _DrawerItem(
                        icon: Icons.book_online_outlined,
                        title: 'Rentals',
                        onTap: () => _handleMenuSelection(context, 'Rentals'),
                      ),
                      _DrawerItem(
                        icon: Icons.bar_chart_outlined,
                        title: 'Sales',
                        onTap: () => _handleMenuSelection(context, 'Sales'),
                      ),
                      _DrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Withdrawals',
                        onTap: () =>
                            _handleMenuSelection(context, 'Withdrawals'),
                      ),
                      _DrawerItem(
                        icon: Icons.message_outlined,
                        title: 'Messages',
                        onTap: () => _handleMenuSelection(context, 'Messages'),
                      ),
                      _DrawerItem(
                        icon: Icons.report_problem_outlined,
                        title: 'Reports & Complaints',
                        onTap: () => _handleMenuSelection(
                            context, 'Reports & Complaints'),
                      ),
                      const Divider(),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => _handleMenuSelection(context, 'Settings'),
                      ),
                      _DrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () => _handleMenuSelection(context, 'Logout'),
                        titleColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dealerName ?? 'Your Dealership',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 2,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage customers, vehicles, rentals, and business operations from your control center.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: _dealerStatus == 'approved'
                    ? AppTheme.successColor.withAlpha(20)
                    : _dealerStatus == 'rejected'
                        ? Colors.redAccent.withAlpha(20)
                        : AppTheme.primaryColor.withAlpha(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLoading
                                  ? 'Loading authorization status...'
                                  : _dealerStatus == 'approved'
                                      ? 'Dealer approved'
                                      : _dealerStatus == 'rejected'
                                          ? 'Authorization rejected'
                                          : 'Authorization pending',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _dealerStatus == 'approved'
                                    ? Colors.green.shade700
                                    : _dealerStatus == 'rejected'
                                        ? Colors.red.shade700
                                        : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusLoading
                                  ? 'Checking your dealer approval progress.'
                                  : _dealerStatus == 'approved'
                                      ? 'Your dealership is fully authorized and can publish vehicles.'
                                      : _dealerStatus == 'rejected'
                                          ? 'Your admin request was rejected. Please update your documents and resubmit.'
                                          : 'Your request is under review by admin. You can check the status and resubmit if needed.',
                              style: const TextStyle(
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_statusLoading)
                        ElevatedButton(
                          onPressed: () => _openScreen(
                            context,
                            const DealerAuthorizationStatusScreen(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: const Text('View status'),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (!_statusLoading && _dealerStatus != 'approved')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.shade700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dealerStatus == 'pending'
                              ? 'Your dealer authorization is pending. You cannot post vehicles until admin approval is granted.'
                              : 'Your dealer authorization was rejected. Please update your details on the Approval Status screen.',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        onPressed: () => _openScreen(
                          context,
                          const DealerAuthorizationStatusScreen(),
                        ),
                        child: const Text('Check status'),
                      ),
                    ],
                  ),
                ),
              if (!_statusLoading && _dealerStatus != 'approved')
                const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Dealer Operations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureGrid(
                [
                  _DealerFeatureItem(
                    icon: Icons.people_outline,
                    title: 'Customers',
                    subtitle: 'Manage customer profiles and activity.',
                    screen: const DealerCustomersScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicles',
                    subtitle: 'Review inventory and vehicle status.',
                    screen: const DealerVehiclesScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.book_online_outlined,
                    title: 'Rentals',
                    subtitle: 'Track rental orders and returns.',
                    screen: const DealerRentalsScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text(
                    'Business Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureGrid(
                [
                  _DealerFeatureItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Approval Status',
                    subtitle: 'Check dealer authorization progress.',
                    screen: const DealerAuthorizationStatusScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'Sales',
                    subtitle: 'Monitor revenue, commissions, and invoices.',
                    screen: const DealerSalesScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Withdrawals',
                    subtitle: 'Manage payout requests and history.',
                    screen: const DealerWithdrawalsScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.message_outlined,
                    title: 'Messages',
                    subtitle: 'Respond to customers and dealer messages.',
                    screen: const DealerMessagesScreen(),
                  ),
                  _DealerFeatureItem(
                    icon: Icons.report_problem_outlined,
                    title: 'Reports',
                    subtitle:
                        'View complaints, damage reports, and escalations.',
                    screen: const DealerReportsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _DealerPageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DealerPageTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealerFeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  const _DealerFeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });
}

class DealerAuthorizationStatusScreen extends StatefulWidget {
  const DealerAuthorizationStatusScreen({super.key});

  @override
  State<DealerAuthorizationStatusScreen> createState() =>
      _DealerAuthorizationStatusScreenState();
}

class _DealerAuthorizationStatusScreenState
    extends State<DealerAuthorizationStatusScreen> {
  bool _loading = true;
  String _status = 'pending';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadAuthorizationStatus();
  }

  Future<void> _loadAuthorizationStatus() async {
    final result = await AuthService.getDealerAuthorizationStatus();
    if (!mounted) return;
    setState(() {
      _status = (result['dealerStatus'] ?? 'pending').toString().toLowerCase();
      _message = result['message']?.toString() ?? '';
      _loading = false;
    });
  }

  Future<void> _showAuthorizationDialog() async {
    final businessNameController = TextEditingController();
    final licenseController = TextEditingController();
    final taxIdController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Submit dealer authorization'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please provide your dealership documentation and contact details for admin review.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: businessNameController,
                      decoration:
                          const InputDecoration(labelText: 'Business name *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: licenseController,
                      decoration:
                          const InputDecoration(labelText: 'License number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taxIdController,
                      decoration: const InputDecoration(labelText: 'Tax ID'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: 'Business address *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration:
                          const InputDecoration(labelText: 'Additional notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (businessNameController.text.trim().isEmpty ||
                              licenseController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill in the required fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final currentUser =
                              await AuthService.getCurrentUser();
                          if (currentUser == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in again.'),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                            return;
                          }

                          final result =
                              await DatabaseService.submitDealerAuthorization(
                            userId: currentUser['id'].toString(),
                            businessName: businessNameController.text.trim(),
                            licenseNumber: licenseController.text.trim(),
                            taxId: taxIdController.text.trim(),
                            address: addressController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            notes: notesController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop(result);
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit request'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result['message']?.toString() ?? 'Request submitted')),
      );
      await _loadAuthorizationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authorization Status'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dealer Authorization',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use this screen to track your dealer approval status and submit your business credentials to the admin.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current status: ${_status.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _status == 'approved'
                                  ? 'Your dealership has been authorized by the admin. You can now publish cars without restrictions.'
                                  : _status == 'rejected'
                                      ? 'Your previous authorization request was rejected. Update your documents and submit again.'
                                      : 'Your authorization request is pending review. The admin will review your documents shortly.',
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            if (_message.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Admin note:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_message),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_status != 'approved')
                      ElevatedButton(
                        onPressed: _showAuthorizationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                        child: Text(
                          _status == 'pending'
                              ? 'Update authorization request'
                              : 'Submit authorization request',
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DealerCustomersScreen extends StatefulWidget {
  const DealerCustomersScreen({super.key});

  @override
  State<DealerCustomersScreen> createState() => _DealerCustomersScreenState();
}

class _DealerCustomersScreenState extends State<DealerCustomersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    final dealerId = user?['id']?.toString();
    if (dealerId == null) {
      setState(() => _loading = false);
      return;
    }
    final customers = await LocalDbService().getDealerCustomers(dealerId);
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customers'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: Colors.white,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Management',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'See which customers are currently renting or buying from your dealership.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    if (_customers.isEmpty)
                      const Text('No customers yet.')
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                              AppTheme.primaryColor.withAlpha(30)),
                          columns: const [
                            DataColumn(label: Text('Customer')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _customers.map((customer) {
                            return DataRow(cells: [
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer['full_name'] ?? 'Customer'),
                                  Text(customer['email'] ?? ''),
                                ],
                              )),
                              DataCell(Chip(
                                backgroundColor:
                                    (customer['booking_status'] ?? 'pending') ==
                                            'confirmed'
                                        ? AppTheme.successColor.withAlpha(30)
                                        : Colors.orange.withAlpha(30),
                                label: Text(
                                  (customer['booking_status'] ?? 'pending')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: (customer['booking_status'] ??
                                                'pending') ==
                                            'confirmed'
                                        ? AppTheme.successColor
                                        : Colors.orange,
                                  ),
                                ),
                              )),
                              DataCell(PopupMenuButton(
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    child: const Text('View'),
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (_) =>
                                              DealerCustomerProfileScreen(
                                            customer: customer,
                                          ),
                                        ));
                                      });
                                    },
                                  ),
                                ],
                                child: const Icon(Icons.more_vert),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DealerCustomerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> customer;

  const DealerCustomerProfileScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(customer['full_name']?.toString() ?? 'Customer Profile'),
            backgroundColor: AppTheme.primaryColor,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Info'),
                Tab(text: 'Rentals'),
                Tab(text: 'Purchases'),
                Tab(text: 'Reviews'),
                Tab(text: 'Reports'),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                            label: 'Name',
                            value: customer['full_name']?.toString() ??
                                'Customer'),
                        _InfoRow(
                            label: 'Phone',
                            value: customer['phone_number']?.toString() ?? '-'),
                        _InfoRow(
                            label: 'Email',
                            value: customer['email']?.toString() ?? '-'),
                        _InfoRow(
                            label: 'Location',
                            value: customer['location']?.toString() ?? '-'),
                        _InfoRow(
                            label: 'Booking Status',
                            value:
                                customer['booking_status']?.toString() ?? '-'),
                        _InfoRow(
                            label: 'Vehicle',
                            value: customer['car_title']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                ),
              ),
              _ProfileSectionCard(
                title: 'Rental/Booking Details',
                content:
                    'Booking started ${customer['booking_start'] ?? '-'} and ends ${customer['booking_end'] ?? '-'} with total ${customer['booking_total'] ?? '-'}',
              ),
              _ProfileSectionCard(
                title: 'Vehicle Status',
                content:
                    'The linked vehicle is currently ${customer['car_status'] ?? 'unknown'}.',
              ),
              _ProfileSectionCard(
                title: 'Notes',
                content:
                    'Use this customer profile to follow up on rental or purchase activity.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DealerDealershipsScreen extends StatelessWidget {
  const DealerDealershipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branches = const [
      {
        'name': 'Dar es Salaam Branch',
        'location': 'Kariakoo',
        'status': 'Open',
      },
      {
        'name': 'Arusha Showroom',
        'location': 'Arusha City',
        'status': 'Open',
      },
      {'name': 'Mwanza Hub', 'location': 'Mwanza', 'status': 'Closed'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealerships'),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dealership Locations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage branches, availability, and operating status.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    AppTheme.primaryColor.withAlpha(30)),
                columns: const [
                  DataColumn(label: Text('Branch')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: branches.map((branch) {
                  return DataRow(cells: [
                    DataCell(Text(branch['name']!)),
                    DataCell(Chip(
                      backgroundColor: branch['status'] == 'Open'
                          ? AppTheme.successColor.withAlpha(30)
                          : Colors.grey.withAlpha(30),
                      label: Text(
                        branch['status']!,
                        style: TextStyle(
                          color: branch['status'] == 'Open'
                              ? AppTheme.successColor
                              : Colors.grey[700],
                        ),
                      ),
                    )),
                    DataCell(PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: const Text('Manage'),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Manage ${branch['name']} branch.'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Update'),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${branch['name']} status updated.'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            });
                          },
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealerVehiclesScreen extends StatefulWidget {
  const DealerVehiclesScreen({super.key});

  @override
  State<DealerVehiclesScreen> createState() => _DealerVehiclesScreenState();
}

class _DealerVehiclesScreenState extends State<DealerVehiclesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];

  String _selectedListingType = 'Rental';
  String _selectedType = 'Sedan';
  String _selectedTransmission = 'Manual';
  String _selectedFuel = 'Petrol';
  String _selectedCondition = 'Excellent';
  String _selectedLocation = 'Dar es Salaam';
  String _selectedRentalDuration = 'Daily';

  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    final userId = user?['id']?.toString();
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final vehicles = await LocalDbService().getUserCars(userId);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _loading = false;
    });
  }

  Future<void> _updateVehicleStatus(String carId, String status) async {
    await LocalDbService().updateCar(carId, {'status': status});
    await _loadVehicles();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle marked as $status')),
    );
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await AuthService.getCurrentUser();
    final userId = user?['id']?.toString();
    final role = (user?['role'] ?? '').toString().toLowerCase();
    final dealerStatus =
        (user?['dealer_status'] ?? 'pending').toString().toLowerCase();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in again to post a vehicle.')),
      );
      return;
    }

    if (role == 'dealer' && dealerStatus != 'approved') {
      await _showAuthorizationDialog();
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image for the vehicle.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final uploadedUrls = <String>[];
      for (final image in _selectedImages) {
        final response = await DatabaseService.uploadImage(image.path);
        if (response['status'] == 'success' && response['image_url'] != null) {
          uploadedUrls.add(response['image_url'] as String);
        }
      }

      await AuthService.postCar(
        title: _titleController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        price: _priceController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        transmission: _selectedTransmission,
        fuel: _selectedFuel,
        condition: _selectedCondition,
        location: _selectedLocation,
        color: _colorController.text.trim(),
        mileage: _mileageController.text.trim(),
        images: uploadedUrls,
        listingType: _selectedListingType,
        rentalDuration: _selectedRentalDuration,
      );

      await _loadVehicles();
      if (!mounted) return;
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedListingType == 'Sell'
                ? 'Vehicle posted for sale.'
                : 'Vehicle posted for rental.',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to post vehicle: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _chooseImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isEmpty) return;
    setState(() {
      _selectedImages.addAll(pickedFiles);
    });
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final image in _selectedImages)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(image.path),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedImages.remove(image));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            GestureDetector(
              onTap: _chooseImages,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor),
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAuthorizationDialog() async {
    final businessNameController = TextEditingController();
    final licenseController = TextEditingController();
    final taxIdController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Dealer authorization required'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You must be approved by the admin before posting vehicles. Submit your business documents below.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: businessNameController,
                      decoration:
                          const InputDecoration(labelText: 'Business name *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: licenseController,
                      decoration:
                          const InputDecoration(labelText: 'License number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taxIdController,
                      decoration: const InputDecoration(labelText: 'Tax ID'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: 'Business address *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone number *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration:
                          const InputDecoration(labelText: 'Additional notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (businessNameController.text.trim().isEmpty ||
                              licenseController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill in the required fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          final currentUser =
                              await AuthService.getCurrentUser();
                          final result =
                              await DatabaseService.submitDealerAuthorization(
                            userId: currentUser?['id']?.toString() ?? '',
                            businessName: businessNameController.text.trim(),
                            licenseNumber: licenseController.text.trim(),
                            taxId: taxIdController.text.trim(),
                            address: addressController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            notes: notesController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop(result);
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit request'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result['message']?.toString() ?? 'Request submitted')),
      );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _modelController.clear();
    _yearController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _colorController.clear();
    _mileageController.clear();
    setState(() {
      _selectedListingType = 'Rental';
      _selectedType = 'Sedan';
      _selectedTransmission = 'Manual';
      _selectedFuel = 'Petrol';
      _selectedCondition = 'Excellent';
      _selectedLocation = 'Dar es Salaam';
      _selectedRentalDuration = 'Daily';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicles'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Posting & Management',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Post dealership vehicles for rental or sale and share the details customers need.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Post a New Vehicle',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedListingType,
                                decoration: const InputDecoration(
                                  labelText: 'Listing Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Rental',
                                    child: Text('For Rent'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sell',
                                    child: Text('For Sale'),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _selectedListingType = value ?? 'Rental';
                                }),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Title',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter a title'
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _modelController,
                                decoration: const InputDecoration(
                                  labelText: 'Model',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter the model'
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _yearController,
                                      decoration: const InputDecoration(
                                        labelText: 'Year',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Please enter the year'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Price (TSh)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Please enter the price'
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please describe the vehicle'
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedType,
                                      decoration: const InputDecoration(
                                        labelText: 'Type',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Sedan',
                                            child: Text('Sedan')),
                                        DropdownMenuItem(
                                            value: 'SUV', child: Text('SUV')),
                                        DropdownMenuItem(
                                            value: 'Hatchback',
                                            child: Text('Hatchback')),
                                        DropdownMenuItem(
                                            value: 'Pickup',
                                            child: Text('Pickup')),
                                      ],
                                      onChanged: (value) => setState(() =>
                                          _selectedType = value ?? 'Sedan'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCondition,
                                      decoration: const InputDecoration(
                                        labelText: 'Condition',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Excellent',
                                            child: Text('Excellent')),
                                        DropdownMenuItem(
                                            value: 'Good', child: Text('Good')),
                                        DropdownMenuItem(
                                            value: 'Fair', child: Text('Fair')),
                                      ],
                                      onChanged: (value) => setState(() =>
                                          _selectedCondition =
                                              value ?? 'Excellent'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedTransmission,
                                      decoration: const InputDecoration(
                                        labelText: 'Transmission',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Manual',
                                            child: Text('Manual')),
                                        DropdownMenuItem(
                                            value: 'Automatic',
                                            child: Text('Automatic')),
                                      ],
                                      onChanged: (value) => setState(() =>
                                          _selectedTransmission =
                                              value ?? 'Manual'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedFuel,
                                      decoration: const InputDecoration(
                                        labelText: 'Fuel',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Petrol',
                                            child: Text('Petrol')),
                                        DropdownMenuItem(
                                            value: 'Diesel',
                                            child: Text('Diesel')),
                                        DropdownMenuItem(
                                            value: 'Hybrid',
                                            child: Text('Hybrid')),
                                      ],
                                      onChanged: (value) => setState(() =>
                                          _selectedFuel = value ?? 'Petrol'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedLocation,
                                      decoration: const InputDecoration(
                                        labelText: 'Location',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Dar es Salaam',
                                            child: Text('Dar es Salaam')),
                                        DropdownMenuItem(
                                            value: 'Arusha',
                                            child: Text('Arusha')),
                                        DropdownMenuItem(
                                            value: 'Mwanza',
                                            child: Text('Mwanza')),
                                      ],
                                      onChanged: (value) => setState(() =>
                                          _selectedLocation =
                                              value ?? 'Dar es Salaam'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _colorController,
                                      decoration: const InputDecoration(
                                        labelText: 'Color',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _mileageController,
                                decoration: const InputDecoration(
                                  labelText: 'Mileage',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              if (_selectedListingType == 'Rental') ...[
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedRentalDuration,
                                  decoration: const InputDecoration(
                                    labelText: 'Rental Duration',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Daily', child: Text('Daily')),
                                    DropdownMenuItem(
                                        value: 'Weekly', child: Text('Weekly')),
                                    DropdownMenuItem(
                                        value: 'Monthly',
                                        child: Text('Monthly')),
                                  ],
                                  onChanged: (value) => setState(() =>
                                      _selectedRentalDuration =
                                          value ?? 'Daily'),
                                ),
                              ],
                              const SizedBox(height: 20),
                              _buildImagePickerSection(),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _submitting ? null : _submitVehicle,
                                  icon: _submitting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.publish),
                                  label: Text(_submitting
                                      ? 'Posting...'
                                      : 'Publish Vehicle'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Posted Vehicles',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_vehicles.isEmpty)
                      const Text('No vehicles posted yet.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final vehicle = _vehicles[index];
                          final title =
                              vehicle['title']?.toString() ?? 'Vehicle';
                          final listingType =
                              vehicle['listing_type']?.toString() ?? 'Rental';
                          final status =
                              (vehicle['status'] ?? 'active').toString();
                          final price = vehicle['price']?.toString() ?? '-';
                          final images = (vehicle['images'] is List)
                              ? vehicle['images'] as List
                              : (vehicle['images'] ?? []);
                          final firstImage = images.isNotEmpty
                              ? images.first.toString()
                              : null;
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 62,
                                  height: 62,
                                  color: Colors.grey.shade100,
                                  child: firstImage != null
                                      ? (firstImage.startsWith('http')
                                          ? Image.network(firstImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.directions_car))
                                          : Image.file(File(firstImage),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.directions_car)))
                                      : const Icon(Icons.directions_car,
                                          size: 30),
                                ),
                              ),
                              title: Text(title),
                              subtitle: Text(
                                  '$listingType • $price TSh • ${vehicle['model'] ?? '-'}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Chip(
                                    label: Text(status.toUpperCase()),
                                    backgroundColor: status == 'active'
                                        ? AppTheme.successColor.withAlpha(30)
                                        : Colors.orange.withAlpha(30),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => DealerVehicleDetailScreen(
                                      vehicle: vehicle),
                                ));
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DealerVehicleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const DealerVehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final listingType = vehicle['listing_type']?.toString() ?? 'Rental';
    final price = vehicle['price']?.toString() ?? '-';
    final model = vehicle['model']?.toString() ?? '-';
    final year = vehicle['year']?.toString() ?? '-';
    final description = vehicle['description']?.toString() ??
        'No additional description provided.';

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(vehicle['title']?.toString() ?? 'Vehicle Details'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vehicle['images'] is List &&
                  (vehicle['images'] as List).isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      (vehicle['images'] as List).first.toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.directions_car_outlined, size: 72),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_outlined,
                      size: 72,
                      color: Colors.grey,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                vehicle['title']?.toString() ?? 'Vehicle',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$listingType • Model: $model • Year: $year',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pricing & Availability',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Price', value: price),
                      _InfoRow(label: 'Listing Type', value: listingType),
                      _InfoRow(
                          label: 'Status',
                          value: vehicle['status']?.toString() ?? '-'),
                      _InfoRow(
                          label: 'Type',
                          value: vehicle['type']?.toString() ?? '-'),
                      _InfoRow(
                          label: 'Location',
                          value: vehicle['location']?.toString() ?? '-'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(description),
                      const SizedBox(height: 8),
                      Text('Transmission: ${vehicle['transmission'] ?? '-'}'),
                      Text('Fuel: ${vehicle['fuel'] ?? '-'}'),
                      Text('Condition: ${vehicle['condition'] ?? '-'}'),
                      Text('Mileage: ${vehicle['mileage'] ?? '-'}'),
                      Text('Color: ${vehicle['color'] ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Documents',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text('• Registration certificate'),
                      Text('• Insurance details'),
                      Text('• Inspection report'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DealerRentalsScreen extends StatelessWidget {
  const DealerRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rentals = [
      {
        'customer': 'Jane Otieno',
        'vehicle': 'Toyota Corolla',
        'period': '3 days',
        'status': 'Ongoing',
        'payment': 'Paid',
        'deadline': '2026-07-09',
        'amount': 'TSh 150,000',
        'contact': '+255 712 000 111',
      },
      {
        'customer': 'Mohamed Said',
        'vehicle': 'Nissan X-Trail',
        'period': '1 day',
        'status': 'Due today',
        'payment': 'Pending',
        'deadline': 'Today',
        'amount': 'TSh 80,000',
        'contact': '+255 713 222 333',
      },
      {
        'customer': 'Amina Hassan',
        'vehicle': 'Suzuki Swift',
        'period': '5 days',
        'status': 'Finished',
        'payment': 'Paid',
        'deadline': 'Completed',
        'amount': 'TSh 210,000',
        'contact': '+255 714 444 555',
      },
    ];

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rentals'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rental Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track active rentals, payment status, deadlines, and customer contact details.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ...rentals.map((rental) {
                final status = rental['status']!.toString();
                final payment = rental['payment']!.toString();
                final isOverdue = status == 'Due today' && payment == 'Pending';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  rental['vehicle']!.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                backgroundColor: status == 'Ongoing'
                                    ? AppTheme.primaryColor.withAlpha(30)
                                    : status == 'Due today'
                                        ? Colors.orange.withAlpha(30)
                                        : AppTheme.successColor.withAlpha(30),
                                label: Text(status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Customer: ${rental['customer']}'),
                          Text('Rental Period: ${rental['period']}'),
                          Text('Payment: $payment'),
                          Text('Amount: ${rental['amount']}'),
                          Text('Deadline: ${rental['deadline']}'),
                          Text('Contact: ${rental['contact']}'),
                          const SizedBox(height: 10),
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Reminder: payment is still pending for this rental.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DealerSalesScreen extends StatefulWidget {
  const DealerSalesScreen({super.key});

  @override
  State<DealerSalesScreen> createState() => _DealerSalesScreenState();
}

class _DealerSalesScreenState extends State<DealerSalesScreen> {
  late final Future<Map<String, dynamic>> _salesData;

  @override
  void initState() {
    super.initState();
    _salesData = _loadDealerSalesData();
  }

  Future<Map<String, dynamic>> _loadDealerSalesData() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) {
      throw Exception('Please log in to view dealer earnings.');
    }

    final dealerId = user['id']?.toString();
    if (dealerId == null || dealerId.isEmpty) {
      throw Exception('Dealer ID is not available.');
    }

    final paymentBase =
        AppConstants.getPaymentApiBase(Theme.of(context).platform);
    final txUrl = Uri.parse(
        '$paymentBase${AppConstants.paymentTransactionsEndpoint}/dealer/$dealerId');
    final walletUrl = Uri.parse(
        '$paymentBase${AppConstants.paymentWalletsEndpoint}/$dealerId');

    final txResp = await http.get(txUrl).timeout(const Duration(seconds: 10));
    if (txResp.statusCode != 200) {
      throw Exception(
          'Failed to load dealer transactions (${txResp.statusCode})');
    }

    final walletResp =
        await http.get(walletUrl).timeout(const Duration(seconds: 10));
    if (walletResp.statusCode != 200) {
      throw Exception(
          'Failed to load dealer wallet (${walletResp.statusCode})');
    }

    final txBody = jsonDecode(txResp.body);
    final walletBody = jsonDecode(walletResp.body);

    final List<Map<String, dynamic>> transactions;
    if (txBody is List) {
      transactions = txBody
          .map(
              (item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
          .toList();
    } else if (txBody is Map<String, dynamic> &&
        txBody['transactions'] != null) {
      transactions = (txBody['transactions'] as List<dynamic>)
          .map(
              (item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
          .toList();
    } else {
      transactions = [];
    }

    final Map<String, dynamic> wallet;
    if (walletBody is Map<String, dynamic> && walletBody['wallet'] != null) {
      wallet = Map<String, dynamic>.from(
          walletBody['wallet'] as Map<String, dynamic>);
    } else if (walletBody is Map<String, dynamic>) {
      wallet = Map<String, dynamic>.from(walletBody);
    } else {
      wallet = {'balance': 0.0};
    }

    return {
      'transactions': transactions,
      'wallet': wallet,
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('complete')) return AppTheme.successColor;
    if (normalized.contains('pending')) return Colors.orange;
    if (normalized.contains('rejected') || normalized.contains('fail')) {
      return Colors.redAccent;
    }
    return Colors.blueGrey;
  }

  String _statusText(String status) {
    return status.isNotEmpty ? status : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dealer Finance'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: FutureBuilder<Map<String, dynamic>>(
          future: _salesData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Unable to load dealer earnings: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final transactions = List<Map<String, dynamic>>.from(
                data['transactions'] as List<dynamic>);
            final wallet = Map<String, dynamic>.from(
                data['wallet'] as Map<String, dynamic>);
            final walletBalance = _toDouble(wallet['balance']);
            final totalOrders = transactions.length;
            final totalEarnings = transactions.fold<double>(
              0.0,
              (sum, item) => sum + _toDouble(item['dealerAmount']),
            );
            final totalCommission = transactions.fold<double>(
              0.0,
              (sum, item) => sum + _toDouble(item['commission']),
            );
            final totalRevenue = transactions.fold<double>(
              0.0,
              (sum, item) => sum + _toDouble(item['amount']),
            );
            final completedCount = transactions
                .where((item) =>
                    item['status']
                        ?.toString()
                        .toLowerCase()
                        .contains('complete') ==
                    true)
                .length;
            final pendingCount = totalOrders - completedCount;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dealer Earnings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View your total earnings, wallet balance, and transaction breakdown from customer orders.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Wallet Balance',
                          value: 'TSh ${walletBalance.toStringAsFixed(0)}',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Earnings',
                          value: 'TSh ${totalEarnings.toStringAsFixed(0)}',
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Orders',
                          value: totalOrders.toString(),
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Pending',
                          value: pendingCount.toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Total Revenue',
                            value: 'TSh ${totalRevenue.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: 'Admin Commission',
                            value: 'TSh ${totalCommission.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: 'Available Wallet',
                            value: 'TSh ${walletBalance.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Transactions completed through Azam Pay will appear here once customers finish payments.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final status = tx['status']?.toString() ?? 'Unknown';
                        final listingType =
                            tx['listingType']?.toString() ?? 'Rental';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      listingType.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status)
                                          .withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _statusText(status),
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Transaction ID: ${tx['id'] ?? tx['transactionId'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Customer',
                                value: tx['customerId']?.toString() ?? '-',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Amount',
                                value:
                                    'TSh ${_toDouble(tx['amount']).toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Dealer Share',
                                value:
                                    'TSh ${_toDouble(tx['dealerAmount']).toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Commission',
                                value:
                                    'TSh ${_toDouble(tx['commission']).toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Provider',
                                value: tx['paymentProvider']?.toString() ?? '-',
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                label: 'Paid At',
                                value: tx['createdAt']?.toString() ?? '-',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class DealerWithdrawalsScreen extends StatefulWidget {
  const DealerWithdrawalsScreen({super.key});

  @override
  State<DealerWithdrawalsScreen> createState() =>
      _DealerWithdrawalsScreenState();
}

class _DealerWithdrawalsScreenState extends State<DealerWithdrawalsScreen> {
  final List<Map<String, dynamic>> _history = [
    {'month': 'May 2026', 'amount': 'TSh 2,100,000', 'status': 'Paid'},
    {'month': 'April 2026', 'amount': 'TSh 1,750,000', 'status': 'Pending'},
    {'month': 'March 2026', 'amount': 'TSh 1,980,000', 'status': 'Approved'},
  ];

  final _amountController = TextEditingController();
  final _methodController = TextEditingController(text: 'Bank Transfer');
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Withdrawals'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payout Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Review payout history and submit fresh withdrawal requests.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Available Balance',
                      value: 'TSh 5,800,000',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending Requests',
                      value: '1',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request New Withdrawal',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (TSh)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _methodController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Payment Note',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Withdrawal request submitted.')),
                            );
                          },
                          child: const Text('Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Withdrawal History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._history.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      title: Text(item['month']),
                      subtitle: Text(item['amount']),
                      trailing: Chip(
                        backgroundColor: item['status'] == 'Paid'
                            ? AppTheme.successColor.withAlpha(30)
                            : item['status'] == 'Approved'
                                ? Colors.blue.withAlpha(30)
                                : Colors.orange.withAlpha(30),
                        label: Text(item['status']),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DealerMessagesScreen extends StatefulWidget {
  const DealerMessagesScreen({super.key});

  @override
  State<DealerMessagesScreen> createState() => _DealerMessagesScreenState();
}

class _DealerMessagesScreenState extends State<DealerMessagesScreen> {
  final List<Map<String, dynamic>> _threads = [
    {
      'name': 'Alice',
      'vehicle': 'Toyota Corolla',
      'preview': 'Is this car available for next weekend?',
      'time': '2m ago',
      'messages': [
        {'from': 'customer', 'text': 'Is this car available for next weekend?'},
        {
          'from': 'dealer',
          'text': 'Yes, it is available and can be booked today.'
        },
      ],
    },
    {
      'name': 'John',
      'vehicle': 'Nissan X-Trail',
      'preview': 'Can you share the invoice for my last booking?',
      'time': '1h ago',
      'messages': [
        {
          'from': 'customer',
          'text': 'Can you share the invoice for my last booking?'
        },
      ],
    },
    {
      'name': 'Mariam',
      'vehicle': 'Suzuki Swift',
      'preview': 'I would like to pick up the vehicle at 9am.',
      'time': 'Yesterday',
      'messages': [
        {
          'from': 'customer',
          'text': 'I would like to pick up the vehicle at 9am.'
        },
      ],
    },
  ];

  int? _selectedThreadIndex;

  @override
  Widget build(BuildContext context) {
    final selectedThread =
        _selectedThreadIndex == null ? null : _threads[_selectedThreadIndex!];

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: _selectedThreadIndex == null
            ? ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _threads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final thread = _threads[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text('${thread['name']} • ${thread['vehicle']}'),
                    subtitle: Text(thread['preview']),
                    trailing: Text(thread['time']),
                    onTap: () {
                      setState(() {
                        _selectedThreadIndex = index;
                      });
                    },
                  );
                },
              )
            : _CustomerChatScreen(
                thread: selectedThread!,
                onBack: () => setState(() => _selectedThreadIndex = null),
              ),
      ),
    );
  }
}

class _CustomerChatScreen extends StatefulWidget {
  final Map<String, dynamic> thread;
  final VoidCallback onBack;

  const _CustomerChatScreen({required this.thread, required this.onBack});

  @override
  State<_CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<_CustomerChatScreen> {
  late final TextEditingController _controller;
  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _messages =
        List<Map<String, dynamic>>.from(widget.thread['messages'] as List);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  '${widget.thread['name']} • ${widget.thread['vehicle']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isDealer = message['from'] == 'dealer';
              return Align(
                alignment:
                    isDealer ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isDealer ? AppTheme.primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                        color: isDealer ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type your reply',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  setState(() {
                    _messages.add(
                        {'from': 'dealer', 'text': _controller.text.trim()});
                    _controller.clear();
                  });
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class DealerReportsScreen extends StatefulWidget {
  const DealerReportsScreen({super.key});

  @override
  State<DealerReportsScreen> createState() => _DealerReportsScreenState();
}

class _DealerReportsScreenState extends State<DealerReportsScreen> {
  final List<Map<String, dynamic>> _reports = [
    {
      'type': 'Late return',
      'customer': 'Alice M.',
      'vehicle': 'Toyota Corolla',
      'summary': 'Customer returned the vehicle 2 days late.',
      'status': 'Open',
      'penalty': 'TSh 120,000',
      'extraCost': 'TSh 50,000',
      'notes': 'Late return penalty applied for extra usage.',
    },
    {
      'type': 'Damage claim',
      'customer': 'John K.',
      'vehicle': 'Nissan X-Trail',
      'summary': 'Minor scratches on the left door reported.',
      'status': 'In review',
      'penalty': 'TSh 80,000',
      'extraCost': 'TSh 30,000',
      'notes': 'Customer requested repair cost reimbursement.',
    },
    {
      'type': 'Refund request',
      'customer': 'Mariam S.',
      'vehicle': 'Suzuki Swift',
      'summary': 'Customer requested a partial refund after a booking issue.',
      'status': 'Resolved',
      'penalty': 'TSh 0',
      'extraCost': 'TSh 25,000',
      'notes': 'Partial refund approved after service disruption.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports & Complaints'),
          backgroundColor: AppTheme.primaryColor,
        ),
        backgroundColor: AppTheme.lightScaffoldBackground,
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = _reports[index];
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report['type'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          backgroundColor: report['status'] == 'Resolved'
                              ? AppTheme.successColor.withAlpha(30)
                              : report['status'] == 'Open'
                                  ? Colors.orange.withAlpha(30)
                                  : Colors.blue.withAlpha(30),
                          label: Text(report['status']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Customer: ${report['customer']}'),
                    Text('Vehicle: ${report['vehicle']}'),
                    const SizedBox(height: 6),
                    Text(report['summary']),
                    const SizedBox(height: 8),
                    Text('Penalty: ${report['penalty']}'),
                    Text('Extra cost: ${report['extraCost']}'),
                    Text('Dealer note: ${report['notes']}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Opened ${report['type']} case')),
                            );
                          },
                          child: const Text('Review'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Penalty applied for ${report['type']}')),
                            );
                          },
                          child: const Text('Apply Penalty'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Extra charge added for ${report['type']}')),
                            );
                          },
                          child: const Text('Add Cost'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final String content;

  const _ProfileSectionCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DealerProfileScreen extends StatefulWidget {
  const DealerProfileScreen({super.key});

  @override
  State<DealerProfileScreen> createState() => _DealerProfileScreenState();
}

class _DealerProfileScreenState extends State<DealerProfileScreen> {
  late TextEditingController _dealerNameController;
  late TextEditingController _dealerPhoneController;
  late TextEditingController _dealerEmailController;
  late TextEditingController _dealerLocationController;
  late TextEditingController _dealerRegistrationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dealerNameController = TextEditingController();
    _dealerPhoneController = TextEditingController();
    _dealerEmailController = TextEditingController();
    _dealerLocationController = TextEditingController();
    _dealerRegistrationController = TextEditingController();
    _loadDealerInfo();
  }

  Future<void> _loadDealerInfo() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _dealerNameController.text = user?['dealer_name'] ?? '';
        _dealerPhoneController.text = user?['phone_number'] ?? '';
        _dealerEmailController.text = user?['email'] ?? '';
        _dealerLocationController.text = user?['location'] ?? '';
        _dealerRegistrationController.text = user?['registration_number'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _dealerNameController.dispose();
    _dealerPhoneController.dispose();
    _dealerEmailController.dispose();
    _dealerLocationController.dispose();
    _dealerRegistrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealership Profile'),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dealership Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Update your dealership details and contact information.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Dealership Name',
                    controller: _dealerNameController,
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Registration Number',
                    controller: _dealerRegistrationController,
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Location',
                    controller: _dealerLocationController,
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _dealerPhoneController,
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Email Address',
                    controller: _dealerEmailController,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveChanges,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save changes. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userUpdates = {
      'dealer_name': _dealerNameController.text.trim(),
      'registration_number': _dealerRegistrationController.text.trim(),
      'phone_number': _dealerPhoneController.text.trim(),
      'email': _dealerEmailController.text.trim(),
      'location': _dealerLocationController.text.trim(),
    };

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await AuthService.updateProfile(userUpdates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dealership profile saved successfully.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
