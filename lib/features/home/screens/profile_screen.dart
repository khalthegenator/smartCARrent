import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/localization_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fullName;
  String? _email;
  String? _phone;
  String? _location;
  String? _dealerName;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
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

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _fullName = user?['full_name'] ?? user?['name'] ?? user?['fullName'];
      _email = user?['email'];
      _phone = user?['phone_number'] ?? user?['phone'] ?? user?['phoneNumber'];
      _location = user?['location'];
      _dealerName = user?['dealer_name'] ?? user?['dealerName'];
      _profileImage = user?['profile_image'] ?? user?['profileImage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().t('profile.title')),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => GoRouter.of(context).go('/notifications'),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                backgroundImage: _profileImage != null
                    ? NetworkImage(_profileImage!) as ImageProvider
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.person,
                        size: 48, color: AppTheme.primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(_fullName ?? 'User Name',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeService().textColor)),
            ),
            const SizedBox(height: 4),
            Center(
                child: Text(_email ?? 'user@example.com',
                    style:
                        TextStyle(color: ThemeService().secondaryTextColor))),
            if (_phone != null) ...[
              const SizedBox(height: 4),
              Center(
                  child: Text(_phone!,
                      style:
                          TextStyle(color: ThemeService().secondaryTextColor))),
            ],
            if (_dealerName != null) ...[
              const SizedBox(height: 4),
              Center(
                  child: Text('Dealership: $_dealerName',
                      style:
                          TextStyle(color: ThemeService().secondaryTextColor))),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle(LocalizationService().t('menu.account')),
            const SizedBox(height: 8),
            _buildListTile(
                context,
                Icons.edit,
                LocalizationService().t('drawer.edit_profile'),
                () => GoRouter.of(context).go('/edit-profile')),
            _buildListTile(
                context,
                Icons.file_upload,
                LocalizationService().t('drawer.documents'),
                () => GoRouter.of(context).go('/documents')),
            const SizedBox(height: 16),
            _buildSectionTitle(LocalizationService().t('menu.support')),
            const SizedBox(height: 8),
            _buildListTile(
                context,
                Icons.help_outline,
                LocalizationService().t('drawer.help_center'),
                () => GoRouter.of(context).go('/help')),
            _buildListTile(
                context,
                Icons.phone,
                LocalizationService().t('drawer.contact_support'),
                () => GoRouter.of(context).go('/contact')),
            const SizedBox(height: 16),
            _buildSectionTitle(LocalizationService().t('menu.settings')),
            const SizedBox(height: 8),
            _buildListTile(
                context,
                Icons.lock_outline,
                LocalizationService().t('drawer.change_password'),
                () => GoRouter.of(context).go('/change-password')),
            _buildListTile(context, Icons.translate, 'Language',
                () => GoRouter.of(context).go('/settings')),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor),
                onPressed: () async {
                  await AuthService.logout();
                  if (!mounted) return;
                  GoRouter.of(context).go('/login');
                },
                child: Text(LocalizationService().t('drawer.logout')),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: TextStyle(color: ThemeService().textColor)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
