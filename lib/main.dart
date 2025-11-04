import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/app_logger.dart';
import 'dice_roller_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Determine which environment file to load
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  // print('🔧 ENVIRONMENT: $environment');
  AppLogger.info('🔧 Environment: $environment');

  // Load secrets
  await dotenv.load(fileName: '.env.$environment');
  // print('📱 Banner ID: ${dotenv.env['ADMOB_BANNER_ID']}');
  AppLogger.debug('📱 Banner ID: ${dotenv.env['ADMOB_BANNER_ID']}');

  // Initialize AdMob
  await MobileAds.instance.initialize();
  // print('✅ AdMob initialized');
  AppLogger.info('✅ AdMob initialized');

  // Run the app
  runApp(const RandomKitApp());
}

class RandomKitApp extends StatelessWidget {
  const RandomKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Kit',
      theme: ThemeData(primaryColor: Colors.blue[900], useMaterial3: true),
      home: const DiceRollerScreen(),
      // debugShowCheckedModeBanner: false,
    );
  }
}
