import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sipariş Takibi',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<OrderModel?>(
        stream: databaseService.getOrderStream(orderId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF880E4F),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // No data state
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: Colors.white38,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sipariş bulunamadı',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ============================================
                // ORDER STATUS STEPPER
                // ============================================
                _buildStatusStepper(order),

                const SizedBox(height: 32),

                // ============================================
                // ORDER INFO CARD
                // ============================================
                _buildOrderInfoCard(order),

                const SizedBox(height: 16),

                // ============================================
                // DELIVERY ADDRESS CARD
                // ============================================
                _buildAddressCard(order),

                const SizedBox(height: 16),

                // ============================================
                // ORDER ITEMS LIST
                // ============================================
                _buildOrderItemsList(order),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // STATUS STEPPER WIDGET
  // ============================================
  Widget _buildStatusStepper(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status title
          Text(
            _getStatusTitle(order.status),
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(order.status),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(order.status),
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStep(
                icon: Icons.receipt_long,
                label: 'Alındı',
                isActive: order.statusStep >= 0,
                isCompleted: order.statusStep > 0,
              ),
              _buildStepConnector(isActive: order.statusStep > 0),
              _buildStep(
                icon: Icons.restaurant_menu,
                label: 'Hazırlanıyor',
                isActive: order.statusStep >= 1,
                isCompleted: order.statusStep > 1,
              ),
              _buildStepConnector(isActive: order.statusStep > 1),
              _buildStep(
                icon: Icons.delivery_dining,
                label: 'Yolda',
                isActive: order.statusStep >= 2,
                isCompleted: order.statusStep > 2,
              ),
              _buildStepConnector(isActive: order.statusStep > 2),
              _buildStep(
                icon: Icons.check_circle,
                label: 'Teslim Edildi',
                isActive: order.statusStep >= 3,
                isCompleted: order.statusStep >= 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF880E4F)
                : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF404040),
              width: 3,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF880E4F).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.white38,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF880E4F)
              : const Color(0xFF404040),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ============================================
  // ORDER INFO CARD
  // ============================================
  Widget _buildOrderInfoCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF880E4F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sipariş Bilgileri',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Sipariş No:', order.id.substring(0, 8).toUpperCase()),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tarih:',
            DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(order.createdAt),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tutar:',
            '${order.totalPrice.toStringAsFixed(0)} ₺',
            valueColor: const Color(0xFF880E4F),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  // ============================================
  // ADDRESS CARD
  // ============================================
  Widget _buildAddressCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF880E4F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Teslimat Adresi',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.deliveryAddress,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ORDER ITEMS LIST
  // ============================================
  Widget _buildOrderItemsList(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF880E4F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sipariş İçeriği',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == order.items.length - 1;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF880E4F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} ₺',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }).toList(),

          const SizedBox(height: 16),
          Divider(
            color: Colors.white.withOpacity(0.2),
            thickness: 2,
          ),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${order.totalPrice.toStringAsFixed(0)} ₺',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF880E4F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================
  String _getStatusTitle(String status) {
    switch (status) {
      case 'received':
        return 'Sipariş Alındı';
      case 'preparing':
        return 'Hazırlanıyor';
      case 'on_way':
        return 'Yolda';
      case 'delivered':
        return 'Teslim Edildi';
      default:
        return 'Sipariş Durumu';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'received':
        return 'Siparişiniz alındı ve işleme başlandı';
      case 'preparing':
        return 'Siparişiniz özenle hazırlanıyor';
      case 'on_way':
        return 'Siparişiniz yola çıktı, kısa sürede kapınızda!';
      case 'delivered':
        return 'Siparişiniz başarıyla teslim edildi. Afiyet olsun!';
      default:
        return 'Sipariş durumunuz güncelleniyor';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'received':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFFFF9800); // Orange
      case 'on_way':
        return const Color(0xFFD4AF37); // Gold
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      default:
        return Colors.white70;
    }
  }
}
