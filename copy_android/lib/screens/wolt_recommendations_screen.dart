import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/video_detection_service.dart';
import '../widgets/recommended_section.dart';
import '../widgets/restaurant_card_with_score.dart';
import '../widgets/menu_item_card_with_score.dart';
import 'restaurant_detail_screen.dart';

class WoltRecommendationsScreen extends StatefulWidget {
  final String videoId;
  final VoidCallback? onBack;

  const WoltRecommendationsScreen({
    super.key,
    required this.videoId,
    this.onBack,
  });

  @override
  State<WoltRecommendationsScreen> createState() => _WoltRecommendationsScreenState();
}

class _WoltRecommendationsScreenState extends State<WoltRecommendationsScreen> {
  final VideoDetectionService _detectionService = VideoDetectionService();
  List<SearchResult>? _searchResults;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final results = await _detectionService.analyzeVideo(widget.videoId);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // App bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                const SizedBox(width: 8),
                const Text(
                  'Wolt',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                    ),
                  )
                : _searchResults == null || _searchResults!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recommendations found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecommendedSection(
                              title: 'Recommended for you',
                              subtitle: 'Based on the video you shared',
                            ),
                            ..._searchResults!.map((result) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RestaurantCardWithScore(
                                    restaurant: result.restaurant,
                                    similarityScore: result.similarityScore,
                                    onTap: () {
                                      // Navigate to restaurant detail
                                      // In demo mode, we can show a snackbar or keep it simple
                                    },
                                  ),
                                  // Matching menu items
                                  if (result.matchingMenuItems.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                                      child: Text(
                                        'Similar items at ${result.restaurant.name}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.grey[700],
                                            ),
                                      ),
                                    ),
                                    ...result.matchingMenuItems.map((itemMatch) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                                        child: MenuItemCardWithScore(
                                          menuItem: itemMatch.menuItem,
                                          similarityScore: itemMatch.similarityScore,
                                          onAddToCart: () {
                                            // Handle add to cart
                                          },
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

