import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';

import 'utils/app_logger.dart';
import 'home_screen.dart';
import 'screens/network_gate_screen.dart';
import 'services/device_capability_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the app draw edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Determine which environment file to load
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // Initialize logger
  AppLogger.initialize(environment);
  AppLogger.info('🚀 App starting...');
  AppLogger.info('🔧 Environment: $environment');

  // Load secrets
  await dotenv.load(fileName: '.env.$environment');
  AppLogger.debug('📱 Banner ID: ${dotenv.env['ADMOB_BANNER_ID']}');

  // Launch UI immediately to attach window to engine
  runApp(const RandomKitApp());

  // Non-blocking initialization of AdMob and background services
  unawaited(
    MobileAds.instance.initialize().then((_) {
      AppLogger.info('✅ AdMob initialized');
    }),
  );

  unawaited(DeviceCapabilityService().scanCapabilities());
}

class RandomKitApp extends StatelessWidget {
  const RandomKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Kit+ Idle',
      theme: ThemeData(
        primaryColor: const Color(0xFFf4750a),
        useMaterial3: true,
      ),
      home: const NetworkGateScreen(child: HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
