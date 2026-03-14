import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _currentRecipe;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _isFavorite = _currentRecipe.isFavorite; 
  }

  void _deleteRecipe(BuildContext context, Color surfaceColor, Color textDark, Color primaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text('Tarifi Sil', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: textDark)),
          content: Text('${_currentRecipe.title} adlı tarifi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
              style: GoogleFonts.nunito(color: textDark)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('İptal', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteRecipe(_currentRecipe.id!);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), elevation: 0),
              child: Text('Evet, Sil', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    final updatedRecipe = Recipe(
      id: _currentRecipe.id,
      title: _currentRecipe.title,
      category: _currentRecipe.category,
      isFavorite: _isFavorite,
      createdAt: _currentRecipe.createdAt,
      shortDescription: _currentRecipe.shortDescription,
      ingredients: _currentRecipe.ingredients,
      instructions: _currentRecipe.instructions,
      coverImage: _currentRecipe.coverImage,
      prepTime: _currentRecipe.prepTime,
      cookTime: _currentRecipe.cookTime,
      servings: _currentRecipe.servings,
      difficulty: _currentRecipe.difficulty,
      calories: _currentRecipe.calories,
      protein: _currentRecipe.protein,
      fat: _currentRecipe.fat,
      carbs: _currentRecipe.carbs,
    );
    await DatabaseHelper.instance.updateRecipe(updatedRecipe);
    _currentRecipe = updatedRecipe;
  }

  // --- YARDIMCI WIDGET'LAR (DERGİ DÜZENİ) ---

  Widget _buildTopBadge(IconData icon, String title, String value, Color iconColor, Color textDark, Color textMuted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.nunito(fontSize: 11, color: textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, Color textDark, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 14, color: textMuted, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: textDark)),
        ],
      ),
    );
  }

  List<Widget> _buildIngredientList(String ingredients, Color textDark, Color textMuted) {
    final List<String> lines = ingredients.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [Text('Malzeme bilgisi yok.', style: GoogleFonts.nunito(color: textMuted))];

    return lines.map((line) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•', style: TextStyle(color: const Color(0xFFE07A5F), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(line.trim(), style: GoogleFonts.nunito(fontSize: 15, color: textDark, height: 1.5, fontWeight: FontWeight.w600))),
        ],
      ),
    )).toList();
  }

  // YENİ: Hazırlanış adımlarını 01, 02 diye bölen fonksiyon
  List<Widget> _buildInstructionSteps(String instructions, Color surfaceColor, Color borderColor, Color primaryColor, Color textDark) {
    final List<String> steps = instructions.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (steps.isEmpty) return [Text('Hazırlanış bilgisi yok.', style: GoogleFonts.nunito(color: textDark))];

    return steps.asMap().entries.map((entry) {
      int index = entry.key + 1;
      String stepText = entry.value;
      // "01", "02" formatı için
      String stepNumber = index.toString().padLeft(2, '0');

      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepNumber,
              style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  stepText.trim(),
                  style: GoogleFonts.nunito(fontSize: 15, height: 1.6, color: textDark, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F); 
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        return MasterLayout(
          title: '', // Üst menü başlığı boş, dergi başlığı sayfa içinde olacak
          activeMenu: 'Yemek Tarifleri',
          onBack: () => Navigator.pop(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- 1. KAPAK FOTOĞRAFI (HERO IMAGE) ---
                Container(
                  width: double.infinity,
                  height: 350, 
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(32.0),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.0),
                    child: _currentRecipe.coverImage != null && _currentRecipe.coverImage!.isNotEmpty && _currentRecipe.coverImage != 'assets/placeholder.png'
                        ? FutureBuilder<String>(
                            future: DatabaseHelper.instance.getImagePath(_currentRecipe.coverImage!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              if (snapshot.hasData) return Image.file(File(snapshot.data!), fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.broken_image, size: 64, color: textMuted));
                              return Icon(Icons.restaurant, size: 64, color: textMuted);
                            },
                          )
                        : Icon(Icons.restaurant, size: 64, color: textMuted),
                  ),
                ),
                
                const SizedBox(height: 32),

                // --- 2. YATAY BİLGİ ROZETLERİ (PILLS) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBadge(Icons.restaurant, 'Kategori', _currentRecipe.category, primaryColor, textDark, textMuted),
                    _buildTopBadge(Icons.people_outline, 'Porsiyon', '${_currentRecipe.servings ?? '-'} Kişi', Colors.amber[700]!, textDark, textMuted),
                    _buildTopBadge(Icons.timer_outlined, 'Hazırlık', '${_currentRecipe.prepTime ?? '-'} Dk', Colors.teal, textDark, textMuted),
                    _buildTopBadge(Icons.local_fire_department_outlined, 'Pişirme', '${_currentRecipe.cookTime ?? '-'} Dk', const Color(0xFFF43F5E), textDark, textMuted),
                    _buildTopBadge(Icons.speed, 'Zorluk', _currentRecipe.difficulty ?? '-', Colors.deepPurple, textDark, textMuted),
                  ],
                ),

                const SizedBox(height: 40),

                // --- 3. BAŞLIK, HİKAYE VE AKSİYONLAR ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Taraf: Başlık ve Hikaye
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentRecipe.title,
                            style: GoogleFonts.nunito(fontSize: 48, fontWeight: FontWeight.w900, color: textDark, height: 1.1),
                          ),
                          const SizedBox(height: 16),
                          if (_currentRecipe.shortDescription != null && _currentRecipe.shortDescription!.isNotEmpty)
                            Text(
                              _currentRecipe.shortDescription!,
                              style: GoogleFonts.nunito(fontSize: 16, color: textMuted, fontWeight: FontWeight.w600, height: 1.6),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    // Sağ Taraf: Yıldızlar, Favori, Düzenle/Sil Butonları
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Derecelendirme Yıldızları (Şimdilik Mock Veri 4.5 yıldız)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ...List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 24)),
                              const Icon(Icons.star_half, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              Text('(12)', style: GoogleFonts.nunito(color: textMuted, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Favori, Düzenle ve Sil Butonları
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: _toggleFavorite,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                                  child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? const Color(0xFFF43F5E) : textMuted, size: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeScreen(recipe: _currentRecipe)))
                                  .then((updated) { if (updated != null) setState(() => _currentRecipe = updated); });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                                  child: Icon(Icons.edit, color: textMuted, size: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _deleteRecipe(context, surfaceColor, textDark, primaryColor),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECDD3))),
                                  child: const Icon(Icons.delete, color: Color(0xFFF43F5E), size: 22),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // --- 4. İKİLİ KOLON: MALZEMELER VE BESİN DEĞERLERİ ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SOL KOLON: MALZEMELER (Geniş Liste)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Malzemeler', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: textDark)),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildIngredientList(_currentRecipe.ingredients ?? '', textDark, textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    // SAĞ KOLON: BESİN DEĞERLERİ & ALERJİ
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Besin Değerleri', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: textDark)),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNutritionRow('Kalori', '${_currentRecipe.calories ?? '-'} kcal', textDark, textMuted),
                                _buildNutritionRow('Protein', '${_currentRecipe.protein ?? '-'} g', textDark, textMuted),
                                _buildNutritionRow('Yağ', '${_currentRecipe.fat ?? '-'} g', textDark, textMuted),
                                _buildNutritionRow('Karbonhidrat', '${_currentRecipe.carbs ?? '-'} g', textDark, textMuted),
                                // Şimdilik MOCK (Örnek) veriler
                                _buildNutritionRow('Lif', '5 g', textDark, textMuted),
                                _buildNutritionRow('Şeker', '2 g', textDark, textMuted),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Alerji Uyarıları (Mock Veri)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Alerjen Uyarısı', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.amber[800])),
                                      const SizedBox(height: 4),
                                      Text('Gluten, Süt Ürünleri', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // --- 5. ADIM ADIM HAZIRLANIŞ ---
                Row(
                  children: [
                    Text('Pişirme', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: textDark)),
                    const SizedBox(width: 8),
                    Text('Adımları', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 24),
                
                ..._buildInstructionSteps(_currentRecipe.instructions ?? '', surfaceColor, borderColor, primaryColor, textDark),

                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }
}