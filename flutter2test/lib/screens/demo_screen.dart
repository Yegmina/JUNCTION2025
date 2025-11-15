import 'package:flutter/material.dart';
import '../widgets/phone_mockup_widget.dart';
import '../widgets/share_menu_widget.dart';
import 'wolt_recommendations_screen.dart';
import 'tiktok_home_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _showShareMenu = false;
  bool _isProcessing = false;
  bool _showWoltApp = false;
  String? _selectedVideoId;

  void _handleShareVideo(String videoId) {
    setState(() {
      _selectedVideoId = videoId;
      _showShareMenu = true;
    });
  }

  void _handleWoltSelected() async {
    setState(() {
      _showShareMenu = false;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _showWoltApp = true;
    });
  }

  void _handleBackToVideos() {
    setState(() {
      _showWoltApp = false;
      _selectedVideoId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wolt Video Share Demo',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scroll videos, share to Wolt, and get food recommendations',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PhoneMockupWidget(
                child: _buildPhoneContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneContent() {
    if (_isProcessing) {
      return _buildProcessingView();
    }

    if (_showWoltApp && _selectedVideoId != null) {
      return WoltRecommendationsScreen(
        videoId: _selectedVideoId!,
        onBack: _handleBackToVideos,
      );
    }

    return Stack(
      children: [
        TikTokHomeScreen(
          onShareVideo: _handleShareVideo,
        ),
        if (_showShareMenu)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showShareMenu = false;
                });
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ShareMenuWidget(
                  onWoltSelected: _handleWoltSelected,
                  onDismiss: () {
                    setState(() {
                      _showShareMenu = false;
                    });
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return SizedBox.expand(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
            const SizedBox(height: 24),
            Text(
              'Processing video...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing food content',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Finding the best matches for you',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

