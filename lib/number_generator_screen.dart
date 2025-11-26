// lib/number_generator_screen.dart

import 'package:flutter/material.dart';

// import 'utils/app_logger.dart';
import 'number_generator_logic.dart';
import 'widgets/base_feature_screen.dart';

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() => _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState extends State<NumberGeneratorScreen> {
  int _currentResult = 0;
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(
    text: '100',
  );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _generateNumber() {
    final int min = int.tryParse(_minController.text) ?? 1;
    final int max = int.tryParse(_maxController.text) ?? 100;
    final newResult = NumberGeneratorLogic.generateNumber(min, max);

    setState(() {
      _currentResult = newResult;
    });
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Random Kit+ Idle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(204),
              ),
            ),
            const Text(
              'Number Generator',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_GENERATOR', // Number generator ad ID
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('Min', _minController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInputField('Max', _maxController)),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '$_currentResult',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: _generateNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'GENERATE NUMBER',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
