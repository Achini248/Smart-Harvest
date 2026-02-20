import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routes/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Smart Harvest User');
  final _phoneCtrl = TextEditingController(text: '+94771234567');
  final _emailCtrl = TextEditingController(text: 'user@smartharvest.lk');

  String _selectedRole = 'Farmer';
  final List<String> _roles = ['Farmer', 'Buyer', 'Agriculture Officer'];

  bool _notificationsEnabled = true;
  bool _weatherAlertsEnabled = true;
  bool _priceAlertsEnabled = false;

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthUpdateProfileEvent(
            displayName: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            role: _selectedRole,
          ),
        );
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.bodyText
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (_) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyText
          .copyWith(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text('Profile Settings', style: AppTextStyles.heading2),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(
              'Save',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated successfully!'),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar section ───────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primaryGreen, width: 2),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 52,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      _nameCtrl.text,
                      style: AppTextStyles.heading2.copyWith(fontSize: 18),
                    ),
                  ),
                  Center(
                    child: Text(
                      _selectedRole,
                      style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Personal info card ────────────────────────────────
                  _SectionCard(
                    title: 'Personal Information',
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: !isLoading,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Name is required'
                            : null,
                        decoration:
                            _inputDecoration(label: 'Full Name', icon: Icons.person_outline),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: false, // email is not editable
                        decoration: _inputDecoration(
                            label: 'Email (read-only)',
                            icon: Icons.email_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneCtrl,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Phone is required'
                            : null,
                        decoration: _inputDecoration(
                            label: 'Phone Number',
                            icon: Icons.phone_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Role card ─────────────────────────────────────────
                  _SectionCard(
                    title: 'My Role',
                    children: [
                      Row(
                        children: _roles.map((role) {
                          final selected = _selectedRole == role;
                          return Expanded(
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () =>
                                      setState(() => _selectedRole = role),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryGreen
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryGreen
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  role == 'Agriculture Officer'
                                      ? 'Officer'
                                      : role,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Language card ──────────────────────────────────────
                  _SectionCard(
                    title: 'Language',
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: _inputDecoration(
                            label: 'App Language',
                            icon: Icons.language_outlined),
                        items: _languages
                            .map((lang) => DropdownMenuItem(
                                value: lang, child: Text(lang)))
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (v) =>
                                setState(() => _selectedLanguage = v!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Notifications card ────────────────────────────────
                  _SectionCard(
                    title: 'Notification Preferences',
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        value: _notificationsEnabled,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                      ),
                      const Divider(height: 1),
                      _ToggleRow(
                        icon: Icons.cloud_outlined,
                        label: 'Weather Alerts',
                        value: _weatherAlertsEnabled,
                        onChanged: (v) =>
                            setState(() => _weatherAlertsEnabled = v),
                      ),
                      const Divider(height: 1),
                      _ToggleRow(
                        icon: Icons.price_change_outlined,
                        label: 'Price Alerts',
                        value: _priceAlertsEnabled,
                        onChanged: (v) =>
                            setState(() => _priceAlertsEnabled = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Save button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _onSave,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Save Changes',
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Logout button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout,
                          color: AppColors.error, size: 20),
                      label: Text(
                        'Logout',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: isLoading ? null : _onLogout,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Reusable section card ───────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ─── Notification toggle row ─────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyText),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}
