import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/models.dart';
import '../models/log_model.dart';

// ============================================================================
// DATABASE SERVICE - Firestore Operations
// ============================================================================
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _productsCollection => _firestore.collection('products');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _auditLogsCollection => _firestore.collection('audit_logs');

  // ============================================================================
  // PRODUCTS OPERATIONS
  // ============================================================================

  /// Get all products as a Stream (Real-time updates)
  Stream<List<ProductModel>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get products by category as a Stream
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    if (category.toLowerCase() == 'all' || category.isEmpty) {
      return getProducts();
    }

    return _productsCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get popular products as a Stream
  Stream<List<ProductModel>> getPopularProducts() {
    return _productsCollection
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Ürün bulunamadı: $e';
    }
  }

  /// Add new product (Admin only)
  Future<void> addProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).set(product.toMap());
    } catch (e) {
      throw 'Ürün eklenemedi: $e';
    }
  }

  /// Update product (Admin only)
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      throw 'Ürün güncellenemedi: $e';
    }
  }

  // ============================================================================
  // ORDERS OPERATIONS
  // ============================================================================

  /// Place a new order
  Future<void> placeOrder(OrderModel order) async {
    try {
      print('📦 Sipariş kaydediliyor: ${order.id}');
      print('   Kullanıcı: ${order.userId}');
      print('   Tutar: ₺${order.totalAmount}');
      print('   Durum: ${order.status}');
      await _ordersCollection.doc(order.id).set(order.toMap());
      print('✅ Sipariş başarıyla kaydedildi!');
    } catch (e) {
      throw 'Sipariş oluşturulamadı: $e';
    }
  }

  /// Get all orders as a Stream (Admin only - for admin panel)
  Stream<List<OrderModel>> getAllOrders() {
    return _ordersCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get user's orders as a Stream
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get single order by ID as a Stream (for live tracking)
  Stream<OrderModel?> getOrderStream(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Get single order by ID (one-time fetch)
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Sipariş bulunamadı: $e';
    }
  }

  /// Update order status (Admin only)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Sipariş durumu güncellenemedi: $e';
    }
  }

  /// Delete order (Admin only)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
    } catch (e) {
      throw 'Sipariş silinemedi: $e';
    }
  }

  /// Get active orders (not delivered) for user
  Stream<List<OrderModel>> getUserActiveOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['Preparing', 'On Way'])
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get completed orders (delivered) for user
  Stream<List<OrderModel>> getUserCompletedOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Delivered')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // USER OPERATIONS (kept for backward compatibility)
  // ============================================================================

  // Create user document
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Kullanıcı oluşturulurken hata: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Kullanıcı getirilirken hata: $e';
    }
  }

  // Alias for consistency with AuthService
  Future<UserModel?> getUserData(String uid) async {
    return getUser(uid);
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
    } catch (e) {
      throw 'Kullanıcı güncellenemedi: $e';
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw 'Kullanıcı güncellenirken hata: $e';
    }
  }

  // Toggle favorite product
  Future<void> toggleFavorite(String uid, String productId) async {
    try {
      final userDoc = await _usersCollection.doc(uid).get();
      if (userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc);
        List<String> favorites = List.from(user.favorites);
        
        if (favorites.contains(productId)) {
          favorites.remove(productId);
        } else {
          favorites.add(productId);
        }
        
        await updateUser(uid, {'favorites': favorites});
      }
    } catch (e) {
      throw 'Favori güncellenirken hata: $e';
    }
  }

  // Add address - Removed as AddressModel is not defined

  // ============ PRODUCT METHODS ============

  // Create product
  Future<void> createProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).set(product.toMap());
    } catch (e) {
      throw 'Ürün oluşturulurken hata: $e';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      print('🗑️ Ürün siliniyor: $productId');
      await _productsCollection.doc(productId).delete();
      print('✅ Ürün başarıyla silindi!');
    } catch (e) {
      print('❌ Ürün silme hatası: $e');
      throw 'Ürün silinirken hata: $e';
    }
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _productsCollection.get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Ürünler getirilirken hata: $e';
    }
  }

  // Get products stream
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Ürün getirilirken hata: $e';
    }
  }

  // Duplicate methods removed - already defined above

  // ============ ORDER METHODS ============

  // Create order
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add(order.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw 'Sipariş oluşturulurken hata: $e';
    }
  }

  // Get user orders stream
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all orders stream (for admin)
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _ordersCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // ADDRESS OPERATIONS (Sub-collection under users/{uid}/addresses)
  // ============================================================================

  /// Get user addresses as a Stream
  Stream<List<AddressModel>> getUserAddresses(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Add a new address for a user
  Future<void> addAddress(String userId, AddressModel address) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap());
    } catch (e) {
      throw 'Adres eklenirken hata: $e';
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw 'Adres silinirken hata: $e';
    }
  }

  // ============================================================================
  // FIREBASE STORAGE - IMAGE UPLOAD
  // ============================================================================

  /// Upload image to Firebase Storage and return download URL
  /// Handles both Web (Uint8List) and Mobile (File) platforms
  /// @param file - The image file to upload (Mobile only)
  /// @param webImage - The image bytes to upload (Web only)
  /// @param fileName - Optional custom filename
  /// @return Download URL of the uploaded image
  Future<String?> uploadImage({
    File? file,
    Uint8List? webImage,
    String? fileName,
  }) async {
    try {
      // Validate input
      if (!kIsWeb && file == null) {
        print('❌ Error: File required for mobile platforms');
        return null;
      }
      if (kIsWeb && webImage == null) {
        print('❌ Error: Web image bytes required for web platform');
        return null;
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String uploadFileName = fileName ?? 
          (kIsWeb 
              ? 'products/${timestamp}_web_image.jpg' 
              : 'products/${timestamp}_${file!.path.split('/').last}');

      // Create reference to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(uploadFileName);

      // Upload based on platform
      final UploadTask uploadTask;
      if (kIsWeb) {
        // Web: Use putData with bytes
        uploadTask = ref.putData(
          webImage!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Mobile: Use putFile
        uploadTask = ref.putFile(file!);
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Legacy method for backward compatibility
  /// @deprecated Use uploadImage with named parameters instead
  Future<String?> uploadImageFile(File file) async {
    return uploadImage(file: file);
  }

  // ============================================================================
  // AUDIT LOG OPERATIONS
  // ============================================================================

  /// Log admin activity to audit_logs collection
  Future<void> logActivity(String action, String details) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get admin name from users collection
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      final adminName = userDoc.exists 
          ? (userDoc.data() as Map<String, dynamic>)['email'] ?? 'Unknown Admin'
          : 'Unknown Admin';

      final log = AuditLog(
        id: _firestore.collection('audit_logs').doc().id,
        action: action,
        adminName: adminName,
        details: details,
        timestamp: DateTime.now(),
      );

      await _auditLogsCollection.doc(log.id).set(log.toMap());
    } catch (e) {
      print('❌ Error logging activity: $e');
    }
  }

  /// Get audit logs stream (most recent first)
  Stream<List<AuditLog>> getAuditLogs({int limit = 50}) {
    return _auditLogsCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AuditLog.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // ANALYTICS & STATISTICS
  // ============================================================================

  /// Increment product sold count
  Future<void> incrementProductSoldCount(String productId, int quantity) async {
    try {
      await _productsCollection.doc(productId).update({
        'soldCount': FieldValue.increment(quantity),
      });
    } catch (e) {
      print('❌ Error incrementing sold count: $e');
    }
  }

  /// Get top selling products
  Stream<List<ProductModel>> getTopSellingProducts({int limit = 10}) {
    return _productsCollection
        .orderBy('soldCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get today's orders count
  Future<int> getTodayOrdersCount() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      print('🔍 Bugünkü siparişler sorgulanıyor: ${startOfDay.toString()}');
      
      final snapshot = await _ordersCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      
      print('✅ Bugünkü sipariş sayısı: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting today\'s orders: $e');
      return 0;
    }
  }

  /// Get today's revenue
  Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      print('🔍 Bugünkü ciro sorgulanıyor: ${startOfDay.toString()}');
      
      final snapshot = await _ordersCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      
      double revenue = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['totalAmount'] ?? 0).toDouble();
        revenue += amount;
        print('  📦 Sipariş: ${doc.id} - Tutar: ₺$amount');
      }
      
      print('✅ Bugünkü toplam ciro: ₺$revenue');
      return revenue;
    } catch (e) {
      print('❌ Error getting today\'s revenue: $e');
      return 0;
    }
  }

  /// Get total orders count (all time)
  Future<int> getTotalOrdersCount() async {
    try {
      final snapshot = await _ordersCollection.get();
      print('✅ Toplam sipariş sayısı: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting total orders: $e');
      return 0;
    }
  }

  /// Get total revenue (all time)
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _ordersCollection.get();
      
      double revenue = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        revenue += (data['totalAmount'] ?? 0).toDouble();
      }
      
      print('✅ Toplam ciro: ₺$revenue');
      return revenue;
    } catch (e) {
      print('❌ Error getting total revenue: $e');
      return 0;
    }
  }

  // ============================================================================
  // STAFF OPERATIONS
  // ============================================================================

  /// Get available staff (users with role 'user' or 'staff')
  Stream<List<UserModel>> getAvailableStaff() {
    return _usersCollection
        .where('role', whereIn: ['user', 'staff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Assign courier to order
  Future<void> assignCourierToOrder(
    String orderId,
    String courierId,
    String courierName,
  ) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'courierId': courierId,
        'courierName': courierName,
        'status': 'On Way',
      });

      await logActivity(
        'Courier Assigned',
        'Order #${orderId.substring(0, 8)} assigned to $courierName',
      );
    } catch (e) {
      print('❌ Error assigning courier: $e');
      throw 'Kurye atama hatası: $e';
    }
  }

  /// Get courier delivery statistics
  Future<Map<String, int>> getCourierDeliveryStats() async {
    try {
      final snapshot = await _ordersCollection
          .where('status', isEqualTo: 'Delivered')
          .get();
      
      final Map<String, int> stats = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final courierName = data['courierName'] as String?;
        if (courierName != null && courierName.isNotEmpty) {
          stats[courierName] = (stats[courierName] ?? 0) + 1;
        }
      }
      
      return stats;
    } catch (e) {
      print('❌ Error getting courier stats: $e');
      return {};
    }
  }
}
