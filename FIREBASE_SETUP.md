# Firebase Setup Guide for SUSHI MAN

## Quick Start - Manual Firebase Configuration

Since FlutterFire CLI requires additional setup, here's the manual configuration process:

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name it "SUSHI MAN" or "sushi-man"
4. Follow the prompts (disable Google Analytics for faster setup)

### Step 2: Enable Services

**Authentication:**
1. In Firebase Console → Build → Authentication
2. Click "Get started"
3. Select "Email/Password" provider
4. Enable and Save

**Firestore Database:**
1. In Firebase Console → Build → Firestore Database
2. Click "Create database"
3. Start in **Test mode** (we'll add security rules later)
4. Choose a location close to your users

### Step 3: Register Your App

#### For Android:
1. Click "Add app" → Android icon
2. Package name: `com.sushiman.app`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### For iOS:
1. Click "Add app" → iOS icon
2. Bundle ID: `com.sushiman.app`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

#### For Web:
1. Click "Add app" → Web icon
2. App nickname: "SUSHI MAN Web"
3. Copy the Firebase configuration

### Step 4: Update firebase_options.dart

After registering your apps, Firebase will show you configuration values. Update `lib/firebase_options.dart`:

**Find these values in Firebase Console → Project Settings → Your apps:**

For **Android**:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...', // From Firebase Console
  appId: '1:123456789:android:abcdef123456', // From Firebase Console
  messagingSenderId: '123456789', // From Firebase Console
  projectId: 'your-project-id', // Your actual project ID
  storageBucket: 'your-project-id.appspot.com',
);
```

For **iOS**:
```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSy...', // From Firebase Console
  appId: '1:123456789:ios:abcdef123456', // From Firebase Console
  messagingSenderId: '123456789', // From Firebase Console
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
  iosBundleId: 'com.sushiman.app',
);
```

For **Web**:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSy...', // From Firebase Console
  appId: '1:123456789:web:abcdef123456', // From Firebase Console
  messagingSenderId: '123456789', // From Firebase Console
  projectId: 'your-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

### Step 5: Android Configuration (if using Android)

Edit `android/app/build.gradle`:

Add at the **top** (below existing plugins):
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // ADD THIS LINE
}
```

Edit `android/build.gradle`:

In `dependencies` block (around line 8-15), add:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.3.0'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    classpath 'com.google.gms:google-services:4.3.15'  // ADD THIS LINE
}
```

### Step 6: Firestore Security Rules

In Firebase Console → Firestore Database → Rules, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products: everyone can read, only admins can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Orders: users can read their own, admins can read all
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

Click "Publish" to save.

### Step 7: Test the App

```bash
flutter pub get
flutter run
```

### Creating Admin Account

1. Register through the app with any email
2. Go to Firebase Console → Firestore Database
3. Find your user in the `users` collection
4. Edit the document
5. Change `role: "user"` to `role: "admin"`
6. Restart the app

### Adding Sample Products

You can use the Admin Panel in the app, or manually add to Firestore:

Collection: `products`

Example document:
```json
{
  "id": "product-1",
  "name": "Salmon Nigiri",
  "price": 89.99,
  "imagePath": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800",
  "rating": 4.8,
  "description": "Taze somonlu geleneksel nigiri",
  "category": "Nigiri",
  "ingredients": ["Salmon", "Pirinç", "Wasabi"],
  "isPopular": true
}
```

### Troubleshooting

**"No Firebase App" error:**
- Make sure you've added `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

**Authentication errors:**
- Verify Email/Password provider is enabled in Firebase Console

**Firestore permission errors:**
- Check that security rules are published
- Verify you're signed in with a valid account

### Quick Firebase CLI Setup (Optional)

If you want to use Firebase CLI in the future:

```bash
npm install -g firebase-tools
firebase login
```

Then you can use FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

✨ Your Firebase backend is now ready! The app is fully configured to work with Firebase.
