import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/app_logger.dart';
import 'home_screen.dart';
// import 'dice_roller_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize AdMob
  await MobileAds.instance.initialize();
  AppLogger.info('✅ AdMob initialized');

  // Run the app
  runApp(const RandomKitApp());
}

class RandomKitApp extends StatelessWidget {
  const RandomKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Kit+ Idle',
      theme: ThemeData(primaryColor: Colors.blue[900], useMaterial3: true),
      home: const HomeScreen(),
      // debugShowCheckedModeBanner: false,
    );
  }
}
