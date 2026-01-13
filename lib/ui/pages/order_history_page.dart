import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';

// ============================================================================
// ORDER HISTORY PAGE - Kullanıcının geçmiş siparişleri
// ============================================================================
class OrderHistoryPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sipariş Geçmişim',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFD4AF37),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: _authService.currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${snapshot.error}',
                    style: GoogleFonts.lato(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];
          
          // Manuel olarak tarihe göre sıralama
          final sortedOrders = List<QueryDocumentSnapshot>.from(orders);
          sortedOrders.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
            final bDate = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate); // Descending order
          });

          if (sortedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Henüz sipariş vermediniz',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menüden sipariş vererek başlayabilirsiniz',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedOrders.length,
            itemBuilder: (context, index) {
              final orderDoc = sortedOrders[index];
              final order = OrderModel.fromFirestore(orderDoc);
              
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  // ============================================================================
  // BUILD ORDER CARD
  // ============================================================================
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    // Durum renkleri
    Color statusColor;
    IconData statusIcon;
    switch (order.status) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'on_way':
        statusColor = Colors.orange;
        statusIcon = Icons.delivery_dining;
        break;
      case 'preparing':
        statusColor = Colors.blue;
        statusIcon = Icons.restaurant;
        break;
      case 'pending':
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    // Tarih formatı
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    final orderDate = dateFormat.format(order.createdAt);

    // Toplam ürün sayısı
    final totalItems = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(context, order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst kısım: Tarih ve durum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tarih
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          orderDate,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // Durum badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(order.status),
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Sipariş özeti
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 18,
                      color: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalItems ürün',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('•', style: TextStyle(color: Colors.white38)),
                    const SizedBox(width: 16),
                    Text(
                      'Sipariş #${order.id.substring(0, 8)}',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Toplam fiyat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam:',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      '₺${order.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SHOW ORDER DETAILS BOTTOM SHEET
  // ============================================================================
  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Sipariş Detayları',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white12, height: 1),
            
            // Ürünler listesi
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white12,
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Row(
                    children: [
                      // Miktar badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF880E4F).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF880E4F).withOpacity(0.5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}x',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Ürün adı
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            color: const Color(0xFFFFFFDE),
                          ),
                        ),
                      ),
                      
                      // Fiyat
                      Text(
                        '₺${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Divider(color: Colors.white12, height: 1),
            
            // Teslimat bilgisi ve toplam
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teslimat adresi
                  if (order.deliveryAddress.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Toplam
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Tutar:',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '₺${order.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // GET STATUS TEXT IN TURKISH
  // ============================================================================
  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'Teslim Edildi';
      case 'on_way':
        return 'Yolda';
      case 'preparing':
        return 'Hazırlanıyor';
      case 'pending':
        return 'Beklemede';
      default:
        return status;
    }
  }
}
