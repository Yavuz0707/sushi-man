# 🍣 SUSHI MAN - Premium Sushi Teslimat Uygulaması

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.2.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Profesyonel, production-ready bir Flutter mobil uygulaması**

Firebase backend ile entegre, tam kapsamlı sushi teslimat platformu

[English](README_EN.md) | **Türkçe**

</div>

---

## 📖 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Özellikler](#-özellikler)
- [Ekran Görüntüleri](#-ekran-görüntüleri)
- [Teknolojiler](#-teknolojiler)
- [Mimari](#️-mimari)
- [Kurulum](#-kurulum)
- [Firebase Yapılandırması](#-firebase-yapılandırması)
- [Veritabanı Şeması](#-veritabanı-şeması)
- [Kullanım](#-kullanım)
- [Admin Paneli](#-admin-paneli)
- [Güvenlik](#-güvenlik)
- [Test Hesapları](#-test-hesapları)
- [Katkıda Bulunma](#-katkıda-bulunma)
- [Lisans](#-lisans)

---

## 🎯 Genel Bakış

**SUSHI MAN**, modern Flutter framework'ü ve Firebase backend altyapısı ile geliştirilmiş, profesyonel bir yemek sipariş ve teslimat uygulamasıdır. Özellikle sushi restoranları için tasarlanmış olan bu uygulama, müşterilerin kolayca sipariş vermelerini ve siparişlerini takip etmelerini sağlarken, restoran yöneticilerine de güçlü bir admin paneli sunar.

### 🌟 Neden SUSHI MAN?

- ✅ **Production-Ready**: Canlı ortamda kullanıma hazır, test edilmiş kod yapısı
- ✅ **Modern UI/UX**: Koyu tema, gradient arka planlar, smooth animasyonlar
- ✅ **Gerçek Zamanlı**: Firebase Streams ile anlık veri güncellemeleri
- ✅ **Ölçeklenebilir**: MVVM mimarisi ile kolayca genişletilebilir kod yapısı
- ✅ **Güvenli**: Firebase Authentication ve Firestore güvenlik kuralları
- ✅ **Cross-Platform**: Android, iOS, Web ve Desktop desteği

---

## 🚀 Özellikler

### 👤 Kullanıcı Özellikleri

#### 🔐 Kimlik Doğrulama
- Email/Şifre ile kayıt ve giriş
- Şifre sıfırlama (unutulan şifre)
- Otomatik oturum yönetimi
- Güvenli çıkış yapma

#### 🔍 Akıllı Arama ve Filtreleme
- Ürün adına göre arama
- Malzeme bazlı arama (örn: "Somon", "Avokado")
- Kategori filtreleme: Nigiri, Maki, Sashimi, Set Menüler
- Anlık arama sonuçları

#### 🛍️ Ürün Yönetimi
- Detaylı ürün bilgileri (fiyat, malzemeler, kalori)
- Yüksek kaliteli ürün görselleri
- Puan ve değerlendirmeler
- Favori ürünleri kaydetme
- Popüler ürünler bölümü

#### 🛒 Sepet İşlemleri
- Ürün ekleme/çıkarma
- Miktar kontrolü (+/- butonları)
- Kaydırarak silme (swipe-to-delete)
- Otomatik toplam hesaplama
- Teslimat ücreti gösterimi (₺15.00)

#### 📦 Sipariş Takibi
- Gerçek zamanlı sipariş durumu
- Görsel sipariş takip stepper'ı:
  - 🔄 Hazırlanıyor
  - 🚗 Yolda
  - ✅ Teslim Edildi
- Sipariş geçmişi görüntüleme
- Aktif ve geçmiş siparişler ayrımı

#### ❤️ Favoriler
- Sevdiğiniz ürünleri kaydedin
- Favori ürünlere hızlı erişim
- Tek tık ile sepete ekleme

### 👨‍💼 Admin Özellikleri

#### 📊 Admin Paneli
- Kısıtlı erişim (sadece admin hesapları)
- Modern ve kullanıcı dostu arayüz
- Tüm işlemlerin merkezi yönetimi

#### 🍱 Ürün Yönetimi
- Yeni ürün ekleme
- Ürün bilgilerini düzenleme
- Ürün görselleri yükleme (Firebase Storage)
- Kategori, fiyat, malzeme yönetimi
- Ürün detaylarını görüntüleme

#### 📋 Sipariş Yönetimi
- Tüm siparişleri görüntüleme
- Sipariş durumunu güncelleme
- Sipariş detaylarını inceleme
- Müşteri bilgilerine erişim
- Sipariş istatistikleri

#### 📈 İstatistikler ve Raporlama
- Toplam sipariş sayısı
- Aktif sipariş takibi
- Teslim edilen sipariş sayıları
- Audit log sistemi (işlem kayıtları)

---

## 📱 Ekran Görüntüleri

```
[Giriş Sayfası] → [Ana Menü] → [Ürün Detay] → [Sepet]
      ↓              ↓            ↓            ↓
[Favoriler]    [Sipariş Takip]  [Admin Panel] [Geçmiş]
```

*Not: Ekran görüntüleri için `screenshots/` klasörüne bakınız.*

---

## 💻 Teknolojiler

### Frontend
- **Flutter** (3.2.0+) - Cross-platform UI framework
- **Dart** (3.0+) - Programming language
- **Material 3** - Modern UI design system
- **Google Fonts** - DM Serif Display & Lato
- **Lottie** - Animasyonlar

### Backend & Servisler
- **Firebase Core** (4.3.0) - Firebase temel servisleri
- **Firebase Auth** (6.1.3) - Kimlik doğrulama
- **Cloud Firestore** (6.1.1) - NoSQL veritabanı
- **Firebase Storage** (13.0.5) - Dosya depolama

### State Management & Diğer
- **Provider** (6.1.5+1) - State yönetimi
- **Cached Network Image** (3.3.1) - Görsel önbellekleme
- **Shimmer** (3.0.0) - Loading skeleton
- **UUID** (4.3.3) - Benzersiz ID üretimi
- **Intl** (0.20.2) - Tarih ve para formatı

---

## 🏗️ Mimari

### MVVM (Model-View-ViewModel) Pattern

```
┌─────────────────────────────────────────────────────┐
│                    UI LAYER                         │
│  ┌───────────────────────────────────────────────┐ │
│  │   Pages (Screens)                             │ │
│  │   - LoginPage, MenuPage, CartPage             │ │
│  │   - AdminPage, OrderTrackingPage, etc.        │ │
│  └───────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────┐ │
│  │   Widgets (Reusable Components)               │ │
│  │   - CustomButton, ProductCard, etc.           │ │
│  └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│                 VIEWMODEL LAYER                     │
│  ┌───────────────────────────────────────────────┐ │
│  │   Providers (State Management)                │ │
│  │   - ShopProvider                              │ │
│  │   - AuthProvider (implicitly via services)    │ │
│  └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│                  MODEL LAYER                        │
│  ┌───────────────────────────────────────────────┐ │
│  │   Models (Data Classes)                       │ │
│  │   - ProductModel, OrderModel, UserModel       │ │
│  │   - CartItem, AddressModel                    │ │
│  └───────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────┐ │
│  │   Services (Business Logic)                   │ │
│  │   - AuthService, DatabaseService              │ │
│  │   - DatabaseSeeder, UserSeeder                │ │
│  └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│              FIREBASE BACKEND                       │
│   Authentication | Firestore | Storage              │
└─────────────────────────────────────────────────────┘
```

### 📁 Proje Yapısı

```
lib/
├── 📂 core/                      # Uygulama çekirdeği
│   ├── 📂 constants/            # Sabitler (renkler, stringler)
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── 📂 theme/                # Tema yapılandırması
│   │   └── app_theme.dart
│   └── 📂 helpers/              # Yardımcı fonksiyonlar
│       ├── price_formatter.dart
│       └── date_formatter.dart
│
├── 📂 models/                    # Veri modelleri
│   ├── models.dart              # Ana model dosyası
│   │   ├── ProductModel         # Ürün modeli
│   │   ├── CartItem            # Sepet öğesi
│   │   ├── OrderModel          # Sipariş modeli
│   │   ├── UserModel           # Kullanıcı modeli
│   │   └── AddressModel        # Adres modeli
│   └── log_model.dart          # Audit log modeli
│
├── 📂 providers/                 # State management
│   └── shop_provider.dart       # Ana shop provider
│
├── 📂 services/                  # İş mantığı katmanı
│   ├── auth_service.dart        # Kimlik doğrulama
│   ├── database_service.dart    # Veritabanı işlemleri
│   ├── database_seeder.dart     # Ürün seed işlemi
│   ├── user_seeder.dart         # Kullanıcı seed işlemi
│   └── admin_data_seeder.dart   # Admin veri seed
│
├── 📂 ui/                        # Kullanıcı arayüzü
│   ├── 📂 pages/                # Sayfalar
│   │   ├── intro_page.dart
│   │   ├── login_page.dart
│   │   ├── menu_page.dart
│   │   ├── food_details_page.dart
│   │   ├── cart_page.dart
│   │   ├── order_tracking_page.dart
│   │   ├── order_history_page.dart
│   │   ├── favorites_page.dart
│   │   ├── profile_page.dart
│   │   ├── admin_page.dart
│   │   └── add_product_page.dart
│   │
│   └── 📂 widgets/              # Yeniden kullanılabilir bileşenler
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       ├── product_card.dart
│       ├── category_chip.dart
│       ├── cart_item_tile.dart
│       └── order_status_stepper.dart
│
├── firebase_options.dart         # Firebase yapılandırması
└── main.dart                     # Uygulama giriş noktası
```

---

## 📥 Kurulum

### Gereksinimler

- **Flutter SDK**: 3.2.0 veya üzeri
- **Dart SDK**: 3.0 veya üzeri
- **Android Studio** / **VS Code** (önerilen IDE'ler)
- **Git**: Version control için
- **Firebase Hesabı**: Backend servisleri için

### Adım 1: Projeyi Klonlayın

```bash
git clone https://github.com/kullaniciadi/SushiMan.git
cd SushiMan
```

### Adım 2: Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### Adım 3: Flutter Kurulumunu Doğrulayın

```bash
flutter doctor
```

Eksik bileşenler varsa, Flutter'ın önerilerini takip edin.

---

## 🔥 Firebase Yapılandırması

### Adım 1: Firebase Projesi Oluşturun

1. [Firebase Console](https://console.firebase.google.com) adresine gidin
2. "Add Project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin (örn: "SushiMan")
4. Google Analytics'i etkinleştirin (opsiyonel)
5. Projeyi oluşturun

### Adım 2: Firebase Authentication

1. Firebase Console'da projenize gidin
2. Sol menüden **Authentication** seçin
3. **Get Started** butonuna tıklayın
4. **Sign-in method** sekmesine gidin
5. **Email/Password** metodunu aktif edin

### Adım 3: Cloud Firestore

1. Sol menüden **Firestore Database** seçin
2. **Create database** butonuna tıklayın
3. **Start in test mode** seçin (geliştirme için)
4. Location seçin (örn: europe-west1)
5. **Enable** butonuna tıklayın

### Adım 4: Firebase Storage

1. Sol menüden **Storage** seçin
2. **Get Started** butonuna tıklayın
3. **Start in test mode** seçin
4. Location seçin
5. **Done** butonuna tıklayın

### Adım 5: Firebase Config Dosyaları

#### Android İçin:

1. Firebase Console'da Android ikonu (+) tıklayın
2. Package name girin: `com.example.sushi_man`
3. `google-services.json` dosyasını indirin
4. Dosyayı şu konuma taşıyın:
   ```
   android/app/google-services.json
   ```

#### iOS İçin:

1. Firebase Console'da iOS ikonu (+) tıklayın
2. Bundle ID girin: `com.example.sushiMan`
3. `GoogleService-Info.plist` dosyasını indirin
4. Dosyayı şu konuma taşıyın:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

#### Web İçin:

1. Firebase Console'da Web ikonu (</>) tıklayın
2. App nickname girin
3. Firebase Config bilgilerini kopyalayın
4. `lib/firebase_options.dart` dosyasını güncelleyin

### Adım 6: FlutterFire CLI (Otomatik Yapılandırma)

```bash
# FlutterFire CLI'yi yükleyin
dart pub global activate flutterfire_cli

# Firebase'i yapılandırın
flutterfire configure
```

---

## 💾 Veritabanı Şeması

### Firestore Collections

#### 1. `users/` Collection

```javascript
{
  "uid": "string",              // User unique ID
  "email": "string",            // User email
  "role": "string",             // "admin" | "user"
  "favorites": ["string"],      // Array of product IDs
  "createdAt": "timestamp",
  "addresses": [                // Array of addresses
    {
      "id": "string",
      "title": "string",        // "Ev", "İş", etc.
      "fullAddress": "string",
      "city": "string",
      "district": "string",
      "isDefault": "boolean"
    }
  ]
}
```

#### 2. `products/` Collection

```javascript
{
  "id": "string",               // Product unique ID
  "name": "string",             // Product name
  "price": "double",            // Price in TL
  "imagePath": "string",        // Image URL
  "rating": "double",           // Rating (0-5)
  "category": "string",         // "Nigiri" | "Maki" | "Sashimi" | "Sets"
  "description": "string",      // Product description
  "ingredients": ["string"],    // Array of ingredients
  "isPopular": "boolean",       // Popular flag
  "soldCount": "int",           // Number of times sold
  "createdAt": "timestamp"
}
```

#### 3. `orders/` Collection

```javascript
{
  "id": "string",               // Order unique ID
  "userId": "string",           // User ID who placed order
  "userEmail": "string",        // User email
  "items": [                    // Cart items
    {
      "id": "string",
      "name": "string",
      "price": "double",
      "quantity": "int",
      "imagePath": "string"
    }
  ],
  "totalAmount": "double",      // Total price
  "status": "string",           // "Preparing" | "On Way" | "Delivered"
  "deliveryAddress": "string",  // Full delivery address
  "courierName": "string",      // Courier name (optional)
  "courierId": "string",        // Courier ID (optional)
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### 4. `audit_logs/` Collection

```javascript
{
  "id": "string",
  "action": "string",           // Action type
  "userId": "string",           // User who performed action
  "userEmail": "string",
  "details": "string",          // Action details
  "timestamp": "timestamp"
}
```

### İlişkiler

```
users (1) ←──→ (N) orders
users (1) ←──→ (N) favorites → products
products (N) ←──→ (N) orders (through cart items)
users (1) ←──→ (N) audit_logs
```

---

## 🎮 Kullanım

### Uygulamayı Çalıştırma

```bash
# Android emulator veya cihaz
flutter run

# iOS simulator (Mac gerekli)
flutter run -d ios

# Web tarayıcı
flutter run -d chrome

# Belirli bir cihaz
flutter devices
flutter run -d [device-id]
```

### İlk Çalıştırma ve Veri Seed

Uygulamayı ilk kez çalıştırdığınızda, örnek verilerle doldurmak için:

1. `lib/main.dart` dosyasını açın
2. `main()` fonksiyonunda şu satırların yorumunu kaldırın:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('tr_TR', null);

  // 🌱 Bu satırların yorumunu kaldırın (sadece ilk çalıştırmada)
  await DatabaseSeeder.seedProducts();      // Ürünleri ekle
  await UserSeeder.seedUsers();             // Test kullanıcıları ekle
  await AdminDataSeeder.seedAll();          // Örnek siparişler ekle

  runApp(const SushiManApp());
}
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

4. Veriler eklendikten sonra, bu satırları **tekrar yoruma alın** veya silin
5. Uygulamayı yeniden başlatın

---

## 👨‍💼 Admin Paneli

### Admin Hesabı Oluşturma

#### Yöntem 1: Otomatik (Seed ile)

Yukarıdaki seed işlemlerini çalıştırdıysanız, otomatik olarak bir admin hesabı oluşturulmuştur:

```
Email: admin@sushiman.com
Şifre: admin123
```

#### Yöntem 2: Manuel

1. Uygulamada normal bir hesap oluşturun
2. [Firebase Console](https://console.firebase.google.com) → Firestore Database
3. `users` collection'ına gidin
4. Kendi kullanıcı belgenizi bulun (email ile)
5. `role` alanını `"user"` 'dan `"admin"` 'e değiştirin
6. Değişiklikleri kaydedin
7. Uygulamadan çıkış yapıp tekrar giriş yapın

### Admin Panel Özellikleri

#### Ürün Ekleme

1. Admin paneline gidin
2. "Yeni Ürün Ekle" butonuna tıklayın
3. Ürün bilgilerini doldurun:
   - Ürün adı
   - Fiyat
   - Kategori
   - Açıklama
   - Malzemeler (virgülle ayırarak)
   - Görsel URL
4. "Ürün Ekle" butonuna tıklayın

#### Sipariş Yönetimi

1. Admin paneline gidin
2. "Siparişler" sekmesine geçin
3. Sipariş kartında durum değiştirme butonlarını kullanın:
   - **Hazırla** → Sipariş hazırlanmaya başlandı
   - **Yola Çıkar** → Kurye sipariş ile yola çıktı
   - **Teslim Et** → Sipariş teslim edildi

---

## 🔒 Güvenlik

### Firestore Security Rules

`firebase.json` dosyanızda security rules'u yapılandırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper Functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isSignedIn() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users Collection
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow create: if isSignedIn();
      allow update: if isOwner(userId);
      allow delete: if isAdmin();
    }
    
    // Products Collection
    match /products/{productId} {
      allow read: if true;  // Everyone can read
      allow write: if isAdmin();  // Only admins can write
    }
    
    // Orders Collection
    match /orders/{orderId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isSignedIn();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Audit Logs Collection
    match /audit_logs/{logId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## 👥 Test Hesapları

Eğer seed işlemlerini çalıştırdıysanız, aşağıdaki test hesaplarını kullanabilirsiniz:

### Admin Hesabı
```
Email: admin@sushiman.com
Şifre: admin123
```

**Yetkiler:**
- Tüm admin panel erişimi
- Ürün ekleme/düzenleme
- Sipariş yönetimi
- Kullanıcı yönetimi

### Normal Kullanıcı Hesabı
```
Email: user@example.com
Şifre: user123
```

**Yetkiler:**
- Ürün görüntüleme
- Sipariş verme
- Favori ekleme
- Sipariş takibi

---

## 🎨 Tema ve Tasarım

### Renk Paleti

```dart
Primary Color (Burgundy):   #880E4F
Secondary Color (Gold):     #D4AF37
Background (Dark):          #121212
Card Background:            #1E1E1E
Text Primary (Light):       #FFFFFF
Text Secondary (Grey):      #B0B0B0
Success Green:              #4CAF50
Error Red:                  #F44336
```

### Fontlar

- **Başlıklar**: DM Serif Display (Google Font)
- **Gövde Metni**: Lato (Google Font)

### UI Bileşenleri

- **Material 3 Design System**
- **Gradient Backgrounds**
- **Card Elevations & Shadows**
- **Smooth Animations**
- **Shimmer Loading Effects**

---

## 🧪 Test Etme

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

---

## 📦 Build & Release

### Android APK

```bash
flutter build apk --release
```

APK dosyası: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

AAB dosyası: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

*Not: iOS build için Mac ve Xcode gereklidir.*

### Web

```bash
flutter build web --release
```

Build dosyaları: `build/web/`

---

## 🤝 Katkıda Bulunma

Katkılarınızı memnuniyetle karşılıyoruz! Lütfen şu adımları takip edin:

1. Projeyi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

### Commit Mesaj Formatı

```
feat: Yeni özellik ekleme
fix: Hata düzeltme
docs: Dokümantasyon değişikliği
style: Kod formatı değişikliği
refactor: Kod yeniden yapılandırma
test: Test ekleme/düzeltme
chore: Diğer değişiklikler
```

---

## 📝 Yol Haritası

- [ ] Push notification desteği
- [ ] Çoklu dil desteği (İngilizce)
- [ ] Kupon ve indirim sistemi
- [ ] Kullanıcı yorumları ve puanlama
- [ ] Canlı sohbet desteği
- [ ] Kredi kartı ile ödeme entegrasyonu
- [ ] Kurye takip haritası (Google Maps)
- [ ] Dark/Light tema geçişi

---

## 🐛 Bilinen Sorunlar

Şu anda bilinen kritik bir sorun bulunmamaktadır. Bir sorun tespit ederseniz lütfen [Issues](https://github.com/Yavuz0707/sushi-man/issues) sayfasından bildirin.

---

## 👨‍💻 Geliştirici

**Şükrü**

---

## 📞 İletişim

Sorularınız için:
- 📧 Email: [your-email@example.com](mailto:your-email@example.com)
- 💼 LinkedIn: [your-linkedin](https://linkedin.com/in/your-profile)
- 🐙 GitHub: [@Yavuz0707](https://github.com/Yavuz0707)

---

## 🙏 Teşekkürler

- Flutter Team - Harika framework için
- Firebase Team - Backend altyapısı için
- Google Fonts - Ücretsiz fontlar için
- Community - Açık kaynak katkıları için

---

## ⭐ Yıldız Verin!

Bu projeyi beğendiyseniz, lütfen GitHub'da ⭐ vererek destek olun!

---

<div align="center">

**Made with ❤️ using Flutter & Firebase**

[⬆ Başa Dön](#-sushi-man---premium-sushi-teslimat-uygulaması)

</div>
