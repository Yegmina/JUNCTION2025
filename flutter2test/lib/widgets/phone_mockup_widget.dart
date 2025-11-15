import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhoneMockupWidget extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const PhoneMockupWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Use static phone canvas size as requested
    final phoneWidth = width ?? AppTheme.phoneWidth;
    final phoneHeight = height ?? AppTheme.phoneHeight;

    return Container(
      width: phoneWidth,
      height: phoneHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            width: phoneWidth - 24, // Account for padding
            height: phoneHeight - 24, // Account for padding
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,
              // Status bar overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 24,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            '9:41',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, size: 14, color: Colors.black87),
                            const SizedBox(width: 4),
                            Icon(Icons.wifi, size: 14, color: Colors.black87),
                            const SizedBox(width: 4),
                            Icon(Icons.battery_full, size: 14, color: Colors.black87),
                          ],
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

