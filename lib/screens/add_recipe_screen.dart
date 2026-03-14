import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // YENİ EKLENDİ
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String _selectedCategory = 'Ana Yemek';
  String _selectedDifficulty = 'Orta';
  
  // YENİ EKLENDİ: Seçilen resim dosyasını ekranda göstermek için
  File? _selectedImageFile; 

  final List<String> _categories = [
    'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği', 
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 'Meze', 
    'Salata', 'Kahvaltılık', 'Tatlı'
  ];

  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor'];

  InputDecoration _buildInputDecoration(String hint, IconData icon, Color surfaceColor, Color borderColor, Color primaryColor, Color textMuted) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: textMuted, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: textMuted),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  // YENİ EKLENDİ: Galeriden resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      
      String? finalImageName;
      // YENİ EKLENDİ: Eğer resim seçildiyse DatabaseHelper ile locale kopyala ve sadece dosya adını al
      if (_selectedImageFile != null) {
        finalImageName = await _dbHelper.saveImageLocally(_selectedImageFile!);
      }

      final newRecipe = Recipe(
        title: _titleController.text,
        shortDescription: _shortDescController.text,
        category: _selectedCategory,
        ingredients: _ingredientsController.text,
        instructions: _instructionsController.text,
        difficulty: _selectedDifficulty,
        prepTime: int.tryParse(_prepTimeController.text) ?? 0,
        cookTime: int.tryParse(_cookTimeController.text) ?? 0,
        servings: int.tryParse(_servingsController.text) ?? 0,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        coverImage: finalImageName, // Kopyalanan yeni resmin adı
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.createRecipe(newRecipe);
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        return MasterLayout(
          title: 'Yeni Tarif Ekle',
          activeMenu: 'Yemek Tarifleri',
          onBack: () => Navigator.pop(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Resim Ekleme Alanı (GÜNCELLENDİ)
                  GestureDetector(
                    onTap: _pickImage, // Tıklayınca dosya seçici açılır
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: _selectedImageFile != null ? primaryColor : borderColor,
                          width: 2,
                        ),
                      ),
                      child: _selectedImageFile != null
                          // Resim seçildiyse resmi göster
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14.0),
                              child: Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          // Resim yoksa standart ikon göster
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 48, color: textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'Vitrin Resmi Seç',
                                  style: GoogleFonts.nunito(
                                    color: textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: textDark),
                    decoration: _buildInputDecoration('Yemek Adı', Icons.restaurant_menu, surfaceColor, borderColor, primaryColor, textMuted),
                    validator: (value) => value == null || value.isEmpty ? 'Yemek adı zorunludur' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _shortDescController,
                    style: TextStyle(color: textDark),
                    decoration: _buildInputDecoration('Kısa Açıklama (İsteğe Bağlı)', Icons.short_text, surfaceColor, borderColor, primaryColor, textMuted),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: surfaceColor,
                          style: TextStyle(color: textDark),
                          decoration: _buildInputDecoration('Kategori', Icons.category, surfaceColor, borderColor, primaryColor, textMuted),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: GoogleFonts.nunito()))).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDifficulty,
                          dropdownColor: surfaceColor,
                          style: TextStyle(color: textDark),
                          decoration: _buildInputDecoration('Zorluk', Icons.speed, surfaceColor, borderColor, primaryColor, textMuted),
                          items: _difficulties.map((diff) => DropdownMenuItem(value: diff, child: Text(diff, style: GoogleFonts.nunito()))).toList(),
                          onChanged: (val) => setState(() => _selectedDifficulty = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textDark),
                          decoration: _buildInputDecoration('Hazırlık (Dk)', Icons.timer_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cookTimeController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textDark),
                          decoration: _buildInputDecoration('Pişirme (Dk)', Icons.local_fire_department_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _servingsController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textDark),
                          decoration: _buildInputDecoration('Porsiyon', Icons.people_outline, surfaceColor, borderColor, primaryColor, textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textDark),
                    decoration: _buildInputDecoration('Kalori (Kcal) - İsteğe Bağlı', Icons.monitor_weight_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ingredientsController,
                    maxLines: 5,
                    style: TextStyle(color: textDark),
                    decoration: _buildInputDecoration('Malzemeler', Icons.shopping_basket_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 7,
                    style: TextStyle(color: textDark),
                    decoration: _buildInputDecoration('Hazırlanışı', Icons.menu_book, surfaceColor, borderColor, primaryColor, textMuted),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _saveRecipe,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Tarifi Kaydet',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}