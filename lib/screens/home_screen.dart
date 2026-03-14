import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // YENİ EKLENDİ: Font paketi eklendi.
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/recipe_card.dart'; // YENİ EKLENDİ: Yeni yazdığımız kart widget'ı import edildi.
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

// --- YENİ EKLENDİ: Master UI Mutfak Renk Paleti Sabitleri ---
const Color kBackgroundColor = Color(0xFFF8FAFC); 
const Color kSurfaceColor = Color(0xFFFFFFFF); 
const Color kPrimaryColor = Color(0xFFE07A5F); // Mutfak için sıcak kiremit rengi
const Color kPrimaryLight = Color(0xFFFEE8E1); 
const Color kBorderColor = Color(0xFFE2E8F0); 
const Color kTextDark = Color(0xFF1E293B); 
const Color kTextMuted = Color(0xFF64748B); 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tümü';

  final List<String> _categories = [
    'Tümü',
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

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
    _searchController.addListener(_filterRecipes);
  }

  // MEVCUT KOD: Veritabanından verileri çekme fonksiyonu korundu.
  Future<void> _refreshRecipes() async {
    final data = await _dbHelper.getRecipes();
    setState(() {
      _recipes = data;
      _filterRecipes();
    });
  }

  // MEVCUT KOD: Arama ve kategori filtreleme mantığı korundu.
  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _recipes.where((recipe) {
        final matchesSearch = recipe.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tümü' || recipe.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // YENİ EKLENDİ: Şeftali rengi AppBar silindi, yerine beyaz, temiz Master UI Topbar eklendi.
      appBar: AppBar(
        backgroundColor: kSurfaceColor,
        elevation: 0, 
        centerTitle: true,
        title: Text(
          'Yemek Kitabım v3',
          style: GoogleFonts.nunito(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: kBorderColor, height: 1.0), 
        ),
      ),
      body: Column(
        children: [
          // YENİ EKLENDİ: Master UI standartlarında yuvarlak hatlı form elemanı (Arama)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tariflerde ara...',
                hintStyle: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600),
                prefixIcon: const Icon(Icons.search, color: kTextMuted),
                filled: true,
                fillColor: kSurfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), 
                  borderSide: const BorderSide(color: kBorderColor, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
                ),
              ),
            ),
          ),

          // YENİ EKLENDİ: Master UI Kategori Seçicileri (Tabs/Pills)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        color: isSelected ? kPrimaryColor : kSurfaceColor,
                        borderRadius: BorderRadius.circular(20.0), 
                        border: Border.all(
                          color: isSelected ? kPrimaryColor : kBorderColor,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
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
                              color: isSelected ? Colors.white : kTextMuted,
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
          
          const SizedBox(height: 16),

          // YENİ EKLENDİ: Eski liste yapısı silinip yeni yazdığımız RecipeCard bileşenine bağlandı.
          Expanded(
            child: _filteredRecipes.isEmpty
                ? Center(
                    child: Text(
                      'Tarif bulunamadı.',
                      style: GoogleFonts.nunito(color: kTextMuted, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return RecipeCard( 
                        title: recipe.name,
                        category: recipe.category,
                        time: '${recipe.prepTime} dk', 
                        difficulty: recipe.difficulty,
                        imagePath: recipe.imagePath ?? 'assets/placeholder.png', 
                        onTap: () {
                          // Detay sayfasına geçiş işlemi
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
      ),
      // YENİ EKLENDİ: Buton Master UI kavislerine ve renklerine uyarlandı.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
          _refreshRecipes(); // Dönüşte listeyi güncelle
        },
        backgroundColor: kPrimaryLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        icon: const Icon(Icons.add, color: kPrimaryColor),
        label: Text(
          'Yeni Tarif',
          style: GoogleFonts.nunito(
            color: kPrimaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}