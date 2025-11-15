import 'restaurant.dart';
import 'menu_item.dart';

class SearchResult {
  final Restaurant restaurant;
  final double similarityScore;
  final List<MenuItemMatch> matchingMenuItems;

  SearchResult({
    required this.restaurant,
    required this.similarityScore,
    required this.matchingMenuItems,
  });
}

class MenuItemMatch {
  final MenuItem menuItem;
  final double similarityScore;

  MenuItemMatch({
    required this.menuItem,
    required this.similarityScore,
  });
}

