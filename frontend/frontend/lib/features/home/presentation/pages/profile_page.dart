import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../config/routes/route_names.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return _AuthProfile(uid: state.uid);
        return const _GuestProfile();
      },
    );
  }
}

// ── Guest ──────────────────────────────────────────────────────────────────────
class _GuestProfile extends StatelessWidget {
  const _GuestProfile();
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline,
                      size: 52, color: AppColors.primaryGreen)),
              const SizedBox(height: 24),
              const Text("You're browsing as a guest",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text(
                  'Sign in to access your profile, track crops, manage orders, and more.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 32),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.login),
                      child: const Text('Sign In',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)))),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.signup),
                      child: const Text('Create Account',
                          style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)))),
            ]),
          ),
        ),
      );
}

// ── Authenticated Profile ──────────────────────────────────────────────────────
class _AuthProfile extends StatefulWidget {
  final String uid;
  const _AuthProfile({required this.uid});
  @override
  State<_AuthProfile> createState() => _AuthProfileState();
}

class _AuthProfileState extends State<_AuthProfile> {
  Map<String, dynamic> _data = {};
  bool _loading = true, _editing = false, _uploadingPhoto = false;
  bool _notif = true;
  String _preferredName = '';
  String? _photoUrl;

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locCtrl   = TextEditingController();
  final _farmCtrl  = TextEditingController();
  StreamSubscription<DocumentSnapshot>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final d = snap.data() ?? {};
      setState(() {
        _data = d;
        _loading = false;
        _nameCtrl.text  = d['name'] ?? '';
        _phoneCtrl.text = d['phoneNo'] ?? '';
        _locCtrl.text   = d['location'] ?? '';
        _farmCtrl.text  = d['farmSize']?.toString() ?? '';
        _photoUrl       = d['photoUrl'] as String?;
      });
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notif        = p.getBool('notif_${widget.uid}') ?? true;
        _preferredName = p.getString('preferred_name_${widget.uid}') ?? '';
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name cannot be empty.', true);
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
        'name': name,
        'phoneNo': _phoneCtrl.text.trim(),
        'location': _locCtrl.text.trim(),
        'farmSize': double.tryParse(_farmCtrl.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Keep Firebase Auth display name in sync too.
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      if (mounted) {
        setState(() => _editing = false);
        _snack('Profile saved!', false);
      }
    } catch (e) {
      // Guard against calling ScaffoldMessenger on a disposed widget.
      if (mounted) _snack('Save failed: $e', true);
    }
  }

  // ── Image picker & upload ──────────────────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    // On web, only gallery is supported (camera source requires native platform).
    ImageSource? source;
    if (kIsWeb) {
      source = ImageSource.gallery;
    } else {
      source = await _showImageSourceDialog();
      if (source == null) return;
    }

    final picked = await picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 600);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final ref = FirebaseStorage.instance
          .ref('profile_photos/\${widget.uid}.jpg');
      // Use putData (bytes) — works on Web, iOS, and Android (no dart:io).
      final bytes = await picked.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'photoUrl': url});
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);

      if (mounted) {
        setState(() {
          _photoUrl = url;
          _uploadingPhoto = false;
        });
        _snack('Profile photo updated!', false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        _snack('Failed to upload photo. Check storage permissions.', true);
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Choose Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_camera_outlined,
                      color: AppColors.primaryGreen)),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Colors.blue)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ]),
        ),
      ),
    );
  }

  void _snack(String msg, bool err) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: err ? AppColors.error : AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  @override
  void dispose() {
    _sub?.cancel();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locCtrl.dispose();
    _farmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    final role = (_data['role'] as String? ?? 'farmer').toLowerCase();
    final isFarmer = role == 'farmer';
    final displayName = _preferredName.isNotEmpty
        ? _preferredName
        : (_data['name'] as String? ?? 'User');
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // ── App bar with avatar ──
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
              onPressed: () => setState(() => _editing = !_editing),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const SizedBox(height: 60),
                // Avatar with upload button
                Stack(children: [
                  _uploadingPhoto
                      ? Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white.withOpacity(0.2)),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3)))
                      : CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: _photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: _photoUrl == null
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white))
                              : null,
                        ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            size: 15, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(isFarmer ? '🌾 Farmer' : '🛒 Buyer',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ]),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Edit form ──
              if (_editing) ...[
                _title('Edit Profile'),
                _card([
                  _field('Full Name', _nameCtrl, Icons.person_outline),
                  const SizedBox(height: 12),
                  _field('Phone Number', _phoneCtrl, Icons.phone_outlined,
                      type: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field('Location / District', _locCtrl,
                      Icons.location_on_outlined),
                  if (isFarmer) ...[
                    const SizedBox(height: 12),
                    _field('Farm Size (acres)', _farmCtrl,
                        Icons.landscape_outlined,
                        type: TextInputType.number),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primaryGreen),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: () =>
                                setState(() => _editing = false),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.primaryGreen)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: _save,
                            child: const Text('Save Changes',
                                style: TextStyle(color: Colors.white)))),
                  ]),
                ]),
              ] else ...[
                // ── Personal info ──
                _title('Personal Information'),
                _card([
                  _row(Icons.person_outline, 'Name', displayName),
                  _div(),
                  _row(Icons.email_outlined, 'Email',
                      email.isNotEmpty ? email : 'Not set'),
                  _div(),
                  _row(Icons.phone_outlined, 'Phone',
                      (_data['phoneNo'] as String?)?.isNotEmpty == true
                          ? _data['phoneNo'] : 'Not set'),
                  _div(),
                  _row(Icons.location_on_outlined, 'Location',
                      (_data['location'] as String?)?.isNotEmpty == true
                          ? _data['location'] : 'Not set'),
                  _div(),
                  _row(Icons.badge_outlined, 'Preferred Name',
                      _preferredName.isNotEmpty ? _preferredName : 'Not set',
                      action: TextButton(
                        onPressed: () async {
                          final ctrl = TextEditingController(
                              text: _preferredName);
                          final r = await showDialog<String>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Preferred Name'),
                                content: TextField(
                                    controller: ctrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      hintText: 'How should we call you?',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    )),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, null),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen),
                                      onPressed: () => Navigator.pop(
                                          context, ctrl.text.trim()),
                                      child: const Text('Save',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                              ));
                          if (r != null) {
                            final p = await SharedPreferences.getInstance();
                            await p.setString(
                                'preferred_name_${widget.uid}', r);
                            if (mounted)
                              setState(() => _preferredName = r);
                          }
                        },
                        child: const Text('Change',
                            style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 12)),
                      )),
                ]),
                const SizedBox(height: 16),

                // ── Farmer / Buyer specific ──
                if (isFarmer) ...[
                  _title('Farm Information'),
                  _card([
                    _row(Icons.landscape_outlined, 'Farm Size',
                        _farmCtrl.text.isNotEmpty
                            ? '${_farmCtrl.text} acres' : 'Not set'),
                    _div(),
                    _row(Icons.agriculture_outlined, 'Farming Type',
                        (_data['farmingType'] as String?) ?? 'Not specified'),
                    _div(),
                    _row(Icons.eco_outlined, 'Crop Types',
                        (_data['cropTypes'] as String?) ?? 'Not specified'),
                  ]),
                  const SizedBox(height: 16),
                  _title('My Activity'),
                  Row(children: [
                    _actCard('My Crops', Icons.agriculture_outlined,
                        AppColors.primaryGreen,
                        () => Navigator.pushNamed(context, RouteNames.myCrops)),
                    const SizedBox(width: 10),
                    _actCard('Analytics', Icons.bar_chart_outlined,
                        Colors.blue,
                        () => Navigator.pushNamed(context, RouteNames.analytics)),
                    const SizedBox(width: 10),
                    _actCard('Messages', Icons.message_outlined, Colors.orange,
                        () => Navigator.pushNamed(
                            context, RouteNames.messagesList)),
                  ]),
                  const SizedBox(height: 16),
                ] else ...[
                  _title('Buyer Preferences'),
                  _card([
                    _row(Icons.local_shipping_outlined, 'Delivery Address',
                        (_data['deliveryAddress'] as String?) ?? 'Not set'),
                    _div(),
                    _row(Icons.payment_outlined, 'Payment',
                        (_data['paymentPref'] as String?) ??
                            'Cash on Delivery'),
                  ]),
                  const SizedBox(height: 16),
                  _title('Orders'),
                  _card([
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.primaryGreen),
                      title: const Text('My Orders'),
                      subtitle: const Text('View all your placed orders'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.myOrders),
                    )
                  ]),
                  const SizedBox(height: 16),
                ],

                _title('Saved Items'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline,
                        color: AppColors.primaryGreen),
                    title: const Text('Saved Crops & Listings'),
                    subtitle: const Text('Your bookmarked items'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _snack('Saved items — coming soon', false),
                  )
                ]),
                const SizedBox(height: 16),
              ],

              // ── Settings ──
              _title('Settings'),
              _card([
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined,
                      color: AppColors.primaryGreen),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Price alerts, order updates'),
                  value: _notif,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) async {
                    setState(() => _notif = v);
                    (await SharedPreferences.getInstance())
                        .setBool('notif_${widget.uid}', v);
                  },
                ),
                _div(),
                ListTile(
                  leading: const Icon(Icons.language_outlined,
                      color: AppColors.primaryGreen),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Select Language',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          for (final l in [
                            'English',
                            'සිංහල (Sinhala)',
                            'தமிழ் (Tamil)'
                          ])
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: Text(l),
                              trailing: l == 'English'
                                  ? const Icon(Icons.check,
                                      color: AppColors.primaryGreen)
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                _snack('$l — coming soon', false);
                              },
                            ),
                        ])),
                  ),
                ),
                _div(),
                // ── Dark mode — wired to ThemeCubit ──
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (ctx, mode) => SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined,
                        color: AppColors.primaryGreen),
                    title: const Text('Dark Mode'),
                    subtitle:
                        Text(mode == ThemeMode.dark ? 'On' : 'Off'),
                    value: mode == ThemeMode.dark,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (_) =>
                        ctx.read<ThemeCubit>().toggle(),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Account & Security — OTP removed ──
              _title('Account & Security'),
              _card([
                ListTile(
                  leading: const Icon(Icons.lock_outline,
                      color: AppColors.primaryGreen),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text('Change Password'),
                          content: const Text(
                              'A password reset email will be sent to your registered email address.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primaryGreen),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Send Email',
                                    style:
                                        TextStyle(color: Colors.white))),
                          ],
                        ));
                    if (ok == true) {
                      final em =
                          FirebaseAuth.instance.currentUser?.email ?? '';
                      if (em.isNotEmpty) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: em);
                        _snack('Reset email sent to $em', false);
                      }
                    }
                  },
                ),
                _div(),
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: AppColors.primaryGreen),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.helpSupport),
                ),
                _div(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete Account',
                      style: TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Row(children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Account',
                              style: TextStyle(color: Colors.red)),
                        ]),
                        content: const Text(
                            'This will permanently delete your account and all data. Cannot be undone.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _snack('Contact support to delete account',
                                    true);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.white))),
                        ],
                      )),
                ),
              ]),
              const SizedBox(height: 16),

              // ── Logout ──
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.red.shade200))),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text('Log out?'),
                          content: const Text(
                              'You will be signed out of your account.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                  context
                                      .read<AuthBloc>()
                                      .add(const LogoutEvent());
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      RouteNames.authSelection, (_) => false);
                                },
                                child: const Text('Log Out',
                                    style:
                                        TextStyle(color: Colors.white))),
                          ],
                        )),
                  )),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _title(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(t,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)));

  Widget _card(List<Widget> children) => Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8))),
      child: Column(children: children));

  Widget _div() => const Divider(height: 0, indent: 56);

  Widget _row(IconData icon, String label, dynamic value, {Widget? action}) =>
      ListTile(
          leading: Icon(icon, color: AppColors.primaryGreen, size: 20),
          title: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          subtitle: Text(value?.toString() ?? 'Not set',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: action,
          dense: true);

  Widget _field(String label, TextEditingController ctrl, IconData icon,
          {TextInputType type = TextInputType.text}) =>
      TextFormField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: AppColors.primaryGreen),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2))));

  Widget _actCard(
          String label, IconData icon, Color color, VoidCallback onTap) =>
      Expanded(
          child: GestureDetector(
              onTap: onTap,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2))),
                  child: Column(children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(height: 6),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color),
                        textAlign: TextAlign.center),
                  ]))));
}
