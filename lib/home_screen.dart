// lib/home_screen.dart

import 'package:flutter/material.dart';
// Note: The new screens we will create/modify
import 'dice_roller_screen.dart';
import 'number_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks the current tab index (0: Dice Roller, 1: Number Generator)
  int _selectedIndex = 0;

  // List of screens the tabs will switch between
  final List<Widget> _widgetOptions = <Widget>[
    const DiceRollerScreen(),
    const NumberGeneratorScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is now provided by the shell and remains consistent
      appBar: AppBar(
        title: const Text('Random Kit', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
      ),

      // The body displays the currently selected screen
      body: _widgetOptions.elementAt(_selectedIndex),

      // The permanent Flutter Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Dice'),
          BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Numbers'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
