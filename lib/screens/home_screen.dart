import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/recipe_model.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart'; // Detay ekranı import edildi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  void _refreshRecipes() {
    setState(() {
      _recipesFuture = DatabaseHelper.instance.readAllRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Kitabım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Henüz tarif eklenmemiş.\nSağ alt köşeden yeni tarif ekleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepOrangeAccent,
                    child: Icon(Icons.restaurant_menu, color: Colors.white),
                  ),
                  title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                    recipe.ingredients,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Tıklandığında detay sayfasına yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
          
          if (result == true) {
            _refreshRecipes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Tarif'),
      ),
    );
  }
}