import 'package:flutter/material.dart';

class TikTokTabBar extends StatelessWidget {
  const TikTokTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF262626),
            offset: Offset(0, -0.33),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Home indicator line at bottom
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          // Tab bar buttons
          Positioned(
            top: 7,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home
                _TabButton(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: true,
                ),
                // Discover
                _TabButton(
                  icon: Icons.search,
                  label: 'Discover',
                  isActive: false,
                ),
                // Create button (center, red)
                Container(
                  width: 43,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA4359), // TikTok Button color
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                // Inbox
                _TabButton(
                  icon: Icons.message_outlined,
                  label: 'Inbox',
                  isActive: false,
                ),
                // Me
                _TabButton(
                  icon: Icons.person_outline,
                  label: 'Me',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _TabButton({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isActive ? 1.0 : 0.8;
    final fontWeight = isActive ? FontWeight.w700 : FontWeight.w400;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(opacity),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(opacity),
            fontSize: 10,
            fontWeight: fontWeight,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }
}


