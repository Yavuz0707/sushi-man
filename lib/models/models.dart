import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// PRODUCT MODEL
// ============================================================================
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final double rating;
  final String category; // 'Nigiri', 'Maki', 'Sashimi', 'Sets'
  final String description;
  final List<String> ingredients;
  final bool isPopular;
  final int soldCount; // Track how many times this product was sold

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.rating = 4.5,
    required this.category,
    this.description = '',
    this.ingredients = const [],
    this.isPopular = false,
    this.soldCount = 0,
  });

  // Convert ProductModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'isPopular': isPopular,
      'soldCount': soldCount,
    };
  }

  // Create ProductModel from Firestore Document
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imagePath: map['imagePath'] ?? '',
      rating: (map['rating'] ?? 4.5).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      soldCount: map['soldCount'] ?? 0,
      isPopular: map['isPopular'] ?? false,
    );
  }

  // Create ProductModel from Firestore DocumentSnapshot
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data);
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? imagePath,
    double? rating,
    String? category,
    String? description,
    List<String>? ingredients,
    bool? isPopular,
    int? soldCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      isPopular: isPopular ?? this.isPopular,
      soldCount: soldCount ?? this.soldCount,
    );
  }
}

// ============================================================================
// CART ITEM MODEL
// ============================================================================
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imagePath;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.imagePath,
  });

  // Total price for this cart item
  double get totalPrice => price * quantity;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }

  // Create from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imagePath: map['imagePath'] ?? '',
    );
  }

  // Create CartItem from ProductModel
  factory CartItem.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItem(
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: quantity,
      imagePath: product.imagePath,
    );
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imagePath,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

// ============================================================================
// ORDER MODEL
// ============================================================================
class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // 'Preparing', 'On Way', 'Delivered'
  final DateTime date;
  final String deliveryAddress;
  final String? userEmail;
  final String? courierName; // Name of the courier assigned
  final String? courierId; // UID of the courier assigned

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.deliveryAddress,
    this.userEmail,
    this.courierName,
    this.courierId,
  });

  // Aliases for different naming conventions
  DateTime get createdAt => date;
  double get totalPrice => totalAmount;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'date': Timestamp.fromDate(date),
      'deliveryAddress': deliveryAddress,
      'userEmail': userEmail,
      'courierName': courierName,
      'courierId': courierId,
    };
  }

  // Create from Firestore Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Preparing',
      date: (map['date'] as Timestamp).toDate(),
      courierName: map['courierName'],
      courierId: map['courierId'],
      deliveryAddress: map['deliveryAddress'] ?? '',
      userEmail: map['userEmail'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data);
  }

  // Status helper methods
  bool get isPreparing => status == 'Preparing';
  bool get isOnWay => status == 'On Way';
  bool get isDelivered => status == 'Delivered';

  // Get status step for UI progress indicator (0-3)
  int get statusStep {
    switch (status) {
      case 'Preparing':
        return 1;
      case 'On Way':
        return 2;
      case 'Delivered':
        return 3;
      default:
        return 0;
    }
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    String? status,
    DateTime? date,
    String? deliveryAddress,
    String? userEmail,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      date: date ?? this.date,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

// ============================================================================
// USER MODEL (Optional - for storing user preferences)
// ============================================================================
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isAdmin;
  final String role; // 'admin' or 'user' or 'staff'
  final List<String> favorites; // Product IDs
  final String? defaultAddress;
  final int points; // Loyalty Points (SushiPoints)
  final bool isOnline; // For staff tracking

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isAdmin = false,
    this.role = 'user',
    this.favorites = const [],
    this.defaultAddress,
    this.points = 0,
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'role': role,
      'favorites': favorites,
      'defaultAddress': defaultAddress,
      'points': points,
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      isAdmin: map['isAdmin'] ?? false,
      role: map['role'] ?? 'user',
      favorites: List<String>.from(map['favorites'] ?? []),
      defaultAddress: map['defaultAddress'],
      isOnline: map['isOnline'] ?? false,
      points: map['points'] ?? 0,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isAdmin,
    String? role,
    List<String>? favorites,
    String? defaultAddress,
    int? points,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      points: points ?? this.points,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

// ============================================================================
// ADDRESS MODEL
// ============================================================================
class AddressModel {
  final String id;
  final String title;
  final String fullAddress;

  AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
    };
  }

  // Create from Map
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
    );
  }

  // Create from Firestore Document
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromMap(data);
  }

  AddressModel copyWith({
    String? id,
    String? title,
    String? fullAddress,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }
}
