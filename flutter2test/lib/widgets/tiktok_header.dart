import 'package:flutter/material.dart';

class TikTokHeader extends StatelessWidget {
  const TikTokHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: Stack(
        children: [
          // Divider line
          Positioned(
            left: 214.5,
            top: 16.5,
            child: Container(
              width: 1,
              height: 11,
              color: const Color(0xFFFFFFFF).withOpacity(0.3),
            ),
          ),
          // Following tab
          const Positioned(
            left: 132,
            top: 13,
            child: Text(
              'Following',
              style: TextStyle(
                color: Color(0x99FFFFFF), // rgba(255,255,255,0.6)
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // For You tab (active)
          const Positioned(
            left: 223,
            top: 11,
            child: Text(
              'For You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

