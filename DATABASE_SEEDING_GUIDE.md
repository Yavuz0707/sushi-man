# 🌱 Database Seeding Guide

## Overview
A `DatabaseSeeder` class has been created to populate your Firestore `products` collection with 6 premium sushi items.

## Files Created
- ✅ `lib/services/database_seeder.dart` - Contains the seeding logic

## How to Use

### Step 1: Enable Seeding
Open `lib/main.dart` and **uncomment** this line:

```dart
// 🌱 SEED DATABASE (RUN ONCE, THEN COMMENT OUT!)
await DatabaseSeeder.seedProducts();  // ← Remove the // to enable
```

### Step 2: Run the App
```bash
flutter run -d chrome
```

Watch the console output:
```
🌱 Starting database seeding...
✅ Added: Salmon Sushi (Nigiri) - ₺21.0
✅ Added: Tuna Slice (Sashimi) - ₺23.0
✅ Added: Salmon Eggs (Gunkan) - ₺19.0
✅ Added: California Roll (Maki) - ₺15.0
✅ Added: Dragon Roll (Special) - ₺25.0
✅ Added: Spicy Shrimp (Maki) - ₺18.5
🎉 Successfully seeded 6 products!
```

### Step 3: Comment It Back Out
After the products are added, **re-comment** the line to prevent duplicates:

```dart
// await DatabaseSeeder.seedProducts();
```

## Products Added
| Product | Category | Price | Rating |
|---------|----------|-------|--------|
| Salmon Sushi | Nigiri | ₺21.00 | 4.9 ⭐ |
| Tuna Slice | Sashimi | ₺23.00 | 4.8 ⭐ |
| Salmon Eggs | Gunkan | ₺19.00 | 4.5 ⭐ |
| California Roll | Maki | ₺15.00 | 4.2 ⭐ |
| Dragon Roll | Special | ₺25.00 | 5.0 ⭐ |
| Spicy Shrimp | Maki | ₺18.50 | 4.6 ⭐ |

## Safety Features
- ✅ **Duplicate Prevention**: Automatically checks if products exist before seeding
- ✅ **Error Handling**: Catches and reports any Firestore errors
- ✅ **Console Feedback**: Clear emoji-based logging

## Optional: Clear All Products
If you need to reset:

```dart
await DatabaseSeeder.clearProducts();
```

⚠️ **WARNING**: This deletes ALL products from Firestore!

## Alternative: Admin Panel
You can also use the existing **"Örnek Sushi Verilerini Ekle"** button in the Admin Panel, which adds 12 products instead of 6.

---

**Created**: 2026-01-08  
**Status**: ✅ Ready to use
