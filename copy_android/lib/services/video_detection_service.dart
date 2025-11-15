import '../models/search_result.dart';
import '../models/mock_data.dart';
import '../models/menu_item.dart';
import '../services/video_service.dart';
import 'dart:math';

class VideoDetectionService {
  // Detect food type from video and return recommendations
  // This simulates AI analyzing video content
  Future<List<SearchResult>> analyzeVideo(String videoId) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Get food type from video
    final foodType = VideoService.detectFoodTypeFromVideo(videoId);
    
    // Get all restaurants and menu items
    final restaurants = MockDataService.getRestaurants();
    final allMenuItems = <String, List<dynamic>>{};
    
    for (var restaurant in restaurants) {
      allMenuItems[restaurant.id] = MockDataService.getMenuItems(restaurant.id);
    }

    final random = Random(videoId.hashCode);
    final results = <SearchResult>[];

    for (var restaurant in restaurants) {
      final menuItems = allMenuItems[restaurant.id] ?? [];
      
      // Base similarity score
      double similarityScore = 60 + random.nextDouble() * 20;
      bool isRelevantRestaurant = false;
      
      // Boost score based on detected food type
      if (foodType == 'sushi') {
        if (restaurant.cuisineType.toLowerCase().contains('japanese') ||
            restaurant.cuisineType.toLowerCase().contains('sushi') ||
            restaurant.name.toLowerCase().contains('sushi')) {
          similarityScore = 88 + random.nextDouble() * 7; // 88-95%
          isRelevantRestaurant = true;
        } else if (restaurant.cuisineType.toLowerCase().contains('ramen')) {
          similarityScore = 75 + random.nextDouble() * 10;
        } else {
          similarityScore = 65 + random.nextDouble() * 10;
        }
      } else if (foodType == 'pizza') {
        if (restaurant.cuisineType.toLowerCase().contains('italian') ||
            restaurant.name.toLowerCase().contains('pizza')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        }
      } else if (foodType == 'burger') {
        if (restaurant.cuisineType.toLowerCase().contains('american') ||
            restaurant.name.toLowerCase().contains('burger')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        }
      } else if (foodType == 'vietnamese' || foodType == 'banmi') {
        // For banh mi / Vietnamese food
        if (restaurant.cuisineType.toLowerCase().contains('vietnamese') ||
            restaurant.name.toLowerCase().contains('vietnamese') ||
            restaurant.name.toLowerCase().contains('banh') ||
            restaurant.description.toLowerCase().contains('vietnamese')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        } else if (restaurant.cuisineType.toLowerCase().contains('asian')) {
          similarityScore = 75 + random.nextDouble() * 10;
        } else {
          similarityScore = 65 + random.nextDouble() * 10;
        }
      } else if (foodType == 'breakfast') {
        // For breakfast - match with cafes, breakfast places, or general restaurants
        if (restaurant.cuisineType.toLowerCase().contains('breakfast') ||
            restaurant.name.toLowerCase().contains('breakfast') ||
            restaurant.name.toLowerCase().contains('cafe') ||
            restaurant.description.toLowerCase().contains('breakfast')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        } else {
          similarityScore = 70 + random.nextDouble() * 15; // Moderate scores for all
        }
      } else if (foodType == 'steak') {
        // For steak - match with BBQ, American, or steakhouse restaurants
        if (restaurant.cuisineType.toLowerCase().contains('bbq') ||
            restaurant.cuisineType.toLowerCase().contains('american') ||
            restaurant.name.toLowerCase().contains('steak') ||
            restaurant.name.toLowerCase().contains('grill')) {
          similarityScore = 88 + random.nextDouble() * 7;
          isRelevantRestaurant = true;
        } else {
          similarityScore = 70 + random.nextDouble() * 15;
        }
      }

      // Find matching menu items
      final matchingItems = <MenuItemMatch>[];
      for (var item in menuItems) {
        double itemScore = similarityScore - 5 - random.nextDouble() * 10;
        
        if (foodType == 'sushi') {
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
        } else if (foodType == 'vietnamese' || foodType == 'banmi') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          
          if (itemNameLower.contains('banh') ||
              itemNameLower.contains('vietnamese') ||
              itemNameLower.contains('pho') ||
              itemDescLower.contains('vietnamese')) {
            itemScore = 85 + random.nextDouble() * 10;
          } else if (isRelevantRestaurant) {
            itemScore = 75 + random.nextDouble() * 10;
          }
        } else if (foodType == 'breakfast') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          final itemCategoryLower = item.category.toLowerCase();
          
          if (itemNameLower.contains('breakfast') ||
              itemNameLower.contains('pancake') ||
              itemNameLower.contains('waffle') ||
              itemNameLower.contains('egg') ||
              itemNameLower.contains('bacon') ||
              itemCategoryLower.contains('breakfast')) {
            itemScore = 85 + random.nextDouble() * 10;
          } else if (isRelevantRestaurant) {
            itemScore = 75 + random.nextDouble() * 10;
          }
        } else if (foodType == 'burger') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          
          if (itemNameLower.contains('burger') ||
              itemDescLower.contains('burger') ||
              itemDescLower.contains('beef patty')) {
            itemScore = 85 + random.nextDouble() * 10;
          } else if (isRelevantRestaurant) {
            itemScore = 75 + random.nextDouble() * 10;
          }
        } else if (foodType == 'pizza') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          
          if (itemNameLower.contains('pizza') ||
              itemDescLower.contains('pizza')) {
            itemScore = 85 + random.nextDouble() * 10;
          } else if (isRelevantRestaurant) {
            itemScore = 75 + random.nextDouble() * 10;
          }
        } else if (foodType == 'steak') {
          final itemNameLower = item.name.toLowerCase();
          final itemDescLower = item.description.toLowerCase();
          
          if (itemNameLower.contains('steak') ||
              itemNameLower.contains('rib') ||
              itemDescLower.contains('steak') ||
              itemDescLower.contains('beef')) {
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

      // Sort by score
      matchingItems.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

      // Include restaurants based on food type and relevance
      final shouldInclude = (foodType == 'sushi' && isRelevantRestaurant) ||
          (foodType == 'vietnamese' && isRelevantRestaurant) ||
          (foodType == 'banmi' && isRelevantRestaurant) ||
          (foodType == 'breakfast' && isRelevantRestaurant) ||
          (foodType == 'burger' && isRelevantRestaurant) ||
          (foodType == 'pizza' && isRelevantRestaurant) ||
          (foodType == 'steak' && isRelevantRestaurant) ||
          (similarityScore > 70 || matchingItems.isNotEmpty);
      
      if (shouldInclude) {
        results.add(SearchResult(
          restaurant: restaurant,
          similarityScore: similarityScore,
          matchingMenuItems: matchingItems.take(5).toList(),
        ));
      }
    }

    // Sort by similarity score
    results.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    // Prioritize relevant restaurants based on food type
    if (foodType == 'sushi' || foodType == 'vietnamese' || foodType == 'banmi' || 
        foodType == 'breakfast' || foodType == 'burger' || foodType == 'pizza' || 
        foodType == 'steak') {
      results.sort((a, b) {
        bool aIsRelevant = false;
        bool bIsRelevant = false;
        
        if (foodType == 'sushi') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('japanese') ||
                       a.restaurant.cuisineType.toLowerCase().contains('sushi') ||
                       a.restaurant.name.toLowerCase().contains('sushi');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('japanese') ||
                       b.restaurant.cuisineType.toLowerCase().contains('sushi') ||
                       b.restaurant.name.toLowerCase().contains('sushi');
        } else if (foodType == 'vietnamese' || foodType == 'banmi') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('vietnamese') ||
                       a.restaurant.name.toLowerCase().contains('vietnamese') ||
                       a.restaurant.name.toLowerCase().contains('banh');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('vietnamese') ||
                       b.restaurant.name.toLowerCase().contains('vietnamese') ||
                       b.restaurant.name.toLowerCase().contains('banh');
        } else if (foodType == 'breakfast') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('breakfast') ||
                       a.restaurant.name.toLowerCase().contains('breakfast') ||
                       a.restaurant.name.toLowerCase().contains('cafe');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('breakfast') ||
                       b.restaurant.name.toLowerCase().contains('breakfast') ||
                       b.restaurant.name.toLowerCase().contains('cafe');
        } else if (foodType == 'burger') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('american') ||
                       a.restaurant.name.toLowerCase().contains('burger');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('american') ||
                       b.restaurant.name.toLowerCase().contains('burger');
        } else if (foodType == 'pizza') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('italian') ||
                       a.restaurant.name.toLowerCase().contains('pizza');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('italian') ||
                       b.restaurant.name.toLowerCase().contains('pizza');
        } else if (foodType == 'steak') {
          aIsRelevant = a.restaurant.cuisineType.toLowerCase().contains('bbq') ||
                       a.restaurant.name.toLowerCase().contains('steak') ||
                       a.restaurant.name.toLowerCase().contains('grill');
          bIsRelevant = b.restaurant.cuisineType.toLowerCase().contains('bbq') ||
                       b.restaurant.name.toLowerCase().contains('steak') ||
                       b.restaurant.name.toLowerCase().contains('grill');
        }
        
        if (aIsRelevant && !bIsRelevant) return -1;
        if (!aIsRelevant && bIsRelevant) return 1;
        return b.similarityScore.compareTo(a.similarityScore);
      });
      
      return results.take(8).toList();
    }

    return results.take(10).toList();
  }
}

