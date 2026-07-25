// lib/screens/network_gate_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

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

  /// Verifies real internet connectivity by probing fast DNS endpoints:
  /// 1. Cloudflare DNS IP (1.1.1.1) - avoids local DNS delay
  /// 2. Google (google.com) - secondary check
  Future<bool> _hasRealInternetAccess() async {
    try {
      // Primary check: Direct IP lookup to Cloudflare DNS (1.1.1.1) to bypass DNS lookup overhead
      final resultIp = await InternetAddress.lookup('1.1.1.1').timeout(
        const Duration(seconds: 4),
      );
      if (resultIp.isNotEmpty && resultIp[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Fall through to domain check if IP ping fails
    }

    try {
      // Secondary check: Hostname lookup to google.com
      final resultDomain = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 4),
      );
      return resultDomain.isNotEmpty && resultDomain[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
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
      final results = await Connectivity().checkConnectivity();
      final hasConnectivity =
          results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);

      if (!hasConnectivity) {
        if (mounted) {
          setState(() {
            _hasInternetAccess = false;
            _isChecking = false;
          });
          AppLogger.warning('⚠️ No connectivity - blocking app access');
        }
        return;
      }

      final hasInternet = await _hasRealInternetAccess();

      if (mounted) {
        setState(() {
          _hasInternetAccess = hasInternet;
          _isChecking = false;
        });

        if (hasInternet) {
          AppLogger.info('✅ Real internet access verified - allowing app');
        } else {
          AppLogger.warning('⚠️ Connected but no internet - blocking app');
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
        if (mounted) {
          setState(() {
            _hasInternetAccess = false;
          });
          AppLogger.warning('断线 📵 Connectivity lost - blocking app');
        }
      } else {
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

  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 15), (
      _,
    ) async {
      if (!mounted) return;
      final hasInternet = await _hasRealInternetAccess();
      if (mounted && hasInternet != _hasInternetAccess) {
        setState(() {
          _hasInternetAccess = hasInternet;
        });
        if (hasInternet) {
          AppLogger.info('✅ Periodic check: Internet restored');
        } else {
          AppLogger.warning('⚠️ Periodic check: Internet lost - blocking app');
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
    if (_isChecking) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
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

    if (_hasInternetAccess) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Auto-checking connection...',
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
