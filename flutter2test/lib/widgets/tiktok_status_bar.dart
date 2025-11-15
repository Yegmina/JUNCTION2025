import 'package:flutter/material.dart';

class TikTokStatusBar extends StatelessWidget {
  const TikTokStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          const Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          // Right side icons
          Row(
            children: [
              // Mobile signal
              Container(
                width: 18.77,
                height: 10.67,
                color: Colors.white,
                child: CustomPaint(
                  painter: _SignalPainter(),
                ),
              ),
              const SizedBox(width: 4),
              // WiFi
              Container(
                width: 16.86,
                height: 10.97,
                color: Colors.white,
                child: CustomPaint(
                  painter: _WifiPainter(),
                ),
              ),
              const SizedBox(width: 4),
              // Battery
              Container(
                width: 24.5,
                height: 10.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -1.5,
                      top: 2.44,
                      child: Container(
                        width: 1.5,
                        height: 3.87,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2.5,
                      child: Container(
                        width: 18,
                        height: 6.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Simple signal bars representation
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.6, size.width * 0.25, size.height * 0.4), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.25, size.height * 0.7), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, 0, size.width * 0.25, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WifiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width, size.height * 0.6);
    canvas.drawPath(path, paint);
    
    path.reset();
    path.moveTo(size.width * 0.3, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.7, size.height * 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

