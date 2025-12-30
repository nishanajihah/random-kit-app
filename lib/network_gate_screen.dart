// lib/network_gate_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'utils/app_logger.dart';

class NetworkGateScreen extends StatefulWidget {
  final Widget child;

  const NetworkGateScreen({super.key, required this.child});

  @override
  State<NetworkGateScreen> createState() => _NetworkGateScreenState();
}

class _NetworkGateScreenState extends State<NetworkGateScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasInternetAccess = true;
  bool _isChecking = true;
  Timer? _periodicCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _setupConnectivityListener();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }

  // Actually check if we can reach the internet
  Future<bool> _hasRealInternetAccess() async {
    try {
      // Try to reach Google's DNS (reliable and fast)
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // No internet access
      return false;
    } on TimeoutException catch (_) {
      // Timeout means no reliable connection
      return false;
    } catch (e) {
      AppLogger.error('Internet check error', e);
      return false;
    }
  }

  Future<void> _checkInitialConnection() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // First check if device has connectivity
      final results = await Connectivity().checkConnectivity();
      final hasConnectivity =
          results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (!hasConnectivity) {
        // Not even connected to WiFi/data
        if (mounted) {
          setState(() {
            _hasInternetAccess = false;
            _isChecking = false;
          });
          AppLogger.warning('⚠️ No connectivity - blocking app access');
        }
        return;
      }

      // Has connectivity, now check actual internet access
      final hasInternet = await _hasRealInternetAccess();

      if (mounted) {
        setState(() {
          _hasInternetAccess = hasInternet;
          _isChecking = false;
        });

        if (hasInternet) {
          AppLogger.info('✅ Real internet access verified - allowing app');
        } else {
          AppLogger.warning(
            '⚠️ Connected but no internet (captive portal?) - blocking app',
          );
        }
      }
    } catch (e) {
      AppLogger.error('Connection check error', e);
      if (mounted) {
        setState(() {
          _hasInternetAccess = false;
          _isChecking = false;
        });
      }
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final hasConnectivity =
          results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (!hasConnectivity) {
        // Lost connectivity
        if (mounted) {
          setState(() {
            _hasInternetAccess = false;
          });
          AppLogger.warning('📵 Connectivity lost - blocking app');
        }
      } else {
        // Gained connectivity - verify real internet
        AppLogger.info(
          '📶 Connectivity detected - verifying internet access...',
        );
        final hasInternet = await _hasRealInternetAccess();

        if (mounted) {
          setState(() {
            _hasInternetAccess = hasInternet;
          });

          if (hasInternet) {
            AppLogger.info('📶 Real internet verified - granting app access');
          } else {
            AppLogger.warning(
              '⚠️ Connected but no real internet - keeping app blocked',
            );
          }
        }
      }
    });
  }

  // Periodic check every 30 seconds (in case of captive portal changes)
  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 30), (
      _,
    ) async {
      if (!_hasInternetAccess && mounted) {
        // Only check if currently blocked
        final hasInternet = await _hasRealInternetAccess();
        if (mounted && hasInternet != _hasInternetAccess) {
          setState(() {
            _hasInternetAccess = hasInternet;
          });
          if (hasInternet) {
            AppLogger.info('✅ Periodic check: Internet restored');
          }
        }
      }
    });
  }

  Future<void> _manualRetry() async {
    setState(() {
      _isChecking = true;
    });
    await _checkInitialConnection();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking
    if (_isChecking) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Checking connection...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If online with real internet, show the app
    if (_hasInternetAccess) {
      return widget.child;
    }

    // If offline or no real internet, show network required screen
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive sizing
            final isSmallScreen = constraints.maxHeight < 600;
            final iconSize = isSmallScreen ? 80.0 : 100.0;
            final titleSize = isSmallScreen ? 20.0 : 24.0;
            final messageSize = isSmallScreen ? 14.0 : 16.0;

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // WiFi off icon with better contrast
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: iconSize * 0.55,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Title
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(77),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Better contrast box for bullet points
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoint(
                              '✓ Connect to WiFi or mobile data',
                              messageSize,
                              Colors.grey[800]!,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint(
                              '✓ Make sure internet is working',
                              messageSize,
                              Colors.grey[800]!,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint(
                              '✓ Disable VPN if enabled',
                              messageSize,
                              Colors.grey[800]!,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 28 : 36),

                      // Better contrast retry button
                      ElevatedButton.icon(
                        onPressed: _manualRetry,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'RETRY',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange[800],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Auto-check message with better contrast
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Auto-checking every 30 seconds',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, double fontSize, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
