import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DİNAMİK RESİM YÜKLEME ALANI ---
            if (recipe.imageName != null && recipe.imageName!.isNotEmpty)
              FutureBuilder<String>(
                future: DatabaseHelper.instance.getImagePath(recipe.imageName!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return _buildNoImagePlaceholder();
                  }
                  
                  // V1 (Yerel PC) ve V2 (Web Sunucu) Mimarisi kontrolü
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

            const SizedBox(height: 24),
            
            // Malzemeler Başlığı
            const Row(
              children: [
                Icon(Icons.shopping_basket, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Malzemeler',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Text(
              recipe.ingredients,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 32),
            
            // Hazırlanışı Başlığı
            const Row(
              children: [
                Icon(Icons.soup_kitchen, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Hazırlanışı',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Text(
              recipe.instructions,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
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