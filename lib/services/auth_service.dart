import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// ============================================================================
// AUTHENTICATION SERVICE
// ============================================================================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================================================
  // SIGN IN WITH EMAIL & PASSWORD
  // ============================================================================
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 Attempting sign in for: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print('✅ Sign in successful for: $email');
      
      // Check if user document exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        print('⚠️ User document not found in Firestore. Creating...');
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email.trim(),
        );
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Auth error code: ${e.code}, message: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  // ============================================================================
  // SIGN UP (REGISTER) WITH EMAIL & PASSWORD
  // ============================================================================
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Create user document in Firestore 'users' collection
      if (userCredential.user != null) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email.trim(),
          displayName: displayName,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Kayıt sırasında bir hata oluştu: $e';
    }
  }

  // LEGACY METHOD - kept for backward compatibility
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return signUpWithEmail(email: email, password: password);
  }

  // ============================================================================
  // CREATE USER DOCUMENT IN FIRESTORE
  // ============================================================================
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        isAdmin: false, // Default to non-admin
        role: 'user', // Default role
        favorites: [],
        defaultAddress: null,
        points: 0, // Initialize with 0 points
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userModel.toMap());
    } catch (e) {
      throw 'Kullanıcı profili oluşturulamadı: $e';
    }
  }

  // ============================================================================
  // GET USER DATA FROM FIRESTORE
  // ============================================================================
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Kullanıcı bilgileri alınamadı: $e';
    }
  }

  // ============================================================================
  // UPDATE USER DATA IN FIRESTORE
  // ============================================================================
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw 'Kullanıcı bilgileri güncellenemedi: $e';
    }
  }

  // ============================================================================
  // TOGGLE FAVORITE PRODUCT
  // ============================================================================
  Future<void> toggleFavorite(String productId) async {
    try {
      final user = currentUser;
      if (user == null) throw 'Kullanıcı oturumu bulunamadı';

      final userDoc = _firestore.collection('users').doc(user.uid);
      final userData = await getUserData(user.uid);

      if (userData == null) throw 'Kullanıcı verisi bulunamadı';

      List<String> favorites = List.from(userData.favorites);

      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }

      await userDoc.update({'favorites': favorites});
    } catch (e) {
      throw 'Favori güncellenemedi: $e';
    }
  }

  // ============================================================================
  // CHECK IF PRODUCT IS FAVORITE
  // ============================================================================
  Future<bool> isFavorite(String productId) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userData = await getUserData(user.uid);
      if (userData == null) return false;

      return userData.favorites.contains(productId);
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // CHECK IF USER IS ADMIN
  // ============================================================================
  Future<bool> isAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userData = await getUserData(user.uid);
      if (userData == null) return false;

      return userData.isAdmin;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // GET USER ROLE
  // ============================================================================
  Future<String> getUserRole([String? uid]) async {
    try {
      final userId = uid ?? currentUser?.uid;
      if (userId == null) return 'user';

      final userData = await getUserData(userId);
      if (userData == null) return 'user';

      return userData.role;
    } catch (e) {
      return 'user';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Çıkış yapılırken hata oluştu: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Şifre sıfırlama hatası: $e';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw 'Hesap silinirken hata oluştu: $e';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter kullanın.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor. Giriş yapmayı deneyin.';
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı. Kayıt olmayı deneyin.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz. Lütfen şifrenizi kontrol edin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi formatı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş denemesi. Lütfen birkaç dakika bekleyin.';
      case 'operation-not-allowed':
        return 'E-posta/Şifre girişi Firebase Console\'da etkinleştirilmemiş. Lütfen Firebase Authentication ayarlarını kontrol edin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.';
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'invalid-login-credentials':
        return 'E-posta veya şifre hatalı. Kayıtlı değilseniz önce kayıt olun.';
      default:
        return 'Kimlik doğrulama hatası: ${e.message ?? e.code}';
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}
