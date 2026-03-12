import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/recipe_model.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedCategory = 'Tümü';

  final List<String> _categories = [
    'Tümü', 'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği', 
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 
    'Meze', 'Salata', 'Kahvaltılık', 'Tatlı'
  ];

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  Future<void> _refreshRecipes() async {
    setState(() => _isLoading = true);
    final recipes = await DatabaseHelper.instance.readAllRecipes();
    setState(() {
      _allRecipes = recipes;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Kitabım v3'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. ARAMA ÇUBUĞU
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tariflerde ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          
          // 2. KATEGORİ SEÇİCİ (Yatay Kaydırılabilir)
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 3. TARİF LİSTESİ (V3 Tasarımı)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
                    ? const Center(child: Text('Aradığınız kriterde tarif bulunamadı.'))
                    : ListView.builder(
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                                _refreshRecipes();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    // Tarif Resmi
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: FutureBuilder<String>(
                                        future: DatabaseHelper.instance.getImagePath(recipe.coverImage ?? ''),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && recipe.coverImage != null && recipe.coverImage!.isNotEmpty) {
                                            return Image.file(
                                              File(snapshot.data!),
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return Container(
                                            width: 90,
                                            height: 90,
                                            color: Colors.orange[50],
                                            child: const Icon(Icons.restaurant, color: Colors.orange, size: 40),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    
                                    // Bilgiler
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe.title,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recipe.shortDescription ?? recipe.category,
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // İkonlu Bilgi Satırı (V3 Yeniliği)
                                          Row(
                                            children: [
                                              if (recipe.prepTime != null) ...[
                                                const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Text('${recipe.prepTime} dk', style: const TextStyle(fontSize: 12)),
                                                const SizedBox(width: 12),
                                              ],
                                              if (recipe.difficulty != null) ...[
                                                const Icon(Icons.bar_chart, size: 14, color: Colors.redAccent),
                                                const SizedBox(width: 4),
                                                Text(recipe.difficulty!, style: const TextStyle(fontSize: 12)),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
          if (result == true) _refreshRecipes();
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Yeni Tarif'),
      ),
    );
  }
}