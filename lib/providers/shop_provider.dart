import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/database_service.dart';

// ============================================================================
// SHOP PROVIDER - State Management for Products, Cart, and Favorites
// ============================================================================
class ShopProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Products
  List<ProductModel> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Cart
  List<CartItem> _cartItems = [];

  // Favorites
  List<String> _favorites = [];

  // User ID
  String? _userId;

  // Coupon System
  String? _appliedCouponCode;
  double _discountPercentage = 0.0;

  // Hardcoded Coupons
  final Map<String, double> _coupons = {
    'SUSHI10': 10.0,
    'MASTER20': 20.0,
  };

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<ProductModel> get allProducts => _allProducts;
  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get favorites => _favorites;

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => cartTotal > 0 ? 15.0 : 0.0;
  
  // Coupon discount amount
  double get discountAmount => cartTotal * (_discountPercentage / 100);
  
  // Grand total with discount
  double get grandTotal => (cartTotal - discountAmount) + deliveryFee;
  
  String? get appliedCouponCode => _appliedCouponCode;
  double get discountPercentage => _discountPercentage;

  // Backward compatibility
  List<CartItem> get cart => _cartItems;
  int get cartCount => cartItemCount;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void setUserId(String? userId) {
    _userId = userId;
    notifyListeners();
  }

  // ============================================================================
  // FILTERED PRODUCTS
  // ============================================================================

  // Filtered products based on category and search
  List<ProductModel> get filteredProducts {
    var products = _allProducts;

    // Filter by category
    if (_selectedCategory != 'All' && _selectedCategory != 'Tümü') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query (name or ingredients)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final descMatch = p.description.toLowerCase().contains(query);
        final ingredientMatch = p.ingredients.any(
          (ingredient) => ingredient.toLowerCase().contains(query),
        );
        return nameMatch || descMatch || ingredientMatch;
      }).toList();
    }

    return products;
  }

  // ============================================================================
  // PRODUCTS METHODS
  // ============================================================================

  // Popular products
  List<ProductModel> get popularProducts {
    return _allProducts.where((p) => p.isPopular).toList();
  }

  // Get products Stream
  Stream<List<ProductModel>> getProductsStream() {
    return _databaseService.getProducts();
  }

  // Load products and set them
  void loadProducts(List<ProductModel> products) {
    _allProducts = products;
    _isLoading = false;
    notifyListeners();
  }

  // Set loading state
  void setLoadingProducts(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize and load products (legacy method)
  Future<void> initializeProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final products = await _databaseService.getProducts().first;
      _allProducts = products;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Listen to products stream
  void listenToProducts() {
    _databaseService.getProducts().listen((products) {
      _allProducts = products;
      notifyListeners();
    });
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filter by category (alternative naming)
  void filterByCategory(String category) {
    setCategory(category);
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Search products (alternative naming)
  void searchProducts(String query) {
    setSearchQuery(query);
  }

  // Reset filters
  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  // Get available categories
  List<String> get categories {
    final cats = _allProducts.map((p) => p.category).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }

  // Get product by ID
  ProductModel? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // CART METHODS
  // ============================================================================

  // Add to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem.fromProduct(product, quantity: quantity));
    }

    notifyListeners();
  }

  // Remove from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  // Update cart item quantity
  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere(
      (item) => item.id == productId,
    );

    if (index >= 0) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  // Increment cart item
  void incrementCartItem(String productId) {
    final index = _cartItems.indexWhere(
      (item) => item.id == productId,
    );

    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  // Decrement cart item
  void decrementCartItem(String productId) {
    final index = _cartItems.indexWhere(
      (item) => item.id == productId,
    );

    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.id == productId);
  }

  // Get cart item quantity
  int getCartItemQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.id == productId,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        quantity: 0,
        imagePath: '',
      ),
    );
    return item.quantity;
  }

  // ============================================================================
  // FAVORITES METHODS
  // ============================================================================

  // Set favorites list
  void setFavorites(List<String> favorites) {
    _favorites = favorites;
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String productId) async {
    if (_userId == null) return;

    try {
      await _databaseService.toggleFavorite(_userId!, productId);
      
      if (_favorites.contains(productId)) {
        _favorites.remove(productId);
      } else {
        _favorites.add(productId);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
      rethrow;
    }
  }

  // Check if product is favorite
  bool isFavorite(String productId) {
    return _favorites.contains(productId);
  }

  // Get favorite products
  List<ProductModel> get favoriteProducts {
    return _allProducts.where((product) => 
        _favorites.contains(product.id)).toList();
  }

  // ============================================================================
  // ORDER METHODS
  // ============================================================================

  // Place order
  Future<OrderModel> placeOrder({
    required String userId,
    required String deliveryAddress,
    String? userEmail,
  }) async {
    if (_cartItems.isEmpty) {
      throw 'Sepetiniz boş!';
    }

    try {
      _isLoading = true;
      notifyListeners();

      final order = OrderModel(
        id: _uuid.v4(),
        userId: userId,
        items: List.from(_cartItems),
        totalAmount: grandTotal,
        status: 'Preparing',
        date: DateTime.now(),
        deliveryAddress: deliveryAddress,
        userEmail: userEmail,
      );

      await _databaseService.placeOrder(order);
      
      // Increment sold count for each product
      for (var item in _cartItems) {
        await _databaseService.incrementProductSoldCount(item.id, item.quantity);
      }
      
      // Award loyalty points (10% of total)
      if (_userId != null) {
        await _awardLoyaltyPoints(_userId!, order.totalAmount);
      }
      
      clearCart();

      _isLoading = false;
      notifyListeners();
      
      return order;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================================
  // COUPON SYSTEM
  // ============================================================================
  
  /// Apply coupon code
  bool applyCoupon(String code) {
    final upperCode = code.toUpperCase().trim();
    
    if (_coupons.containsKey(upperCode)) {
      _appliedCouponCode = upperCode;
      _discountPercentage = _coupons[upperCode]!;
      notifyListeners();
      return true;
    }
    
    return false;
  }
  
  /// Remove applied coupon
  void removeCoupon() {
    _appliedCouponCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  // ============================================================================
  // LOYALTY POINTS SYSTEM
  // ============================================================================
  
  /// Award loyalty points (10% of order total)
  Future<void> _awardLoyaltyPoints(String userId, double orderTotal) async {
    try {
      final pointsToAdd = (orderTotal * 0.10).round(); // 10% of total as points
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final currentPoints = userDoc.data()?['points'] ?? 0;
        await _firestore.collection('users').doc(userId).update({
          'points': currentPoints + pointsToAdd,
        });
        
        print('✅ Awarded $pointsToAdd points to user $userId');
      }
    } catch (e) {
      print('❌ Error awarding points: $e');
    }
  }
  
  /// Get user's current points
  Future<int> getUserPoints(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['points'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting user points: $e');
      return 0;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') return _allProducts;
    return _allProducts.where((product) => 
        product.category == category).toList();
  }

  // Add new product (Admin)
  Future<bool> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.createProduct(product);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update product (Admin)
  Future<bool> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.updateProduct(product);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
