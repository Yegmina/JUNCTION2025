import '../models/video_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class VideoService {
  static String _getVideoPath(String filename) {
    // For web, videos are in web/assets folder
    // For mobile, use asset path from pubspec.yaml
    if (kIsWeb) {
      return 'assets/$filename';
    } else {
      return 'assets/$filename';
    }
  }

  static List<VideoModel> getVideos() {
    return [
      VideoModel(
        id: 'banmi',
        title: 'Amazing Banh Mi',
        description: 'Delicious Vietnamese sandwich with fresh ingredients',
        videoUrl: _getVideoPath('banmi.mp4'),
        thumbnailUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        foodType: 'vietnamese',
        category: 'food',
        durationSeconds: 30,
      ),
      VideoModel(
        id: 'breakfast',
        title: 'Perfect Breakfast',
        description: 'Start your day with this amazing breakfast',
        videoUrl: _getVideoPath('breakfast.mp4'),
        thumbnailUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        foodType: 'breakfast',
        category: 'food',
        durationSeconds: 45,
      ),
      VideoModel(
        id: 'burger',
        title: 'Best Burger in Town',
        description: 'Check out this mouth-watering burger',
        videoUrl: _getVideoPath('burger.mp4'),
        thumbnailUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        foodType: 'burger',
        category: 'food',
        durationSeconds: 30,
      ),
      VideoModel(
        id: 'pizza',
        title: 'Pizza Night Recipe',
        description: 'Homemade pizza recipe that will blow your mind',
        videoUrl: _getVideoPath('pizza.mp4'),
        thumbnailUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        foodType: 'pizza',
        category: 'cooking',
        durationSeconds: 45,
      ),
      VideoModel(
        id: 'steak',
        title: 'Perfect Steak',
        description: 'Juicy steak cooked to perfection',
        videoUrl: _getVideoPath('steak.mp4'),
        thumbnailUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        foodType: 'steak',
        category: 'food',
        durationSeconds: 60,
      ),
    ];
  }

  static String detectFoodTypeFromVideo(String videoId) {
    final video = getVideos().firstWhere(
      (v) => v.id == videoId,
      orElse: () => getVideos().first,
    );
    return video.foodType;
  }

  static VideoModel? getVideoById(String videoId) {
    try {
      return getVideos().firstWhere((v) => v.id == videoId);
    } catch (e) {
      return null;
    }
  }
}

