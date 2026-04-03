// lib/widgets/base_feature_screen.dart

import 'package:flutter/material.dart';
import 'ad_banner_widget.dart';

/// A reusable layout wrapper for all feature screens
/// Handles the consistent structure: optional header + scrollable content + fixed ad banner

class BaseFeatureScreen extends StatelessWidget {
  final String adUnitIdKey;
  final List<Widget> children;
  final EdgeInsets padding;
  final Color? adBackgroundColor; // Optional background color for ad banner
  final bool showHeader; // Whether to show the glass header
  final String? headerTitle; // Title for the header
  final String? headerSubtitle; // Subtitle for the header
  final VoidCallback? onBackPressed; // Back button callback

  const BaseFeatureScreen({
    super.key,
    required this.adUnitIdKey,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.adBackgroundColor, // Default to theme color if null
    this.showHeader = false,
    this.headerTitle,
    this.headerSubtitle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          // Optional Glass Header
          if (showHeader) _buildGlassHeader(context),

          // Main Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                ),
              ),
            ),
          ),

          // Enhanced ad banner at bottom - neumorphic design
          _buildEnhancedAdBanner(context),
        ],
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context) {
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
          if (onBackPressed != null)
            GestureDetector(
              onTap: onBackPressed,
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
          if (onBackPressed != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (headerTitle != null)
                  Text(
                    headerTitle!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                if (headerSubtitle != null)
                  Text(
                    headerSubtitle!,
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
          // Main dark shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          // Secondary lighter shadow for pop effect
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
          AdBannerWidget(adUnitIdKey: adUnitIdKey),
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
