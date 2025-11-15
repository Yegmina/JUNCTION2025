import 'dart:io';
import 'dart:math';
import '../models/menu_item.dart';
import '../models/search_result.dart';
import '../models/mock_data.dart';

class ImageSearchService {
  // Mock AI analysis - simulates image recognition
  // In production, this would call a real AI/ML API
  
  // Detect food type from image (mock implementation)
  String _detectFoodType(File imageFile) {
    final fileName = imageFile.path.toLowerCase();
    final fileNameParts = fileName.split(RegExp(r'[/\\]'));
    final fullPath = fileNameParts.join(' ').toLowerCase();
    
    // Check for sushi-related keywords in file name or path
    if (fullPath.contains('sushi') || 
        fullPath.contains('sashimi') || 
        fullPath.contains('japanese') ||
        fullPath.contains('roll') ||
        fullPath.contains('nigiri') ||
        fullPath.contains('maki')) {
      return 'sushi';
    }
    
    // Check for other food types
    if (fullPath.contains('pizza') || fullPath.contains('italian')) {
      return 'pizza';
    }
    if (fullPath.contains('burger') || fullPath.contains('hamburger')) {
      return 'burger';
    }
    if (fullPath.contains('ramen') || fullPath.contains('noodle')) {
      return 'ramen';
    }
    
    // Default: try to detect based on image characteristics
    final imageSize = imageFile.lengthSync();
    if (imageSize < 500000) {
      return 'sushi';
    }
    
    return 'unknown';
  }

  Future<List<SearchResult>> analyzeImage(File imageFile) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Detect food type from image
    final detectedFoodType = _detectFoodType(imageFile);
    
    // Get all restaurants and menu items
    final restaurants = MockDataService.getRestaurants();
    final allMenuItems = <String, List<MenuItem>>{};
    
    for (var restaurant in restaurants) {
      allMenuItems[restaurant.id] = MockDataService.getMenuItems(restaurant.id);
    }

    // Mock analysis: Extract image metadata
    final imageSize = await imageFile.length();
    final random = Random(imageSize.hashCode);

    // Generate mock similarity scores based on detected food type
    final results = <SearchResult>[];

    for (var restaurant in restaurants) {
      final menuItems = allMenuItems[restaurant.id] ?? [];
      
      // Base similarity score
      double similarityScore = 60 + random.nextDouble() * 20;
      bool isRelevantRestaurant = false;
      
      if (detectedFoodType == 'sushi') {
        if (restaurant.cuisineType.toLowerCase().contains('japanese') ||
            restaurant.cuisineType.toLowerCase().contains('sushi') ||
            restaurant.name.toLowerCase().contains('sushi')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        } else if (restaurant.cuisineType.toLowerCase().contains('ramen')) {
          similarityScore = 75 + random.nextDouble() * 10;
        } else {
          similarityScore = 65 + random.nextDouble() * 10;
        }
      } else if (detectedFoodType == 'pizza') {
        if (restaurant.cuisineType.toLowerCase().contains('italian') ||
            restaurant.name.toLowerCase().contains('pizza')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        }
      } else if (detectedFoodType == 'burger') {
        if (restaurant.cuisineType.toLowerCase().contains('american') ||
            restaurant.name.toLowerCase().contains('burger')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        }
      } else if (detectedFoodType == 'ramen') {
        if (restaurant.cuisineType.toLowerCase().contains('japanese') ||
            restaurant.name.toLowerCase().contains('ramen')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        }
      }

      // Find matching menu items with similarity scores
      final matchingItems = <MenuItemMatch>[];
      for (var item in menuItems) {
        double itemScore = similarityScore - 5 - random.nextDouble() * 10;
        
        if (detectedFoodType == 'sushi') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          final itemCategoryLower = item.category.toLowerCase();
          
          if (itemNameLower.contains('sushi') ||
              itemNameLower.contains('sashimi') ||
              itemNameLower.contains('roll') ||
              itemNameLower.contains('nigiri') ||
              itemNameLower.contains('maki') ||
              itemCategoryLower.contains('sashimi') ||
              itemCategoryLower.contains('roll') ||
              itemDescLower.contains('salmon') ||
              itemDescLower.contains('tuna') ||
              itemDescLower.contains('eel')) {
            itemScore = 85 + random.nextDouble() * 10;
          } else if (isRelevantRestaurant) {
            itemScore = 75 + random.nextDouble() * 10;
          }
        }
        
        if (itemScore > 65) {
          matchingItems.add(MenuItemMatch(
            menuItem: item,
            similarityScore: itemScore,
          ));
        }
      }

      // Sort matching items by similarity
      matchingItems.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

      // For sushi detection, prioritize sushi restaurants even if score is lower
      final shouldInclude = detectedFoodType == 'sushi' && isRelevantRestaurant
          ? true
          : (similarityScore > 70 || matchingItems.isNotEmpty);
      
      if (shouldInclude) {
        results.add(SearchResult(
          restaurant: restaurant,
          similarityScore: similarityScore,
          matchingMenuItems: matchingItems.take(5).toList(),
        ));
      }
    }

    // Sort by similarity score (highest first)
    results.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    // For sushi, prioritize showing sushi restaurants first
    if (detectedFoodType == 'sushi') {
      results.sort((a, b) {
        final aIsSushi = a.restaurant.cuisineType.toLowerCase().contains('japanese') ||
                        a.restaurant.cuisineType.toLowerCase().contains('sushi') ||
                        a.restaurant.name.toLowerCase().contains('sushi');
        final bIsSushi = b.restaurant.cuisineType.toLowerCase().contains('japanese') ||
                        b.restaurant.cuisineType.toLowerCase().contains('sushi') ||
                        b.restaurant.name.toLowerCase().contains('sushi');
        
        if (aIsSushi && !bIsSushi) return -1;
        if (!aIsSushi && bIsSushi) return 1;
        return b.similarityScore.compareTo(a.similarityScore);
      });
      
      return results.take(8).toList();
    }

    return results.take(10).toList();
  }
}

