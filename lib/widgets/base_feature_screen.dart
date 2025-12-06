// lib/widgets/base_feature_screen.dart

import 'package:flutter/material.dart';
import 'ad_banner_widget.dart';

/// A reusable layout wrapper for all feature screens
/// Handles the consistent structure: scrollable content + fixed ad banner

class BaseFeatureScreen extends StatelessWidget {
  final String adUnitIdKey;
  final List<Widget> children;
  final EdgeInsets padding;
  final Color? adBackgroundColor; // Optional background color for ad banner

  const BaseFeatureScreen({
    super.key,
    required this.adUnitIdKey,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.adBackgroundColor, // Default to theme color if null
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        // Fixed ad banner at bottom
        Container(
          width: double.infinity,
          color: adBackgroundColor ?? Theme.of(context).primaryColor,
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: MediaQuery.of(context).padding.bottom + 8.0,
          ),
          child: AdBannerWidget(adUnitIdKey: adUnitIdKey),
        ),
      ],
    );
  }
}
