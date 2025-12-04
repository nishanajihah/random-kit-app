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
    return Stack(
      children: [
        // Main Content
        SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top -
                  60, //Ad Banner space
            ),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        ),

        // Fixed ad banner at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: adBackgroundColor ?? Theme.of(context).primaryColor,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).padding.bottom, // Safe area padding
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: AdBannerWidget(adUnitIdKey: adUnitIdKey),
            ),
          ),
        ),
      ],
    );
  }
}
