import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../models/video_model.dart';

class TikTokVideoItem extends StatefulWidget {
  final VideoModel video;
  final bool isPlaying;
  final VoidCallback? onShare;

  const TikTokVideoItem({
    super.key,
    required this.video,
    this.isPlaying = false,
    this.onShare,
  });

  @override
  State<TikTokVideoItem> createState() => _TikTokVideoItemState();
}

class _TikTokVideoItemState extends State<TikTokVideoItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  late AnimationController _discAnimationController;
  int _likes = 328700; // 328.7K from Figma
  int _comments = 578; // From Figma

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _discAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  Future<void> _initializeVideo() async {
    try {
      if (kIsWeb) {
        final videoPath = widget.video.videoUrl.replaceFirst('assets/', '');
        _controller = VideoPlayerController.networkUrl(
          Uri.parse('/assets/$videoPath'),
        );
      } else {
        _controller = VideoPlayerController.asset(widget.video.videoUrl);
      }
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isPlaying) {
          _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(TikTokVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying && _controller != null) {
      if (widget.isPlaying) {
        _controller!.play();
        _discAnimationController.repeat();
      } else {
        _controller!.pause();
        _discAnimationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _discAnimationController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background video/image
          if (_isInitialized && _controller != null && !_hasError)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: widget.video.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Right side overlay (User avatar, action buttons) - from Figma: left: 357px, width: 49px
          Positioned(
            right: 8, // 414 - 357 - 49 = 8px
            top: 0,
            bottom: 120, // Leave space for bottom overlay
            child: SizedBox(
              width: 49,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User avatar with plus button
                  Stack(
                    children: [
                      Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                // Action buttons
                _ActionButton(
                  icon: Icons.favorite,
                  count: _formatNumber(_likes),
                  onTap: () {
                    setState(() {
                      _likes++;
                    });
                  },
                ),
                const SizedBox(height: 26),
                _ActionButton(
                  icon: Icons.comment,
                  count: _formatNumber(_comments),
                  onTap: () {
                    // Handle comment tap
                  },
                ),
                const SizedBox(height: 26),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: widget.onShare,
                ),
                const SizedBox(height: 26),
                // Music disc
                AnimatedBuilder(
                  animation: _discAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _discAnimationController.value * 2 * math.pi,
                      child: Container(
                        width: 49,
                        height: 49,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE500), Color(0xFF000000)],
                            stops: [0.5, 0.5],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 12.5,
                            height: 12.5,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
          // Bottom left overlay (Username, caption, music) - from Figma: left: 12px, top: 703px
          Positioned(
            left: 12,
            bottom: 193, // 896 - 703 = 193px from top, or from bottom: 896 - 703 - content height
            right: 65, // Leave space for right overlay (49px + 16px padding)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                Text(
                  '@food_prn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Caption
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF), // rgba(255,255,255,0.9)
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    children: [
                      const TextSpan(text: 'The most satisfying meal '),
                      TextSpan(
                        text: '#fyp #satisfying #koreanfriedchicken',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Music
                Row(
                  children: [
                    // Music icon
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x4DFFFFFF),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Music name
                    const Text(
                      'Roddy Roundicch - The Rou',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Floating tones icon (bottom right) - from Figma: left: 313.67px, top: 741.79px, size: 56.552 x 67.529
          Positioned(
            right: 44, // 414 - 313.67 - 56.552 ≈ 44px
            bottom: 87, // 896 - 741.79 - 67.529 ≈ 87px
            child: SizedBox(
              width: 56.552,
              height: 67.529,
              child: const Icon(
                Icons.graphic_eq,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? count;
  final String? label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.count,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 35,
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
          if (count != null || label != null)
            const SizedBox(height: 4),
          if (count != null)
            Text(
              count!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            )
          else if (label != null)
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

