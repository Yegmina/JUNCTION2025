class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String foodType; // 'sushi', 'pizza', 'burger', etc.
  final String category; // 'food', 'cooking', 'restaurant', etc.
  final int durationSeconds;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.foodType,
    required this.category,
    required this.durationSeconds,
  });
}

