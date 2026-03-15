import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _selectedImageFile;

  final List<String> _categories = [
    'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği',
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 'Meze',
    'Salata', 'Kahvaltılık', 'Tatlı'
  ];

  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor'];

  // BELLEK YÖNETİMİ: Ekran kapandığında tüm controller'ları RAM'den temizle
  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Widget _buildLabeledField(String label, Widget field, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        field,
        const SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    IconData icon,
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    Color textMuted,
  ) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: textMuted, size: 20),
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
        coverImage: finalImageName,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Veritabanı I/O işlemi
      await _dbHelper.createRecipe(newRecipe);
      
      // ASENKRON GÜVENLİK BARIYERİ: İşlem bitene kadar ekran kapatıldıysa hata verme
      if (!mounted) return; 
      
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

                  // 1. Resim Ekleme Alanı
                  _buildLabeledField(
                    'Vitrin Resmi',
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: _selectedImageFile != null ? primaryColor : borderColor,
                            width: _selectedImageFile != null ? 2 : 1,
                          ),
                        ),
                        child: _selectedImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: Image.file(
                                  _selectedImageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48, color: textMuted.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Bilgisayardan Seç',
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
                    textMuted,
                  ),

                  // 2. Başlık ve Kısa Açıklama
                  _buildLabeledField(
                    'Yemek Adı',
                    TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: textDark),
                      decoration: _buildInputDecoration(
                          Icons.restaurant_menu, surfaceColor, borderColor, primaryColor, textMuted),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Yemek adı zorunludur' : null,
                    ),
                    textMuted,
                  ),

                  _buildLabeledField(
                    'Kısa Açıklama (İsteğe Bağlı)',
                    TextFormField(
                      controller: _shortDescController,
                      style: TextStyle(color: textDark),
                      decoration: _buildInputDecoration(
                          Icons.short_text, surfaceColor, borderColor, primaryColor, textMuted),
                    ),
                    textMuted,
                  ),

                  // 3. Kategori ve Zorluk
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          'Kategori Seçimi',
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: surfaceColor,
                            style: TextStyle(color: textDark),
                            decoration: _buildInputDecoration(
                                Icons.category, surfaceColor, borderColor, primaryColor, textMuted),
                            items: _categories
                                .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat, style: GoogleFonts.nunito())))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                          textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          'Zorluk Derecesi',
                          DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            dropdownColor: surfaceColor,
                            style: TextStyle(color: textDark),
                            decoration: _buildInputDecoration(
                                Icons.speed, surfaceColor, borderColor, primaryColor, textMuted),
                            items: _difficulties
                                .map((diff) => DropdownMenuItem(
                                    value: diff,
                                    child: Text(diff, style: GoogleFonts.nunito())))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedDifficulty = val!),
                          ),
                          textMuted,
                        ),
                      ),
                    ],
                  ),

                  // 4. Süreler ve Porsiyon
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          'Hazırlık (Dk)',
                          TextFormField(
                            controller: _prepTimeController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textDark),
                            decoration: _buildInputDecoration(
                                Icons.timer_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                          ),
                          textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          'Pişirme (Dk)',
                          TextFormField(
                            controller: _cookTimeController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textDark),
                            decoration: _buildInputDecoration(
                                Icons.local_fire_department_outlined,
                                surfaceColor,
                                borderColor,
                                primaryColor,
                                textMuted),
                          ),
                          textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          'Porsiyon (Kişi)',
                          TextFormField(
                            controller: _servingsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textDark),
                            decoration: _buildInputDecoration(
                                Icons.people_outline, surfaceColor, borderColor, primaryColor, textMuted),
                          ),
                          textMuted,
                        ),
                      ),
                    ],
                  ),

                  // 5. Kalori
                  _buildLabeledField(
                    'Enerji (Kcal)',
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textDark),
                      decoration: _buildInputDecoration(
                          Icons.monitor_weight_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                    ),
                    textMuted,
                  ),

                  // 6. Geniş Alanlar
                  _buildLabeledField(
                    'Malzemeler',
                    TextFormField(
                      controller: _ingredientsController,
                      maxLines: 5,
                      style: TextStyle(color: textDark),
                      decoration: _buildInputDecoration(
                          Icons.shopping_basket_outlined, surfaceColor, borderColor, primaryColor, textMuted),
                    ),
                    textMuted,
                  ),

                  _buildLabeledField(
                    'Hazırlanışı',
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 7,
                      style: TextStyle(color: textDark),
                      decoration: _buildInputDecoration(
                          Icons.menu_book, surfaceColor, borderColor, primaryColor, textMuted),
                    ),
                    textMuted,
                  ),

                  const SizedBox(height: 8),

                  // 7. Kaydet Butonu
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