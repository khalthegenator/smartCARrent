import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/local_db_service.dart';
import '../../../theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardMetrics();
  }

  Future<Map<String, dynamic>> _loadDashboardMetrics() async {
    final customers = await LocalDbService().getUserCount(role: 'customer');
    final dealers = await LocalDbService().getUserCount(role: 'dealer');
    final pendingApprovals =
        await LocalDbService().getPendingDealerApprovalCount();
    final activeVehicles = await LocalDbService().getActiveVehicleCount();
    final bookings = await LocalDbService().getTotalBookingCount();
    final revenue = await LocalDbService().getTotalBookingRevenue();

    return {
      'customers': customers,
      'dealers': dealers,
      'pendingApprovals': pendingApprovals,
      'activeVehicles': activeVehicles,
      'bookings': bookings,
      'revenue': revenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightScaffoldBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const _AdminDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load dashboard data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data ?? {};
          final overviewMetrics = [
            {
              'label': 'Customers',
              'value': (data['customers'] ?? 0).toString(),
              'icon': Icons.group,
              'color': AppTheme.primaryColor,
            },
            {
              'label': 'Dealers',
              'value': (data['dealers'] ?? 0).toString(),
              'icon': Icons.storefront,
              'color': Colors.green,
            },
            {
              'label': 'Vehicles',
              'value': (data['activeVehicles'] ?? 0).toString(),
              'icon': Icons.directions_car,
              'color': Colors.orange,
            },
            {
              'label': 'Pending Approvals',
              'value': (data['pendingApprovals'] ?? 0).toString(),
              'icon': Icons.pending_actions,
              'color': Colors.blue,
            },
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Super Admin Control Center',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Live counts for the app and a fast entry point to payments, dealers, and approvals.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth >= 1200
                              ? 4
                              : constraints.maxWidth >= 800
                                  ? 2
                                  : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: overviewMetrics.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.16,
                            ),
                            itemBuilder: (context, index) {
                              final metric = overviewMetrics[index];
                              return _OverviewMetricCard(
                                label: metric['label'] as String,
                                value: metric['value'] as String,
                                icon: metric['icon'] as IconData,
                                color: metric['color'] as Color,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 247, 232, 1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color.fromRGBO(245, 166, 35, 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recommended next action',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (data['pendingApprovals'] ?? 0) > 0
                                  ? 'Review the pending dealer approvals first so newly approved dealers can publish vehicles and serve customers.'
                                  : 'All dealer approvals are up to date. Keep monitoring new vehicle postings and payment activity.',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Finance Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Revenue: TZS ${(data['revenue'] as double).toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bookings: ${data['bookings'] ?? 0}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pending dealer approvals: ${data['pendingApprovals'] ?? 0}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Azam Pay commissions and payout split are shown in the Azam Pay summary below.',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/payments/test'),
                        icon: const Icon(Icons.payment),
                        label: const Text('Azam Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Azam Pay Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'All customer payments flow through Azam Pay. Purchase transactions add 8% admin commission, while rental transactions add 5% admin commission. The remainder is directed to the dealer wallet.',
                        style: TextStyle(fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 600
                                  ? 2
                                  : 1;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.35,
                            children: [
                              _StatCard(
                                title: 'Purchase Commission',
                                value: '8%',
                                color: Colors.orange,
                              ),
                              _StatCard(
                                title: 'Rental Commission',
                                value: '5%',
                                color: Colors.green,
                              ),
                              _StatCard(
                                title: 'Dealer Share',
                                value: '92% / 95%',
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Admin Quick Actions',
                  subtitle: 'Open the sections you need most often.',
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth >= 920
                        ? (constraints.maxWidth - 64) / 3
                        : constraints.maxWidth >= 680
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.group,
                            title: 'Customers',
                            description: 'Manage customers and their profiles.',
                            onTap: () =>
                                context.go('/admin-dashboard/customers'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.people,
                            title: 'Staff',
                            description: 'Create and manage support staff.',
                            onTap: () => context.go('/admin-dashboard/staff'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.verified_user,
                            title: 'Dealers',
                            description:
                                'Review dealer authorization requests.',
                            onTap: () => context.go('/admin-dashboard/dealers'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.local_offer,
                            title: 'Vehicles',
                            description: 'Approve or reject vehicle listings.',
                            onTap: () =>
                                context.go('/admin-dashboard/vehicles'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.account_balance_wallet,
                            title: 'Finance',
                            description:
                                'Review payments and revenue summaries.',
                            onTap: () => context.go('/admin-dashboard/finance'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.payment,
                            title: 'Azam Payments',
                            description: 'Open the Azam payment testing page.',
                            onTap: () => context.go('/payments/test'),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth.clamp(260, double.infinity),
                          child: _AdminCard(
                            icon: Icons.receipt_long,
                            title: 'Transactions',
                            description:
                                'Inspect recent rental and purchase transactions.',
                            onTap: () =>
                                context.go('/admin-dashboard/transactions'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppTheme.primaryColor,
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => context.go('/admin-dashboard'),
            ),
            _DrawerTile(
              icon: Icons.group,
              title: 'Customers',
              onTap: () => context.go('/admin-dashboard/customers'),
            ),
            _DrawerTile(
              icon: Icons.people,
              title: 'Staff',
              onTap: () => context.go('/admin-dashboard/staff'),
            ),
            _DrawerTile(
              icon: Icons.storefront,
              title: 'Dealer Approvals',
              onTap: () => context.go('/admin-dashboard/dealers'),
            ),
            _DrawerTile(
              icon: Icons.local_offer,
              title: 'Vehicle Moderation',
              onTap: () => context.go('/admin-dashboard/vehicles'),
            ),
            _DrawerTile(
              icon: Icons.account_balance_wallet,
              title: 'Finance',
              onTap: () => context.go('/admin-dashboard/finance'),
            ),
            _DrawerTile(
              icon: Icons.receipt_long,
              title: 'Transactions',
              onTap: () => context.go('/admin-dashboard/transactions'),
            ),
            const Divider(),
            _DrawerTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final db = await LocalDbService().database;
      final rows = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['customer'],
        orderBy: 'created_at DESC',
      );

      if (!mounted) return;
      setState(() {
        _customers
          ..clear()
          ..addAll(rows.map((row) => Map<String, dynamic>.from(row)));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load customers: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    final lower = _filter.trim().toLowerCase();
    if (lower.isEmpty) return _customers;
    return _customers.where((customer) {
      final values = [
        customer['full_name'],
        customer['email'],
        customer['phone_number'],
        customer['location'],
      ].whereType<String>().map((value) => value.toLowerCase());
      return values.any((value) => value.contains(lower));
    }).toList();
  }

  void _addCustomer() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop();
                try {
                  await LocalDbService().registerUser(
                    fullName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: 'password123',
                    phoneNumber: phoneController.text.trim(),
                    location: 'Unknown',
                    role: 'customer',
                  );
                  await _loadCustomers();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to add customer: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Customer Management',
              subtitle: 'Search and review customer accounts.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search customers',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filter = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addCustomer,
                  child: const Text('Add Customer'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCustomers.isEmpty
                      ? const Center(child: Text('No customers found.'))
                      : ListView.separated(
                          itemCount: _filteredCustomers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            final status = customer['role'] == 'customer'
                                ? 'Active'
                                : 'Pending';
                            return Card(
                              child: ListTile(
                                title: Text(
                                  customer['full_name']?.toString() ??
                                      'Customer',
                                ),
                                subtitle: Text(
                                  '${customer['email']?.toString() ?? 'No email'}\n${customer['phone_number']?.toString() ?? 'No phone'}',
                                ),
                                trailing: Text(status),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminStaffScreen extends StatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  State<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {
  final List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final db = await LocalDbService().database;
      final rows = await db.query(
        'users',
        where: 'role IN (?, ?, ?, ?)',
        whereArgs: [
          'super_admin',
          'finance_manager',
          'support_officer',
          'vehicle_moderator',
        ],
        orderBy: 'created_at DESC',
      );
      if (!mounted) return;
      setState(() {
        _staff
          ..clear()
          ..addAll(rows.map((row) => Map<String, dynamic>.from(row)));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load staff: $e')),
      );
    }
  }

  void _showAddStaff() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String role = 'Support';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Staff Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'Support', child: Text('Support')),
                  DropdownMenuItem(
                      value: 'Operations', child: Text('Operations')),
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                ],
                onChanged: (value) {
                  if (value != null) role = value;
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop();
                try {
                  await LocalDbService().registerUser(
                    fullName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: 'password123',
                    phoneNumber:
                        '+255700000${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                    location: 'Head Office',
                    role: switch (role) {
                      'Operations' => 'support_officer',
                      'Finance' => 'finance_manager',
                      _ => 'support_officer',
                    },
                  );
                  await _loadStaff();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to add staff: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Staff Management',
              subtitle:
                  'Create support, operations, and finance staff accounts.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddStaff,
              child: const Text('Add Staff Member'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _staff.isEmpty
                      ? const Center(child: Text('No staff accounts found.'))
                      : ListView.separated(
                          itemCount: _staff.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final staff = _staff[index];
                            final roleLabel =
                                (staff['role'] as String?) ?? 'Staff';
                            return Card(
                              child: ListTile(
                                title: Text(
                                    staff['full_name']?.toString() ?? 'Staff'),
                                subtitle: Text(
                                  '$roleLabel • ${staff['email']?.toString() ?? 'No email'}',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealerAuthorizationScreen extends StatefulWidget {
  const DealerAuthorizationScreen({super.key});

  @override
  State<DealerAuthorizationScreen> createState() =>
      _DealerAuthorizationScreenState();
}

class _DealerAuthorizationScreenState extends State<DealerAuthorizationScreen> {
  final List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final applications =
          await DatabaseService.getDealerAuthorizationApplications();
      if (!mounted) return;
      setState(() {
        _applications
          ..clear()
          ..addAll(applications.map((application) {
            final rawStatus =
                (application['status'] ?? 'pending').toString().toLowerCase();
            final displayStatus = rawStatus == 'approved'
                ? 'Approved'
                : rawStatus == 'rejected'
                    ? 'Rejected'
                    : 'Pending';

            return {
              ...application,
              'business': (application['business_name'] ?? 'Unnamed business')
                  .toString(),
              'license': (application['license_number'] ?? 'N/A').toString(),
              'email': (application['business_email'] ?? 'N/A').toString(),
              'status': displayStatus,
            };
          }));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dealer applications: $e')),
      );
    }
  }

  Future<void> _updateStatus(int index, String status) async {
    final application = _applications[index];
    final applicationId = application['id']?.toString();
    if (applicationId == null || applicationId.isEmpty) return;

    final currentUser = await AuthService.getCurrentUser();
    final adminUserId = currentUser?['id']?.toString() ?? 'admin';

    try {
      await DatabaseService.updateDealerAuthorizationStatus(
        applicationId: applicationId,
        status: status.toLowerCase(),
        adminUserId: adminUserId,
      );
      await _loadApplications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update approval: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Approvals'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(232, 245, 233, 1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromRGBO(76, 175, 80, 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Dealer approval is required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dealers cannot publish vehicles until the admin approves their application.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: _SectionHeader(
                    title: 'Dealer approval queue',
                    subtitle:
                        'Approve or reject dealers to control who can list cars.',
                  ),
                ),
                IconButton(
                  onPressed: _loadApplications,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh approvals',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _applications.isEmpty
                      ? const Center(
                          child: Text('No dealer authorization requests yet.'),
                        )
                      : GridView.builder(
                          itemCount: _applications.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width >= 900
                                    ? 2
                                    : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.15,
                          ),
                          itemBuilder: (context, index) {
                            final application = _applications[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      application['business'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('License: ${application['license']}'),
                                    Text('Email: ${application['email']}'),
                                    if ((application['business_notes'] ?? '')
                                        .toString()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Notes: ${application['business_notes']}',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Chip(
                                      backgroundColor: application['status'] ==
                                              'Approved'
                                          ? const Color.fromRGBO(
                                              76, 175, 80, 0.16)
                                          : application['status'] == 'Rejected'
                                              ? const Color.fromRGBO(
                                                  244, 67, 54, 0.16)
                                              : const Color.fromRGBO(
                                                  255, 152, 0, 0.16),
                                      label:
                                          Text(application['status'] as String),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: application['status'] ==
                                                    'Approved'
                                                ? null
                                                : () => _updateStatus(
                                                    index, 'Approved'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.successColor,
                                            ),
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: application['status'] ==
                                                    'Rejected'
                                                ? null
                                                : () => _updateStatus(
                                                    index, 'Rejected'),
                                            child: const Text('Reject'),
                                          ),
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
          ],
        ),
      ),
    );
  }
}

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  late final Future<Map<String, dynamic>> _transactionData;

  @override
  void initState() {
    super.initState();
    _transactionData = _loadTransactionData();
  }

  Future<Map<String, dynamic>> _loadTransactionData() async {
    final bookings = await LocalDbService().getAllBookings();
    final wallets = await LocalDbService().getWallets();

    final transactions = bookings.map((booking) {
      final amount = _toDouble(booking['total_price']);
      final listingType = (booking['car_title']?.toString().isNotEmpty ?? false)
          ? 'rental'
          : 'purchase';
      final commission =
          listingType == 'purchase' ? amount * 0.08 : amount * 0.05;
      final dealerAmount = amount - commission;

      return {
        'id': booking['id'],
        'listingType': listingType,
        'customerId': booking['user_id'],
        'dealerId': booking['dealer_id'],
        'status': booking['status'] ?? 'pending',
        'amount': amount,
        'commission': commission,
        'dealerAmount': dealerAmount,
        'createdAt': booking['created_at'],
        'startDate': booking['start_date'],
        'endDate': booking['end_date'],
        'paymentProvider': booking['payment_provider'],
        'customerPhone': booking['customer_phone'],
        'paymentNote': booking['payment_note'],
      };
    }).toList();

    return {
      'transactions': transactions,
      'wallets': wallets,
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _transactionData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load transactions: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          final transactions = List<Map<String, dynamic>>.from(
            data['transactions'] as List<dynamic>,
          );
          final wallets = Map<String, dynamic>.from(
            data['wallets'] as Map<String, dynamic>,
          );
          final adminWallet = wallets['admin'] ?? {'balance': 0.0};
          final adminBalance = _toDouble(adminWallet['balance']);
          final totalAmount = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['amount']),
          );
          final totalCommission = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['commission']),
          );
          final totalDealerAmount = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['dealerAmount']),
          );
          final rentalCount = transactions
              .where((item) => item['listingType'] == 'rental')
              .length;
          final purchaseCount = transactions
              .where((item) => item['listingType'] == 'purchase')
              .length;
          final completedCount = transactions
              .where((item) =>
                  item['status']?.toString().toLowerCase() == 'completed')
              .length;
          final pendingCount = transactions.length - completedCount;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Financial Activity',
                  subtitle:
                      'Track revenue, commissions, dealer payouts and payment status.',
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      title: 'Admin Balance',
                      value: 'TZS ${adminBalance.toStringAsFixed(0)}',
                      color: AppTheme.primaryColor,
                    ),
                    _StatCard(
                      title: 'Total Revenue',
                      value: 'TZS ${totalAmount.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Admin Commission',
                      value: 'TZS ${totalCommission.toStringAsFixed(0)}',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Dealer Payouts',
                      value: 'TZS ${totalDealerAmount.toStringAsFixed(0)}',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Rentals',
                        value: rentalCount.toString(),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Purchases',
                        value: purchaseCount.toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Completed',
                        value: completedCount.toString(),
                        color: AppTheme.successColor,
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
                Expanded(
                  child: ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final amount = _toDouble(item['amount']);
                      final commission = _toDouble(item['commission']);
                      final dealerAmount = _toDouble(item['dealerAmount']);
                      final status = (item['status']?.toString() ?? 'pending')
                          .toLowerCase();
                      final statusColor = status.contains('complete') ||
                              status.contains('success')
                          ? AppTheme.successColor
                          : status.contains('pending')
                              ? Colors.orange
                              : Colors.redAccent;
                      return Container(
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['id']?.toString() ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(28),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          item['status']?.toString() ??
                                              'Pending',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item['listingType']?.toString().toUpperCase() ?? 'N/A'} • Customer ${item['customerId'] ?? 'N/A'} → Dealer ${item['dealerId'] ?? 'N/A'}',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Provider: ${item['paymentProvider'] ?? 'N/A'} • Phone: ${item['customerPhone'] ?? 'N/A'}',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'TZS ${amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Comm: TZS ${commission.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                Text(
                                  'Dealer: TZS ${dealerAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminFinanceOverviewScreen extends StatefulWidget {
  const AdminFinanceOverviewScreen({super.key});

  @override
  State<AdminFinanceOverviewScreen> createState() =>
      _AdminFinanceOverviewScreenState();
}

class _AdminFinanceOverviewScreenState
    extends State<AdminFinanceOverviewScreen> {
  late final Future<Map<String, dynamic>> _financeData;

  @override
  void initState() {
    super.initState();
    _financeData = _loadFinanceData();
  }

  Future<Map<String, dynamic>> _loadFinanceData() async {
    final paymentBase =
        AppConstants.getPaymentApiBase(Theme.of(context).platform);
    final txUrl =
        Uri.parse('$paymentBase${AppConstants.paymentTransactionsEndpoint}');
    final walletUrl =
        Uri.parse('$paymentBase${AppConstants.paymentWalletsEndpoint}');

    final txResp = await http.get(txUrl).timeout(const Duration(seconds: 10));
    final walletResp =
        await http.get(walletUrl).timeout(const Duration(seconds: 10));

    if (txResp.statusCode != 200) {
      throw Exception('Failed to load finance data (${txResp.statusCode})');
    }
    if (walletResp.statusCode != 200) {
      throw Exception('Failed to load wallet data (${walletResp.statusCode})');
    }

    final txBody = jsonDecode(txResp.body);
    final walletBody = jsonDecode(walletResp.body);

    final transactions = (txBody is List
            ? txBody
            : txBody is Map<String, dynamic> && txBody['transactions'] != null
                ? txBody['transactions'] as List<dynamic>
                : <dynamic>[])
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();

    final wallets =
        Map<String, dynamic>.from(walletBody as Map<String, dynamic>);

    return {
      'transactions': transactions,
      'wallets': wallets,
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Overview'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _financeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load finance data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          final transactions = List<Map<String, dynamic>>.from(
            data['transactions'] as List<dynamic>,
          );
          final wallets = Map<String, dynamic>.from(
            data['wallets'] as Map<String, dynamic>,
          );
          final adminWallet = wallets['admin'] ?? {'balance': 0.0};
          final adminBalance = _toDouble(adminWallet['balance']);
          final totalCommission = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['commission']),
          );
          final totalRevenue = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['amount']),
          );
          final totalDealerPayout = transactions.fold<double>(
            0.0,
            (sum, item) => sum + _toDouble(item['dealerAmount']),
          );
          final completed = transactions
              .where((item) =>
                  item['status']?.toString().toLowerCase() == 'completed' ||
                  item['status']?.toString().toLowerCase() == 'success')
              .length;
          final pending = transactions.length - completed;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Finance Summary',
                  subtitle:
                      'Review revenue, admin earnings and dealer payouts.',
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      title: 'Admin Balance',
                      value: 'TZS ${adminBalance.toStringAsFixed(0)}',
                      color: AppTheme.primaryColor,
                    ),
                    _StatCard(
                      title: 'Total Revenue',
                      value: 'TZS ${totalRevenue.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Admin Commission',
                      value: 'TZS ${totalCommission.toStringAsFixed(0)}',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Dealer Payouts',
                      value: 'TZS ${totalDealerPayout.toStringAsFixed(0)}',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Completed',
                        value: completed.toString(),
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Pending',
                        value: pending.toString(),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Azam Pay flow description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Customer payments pass through Azam Pay. Rental payments send 5% commission to admin and purchase payments send 8% commission to admin. The remaining amount is credited to the dealer wallet.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(248, 250, 255, 1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color.fromRGBO(33, 150, 243, 0.16),
                          ),
                        ),
                        child: const Text(
                          'Commission rule: 5% for rentals and 8% for purchases. The rest is paid out to the dealer wallet.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminVehicleModerationScreen extends StatefulWidget {
  const AdminVehicleModerationScreen({super.key});

  @override
  State<AdminVehicleModerationScreen> createState() =>
      _AdminVehicleModerationScreenState();
}

class _AdminVehicleModerationScreenState
    extends State<AdminVehicleModerationScreen> {
  final List<Map<String, String>> _requests = [
    {
      'vehicle': 'Toyota Prado',
      'dealer': 'Golden Motors',
      'status': 'Pending',
      'submitted': '04 Jul 2026',
    },
    {
      'vehicle': 'BMW X5',
      'dealer': 'City Cars',
      'status': 'Pending',
      'submitted': '03 Jul 2026',
    },
  ];

  void _updateStatus(int index, String status) {
    setState(() {
      _requests[index]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Moderation'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const _AdminDrawer(),
      backgroundColor: AppTheme.lightScaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: _requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = _requests[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['vehicle']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Dealer: ${request['dealer']}'),
                    Text('Submitted: ${request['submitted']}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          backgroundColor: request['status'] == 'Pending'
                              ? const Color.fromRGBO(255, 152, 0, 0.16)
                              : const Color.fromRGBO(76, 175, 80, 0.16),
                          label: Text(request['status']!),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: request['status'] == 'Approved'
                              ? null
                              : () => _updateStatus(index, 'Approved'),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: request['status'] == 'Rejected'
                              ? null
                              : () => _updateStatus(index, 'Rejected'),
                          child: const Text('Reject'),
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

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 30),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final softTint = Color.fromARGB(
      (0.16 * 255).round(),
      color.r.toInt(),
      color.g.toInt(),
      color.b.toInt(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 248, 241, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(76, 175, 80, 0.25)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: softTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Live app data',
            style: TextStyle(color: color.withAlpha(204), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _StatCard({
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.black;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(158, 158, 158, 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: displayColor,
              )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

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

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
