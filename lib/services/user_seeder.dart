import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// ============================================================================
// USER SEEDER - Create default admin and user accounts
// ============================================================================
class UserSeeder {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds default admin and user accounts
  /// Call this ONCE during development, then remove/comment out
  static Future<void> seedUsers() async {
    print('👤 Starting user account seeding...');

    try {
      // 1. Create Admin Accounts
      await _createUserAccount(
        email: 'sushiman.admin@gmail.com',
        password: 'admin2026',
        role: 'admin',
        isAdmin: true,
      );

      await _createUserAccount(
        email: 'admin123@sushiman.com',
        password: 'admin123',
        role: 'admin',
        isAdmin: true,
      );

      // 2. Create Staff/User Account
      await _createUserAccount(
        email: 'personel@sushiman.com',
        password: 'password123',
        role: 'user',
        isAdmin: false,
      );

      print('🎉 Successfully seeded user accounts!');
      print('📧 Admin 1: sushiman.admin@gmail.com / admin2026');
      print('📧 Admin 2: admin123@sushiman.com / admin123');
      print('📧 User: personel@sushiman.com / password123');
      print('💡 TIP: You can now remove/comment out the seeding call in main.dart');
    } catch (e) {
      print('❌ Error seeding users: $e');
      rethrow;
    }
  }

  /// Helper method to create a user account
  static Future<void> _createUserAccount({
    required String email,
    required String password,
    required String role,
    required bool isAdmin,
  }) async {
    try {
      print('🔄 Creating account for: $email');
      
      // Try to create user in Firebase Auth
      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase Auth account created: $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('⚠️  Auth account exists. Checking Firestore document...');
          // Sign in to get uid
          final signIn = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          userCredential = signIn;
          await _auth.signOut();
        } else {
          print('❌ Firebase Auth error: ${e.code}');
          throw e;
        }
      }

      final uid = userCredential.user!.uid;

      // Check if Firestore document exists
      final existingDoc = await _firestore.collection('users').doc(uid).get();
      
      if (existingDoc.exists) {
        final existingData = existingDoc.data();
        print('⚠️  Firestore document exists. Current role: ${existingData?['role']}');
        
        // Update role if different and ensure points field exists
        await _firestore.collection('users').doc(uid).update({
          'role': role,
          'isAdmin': isAdmin,
          'points': existingData?['points'] ?? 0, // Ensure points field exists
        });
        print('✅ Updated role to: $role for $email');
        return;
      }

      // Create user document in Firestore
      final userModel = UserModel(
        uid: uid,
        email: email,
        role: role,
        isAdmin: isAdmin,
        favorites: [],
        points: 0, // Initialize with 0 points
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      print('✅ Created $role account: $email (Auth + Firestore)');
    } catch (e) {
      print('❌ Error creating user $email: $e');
    }
  }

  /// Optional: Clear all users (use with caution!)
  static Future<void> clearUsers() async {
    print('🗑️  WARNING: This will delete all user accounts!');
    try {
      final snapshot = await _firestore.collection('users').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ All user documents cleared from Firestore');
      print('⚠️  Note: Firebase Auth users must be deleted manually from console');
    } catch (e) {
      print('❌ Error clearing users: $e');
      rethrow;
    }
  }
}
