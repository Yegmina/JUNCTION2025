import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/demo_screen.dart';
import 'services/restaurant_provider.dart';

void main() {
  runApp(const WoltApp());
}

class WoltApp extends StatelessWidget {
  const WoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantProvider(),
      child: MaterialApp(
        title: 'Wolt Video Share Demo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Use demo screen for web, home screen for mobile
        home: kIsWeb ? const DemoScreen() : const HomeScreen(),
      ),
    );
  }
}

