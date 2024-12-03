import 'package:flutter/material.dart';
import 'package:inventorypos/pages/homepage.dart';
import 'package:window_size/window_size.dart';

void main() {
  // Ensure window size can be set
  WidgetsFlutterBinding.ensureInitialized();

  // Set the minimum and maximum window size
  setWindowMinSize(Size(1200, 800)); // Set minimum window size
  setWindowMaxSize(Size(1600, 1200)); // Set maximum window size
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF003049)),
        primaryColor: Color(0xFF003049),
        useMaterial3: true,
      ),
      home: POSHomePage(),
    );
  }
}
