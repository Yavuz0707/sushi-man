import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/log_model.dart';

/// Seeds test data for Admin panel - Orders and Audit Logs
class AdminDataSeeder {
  static final _firestore = FirebaseFirestore.instance;
  static final _uuid = const Uuid();

  /// Seed sample orders with different statuses
  static Future<void> seedOrders() async {
    print('📦 Admin veri ekleme başlatılıyor...');

    try {
      // Get a test user ID (you can change this to any existing user ID)
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      if (usersSnapshot.docs.isEmpty) {
        print('❌ Kullanıcı bulunamadı! Önce kullanıcı oluşturun.');
        return;
      }
      final testUserId = usersSnapshot.docs.first.id;
      final testUserEmail = usersSnapshot.docs.first.data()['email'] ?? 'test@example.com';

      // Get some products
      final productsSnapshot = await _firestore.collection('products').limit(5).get();
      if (productsSnapshot.docs.isEmpty) {
        print('❌ Ürün bulunamadı! Önce ürün ekleyin.');
        return;
      }

      final products = productsSnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();

      // Create orders with different statuses and dates
      final statuses = ['Preparing', 'On Way', 'Delivered'];
      final addresses = [
        'Atatürk Cad. No:45 Kadıköy/İstanbul',
        'Cumhuriyet Mah. 123 Sok. No:7 Beşiktaş/İstanbul',
        'Bağdat Cad. No:234 Maltepe/İstanbul',
        'İstiklal Cad. No:156 Beyoğlu/İstanbul',
        'Nispetiye Cad. No:89 Levent/İstanbul',
      ];

      int orderCount = 0;

      // Create 15 orders with varying dates and statuses
      for (int i = 0; i < 15; i++) {
        final orderId = _uuid.v4();
        final status = statuses[i % 3];
        final address = addresses[i % 5];
        
        // Create orders from last 7 days
        final daysAgo = (i % 7);
        final orderDate = DateTime.now().subtract(Duration(days: daysAgo, hours: i % 24));

        // Create random cart items
        final itemCount = (i % 3) + 1;
        final items = <CartItem>[];
        double totalAmount = 0;

        for (int j = 0; j < itemCount; j++) {
          final product = products[j % products.length];
          final quantity = (j % 3) + 1;
          final item = CartItem(
            id: product.id,
            name: product.name,
            price: product.price,
            quantity: quantity,
            imagePath: product.imagePath,
          );
          items.add(item);
          totalAmount += item.totalPrice;
        }

        // Add delivery fee
        totalAmount += 15.0;

        final order = OrderModel(
          id: orderId,
          userId: testUserId,
          userEmail: testUserEmail,
          items: items,
          totalAmount: totalAmount,
          status: status,
          date: orderDate,
          deliveryAddress: address,
        );

        await _firestore.collection('orders').doc(orderId).set(order.toMap());
        orderCount++;

        print('✅ Sipariş oluşturuldu: $orderId - Status: $status - Tarih: ${orderDate.day}/${orderDate.month}');
      }

      print('🎉 $orderCount sipariş başarıyla oluşturuldu!');

      // Now seed audit logs
      await seedAuditLogs(testUserId, testUserEmail);

    } catch (e) {
      print('❌ Sipariş oluşturma hatası: $e');
    }
  }

  /// Seed sample audit logs
  static Future<void> seedAuditLogs(String userId, String userEmail) async {
    print('\n📝 İşlem kayıtları ekleniyor...');

    try {
      final actions = [
        {'action': 'product_added', 'details': 'Yeni ürün eklendi: Salmon Nigiri'},
        {'action': 'product_updated', 'details': 'Ürün güncellendi: Tuna Sashimi fiyatı değiştirildi'},
        {'action': 'product_deleted', 'details': 'Ürün silindi: Old Product'},
        {'action': 'order_status_changed', 'details': 'Sipariş durumu güncellendi: Preparing -> On Way'},
        {'action': 'order_status_changed', 'details': 'Sipariş durumu güncellendi: On Way -> Delivered'},
        {'action': 'user_login', 'details': 'Admin paneline giriş yapıldı'},
        {'action': 'product_added', 'details': 'Yeni ürün eklendi: Dragon Roll Set'},
        {'action': 'order_cancelled', 'details': 'Sipariş iptal edildi'},
        {'action': 'product_updated', 'details': 'Ürün stok durumu güncellendi'},
        {'action': 'settings_changed', 'details': 'Sistem ayarları güncellendi'},
      ];

      int logCount = 0;

      for (int i = 0; i < actions.length; i++) {
        final logId = _uuid.v4();
        final action = actions[i];
        
        // Create logs from last 5 days
        final daysAgo = (i % 5);
        final logDate = DateTime.now().subtract(Duration(days: daysAgo, hours: i % 12));

        final log = AuditLog(
          id: logId,
          action: action['action']!,
          adminName: userEmail,
          details: action['details']!,
          timestamp: logDate,
        );

        await _firestore.collection('audit_logs').doc(logId).set(log.toMap());
        logCount++;

        print('✅ Log oluşturuldu: ${action['action']} - ${logDate.day}/${logDate.month}');
      }

      print('🎉 $logCount işlem kaydı başarıyla oluşturuldu!');

    } catch (e) {
      print('❌ Log oluşturma hatası: $e');
    }
  }

  /// Seed everything at once
  static Future<void> seedAll() async {
    print('\n🌱 Tüm admin verileri ekleniyor...\n');
    await seedOrders();
    print('\n✨ Admin veri ekleme tamamlandı!\n');
  }
}
