// lib/screens/settings_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/ad_banner_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _appVersion = 'Loading...';
  final bool _isLegalReady = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: ${e.toString()}')),
        );
      }
    }
  }

  void _showContactSupportDialog() {
    String selectedCategory = 'General Inquiry';
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal on click outside
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              backgroundColor: Colors.white,
              elevation: 16,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row with Title, Email & Close Button (X)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF4750A), Color(0xFFE65100)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF4750A).withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Support',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'nishanajihah.dev@gmail.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF4750A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dedicated Close Button (X)
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey[600],
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Scrollable Input Content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category Template',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Segmented template buttons
                              Row(
                                children: [
                                  _buildTemplateChip(
                                    label: 'General',
                                    icon: Icons.chat_bubble_outline_rounded,
                                    isSelected: selectedCategory == 'General Inquiry',
                                    onTap: () => setDialogState(
                                      () => selectedCategory = 'General Inquiry',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildTemplateChip(
                                    label: 'Bug Report',
                                    icon: Icons.bug_report_outlined,
                                    isSelected: selectedCategory == 'Bug Report',
                                    onTap: () => setDialogState(
                                      () => selectedCategory = 'Bug Report',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildTemplateChip(
                                    label: 'Idea',
                                    icon: Icons.lightbulb_outline_rounded,
                                    isSelected: selectedCategory == 'Feature Idea',
                                    onTap: () => setDialogState(
                                      () => selectedCategory = 'Feature Idea',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // User Email Box
                              const Text(
                                'Your Email',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'e.g. user@example.com',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFFF4750A),
                                  ),
                                  filled: true,
                                  fillColor: Colors.orange.shade50.withAlpha(120),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF4750A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Message Input Box (Expands for long text with scroll support)
                              const Text(
                                'Message',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: messageController,
                                minLines: 5,
                                maxLines: 10,
                                keyboardType: TextInputType.multiline,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your message';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Type your message or details here...',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.all(16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF4750A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons Row: CANCEL and SEND
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                final userEmail = emailController.text.trim();
                                final userMessage = messageController.text.trim();

                                final Uri emailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'nishanajihah.dev@gmail.com',
                                  queryParameters: {
                                    'subject':
                                        '[$selectedCategory] Random Kit+ Idle',
                                    'body':
                                        'From: $userEmail\nCategory: $selectedCategory\n\nMessage:\n$userMessage',
                                  },
                                );

                                Navigator.of(ctx).pop();

                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  if (!await launchUrl(
                                    emailUri,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    throw Exception('Could not open email app');
                                  }
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Email app unavailable. Please send directly to nishanajihah.dev@gmail.com',
                                      ),
                                      backgroundColor: Colors.orange.shade800,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'SEND',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4750A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFFF4750A).withAlpha(140),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTemplateChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF4750A) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFFF4750A) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Random Kit+ Idle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version: $_appVersion',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'A collection of random generators and decision-making tools to make your life easier.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Text(
              '© ${DateTime.now().year} Random Kit+ Idle',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'CLOSE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Glass morphism app bar
              _buildGlassAppBar(),

              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    const SizedBox(height: 8),

                    // Appearance Section
                    _buildSectionHeader('APPEARANCE'),
                    const SizedBox(height: 12),
                    _buildNeumorphicCard(
                      child: _buildListTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Coming soon',
                        gradient: const LinearGradient(
                          colors: [Colors.indigo, Colors.purple],
                        ),
                        trailing: Transform.scale(
                          scale: 0.9,
                          child: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Dark mode ${value ? "enabled" : "disabled"} (Coming soon!)',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            activeThumbColor: Colors.orange,
                            activeTrackColor: Colors.orange.shade200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Legal Section
                    _buildSectionHeader('LEGAL'),
                    const SizedBox(height: 12),
                    _buildNeumorphicCard(
                      child: Column(
                        children: [
                          _isLegalReady
                              ? _buildListTile(
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Privacy Policy',
                                  subtitle: 'How we handle your data',
                                  gradient: const LinearGradient(
                                    colors: [Colors.blue, Colors.cyan],
                                  ),
                                  onTap: () => _launchURL(
                                    'https://yourwebsite.com/privacy',
                                  ),
                                )
                              : _buildDisabledBlock(
                                  _buildListTile(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: 'Page building - coming soon',
                                    gradient: const LinearGradient(
                                      colors: [Colors.blue, Colors.cyan],
                                    ),
                                    onTap: null,
                                  ),
                                  'Privacy Page in building',
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 1, color: Colors.grey[200]),
                          ),
                          _isLegalReady
                              ? _buildListTile(
                                  icon: Icons.description_outlined,
                                  title: 'Terms & Conditions',
                                  subtitle: 'Terms of service',
                                  gradient: const LinearGradient(
                                    colors: [Colors.teal, Colors.green],
                                  ),
                                  onTap: () => _launchURL(
                                    'https://yourwebsite.com/terms',
                                  ),
                                )
                              : _buildDisabledBlock(
                                  _buildListTile(
                                    icon: Icons.description_outlined,
                                    title: 'Terms & Conditions',
                                    subtitle: 'Page building - coming soon',
                                    gradient: const LinearGradient(
                                      colors: [Colors.teal, Colors.green],
                                    ),
                                    onTap: null,
                                  ),
                                  'Terms Page in building',
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Support Section
                    _buildSectionHeader('SUPPORT & FEEDBACK'),
                    const SizedBox(height: 12),
                    _buildNeumorphicCard(
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.mail_outline,
                            title: 'Contact Support',
                            subtitle: 'Send us an email',
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            onTap: _showContactSupportDialog,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 1, color: Colors.grey[200]),
                          ),
                          _buildListTile(
                            icon: Icons.share_outlined,
                            title: 'Share App',
                            subtitle: 'Tell your friends',
                            gradient: const LinearGradient(
                              colors: [Colors.pink, Colors.red],
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Share functionality coming soon!',
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // About Section
                    _buildSectionHeader('ABOUT'),
                    const SizedBox(height: 12),
                    _buildNeumorphicCard(
                      child: _buildListTile(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        subtitle: _appVersion,
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                        ),
                        onTap: _showAboutDialog,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade100.withAlpha(77),
                                  Colors.orange.shade50.withAlpha(77),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Made with ❤️ by ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _launchURL(
                                    'https://linktree.com/nisha.najihah',
                                  ),
                                  child: const Text(
                                    'Nisha Najihah',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Random Kit+ Idle © ${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Banner Ad Widget
              _buildEnhancedAdBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withAlpha(230), Colors.white.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(128), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Customize your experience',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicCard({required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.orange.withAlpha(13),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing:
          trailing ??
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.orange[700],
            ),
          ),
      onTap: onTap,
    );
  }

  Widget _buildDisabledBlock(Widget child, String label) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(26),
                      Colors.grey.withAlpha(51),
                      Colors.white.withAlpha(26),
                    ],
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedAdBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const AdBannerWidget(adUnitIdKey: 'ADMOB_BANNER_ID_SETTING'),
          SizedBox(
            height: MediaQuery.of(context).viewPadding.bottom > 0
                ? MediaQuery.of(context).viewPadding.bottom
                : 4.0,
          ),
        ],
      ),
    );
  }
}
