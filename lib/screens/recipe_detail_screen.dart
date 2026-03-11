import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _currentRecipe;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarifi Sil'),
        content: const Text('Bu tarifi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.deleteRecipe(_currentRecipe.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Düzenle',
            onPressed: () async {
              final updatedRecipe = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRecipeScreen(recipe: _currentRecipe),
                ),
              );

              if (updatedRecipe != null && updatedRecipe is Recipe) {
                setState(() {
                  _currentRecipe = updatedRecipe;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Sil',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentRecipe.imageName != null && _currentRecipe.imageName!.isNotEmpty)
              FutureBuilder<String>(
                future: DatabaseHelper.instance.getImagePath(_currentRecipe.imageName!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return _buildNoImagePlaceholder();
                  }
                  
                  if (DatabaseHelper.isLocalMode) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(snapshot.data!),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        snapshot.data!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
              )
            else
              _buildNoImagePlaceholder(),

            const SizedBox(height: 16),
            
            // --- KATEGORİ ROZETİ ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _currentRecipe.category,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.shopping_basket, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('Malzemeler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Text(_currentRecipe.ingredients, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 32),
            
            const Row(
              children: [
                Icon(Icons.soup_kitchen, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('Hazırlanışı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Text(_currentRecipe.instructions, style: const TextStyle(fontSize: 16, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Resim Yok', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}