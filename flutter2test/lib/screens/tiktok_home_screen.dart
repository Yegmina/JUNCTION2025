import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/tiktok_status_bar.dart';
import '../widgets/tiktok_header.dart';
import '../widgets/tiktok_tab_bar.dart';
import '../widgets/tiktok_video_item.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class TikTokHomeScreen extends StatefulWidget {
  final Function(String videoId)? onShareVideo;
  
  const TikTokHomeScreen({
    super.key,
    this.onShareVideo,
  });

  @override
  State<TikTokHomeScreen> createState() => _TikTokHomeScreenState();
}

class _TikTokHomeScreenState extends State<TikTokHomeScreen> {
  final PageController _pageController = PageController();
  final List<VideoModel> _videos = VideoService.getVideos();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleShare(VideoModel video) {
    if (widget.onShareVideo != null) {
      widget.onShareVideo!(video.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Main video feed
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final video = _videos[index];
                final isCurrentVideo = index == _currentIndex;
                
                return TikTokVideoItem(
                  video: video,
                  isPlaying: isCurrentVideo,
                  onShare: () => _handleShare(video),
                );
              },
            ),
            // Status bar overlay
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TikTokStatusBar(),
            ),
            // Header overlay
            const Positioned(
              top: 44,
              left: 0,
              right: 0,
              child: TikTokHeader(),
            ),
            // Bottom tab bar overlay
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TikTokTabBar(),
            ),
          ],
        ),
      ),
    );
  }
}

