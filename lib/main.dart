import 'package:flutter/material.dart';
import 'screens/cat_pick_screen.dart';

void main() {
  runApp(const CatPickerApp());
}

class CatPickerApp extends StatelessWidget {
  const CatPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const TinderSwipeScreen(),
    );
  }
}
