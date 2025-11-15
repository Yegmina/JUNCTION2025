import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/mock_data.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  String _searchQuery = '';

  RestaurantProvider() {
    _loadRestaurants();
  }

  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  String get searchQuery => _searchQuery;

  void _loadRestaurants() {
    _restaurants = MockDataService.getRestaurants();
    notifyListeners();
  }

  void setSelectedRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Restaurant> getFilteredRestaurants(String? cuisineType) {
    var filtered = _restaurants;
    
    if (cuisineType != null && cuisineType != 'All') {
      filtered = filtered.where((r) => r.cuisineType == cuisineType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.cuisineType.toLowerCase().contains(query) ||
            r.description.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void refreshRestaurants() {
    _loadRestaurants();
  }
}


