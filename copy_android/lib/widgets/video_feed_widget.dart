import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import 'video_player_widget.dart';

class VideoFeedWidget extends StatefulWidget {
  final Function(String videoId) onShareVideo;

  const VideoFeedWidget({
    super.key,
    required this.onShareVideo,
  });

  @override
  State<VideoFeedWidget> createState() => _VideoFeedWidgetState();
}

class _VideoFeedWidgetState extends State<VideoFeedWidget> {
  final PageController _pageController = PageController();
  final List<VideoModel> _videos = VideoService.getVideos();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleShare(VideoModel video) {
    widget.onShareVideo(video.id);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
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
        
        return VideoPlayerWidget(
          video: video,
          isPlaying: isCurrentVideo,
          onShare: () => _handleShare(video),
        );
      },
    );
  }
}

