import 'dart:io';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/image_search_service.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/recommended_section.dart';
import '../widgets/restaurant_card_with_score.dart';
import '../widgets/menu_item_card_with_score.dart';
import 'restaurant_detail_screen.dart';
import '../models/mock_data.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  final ImageSearchService _searchService = ImageSearchService();
  File? _selectedImage;
  List<SearchResult>? _searchResults;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _isAnalyzing = true;
      _searchResults = null;
      _errorMessage = null;
    });

    try {
      final results = await _searchService.analyzeImage(imageFile);
      setState(() {
        _searchResults = results;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing image: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _selectedImage = null;
      _searchResults = null;
      _errorMessage = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Image'),
        actions: _selectedImage != null
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetSearch,
                  tooltip: 'Try another image',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            if (_selectedImage == null && _searchResults == null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Find Similar Food',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload a photo of food you\'d like to find, and we\'ll show you the best matches available on Wolt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Image upload widget
            ImageUploadWidget(
              onImageSelected: _analyzeImage,
              isLoading: _isAnalyzing,
            ),

            // Loading state
            if (_isAnalyzing) ...[
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Analyzing your image...',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Finding the best matches for you',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                ),
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // Error state
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Results
            if (_searchResults != null) ...[
              if (_searchResults!.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try uploading a different image',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: RecommendedSection(
                    title: 'Recommended Restaurants',
                    subtitle: '${_searchResults!.length} matches found',
                  ),
                ),

                // Restaurant results
                ..._searchResults!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RestaurantCardWithScore(
                          restaurant: result.restaurant,
                          similarityScore: result.similarityScore,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailScreen(
                                  restaurant: result.restaurant,
                                ),
                              ),
                            );
                          },
                        ),

                        // Matching menu items for this restaurant
                        if (result.matchingMenuItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantDetailScreen(
                                        restaurant: result.restaurant,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

