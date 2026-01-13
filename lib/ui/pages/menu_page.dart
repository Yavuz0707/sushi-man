import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../providers/shop_provider.dart';
import '../../models/models.dart';
import 'food_details_page.dart';
import 'cart_page.dart';
import 'admin_page.dart';
import 'order_history_page.dart';
import 'active_orders_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

// ============================================================================
// MENU PAGE - Advanced UI with Drawer, Search, Categories, Product Grid
// ============================================================================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _searchController = TextEditingController();
  final _authService = AuthService();
  final List<String> _categories = ['All', 'Nigiri', 'Maki', 'Sashimi', 'Sets'];

  @override
  void initState() {
    super.initState();
    // Listen to products stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().listenToProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();

    return PopScope(
      canPop: false, // Geri tuşunu engelle
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Geri tuşuna basıldığında hiçbir şey yapma
      },
      child: Scaffold(
        drawer: _buildDrawer(context),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF880E4F).withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ============================================
              // APP BAR
              // ============================================
              SliverAppBar(
                floating: true,
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 4,
                title: Text(
                  'SUSHI MAN',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  // Cart Button with Badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                      ),
                      if (shopProvider.cartItemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${shopProvider.cartItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // ============================================
              // PROMO BANNER
              // ============================================
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37), // Gold
                        Color(0xFFFFD700), // Light Gold
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_offer,
                        color: Color(0xFF880E4F),
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '32% İNDİRİM',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF880E4F),
                              ),
                            ),
                            Text(
                              'Premium Sushi\'de Özel Fırsat!',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: const Color(0xFF880E4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ============================================
              // SEARCH BAR
              // ============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      shopProvider.setSearchQuery(value);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Sushi ara...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54),
                              onPressed: () {
                                _searchController.clear();
                                shopProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // ============================================
              // CATEGORY FILTER CHIPS
              // ============================================
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(category),
                          selected: shopProvider.selectedCategory == category,
                          onSelected: (selected) {
                            shopProvider.setCategory(category);
                          },
                          backgroundColor: const Color(0xFF1E1E1E),
                          selectedColor: const Color(0xFF880E4F),
                          labelStyle: GoogleFonts.lato(
                            color: shopProvider.selectedCategory == category ? Colors.white : Colors.white70,
                            fontWeight: shopProvider.selectedCategory == category ? FontWeight.bold : FontWeight.normal,
                          ),
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: shopProvider.selectedCategory == category
                                ? const Color(0xFFD4AF37) 
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // ============================================
              // PRODUCTS GRID (StreamBuilder from Firestore)
              // ============================================
              StreamBuilder<List<ProductModel>>(
                stream: shopProvider.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF880E4F),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Hata: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz ürün yok',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Get all products from snapshot
                  final allProducts = snapshot.data!;
                  
                  // Apply filters directly without setState
                  final searchQuery = shopProvider.searchQuery.toLowerCase();
                  final selectedCategory = shopProvider.selectedCategory;
                  
                  final filteredProducts = allProducts.where((product) {
                    final matchesSearch = searchQuery.isEmpty ||
                        product.name.toLowerCase().contains(searchQuery);
                    final matchesCategory = selectedCategory == 'All' ||
                        product.category == selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Sonuç bulunamadı',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 
                                       MediaQuery.of(context).size.width > 800 ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product, shopProvider);
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  );
                },
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ), // SafeArea closing
        ), // Container closing
      ), // Scaffold closing
    ); // PopScope closing
  }

  // ============================================================================
  // BUILD DRAWER
  // ============================================================================
  Widget _buildDrawer(BuildContext context) {
    final shopProvider = context.read<ShopProvider>();
    
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF880E4F),
                  const Color(0xFF4A0E1F),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SUSHI MAN',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SushiPoints Display
          if (_authService.currentUserId != null)
            FutureBuilder<int>(
              future: shopProvider.getUserPoints(_authService.currentUserId!),
              builder: (context, snapshot) {
                final points = snapshot.data ?? 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        size: 32,
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
                            '$points puan',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFD4AF37)),
            title: const Text('Ana Sayfa', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Color(0xFFD4AF37)),
            title: const Text('Sepet', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
            title: const Text('Favorilerim', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFD4AF37)),
            title: const Text('Profilim', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFFD4AF37)),
            title: const Text('Geçmiş Siparişler', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Color(0xFFD4AF37)),
            title: const Text('Aktif Siparişlerim', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ActiveOrdersPage()),
              );
            },
          ),
          FutureBuilder<String>(
            future: _authService.getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.data == 'admin') {
                return ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                  title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AdminPage()),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================================
  // BUILD PRODUCT CARD
  // ============================================================================
  Widget _buildProductCard(BuildContext context, ProductModel product, ShopProvider shopProvider) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FoodDetailsPage(product: product),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E1E),
                const Color(0xFF2A2A2A),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF880E4F).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF880E4F).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Hero Animation
              Stack(
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF2A2A2A),
                            const Color(0xFF1E1E1E),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: product.imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                product.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      size: 60,
                                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 60,
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FutureBuilder<bool>(
                      future: _authService.isFavorite(product.id),
                      builder: (context, snapshot) {
                        final isFavorite = snapshot.data ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFFFF1744) : Colors.white,
                              size: 20,
                            ),
                            onPressed: () async {
                              await _authService.toggleFavorite(product.id);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Rating Badge with Glow
                  if (product.rating > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFD4AF37)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Product Info with Better Spacing
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF880E4F).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF880E4F).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              product.category,
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: const Color(0xFFD4AF37),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                      // Price and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₺${product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.lato(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFB91450), Color(0xFF880E4F)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF880E4F).withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
