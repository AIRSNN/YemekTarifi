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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  // Veritabanından tüm tarifleri çeker
  Future<void> _refreshRecipes() async {
    setState(() => _isLoading = true);
    final recipes = await DatabaseHelper.instance.readAllRecipes();
    setState(() {
      _allRecipes = recipes;
      _isLoading = false;
    });
    _applyFilters();
  }

  // Arama ve kategoriye göre listeyi süzer (Hafızada anlık çalışır)
  void _applyFilters() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final matchesCategory = _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
        final matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              recipe.ingredients.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Kitabım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- ARAMA ÇUBUĞU ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                labelText: 'Tarif veya malzeme ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear), 
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _applyFilters();
                        }
                      ) 
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // --- KATEGORİ FİLTRELERİ (YATAY KAYDIRMA) ---
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _selectedCategory = category;
                        _applyFilters(); // Kategori değiştiğinde anında filtrele
                      }
                    },
                    selectedColor: Colors.deepOrangeAccent.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepOrange[900] : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // --- TARİF LİSTESİ ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
                    ? const Center(
                        child: Text(
                          'Aranan kriterlere uygun tarif bulunamadı.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  // Liste görünümünde de kategori rozeti
                                  Text(
                                    recipe.category,
                                    style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.ingredients,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                                // Detaydan dönünce listeyi tazele
                                if (result == true || result != null) {
                                  _refreshRecipes();
                                }
                              },
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