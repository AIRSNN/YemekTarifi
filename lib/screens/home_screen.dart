import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/recipe_card.dart';
import '../widgets/master_layout.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Tümü';

  final List<String> _categories = [
    'Tümü', 'Çorba', 'Ana Yemek', 'Sebze Yemeği', 'Et Yemeği',
    'Baklagil', 'Dolma-Sarma', 'Hamur İşi', 'Pilav', 'Meze',
    'Salata', 'Kahvaltılık', 'Tatlı',
  ];

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
    _searchController.addListener(_filterRecipes);
  }

  // BELLEK YÖNETİMİ: Arama çubuğu bellek sızıntısını önlemek için temizleniyor
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRecipes() async {
    final data = await _dbHelper.readAllRecipes();
    // PERFORMANS: Gereksiz çift setState çağrısı teke düşürüldü
    setState(() {
      _recipes = data;
      _applyFilter();
    });
  }

  void _filterRecipes() {
    setState(() {
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filteredRecipes = _recipes.where((recipe) {
      final matchesSearch = recipe.title
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color surfaceColor =
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color borderColor =
            isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final Color textDark =
            isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F);

        return MasterLayout(
          title: 'Yemek Tarifleri',
          activeMenu: 'Yemek Tarifleri',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
              );
              _refreshRecipes();
            },
            backgroundColor: isDark
                ? primaryColor.withOpacity(0.2)
                : const Color(0xFFFEE8E1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: primaryColor, width: 1.5),
            ),
            icon: Icon(Icons.add, color: primaryColor),
            label: Text('Yeni Tarif',
                style: GoogleFonts.nunito(
                    color: primaryColor, fontWeight: FontWeight.w800)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textDark),
                  decoration: InputDecoration(
                    hintText: 'Tariflerde ara...',
                    hintStyle: GoogleFonts.nunito(
                        color: textMuted, fontWeight: FontWeight.w600),
                    prefixIcon: Icon(Icons.search, color: textMuted),
                    filled: true,
                    fillColor: surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: borderColor, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _applyFilter();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : surfaceColor,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                                color: isSelected ? primaryColor : borderColor),
                          ),
                          child: Row(
                            children: [
                              if (isSelected) ...[
                                const Icon(Icons.check,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                category,
                                style: GoogleFonts.nunito(
                                  color: isSelected
                                      ? Colors.white
                                      : textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _filteredRecipes.isEmpty
                    ? Center(
                        child: Text(
                          'Tarif bulunamadı.',
                          style: GoogleFonts.nunito(
                              color: textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          // isDarkMode parametresi RecipeCard'dan kaldırıldı
                          return RecipeCard(
                            title: recipe.title,
                            category: recipe.category,
                            time: '${recipe.prepTime ?? 0} dk',
                            difficulty: recipe.difficulty ?? '-',
                            imagePath: recipe.coverImage ?? 'assets/placeholder.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe)),
                              ).then((_) => _refreshRecipes());
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}