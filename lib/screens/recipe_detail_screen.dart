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

    if (confirm == true) {
      await DatabaseHelper.instance.deleteRecipe(_currentRecipe.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRecipeScreen(recipe: _currentRecipe),
                ),
              );
              if (result != null && result is Recipe) {
                setState(() => _currentRecipe = result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: DatabaseHelper.instance.getImagePath(_currentRecipe.coverImage ?? ''),
              builder: (context, snapshot) {
                if (snapshot.hasData && _currentRecipe.coverImage != null) {
                  return Image.file(
                    File(snapshot.data!),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  );
                }
                return _buildNoImagePlaceholder();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRecipe.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _currentRecipe.category,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.timer, "${_currentRecipe.prepTime ?? '-'} dk", "Hazırlık"),
                      _buildInfoItem(Icons.speed, _currentRecipe.difficulty ?? "Orta", "Zorluk"),
                      _buildInfoItem(Icons.restaurant, "${_currentRecipe.servings ?? '-'} Kişi", "Porsiyon"),
                      _buildInfoItem(Icons.local_fire_department, "${_currentRecipe.calories ?? '-'} kcal", "Enerji"),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1),
                  if (_currentRecipe.shortDescription != null && _currentRecipe.shortDescription!.isNotEmpty) ...[
                    Text(
                      _currentRecipe.shortDescription!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Row(
                    children: [
                      Icon(Icons.shopping_basket, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Malzemeler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentRecipe.ingredients ?? "Malzeme belirtilmedi.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Hazırlanışı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentRecipe.instructions ?? "Hazırlanış bilgisi belirtilmedi.",
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrange),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
    );
  }
}
