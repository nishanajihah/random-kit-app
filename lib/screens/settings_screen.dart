// lib/screens/settings_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'nishanajihah.dev@gmail.com',
      query: 'subject=Random Kit+ Idle Feedback',
    );

    try {
      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No email app found. Please email: nishanajihah.dev@gmail.com',
            ),
          ),
        );
      }
    }
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
                                  'Terms & Conditions Page in building',
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Support Section
                    _buildSectionHeader('SUPPORT'),
                    const SizedBox(height: 12),
                    _buildNeumorphicCard(
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.email_outlined,
                            title: 'Send Feedback',
                            subtitle: 'Help us improve',
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            onTap: _sendEmail,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 1, color: Colors.grey[200]),
                          ),
                          _buildListTile(
                            icon: Icons.star_outline,
                            title: 'Rate App',
                            subtitle: 'Rate us on the store',
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Opening app store...'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
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
                                  ), // Change to your link
                                  child: Text(
                                    'Nisha Najihah',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      decorationColor: Colors.black87,
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
    return Container(
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
      child: child,
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
                alignment: Alignment.centerLeft, // Align box to the left
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                  ), // Add some margin from left edge
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
}
