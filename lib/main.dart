import 'package:inventorypos/state_util.dart';
import 'package:inventorypos/core.dart';
import 'package:flutter/material.dart';
import 'package:inventorypos/keys/keys.dart';
import 'package:inventorypos/pages/homepage.dart';
import 'package:inventorypos/pages/login_page.dart';
import 'package:inventorypos/provider/login_provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';

void main() async {
  // Ensure window size can be set
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Set the minimum and maximum window size
  setWindowMinSize(Size(1200, 800)); // Set minimum window size
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LoginProvider(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          navigatorKey: Get.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3651A4)),
            primaryColor: Color(0xFF3651A4),
            useMaterial3: true,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3651A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          home: LoginPage(),
        ),
      ),
    );
  }
}
