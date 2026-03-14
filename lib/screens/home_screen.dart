import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/recipe_card.dart';
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
  TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'Tümü';
  String _selectedMenuItem = 'Yemek Tarifleri'; 
  bool _isDarkMode = false; 

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

  Future<void> _refreshRecipes() async {
    final data = await _dbHelper.readAllRecipes();
    setState(() {
      _recipes = data;
      _filterRecipes();
    });
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _recipes.where((recipe) {
        final matchesSearch = recipe.title.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildMenuItem(String title, IconData icon) {
    bool isActive = _selectedMenuItem == title;
    Color primaryColor = const Color(0xFFE07A5F);
    Color textColor = isActive ? primaryColor : (_isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    Color bgColor = isActive 
        ? (_isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1)) 
        : Colors.transparent;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMenuItem = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.nunito(
                color: textColor,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color surfaceColor = _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final Color borderColor = _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textDark = _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final Color textMuted = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryColor = const Color(0xFFE07A5F);

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // ==========================================
          // 1. BÖLÜM: SOL MENÜ (SIDEBAR)
          // ==========================================
          Container(
            width: 260, 
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(right: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / Başlık Alanı
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerLeft,
                  // DEĞİŞTİRİLDİ: Hata veren "border:" yapısı düzeltildi, BoxDecoration içine alındı.
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant_menu, color: Color(0xFFE07A5F), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Master Şef',
                        style: GoogleFonts.nunito(
                          color: textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuItem('Giriş', Icons.dashboard_outlined),
                _buildMenuItem('Yemek Tarifleri', Icons.receipt_long_outlined),
                _buildMenuItem('Listeleri', Icons.format_list_bulleted),
                _buildMenuItem('Ayarlar', Icons.settings_outlined),
              ],
            ),
          ),

          // ==========================================
          // 2. VE 3. BÖLÜM: ÜST MENÜ (TOPBAR) VE ANA İÇERİK
          // ==========================================
          Expanded(
            child: Column(
              children: [
                // --- ÜST MENÜ (TOPBAR) ---
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedMenuItem,
                        style: GoogleFonts.nunito(
                          color: textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(12),
                                color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _isDarkMode ? 'Karanlık Mod' : 'Aydınlık Mod',
                                    style: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                    color: _isDarkMode ? Colors.blue[300] : Colors.orange,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () => exit(0), 
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2), 
                                border: Border.all(color: const Color(0xFFFECDD3)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.power_settings_new, color: Color(0xFFF43F5E), size: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // --- ANA İÇERİK ---
                Expanded(
                  child: _selectedMenuItem == 'Yemek Tarifleri' 
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: textDark),
                            decoration: InputDecoration(
                              hintText: 'Tariflerde ara...',
                              hintStyle: GoogleFonts.nunito(color: textMuted, fontWeight: FontWeight.w600),
                              prefixIcon: Icon(Icons.search, color: textMuted),
                              filled: true,
                              fillColor: surfaceColor,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: borderColor, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: primaryColor, width: 2.0),
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
                                      _filterRecipes();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryColor : surfaceColor,
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: isSelected ? primaryColor : borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (isSelected) ...[
                                          const Icon(Icons.check, size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          category,
                                          style: GoogleFonts.nunito(
                                            color: isSelected ? Colors.white : textMuted,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
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
                                    style: GoogleFonts.nunito(color: textMuted, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  itemCount: _filteredRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _filteredRecipes[index];
                                    return RecipeCard(
                                      title: recipe.title,
                                      category: recipe.category,
                                      time: '${recipe.prepTime ?? 0} dk',
                                      difficulty: recipe.difficulty ?? '-',
                                      imagePath: recipe.coverImage ?? 'assets/placeholder.png',
                                      isDarkMode: _isDarkMode, // DEĞİŞTİRİLDİ: Dark mode durumu karta geçirildi
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RecipeDetailScreen(recipe: recipe),
                                          ),
                                        ).then((_) => _refreshRecipes());
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        '$_selectedMenuItem Ekranı Yapım Aşamasında',
                        style: GoogleFonts.nunito(color: textMuted, fontSize: 18),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedMenuItem == 'Yemek Tarifleri' 
        ? FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRecipeScreen()),
              );
              _refreshRecipes();
            },
            backgroundColor: _isDarkMode ? primaryColor.withOpacity(0.2) : const Color(0xFFFEE8E1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: Color(0xFFE07A5F), width: 1.5),
            ),
            icon: const Icon(Icons.add, color: Color(0xFFE07A5F)),
            label: Text(
              'Yeni Tarif',
              style: GoogleFonts.nunito(
                color: const Color(0xFFE07A5F),
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        : null, 
    );
  }
}