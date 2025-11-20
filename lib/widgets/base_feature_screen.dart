// lib/widgets/base_feature_screen.dart

import 'package:flutter/material.dart';
import 'ad_banner_widget.dart';

/// A reusable layout wrapper for all feature screens
/// Handles the consistent structure: scrollable content + fixed ad banner

class BaseFeatureScreen extends StatelessWidget {
  final String adUnitIdKey;
  final List<Widget> children;
  final EdgeInsets padding;

  const BaseFeatureScreen({
    super.key,
    required this.adUnitIdKey,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
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
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: AdBannerWidget(adUnitIdKey: adUnitIdKey),
            ),
          ),
        ),
      ],
    );
  }
}
