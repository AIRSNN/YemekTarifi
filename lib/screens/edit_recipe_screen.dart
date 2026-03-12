import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _shortDescController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;

  String? _selectedCategory;
  String? _selectedDifficulty;

  final List<String> _categories = [
    'Çorba',
    'Ana Yemek',
    'Sebze Yemeği',
    'Et Yemeği',
    'Baklagil',
    'Dolma-Sarma',
    'Hamur İşi',
    'Pilav',
    'Meze',
    'Salata',
    'Kahvaltılık',
    'Tatlı',
  ];

  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor', 'Şef Seviyesi'];

  File? _newSelectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _shortDescController = TextEditingController(text: widget.recipe.shortDescription);
    _ingredientsController = TextEditingController(text: widget.recipe.ingredients);
    _instructionsController = TextEditingController(text: widget.recipe.instructions);
    _prepTimeController = TextEditingController(text: widget.recipe.prepTime?.toString() ?? '');
    _cookTimeController = TextEditingController(text: widget.recipe.cookTime?.toString() ?? '');
    _servingsController = TextEditingController(text: widget.recipe.servings?.toString() ?? '');
    _caloriesController = TextEditingController(text: widget.recipe.calories?.toString() ?? '');
    _selectedCategory = widget.recipe.category;
    _selectedDifficulty = widget.recipe.difficulty;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newSelectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      String? finalImageName = widget.recipe.coverImage;

      if (_newSelectedImage != null) {
        finalImageName = await DatabaseHelper.instance.saveImageLocally(_newSelectedImage!);
      }

      int? tryParseInt(String text) {
        if (text.trim().isEmpty) return null;
        return int.tryParse(text.trim());
      }

      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        category: _selectedCategory!,
        ingredients: _ingredientsController.text.trim(),
        instructions: _instructionsController.text.trim(),
        coverImage: finalImageName,
        prepTime: tryParseInt(_prepTimeController.text),
        cookTime: tryParseInt(_cookTimeController.text),
        servings: tryParseInt(_servingsController.text),
        difficulty: _selectedDifficulty,
        tags: widget.recipe.tags,
        isFavorite: widget.recipe.isFavorite,
        ratingScore: widget.recipe.ratingScore,
        reviewCount: widget.recipe.reviewCount,
        calories: tryParseInt(_caloriesController.text),
        protein: widget.recipe.protein,
        fat: widget.recipe.fat,
        carbs: widget.recipe.carbs,
        isDailySpecial: widget.recipe.isDailySpecial,
        viewCount: widget.recipe.viewCount,
        createdAt: widget.recipe.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.updateRecipe(updatedRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarif başarıyla güncellendi!')),
        );
        Navigator.pop(context, updatedRecipe);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarifi Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _newSelectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_newSelectedImage!, fit: BoxFit.cover),
                        )
                      : FutureBuilder<String>(
                          future: DatabaseHelper.instance.getImagePath(widget.recipe.coverImage ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && widget.recipe.coverImage != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(snapshot.data!), fit: BoxFit.cover),
                              );
                            }
                            return const Center(child: Icon(Icons.add_a_photo, size: 50));
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Yemek Adı', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shortDescController,
                decoration: const InputDecoration(labelText: 'Kısa Açıklama', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(labelText: 'Zorluk', border: OutlineInputBorder()),
                      items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _selectedDifficulty = v),
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
                      decoration: const InputDecoration(labelText: 'Hazırlık (dk)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Pişirme (dk)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Porsiyon', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kalori', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Malzemeler', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Hazırlanışı',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) => value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Değişiklikleri Kaydet'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
