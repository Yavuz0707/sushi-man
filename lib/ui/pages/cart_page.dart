import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/shop_provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

// ============================================================================
// CART PAGE - List of Items, Swipe to Delete, Checkout, Coupons, Points
// ============================================================================
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPoints() async {
    final authService = AuthService();
    final shopProvider = context.read<ShopProvider>();
    
    if (authService.currentUserId != null) {
      final points = await shopProvider.getUserPoints(authService.currentUserId!);
      setState(() {
        _userPoints = points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sepetim',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF880E4F).withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: shopProvider.cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sepetiniz boş',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // ============================================
                  // CART ITEMS LIST (Swipe to Delete)
                  // ============================================
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shopProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = shopProvider.cartItems[index];
                        return Dismissible(
                          key: Key(cartItem.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          onDismissed: (direction) {
                            shopProvider.removeFromCart(cartItem.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${cartItem.name} sepetten çıkarıldı'),
                                backgroundColor: Colors.red.shade700,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Product Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: cartItem.imagePath.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              cartItem.imagePath,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.restaurant_menu,
                                                  color: Color(0xFFD4AF37),
                                                  size: 40,
                                                );
                                              },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.restaurant_menu,
                                            color: Color(0xFFD4AF37),
                                            size: 40,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.name,
                                          style: GoogleFonts.dmSerifDisplay(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${cartItem.price.toStringAsFixed(0)} ₺',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color: const Color(0xFFD4AF37),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Quantity Controls
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                shopProvider.decrementCartItem(cartItem.id);
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Color(0xFF880E4F),
                                                size: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '${cartItem.quantity}',
                                              style: GoogleFonts.lato(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              onPressed: () {
                                                shopProvider.incrementCartItem(cartItem.id);
                                              },
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: Color(0xFF880E4F),
                                                size: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Total Price
                                  Text(
                                    '${cartItem.totalPrice.toStringAsFixed(0)} ₺',
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF880E4F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ============================================
                  // CHECKOUT SUMMARY
                  // ============================================
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          // ============================================
                          // LOYALTY POINTS DISPLAY
                          // ============================================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFD4AF37).withOpacity(0.2),
                                  const Color(0xFF880E4F).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SushiPoints',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Colors.white60,
                                      ),
                                    ),
                                    Text(
                                      '$_userPoints puan',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '+${(shopProvider.grandTotal * 0.10).round()} puan kazanacaksınız',
                                    style: GoogleFonts.lato(
                                      fontSize: 11,
                                      color: const Color(0xFFD4AF37),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ============================================
                          // COUPON INPUT
                          // ============================================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_offer,
                                      color: Color(0xFFD4AF37),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Promo Kodu',
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (shopProvider.appliedCouponCode != null) ...[
                                  // Applied Coupon Display
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                shopProvider.appliedCouponCode!,
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Text(
                                                '${shopProvider.discountPercentage.toStringAsFixed(0)}% indirim uygulandı',
                                                style: GoogleFonts.lato(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            shopProvider.removeCoupon();
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white70,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // Coupon Input Field
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _couponController,
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'SUSHI10, MASTER20',
                                            hintStyle: GoogleFonts.lato(
                                              color: Colors.white38,
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF2A2A2A),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          textCapitalization: TextCapitalization.characters,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          final code = _couponController.text.trim();
                                          if (code.isEmpty) return;
                                          
                                          final success = shopProvider.applyCoupon(code);
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? '✅ Kupon uygulandı!'
                                                    : '❌ Geçersiz kupon kodu',
                                              ),
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red.shade700,
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                          
                                          if (success) {
                                            _couponController.clear();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF880E4F),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Uygula',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ara Toplam',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${shopProvider.cartTotal.toStringAsFixed(0)} ₺',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Discount (if applied)
                          if (shopProvider.appliedCouponCode != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'İndirim (${shopProvider.discountPercentage.toStringAsFixed(0)}%)',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '-${shopProvider.discountAmount.toStringAsFixed(0)} ₺',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Delivery Fee
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Teslimat Ücreti',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${shopProvider.deliveryFee.toStringAsFixed(0)} ₺',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          Divider(
                            height: 32,
                            thickness: 2,
                            color: Colors.white.withOpacity(0.1),
                          ),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${shopProvider.grandTotal.toStringAsFixed(0)} ₺',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF880E4F),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ============================================
                          // CHECKOUT BUTTON
                          // ============================================
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Get current user
                                final user = authService.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Lütfen önce giriş yapınız'),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                // Show address dialog
                                _showAddressDialog(context, shopProvider, authService, user.uid, user.email);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF880E4F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_bag, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Siparişi Tamamla',
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================
  // ADDRESS DIALOG - WITH SAVED ADDRESSES
  // ============================================
  void _showAddressDialog(
    BuildContext context,
    ShopProvider shopProvider,
    AuthService authService,
    String userId,
    String? userEmail,
  ) {
    final databaseService = DatabaseService();
    AddressModel? selectedAddress;
    final manualAddressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => StreamBuilder<List<AddressModel>>(
          stream: databaseService.getUserAddresses(userId),
          builder: (context, snapshot) {
            final addresses = snapshot.data ?? [];

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF880E4F),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Teslimat Adresi',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addresses.isNotEmpty) ...[
                      Text(
                        'Kayıtlı Adreslerim',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF880E4F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Address List
                      ...addresses.map((address) {
                        final isSelected = selectedAddress?.id == address.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddress = address;
                              manualAddressController.clear();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF880E4F).withOpacity(0.3)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF880E4F)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: const Color(0xFF880E4F),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address.title,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address.fullAddress,
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                    ],
                    // Manual Address Input
                    Text(
                      addresses.isEmpty
                          ? 'Teslimat Adresi'
                          : 'Veya Yeni Adres Girin',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: manualAddressController,
                      maxLines: 3,
                      style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            selectedAddress = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Adresinizi giriniz...',
                        hintStyle: GoogleFonts.lato(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF880E4F),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF880E4F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String? deliveryAddress;

                      // Use selected address or manual input
                    if (selectedAddress != null) {
                      deliveryAddress = selectedAddress!.fullAddress;
                    } else if (manualAddressController.text.trim().isNotEmpty) {
                      deliveryAddress = manualAddressController.text.trim();
                    }

                    if (deliveryAddress == null || deliveryAddress.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Lütfen bir adres seçin veya girin'),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    // Place order
                    final order = await shopProvider.placeOrder(
                      userId: userId,
                      deliveryAddress: deliveryAddress,
                      userEmail: userEmail ?? '',
                    );

                    // Close dialog first
                    if (!context.mounted) return;
                    Navigator.of(ctx).pop();

                    // Show success message
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎉 Sipariş başarıyla oluşturuldu!'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Navigate to tracking page
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamed(
                      '/track',
                      arguments: order.id,
                    );
                  } catch (e) {
                    // Handle errors
                    if (!context.mounted) return;
                    Navigator.of(ctx).pop();
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Hata: $e'),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF880E4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Onayla',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}