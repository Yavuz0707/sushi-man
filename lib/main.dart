import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/shop_provider.dart';
import 'services/user_seeder.dart'; // Import user seeder
import 'services/admin_data_seeder.dart'; // Import admin data seeder
import 'ui/pages/login_page.dart';
import 'ui/pages/menu_page.dart';
import 'ui/pages/cart_page.dart';
import 'ui/pages/order_tracking_page.dart';
import 'ui/pages/admin_page.dart';
import 'ui/pages/add_product_page.dart';
import 'ui/pages/order_history_page.dart';
import 'ui/pages/favorites_page.dart';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Turkish locale for date formatting
  await initializeDateFormatting('tr_TR', null);

  // 🌱 SEED DATABASE (RUN ONCE, THEN COMMENT OUT!)
  // Uncomment the line below to populate Firestore with sample sushi products
  // await DatabaseSeeder.seedProducts();

  // 👤 SEED USER ACCOUNTS (RUN ONCE, THEN COMMENT OUT!)
  // Uncomment the line below to create admin and user test accounts
  await UserSeeder.seedUsers();

  // 📦 SEED ADMIN DATA - Orders & Audit Logs (RUN ONCE, THEN COMMENT OUT!)
  // Uncomment the line below to create sample orders and audit logs
  await AdminDataSeeder.seedAll();

  runApp(const SushiManApp());
}

// ============================================================================
// APP ROOT
// ============================================================================
class SushiManApp extends StatelessWidget {
  const SushiManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: MaterialApp(
        title: 'SUSHI MAN',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/menu': (context) => const MenuPage(),
          '/cart': (context) => const CartPage(),
          '/admin': (context) => const AdminPage(),
          '/add_product': (context) => const AddProductPage(),
          '/order-history': (context) => OrderHistoryPage(),
          '/favorites': (context) => const FavoritesPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/track') {
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OrderTrackingPage(orderId: orderId),
            );
          }
          return null;
        },
      ),
    );
  }

  // ============================================================================
  // THEME DATA - Dark Red/Burgundy (0xFF880E4F)
  // ============================================================================
  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF880E4F); // Dark Red/Burgundy
    const secondaryColor = Color(0xFFD4AF37); // Gold accent
    const darkBg = Color(0xFF121212);
    const cardBg = Color(0xFF1E1E1E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardBg,
        error: Colors.red.shade300,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: Colors.white70,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: Colors.white60,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 24,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }
}
