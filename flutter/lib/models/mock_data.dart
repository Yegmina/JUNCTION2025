import 'restaurant.dart';
import 'menu_item.dart';

class MockDataService {
  static List<Restaurant> getRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Bella Italia',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        rating: 4.5,
        deliveryTimeMinutes: 25,
        cuisineType: 'Italian',
        distanceKm: 1.2,
        description: 'Authentic Italian cuisine with fresh ingredients',
        minOrderAmount: 15.0,
      ),
      Restaurant(
        id: '2',
        name: 'Sushi Master',
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
        rating: 4.8,
        deliveryTimeMinutes: 30,
        cuisineType: 'Japanese',
        distanceKm: 2.1,
        description: 'Fresh sushi and Japanese specialties',
        minOrderAmount: 20.0,
      ),
      Restaurant(
        id: '3',
        name: 'Burger House',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        rating: 4.3,
        deliveryTimeMinutes: 20,
        cuisineType: 'American',
        distanceKm: 0.8,
        description: 'Gourmet burgers and fries',
        minOrderAmount: 12.0,
      ),
      Restaurant(
        id: '4',
        name: 'Taco Fiesta',
        imageUrl: 'https://images.unsplash.com/photo-1565299585323-38174c0b5e3a?w=400',
        rating: 4.6,
        deliveryTimeMinutes: 18,
        cuisineType: 'Mexican',
        distanceKm: 1.5,
        description: 'Authentic Mexican street food',
        minOrderAmount: 10.0,
      ),
      Restaurant(
        id: '5',
        name: 'Curry Express',
        imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
        rating: 4.7,
        deliveryTimeMinutes: 35,
        cuisineType: 'Indian',
        distanceKm: 2.8,
        description: 'Spicy Indian curries and naan',
        minOrderAmount: 18.0,
      ),
      Restaurant(
        id: '6',
        name: 'Pizza Corner',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        rating: 4.4,
        deliveryTimeMinutes: 22,
        cuisineType: 'Italian',
        distanceKm: 1.0,
        description: 'Wood-fired pizzas and Italian classics',
        minOrderAmount: 14.0,
      ),
      Restaurant(
        id: '7',
        name: 'Ramen Shop',
        imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        rating: 4.9,
        deliveryTimeMinutes: 28,
        cuisineType: 'Japanese',
        distanceKm: 1.8,
        description: 'Traditional ramen bowls',
        minOrderAmount: 16.0,
      ),
      Restaurant(
        id: '8',
        name: 'Mediterranean Delight',
        imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
        rating: 4.5,
        deliveryTimeMinutes: 32,
        cuisineType: 'Mediterranean',
        distanceKm: 2.5,
        description: 'Fresh Mediterranean dishes',
        minOrderAmount: 17.0,
      ),
      Restaurant(
        id: '9',
        name: 'BBQ Smokehouse',
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        rating: 4.6,
        deliveryTimeMinutes: 40,
        cuisineType: 'BBQ',
        distanceKm: 3.2,
        description: 'Slow-smoked meats and sides',
        minOrderAmount: 22.0,
      ),
      Restaurant(
        id: '10',
        name: 'Vegan Garden',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        rating: 4.2,
        deliveryTimeMinutes: 24,
        cuisineType: 'Vegan',
        distanceKm: 1.3,
        description: 'Plant-based healthy options',
        minOrderAmount: 13.0,
      ),
    ];
  }

  static List<MenuItem> getMenuItems(String restaurantId) {
    final menuItems = <MenuItem>[];

    switch (restaurantId) {
      case '1': // Bella Italia
        menuItems.addAll([
          MenuItem(
            id: '1-1',
            name: 'Margherita Pizza',
            description: 'Fresh mozzarella, tomato sauce, basil',
            price: 12.99,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300',
            restaurantId: '1',
            category: 'Mains',
          ),
          MenuItem(
            id: '1-2',
            name: 'Spaghetti Carbonara',
            description: 'Creamy pasta with bacon and parmesan',
            price: 14.99,
            imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300',
            restaurantId: '1',
            category: 'Mains',
          ),
          MenuItem(
            id: '1-3',
            name: 'Caesar Salad',
            description: 'Romaine lettuce, croutons, parmesan',
            price: 9.99,
            imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=300',
            restaurantId: '1',
            category: 'Appetizers',
          ),
          MenuItem(
            id: '1-4',
            name: 'Tiramisu',
            description: 'Classic Italian dessert',
            price: 7.99,
            imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=300',
            restaurantId: '1',
            category: 'Desserts',
          ),
        ]);
        break;

      case '2': // Sushi Master
        menuItems.addAll([
          MenuItem(
            id: '2-1',
            name: 'Salmon Sashimi',
            description: 'Fresh salmon slices',
            price: 18.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Sashimi',
          ),
          MenuItem(
            id: '2-2',
            name: 'Dragon Roll',
            description: 'Eel, cucumber, avocado, eel sauce',
            price: 16.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Rolls',
          ),
          MenuItem(
            id: '2-3',
            name: 'Tuna Sashimi',
            description: 'Premium fresh tuna slices',
            price: 19.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Sashimi',
          ),
          MenuItem(
            id: '2-4',
            name: 'California Roll',
            description: 'Crab, avocado, cucumber',
            price: 12.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Rolls',
          ),
          MenuItem(
            id: '2-5',
            name: 'Salmon Nigiri',
            description: 'Fresh salmon on sushi rice',
            price: 14.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Nigiri',
          ),
          MenuItem(
            id: '2-6',
            name: 'Spicy Tuna Roll',
            description: 'Spicy tuna, cucumber, spicy mayo',
            price: 15.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Rolls',
          ),
          MenuItem(
            id: '2-7',
            name: 'Miso Soup',
            description: 'Traditional Japanese soup',
            price: 4.99,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300',
            restaurantId: '2',
            category: 'Soups',
          ),
        ]);
        break;

      case '3': // Burger House
        menuItems.addAll([
          MenuItem(
            id: '3-1',
            name: 'Classic Cheeseburger',
            description: 'Beef patty, cheese, lettuce, tomato',
            price: 11.99,
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
            restaurantId: '3',
            category: 'Burgers',
          ),
          MenuItem(
            id: '3-2',
            name: 'Bacon BBQ Burger',
            description: 'Beef, bacon, BBQ sauce, onion rings',
            price: 13.99,
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
            restaurantId: '3',
            category: 'Burgers',
          ),
          MenuItem(
            id: '3-3',
            name: 'French Fries',
            description: 'Crispy golden fries',
            price: 4.99,
            imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300',
            restaurantId: '3',
            category: 'Sides',
          ),
        ]);
        break;

      default:
        // Generic menu items for other restaurants
        menuItems.addAll([
          MenuItem(
            id: '$restaurantId-1',
            name: 'Signature Dish',
            description: 'Chef\'s special recommendation',
            price: 15.99,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
            restaurantId: restaurantId,
            category: 'Mains',
          ),
          MenuItem(
            id: '$restaurantId-2',
            name: 'Appetizer Platter',
            description: 'Selection of appetizers',
            price: 12.99,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
            restaurantId: restaurantId,
            category: 'Appetizers',
          ),
          MenuItem(
            id: '$restaurantId-3',
            name: 'Dessert Special',
            description: 'House dessert',
            price: 6.99,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
            restaurantId: restaurantId,
            category: 'Desserts',
          ),
        ]);
    }

    return menuItems;
  }

  static List<String> getCuisineTypes() {
    return ['All', 'Italian', 'Japanese', 'American', 'Mexican', 'Indian', 'Mediterranean', 'BBQ', 'Vegan'];
  }
}


