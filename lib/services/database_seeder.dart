import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// ============================================================================
// DATABASE SEEDER - Populate Firestore with initial product data
// ============================================================================
class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds the products collection with initial sushi data
  /// Call this ONCE during development, then remove/comment out
  static Future<void> seedProducts() async {
    print('🌱 Starting database seeding...');

    try {
      // Check if products already exist
      final existingProducts = await _firestore.collection('products').limit(1).get();
      if (existingProducts.docs.isNotEmpty) {
        print('⚠️  Products already exist. Skipping seed.');
        return;
      }

      final sushiProducts = [
        // 1. Salmon Sushi (Nigiri)
        ProductModel(
          id: 'salmon-nigiri-001',
          name: 'Salmon Sushi',
          price: 21.00,
          imagePath: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&q=80',
          rating: 4.9,
          category: 'Nigiri',
          ingredients: ['Fresh Salmon', 'Sushi Rice', 'Wasabi'],
          description: 'Fresh salmon over seasoned rice.',
        ),

        // 2. Tuna Slice (Sashimi)
        ProductModel(
          id: 'tuna-sashimi-002',
          name: 'Tuna Slice',
          price: 23.00,
          imagePath: 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=800&q=80',
          rating: 4.8,
          category: 'Sashimi',
          ingredients: ['Premium Tuna', 'Soy Sauce', 'Ginger'],
          description: 'Premium cut tuna sashimi.',
        ),

        // 3. Salmon Eggs (Gunkan)
        ProductModel(
          id: 'salmon-roe-003',
          name: 'Salmon Eggs',
          price: 19.00,
          imagePath: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800&q=80',
          rating: 4.5,
          category: 'Gunkan',
          ingredients: ['Salmon Roe', 'Seaweed', 'Sushi Rice'],
          description: 'Fresh salmon roe wrapped in seaweed.',
        ),

        // 4. California Roll (Maki)
        ProductModel(
          id: 'california-roll-004',
          name: 'California Roll',
          price: 15.00,
          imagePath: 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=800&q=80',
          rating: 4.2,
          category: 'Maki',
          ingredients: ['Crab Meat', 'Avocado', 'Cucumber', 'Sesame Seeds'],
          description: 'Crab, avocado, and cucumber.',
        ),

        // 5. Dragon Roll (Special)
        ProductModel(
          id: 'dragon-roll-005',
          name: 'Dragon Roll',
          price: 25.00,
          imagePath: 'https://images.unsplash.com/photo-1563612116625-3012372fccce?w=800&q=80',
          rating: 5.0,
          category: 'Special',
          ingredients: ['Eel', 'Cucumber', 'Avocado', 'Teriyaki Sauce'],
          description: 'Eel and cucumber topped with avocado.',
        ),

        // 6. Spicy Shrimp (Maki)
        ProductModel(
          id: 'spicy-shrimp-006',
          name: 'Spicy Shrimp',
          price: 18.50,
          imagePath: 'https://images.unsplash.com/photo-1580822184713-fc5400e7fe10?w=800&q=80',
          rating: 4.6,
          category: 'Maki',
          ingredients: ['Shrimp Tempura', 'Spicy Mayo', 'Cucumber', 'Lettuce'],
          description: 'Spicy shrimp tempura roll.',
        ),

        // 7. Rainbow Roll
        ProductModel(
          id: 'rainbow-roll-007',
          name: 'Rainbow Roll',
          price: 28.00,
          imagePath: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&q=80',
          rating: 4.9,
          category: 'Special',
          ingredients: ['Tuna', 'Salmon', 'Avocado', 'Crab'],
          description: 'Colorful assorted fish over California roll.',
        ),

        // 8. Philadelphia Roll
        ProductModel(
          id: 'philadelphia-roll-008',
          name: 'Philadelphia Roll',
          price: 22.00,
          imagePath: 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=800&q=80',
          rating: 4.7,
          category: 'Maki',
          ingredients: ['Salmon', 'Cream Cheese', 'Cucumber'],
          description: 'Classic salmon and cream cheese combination.',
        ),

        // 9. Tuna Nigiri
        ProductModel(
          id: 'tuna-nigiri-009',
          name: 'Tuna Nigiri',
          price: 24.00,
          imagePath: 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=800&q=80',
          rating: 4.8,
          category: 'Nigiri',
          ingredients: ['Premium Tuna', 'Sushi Rice'],
          description: 'Premium tuna over seasoned rice.',
        ),

        // 10. Volcano Roll
        ProductModel(
          id: 'volcano-roll-010',
          name: 'Volcano Roll',
          price: 26.00,
          imagePath: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800&q=80',
          rating: 4.9,
          category: 'Special',
          ingredients: ['Spicy Tuna', 'Avocado', 'Jalapeño', 'Sriracha'],
          description: 'Hot and spicy roll with kick.',
        ),

        // 11. Cucumber Roll
        ProductModel(
          id: 'cucumber-roll-011',
          name: 'Cucumber Roll',
          price: 12.00,
          imagePath: 'https://images.unsplash.com/photo-1580822184713-fc5400e7fe10?w=800&q=80',
          rating: 4.3,
          category: 'Maki',
          ingredients: ['Cucumber', 'Sesame Seeds'],
          description: 'Simple and refreshing cucumber roll.',
        ),

        // 12. Avocado Roll
        ProductModel(
          id: 'avocado-roll-012',
          name: 'Avocado Roll',
          price: 13.00,
          imagePath: 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=800&q=80',
          rating: 4.4,
          category: 'Maki',
          ingredients: ['Avocado', 'Sesame Seeds'],
          description: 'Creamy avocado wrapped in rice.',
        ),

        // 13. Ebi Nigiri (Shrimp)
        ProductModel(
          id: 'ebi-nigiri-013',
          name: 'Ebi Nigiri',
          price: 20.00,
          imagePath: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800&q=80',
          rating: 4.6,
          category: 'Nigiri',
          ingredients: ['Cooked Shrimp', 'Sushi Rice'],
          description: 'Sweet cooked shrimp over rice.',
        ),

        // 14. Unagi Roll (Eel)
        ProductModel(
          id: 'unagi-roll-014',
          name: 'Unagi Roll',
          price: 24.00,
          imagePath: 'https://images.unsplash.com/photo-1563612116625-3012372fccce?w=800&q=80',
          rating: 4.8,
          category: 'Special',
          ingredients: ['Grilled Eel', 'Cucumber', 'Teriyaki Sauce'],
          description: 'Sweet grilled eel with teriyaki glaze.',
        ),

        // 15. Hamachi Nigiri (Yellowtail)
        ProductModel(
          id: 'hamachi-nigiri-015',
          name: 'Hamachi Nigiri',
          price: 25.00,
          imagePath: 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=800&q=80',
          rating: 4.9,
          category: 'Nigiri',
          ingredients: ['Yellowtail', 'Sushi Rice', 'Scallion'],
          description: 'Buttery yellowtail sushi.',
        ),

        // 16. Tekka Maki (Tuna Roll)
        ProductModel(
          id: 'tekka-maki-016',
          name: 'Tekka Maki',
          price: 16.00,
          imagePath: 'https://images.unsplash.com/photo-1580822184713-fc5400e7fe10?w=800&q=80',
          rating: 4.5,
          category: 'Maki',
          ingredients: ['Fresh Tuna', 'Nori', 'Sushi Rice'],
          description: 'Classic tuna roll.',
        ),
      ];

      // Add each product to Firestore
      int successCount = 0;
      for (var product in sushiProducts) {
        await _firestore.collection('products').doc(product.id).set(product.toMap());
        successCount++;
        print('✅ Added: ${product.name} (${product.category}) - ₺${product.price}');
      }

      print('🎉 Successfully seeded $successCount products!');
      print('💡 TIP: You can now remove/comment out the seeding call in main.dart');
    } catch (e) {
      print('❌ Error seeding database: $e');
      rethrow;
    }
  }

  /// Optional: Clear all products (use with caution!)
  static Future<void> clearProducts() async {
    print('🗑️  Clearing all products...');
    try {
      final snapshot = await _firestore.collection('products').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ All products cleared');
    } catch (e) {
      print('❌ Error clearing products: $e');
      rethrow;
    }
  }
}
