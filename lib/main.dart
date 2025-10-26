import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dice_roller_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Determine which environment file to load
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Load secrets
  await dotenv.load(fileName: '.env.$environment');
  // Initialize AdMob
  await MobileAds.instance.initialize();

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
