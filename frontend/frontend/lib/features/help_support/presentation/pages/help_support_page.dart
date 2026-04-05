import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _msgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _sending = false;
  String? _feedbackCategory = 'Bug Report';

  static const _green = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _msgCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _sending = false);
      _msgCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: _green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, color: _green, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Message Sent!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Our support team will get back to you within 24–48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ]),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(context),
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: _green,
          labelColor: _green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline, size: 18), text: 'FAQ'),
            Tab(icon: Icon(Icons.headset_mic_outlined, size: 18), text: 'Contact'),
            Tab(icon: Icon(Icons.info_outline, size: 18), text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildFAQ(surfaceColor, isDark),
          _buildContact(surfaceColor, isDark),
          _buildAbout(surfaceColor, isDark),
        ],
      ),
    );
  }

  // ── FAQ ──────────────────────────────────────────────────────────────────────
  Widget _buildFAQ(Color surface, bool isDark) {
    const faqs = [
      ('Getting Started', [
        ('How do I create an account?', 'Tap "Create Account" on the welcome screen. Fill in your name, email, and password. You will receive an email verification link to activate your account.'),
        ('What types of users can register?', 'Smart Harvest supports two user types: Farmers (who list crops and manage produce) and Buyers (who browse listings and place orders).'),
        ('Is Smart Harvest free to use?', 'Yes! Smart Harvest is completely free for all users. We aim to empower Sri Lankan farmers and buyers.'),
      ]),
      ('Crops & Listings', [
        ('How do I add my crops?', 'Go to My Crops from the menu, then tap the + button. Enter crop name, quantity, harvest date, price, and location. Your listing will be visible to buyers instantly.'),
        ('Can I update crop prices?', 'Yes. Open your crop listing, tap Edit, update the price or quantity, and save. Changes are reflected immediately in the marketplace.'),
        ('How long do listings stay active?', 'Listings remain active until you manually remove them or the quantity reaches zero after orders are fulfilled.'),
      ]),
      ('Marketplace & Orders', [
        ('How do I place an order?', 'Browse the Marketplace, find a crop you want, tap on it to see details, then tap "Place Order." You can specify quantity and preferred delivery method.'),
        ('How do I track my orders?', 'Go to My Orders in your account. You will see all active and past orders with their current status.'),
        ('What if a seller doesn\'t respond?', 'You can send a message directly to the seller via the Chat feature. If issues persist, contact our support team.'),
      ]),
      ('Account & Security', [
        ('How do I reset my password?', 'On the Login screen, tap "Forgot Password," enter your email address, and we will send a reset link to your inbox. Check spam if not received.'),
        ('How do I update my profile?', 'Go to the Profile tab, tap the edit (pencil) icon, update your details, and save.'),
        ('Is my data secure?', 'Yes. Smart Harvest uses Firebase Authentication and Firestore with industry-standard encryption. Your data is stored securely and never shared.'),
      ]),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _searchHint(),
        const SizedBox(height: 8),
        for (final section in faqs) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(section.$1,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                    color: AppColors.primaryGreen)),
          ),
          ...section.$2.map((q) => _FAQTile(question: q.$1, answer: q.$2)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _searchHint() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
    ),
    child: Row(children: const [
      Icon(Icons.tips_and_updates_outlined, color: AppColors.primaryGreen, size: 20),
      SizedBox(width: 10),
      Expanded(child: Text('Can\'t find your answer? Use the Contact tab to reach our team.',
          style: TextStyle(fontSize: 13, color: AppColors.primaryGreen))),
    ]),
  );

  // ── Contact ──────────────────────────────────────────────────────────────────
  Widget _buildContact(Color surface, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Quick contact cards
        Row(children: [
          Expanded(child: _quickCard(Icons.email_outlined, 'Email Us',
              'support@smartharvest.lk', () => _launchUrl('mailto:support@smartharvest.lk'))),
          const SizedBox(width: 12),
          Expanded(child: _quickCard(Icons.phone_outlined, 'Call Us',
              '+94 11 234 5678', () => _launchUrl('tel:+94112345678'))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _quickCard(Icons.chat_outlined, 'WhatsApp',
              'Chat with us', () => _launchUrl('https://wa.me/94112345678'))),
          const SizedBox(width: 12),
          Expanded(child: _quickCard(Icons.schedule_outlined, 'Hours',
              'Mon–Fri, 8am–6pm', null)),
        ]),
        const SizedBox(height: 24),

        // Send message form
        const Text('Send Us a Message',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text('We typically respond within 24 hours.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 16),

        // Category picker
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['Bug Report', 'Feature Request', 'Account Help', 'Other']
              .map((c) => GestureDetector(
                onTap: () => setState(() => _feedbackCategory = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _feedbackCategory == c
                        ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(c, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: _feedbackCategory == c ? Colors.white : AppColors.primaryGreen)),
                ),
              )).toList(),
        ),
        const SizedBox(height: 16),

        _formField(_emailCtrl, 'Your Email *', Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _formField(_subjectCtrl, 'Subject', Icons.subject_outlined),
        const SizedBox(height: 12),
        TextField(
          controller: _msgCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Your Message *',
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 64),
              child: Icon(Icons.message_outlined),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: _sending ? null : _sendMessage,
            icon: _sending
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: Text(_sending ? 'Sending...' : 'Send Message',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _quickCard(IconData icon, String title, String sub, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.primaryGreen, size: 22),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
      );

  Widget _formField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
        ),
      );

  // ── About ──────────────────────────────────────────────────────────────────
  Widget _buildAbout(Color surface, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Logo & name
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, Color(0xFF6B8E23)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.eco, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Smart Harvest', style: TextStyle(color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Empowering Sri Lankan Agriculture',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        _aboutSection('Our Mission', Icons.flag_outlined,
            'Smart Harvest connects Sri Lankan farmers and buyers through a modern digital marketplace, enabling fair pricing, reducing food waste, and supporting agricultural sustainability across the island.'),

        _aboutSection('What We Offer', Icons.star_outline, null,
            bullets: ['Real-time crop marketplace', 'Live market price tracking',
              'AI-powered price forecasting', 'Weather updates for farmers',
              'Government agriculture dashboard', 'Secure messaging between parties']),

        _aboutSection('Contact & Support', Icons.support_agent_outlined, null,
            bullets: ['📧 support@smartharvest.lk', '📞 +94 11 234 5678',
              '🌐 www.smartharvest.lk', '⏰ Mon–Fri, 8am–6pm']),

        _aboutSection('Legal', Icons.gavel_outlined, null, links: [
          ('Privacy Policy', 'https://smartharvest.lk/privacy'),
          ('Terms of Service', 'https://smartharvest.lk/terms'),
          ('Open Source Licenses', 'https://smartharvest.lk/licenses'),
        ]),

        const SizedBox(height: 24),
        const Text('Made with ❤️ in Sri Lanka',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _aboutSection(String title, IconData icon, String? body,
      {List<String>? bullets, List<(String, String)>? links}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          if (body != null)
            Text(body, style: const TextStyle(fontSize: 13, height: 1.6)),
          if (bullets != null)
            ...bullets.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                Expanded(child: Text(b, style: const TextStyle(fontSize: 13))),
              ]),
            )),
          if (links != null)
            ...links.map((l) => ListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, size: 16, color: AppColors.primaryGreen),
              title: Text(l.$1, style: const TextStyle(
                  color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w500)),
              onTap: () => _launchUrl(l.$2),
            )),
        ]),
      );
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _open
                ? AppColors.primaryGreen.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15)),
      ),
      child: Column(children: [
        ListTile(
          title: Text(widget.question,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14,
                  color: _open ? AppColors.primaryGreen : null)),
          trailing: AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down,
                color: _open ? AppColors.primaryGreen : Colors.grey),
          ),
          onTap: () => setState(() => _open = !_open),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(widget.answer,
                style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.grey)),
          ),
      ]),
    );
  }
}
