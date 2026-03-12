import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Temel Metin Kontrolcüleri
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController(); 
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController(); // EKLENDİ: Hazırlanış Kontrolcüsü
  
  // Operasyonel Veri Kontrolcüleri (Sayısal)
  final _prepTimeController = TextEditingController(); 
  final _cookTimeController = TextEditingController(); 
  final _servingsController = TextEditingController(); 
  final _caloriesController = TextEditingController(); 

  // Kategori ve Zorluk Seçicileri
  String? _selectedCategory;
  final List<String> _categories = [
    'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği', 
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 
    'Meze', 'Salata', 'Kahvaltılık', 'Tatlı'
  ];

  String? _selectedDifficulty; 
  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor', 'Şef Seviyesi'];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      String? savedImageName;
      
      if (_selectedImage != null) {
        savedImageName = await DatabaseHelper.instance.saveImageLocally(_selectedImage!);
      }

      int? tryParseInt(String text) {
        if (text.trim().isEmpty) return null;
        return int.tryParse(text.trim());
      }

      final newRecipe = Recipe(
        title: _titleController.text.trim(),
        shortDescription: _shortDescController.text.trim(), 
        category: _selectedCategory!, 
        ingredients: _ingredientsController.text.trim(),
        instructions: _instructionsController.text.trim(), // EKLENDİ: Hazırlanış metnini modele gönderiyoruz
        coverImage: savedImageName, 
        difficulty: _selectedDifficulty, 
        prepTime: tryParseInt(_prepTimeController.text), 
        cookTime: tryParseInt(_cookTimeController.text), 
        servings: tryParseInt(_servingsController.text), 
        calories: tryParseInt(_caloriesController.text), 
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.createRecipe(newRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarif başarıyla kaydedildi!')),
        );
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose(); // EKLENDİ
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Tarif Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- VİTRİN GÖRSELİ ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Vitrin Resmi Ekle', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Yemek Adı', border: OutlineInputBorder(), prefixIcon: Icon(Icons.restaurant)),
                validator: (value) => value == null || value.isEmpty ? 'Lütfen yemek adını girin' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _shortDescController,
                decoration: const InputDecoration(labelText: 'Kısa Açıklama (İsteğe Bağlı)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.subtitles)),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                      value: _selectedCategory,
                      items: _categories.map((String category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                      onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                      validator: (value) => value == null ? 'Seçiniz' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Zorluk', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed)),
                      value: _selectedDifficulty,
                      items: _difficulties.map((String diff) => DropdownMenuItem(value: diff, child: Text(diff))).toList(),
                      onChanged: (newValue) => setState(() => _selectedDifficulty = newValue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: TextFormField(controller: _prepTimeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hazırlık (Dk)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.timer_outlined)))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _cookTimeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pişirme (Dk)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_fire_department)))),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: _servingsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porsiyon', border: OutlineInputBorder(), prefixIcon: Icon(Icons.people)))),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(controller: _caloriesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kalori (Kcal) - İsteğe Bağlı', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monitor_weight))),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Malzemeler', border: OutlineInputBorder(), prefixIcon: Icon(Icons.format_list_bulleted)),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Lütfen malzemeleri girin' : null,
              ),
              const SizedBox(height: 16),

              // EKLENDİ: Hazırlanışı Metin Kutusu
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Hazırlanışı', border: OutlineInputBorder(), prefixIcon: Icon(Icons.menu_book)),
                maxLines: 6,
                validator: (value) => value == null || value.isEmpty ? 'Lütfen hazırlanış adımlarını girin' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Tarifi Kaydet'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}