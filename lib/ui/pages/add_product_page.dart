import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/models.dart';
import '../../providers/shop_provider.dart';
import '../../services/database_service.dart';
import '../../ui/widgets/custom_button.dart';
import '../../ui/widgets/custom_text_field.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _databaseService = DatabaseService();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;

  String _selectedCategory = AppStrings.nigiri;
  bool _isPopular = false;
  final double _rating = 4.5;

  final List<String> _categories = [
    AppStrings.nigiri,
    AppStrings.maki,
    AppStrings.sashimi,
    AppStrings.sets,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  // ============================================
  // PICK IMAGE FROM GALLERY
  // ============================================
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web: Read as bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // Mobile: Use File
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel seçilirken hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ============================================
  // UPLOAD IMAGE AND ADD PRODUCT
  // ============================================
  Future<void> _handleAddProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null && _webImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir görsel seçin'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // 1. Upload image to Firebase Storage
        final imageUrl = await _databaseService.uploadImage(
          file: _selectedImage,
          webImage: _webImage,
        );

        if (imageUrl == null) {
          throw 'Görsel yüklenemedi';
        }

        // 2. Create product with uploaded image URL
        final shopProvider = context.read<ShopProvider>();
        final product = ProductModel(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          imagePath: imageUrl,
          rating: _rating,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          ingredients: _ingredientsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          isPopular: _isPopular,
        );

        // 3. Save product to Firestore
        final success = await shopProvider.addProduct(product);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ürün başarıyla eklendi'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(shopProvider.errorMessage ?? 'Ürün eklenemedi'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Hata: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addProduct),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  AppStrings.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Örn: Salmon Nigiri',
                  prefixIcon: Icons.restaurant,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ürün adı gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Price
                Text(
                  AppStrings.price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                CustomTextField(
                  controller: _priceController,
                  hintText: 'Örn: 89.99',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Fiyat gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir fiyat girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Image Picker Container
                Text(
                  'Ürün Görseli',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: AppColors.primaryRed.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: (_selectedImage != null || _webImage != null)
                        ? Stack(
                            children: [
                              // Image Preview
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                child: kIsWeb
                                    ? Image.memory(
                                        _webImage!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _selectedImage!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              // Change Image Button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: AppColors.primaryRed.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Görsel Seç',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Galeriden seçmek için dokunun',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Category
                Text(
                  AppStrings.category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.cardBackground,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Description
                Text(
                  AppStrings.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Ürün açıklaması...',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Açıklama gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Ingredients
                Text(
                  AppStrings.ingredients,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                CustomTextField(
                  controller: _ingredientsController,
                  hintText: 'Salmon, Pirinç, Nori (virgülle ayırın)',
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İçindekiler gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginL),

                // Is Popular Checkbox
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: CheckboxListTile(
                    value: _isPopular,
                    onChanged: (value) {
                      setState(() {
                        _isPopular = value ?? false;
                      });
                    },
                    title: const Text(AppStrings.isPopular),
                    subtitle: const Text('Popüler bölümünde göster'),
                    activeColor: AppColors.primaryRed,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                const SizedBox(height: AppDimensions.marginXL),

                // Add Button
                CustomButton(
                  text: _isUploading ? 'Yükleniyor...' : AppStrings.addProduct,
                  onPressed: _isUploading ? () {} : () => _handleAddProduct(),
                  isLoading: _isUploading,
                  width: double.infinity,
                  height: AppDimensions.buttonHeightL,
                  icon: _isUploading ? null : Icons.add_circle,
                ),

                const SizedBox(height: AppDimensions.marginL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
