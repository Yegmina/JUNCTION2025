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
        title: 'Wolt Food Delivery',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Use demo screen for web, home screen for mobile
        home: kIsWeb ? const _PhoneCanvasWrapper(child: DemoScreen()) : const HomeScreen(),
      ),
    );
  }
}

// Phone canvas wrapper for web
class _PhoneCanvasWrapper extends StatelessWidget {
  final Widget child;
  
  const _PhoneCanvasWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    // Center the phone canvas on web
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
