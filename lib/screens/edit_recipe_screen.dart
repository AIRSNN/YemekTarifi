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
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late String _selectedCategory;
  
  final List<String> _categories = [
    'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği', 
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 
    'Meze', 'Salata', 'Kahvaltılık', 'Tatlı'
  ];
  
  File? _newSelectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _selectedCategory = widget.recipe.category; // Mevcut kategoriyi yükle
    _ingredientsController = TextEditingController(text: widget.recipe.ingredients);
    _instructionsController = TextEditingController(text: widget.recipe.instructions);
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
      String? updatedImageName = widget.recipe.imageName; 
      
      if (_newSelectedImage != null) {
        updatedImageName = await DatabaseHelper.instance.saveImageLocally(_newSelectedImage!);
      }

      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text,
        category: _selectedCategory, // Güncellenmiş kategori
        ingredients: _ingredientsController.text,
        instructions: _instructionsController.text,
        createdAt: widget.recipe.createdAt, 
        imageName: updatedImageName, 
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
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifi Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
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
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _newSelectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_newSelectedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : (widget.recipe.imageName != null && widget.recipe.imageName!.isNotEmpty)
                          ? FutureBuilder<String>(
                              future: DatabaseHelper.instance.getImagePath(widget.recipe.imageName!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: DatabaseHelper.isLocalMode
                                        ? Image.file(File(snapshot.data!), fit: BoxFit.cover, width: double.infinity)
                                        : Image.network(snapshot.data!, fit: BoxFit.cover, width: double.infinity),
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Yeni Resim Seç (İsteğe Bağlı)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Yemek Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Lütfen yemek adını girin' : null,
              ),
              const SizedBox(height: 16),
              // --- KATEGORİ SEÇİCİ ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Yemek Grubu / Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Lütfen bir kategori seçin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Malzemeler',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_bulleted),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Lütfen malzemeleri girin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Hazırlanışı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
                maxLines: 6,
                validator: (value) => value == null || value.isEmpty ? 'Lütfen hazırlanışını girin' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Değişiklikleri Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}