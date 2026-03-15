import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart';
import 'edit_recipe_screen.dart'; // Düzenleme ekranı import edildi

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Recipe _currentRecipe;
  bool _isLoading = true; // Resim yükleme vs için loading state'i ekledik

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _loadRecipeDetails();
  }

  // Yenilenmiş tarifi getirmek için (Edit'ten dönünce)
  Future<void> _loadRecipeDetails() async {
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleFavorite() async {
    final updatedRecipe = _currentRecipe.copyWith(
      isFavorite: _currentRecipe.isFavorite == 1 ? 0 : 1,
    );
    await _dbHelper.updateRecipe(updatedRecipe);
    setState(() {
      _currentRecipe = updatedRecipe;
    });
    
    // Snackbar ile bilgi verelim
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(_currentRecipe.isFavorite == 1 ? 'Favorilere Eklendi' : 'Favorilerden Çıkarıldı'),
           backgroundColor: _currentRecipe.isFavorite == 1 ? Colors.green : Colors.redAccent,
           duration: const Duration(seconds: 1),
         )
       );
    }
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tarifi Sil', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: Text('${_currentRecipe.title} silinecek. Onaylıyor musunuz?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _dbHelper.deleteRecipe(_currentRecipe.id!);
              if (!mounted) return;
              Navigator.pop(context); // Dialogu kapat
              Navigator.pop(context, true); // Ekranı kapat ve listeyi güncellemek için 'true' dön
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color bg, Color iconColor, Color textDark, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Sıkışıklığı önlemek için
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color textDark, Color textMuted, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // MÜHENDİSLİK ÇÖZÜMÜ: Dümdüz metni alıp, "01, 02" diye tasarımlı satırlara bölen Widget
  Widget _buildInstructionSteps(String instructionsText, Color textDark, Color primaryColor, Color borderColor) {
    // Paragrafları veya satırları bölüyoruz
    List<String> steps = instructionsText.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return ListView.separated(
      shrinkWrap: true, // Scrollable column içinde sorun çıkarmaması için
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Divider(color: borderColor, height: 1),
      ),
      itemBuilder: (context, index) {
        String stepNumber = (index + 1).toString().padLeft(2, '0'); // 1 -> "01"
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepNumber,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: primaryColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  steps[index].trim(),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.6,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color bgLayer1 = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color bgLayer2 = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F);
        final Color borderColor = isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0);

        if (_isLoading) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return MasterLayout(
          title: 'Tarif Detayı',
          activeMenu: 'Yemek Tarifleri',
          onBack: () => Navigator.pop(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Vitrin Resmi
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: bgLayer2,
                    border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  child: _currentRecipe.coverImage != null && _currentRecipe.coverImage!.isNotEmpty
                      ? FutureBuilder<String>(
                          future: _dbHelper.getImagePath(_currentRecipe.coverImage!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasData) {
                              return Image.file(
                                File(snapshot.data!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 64, color: textMuted.withOpacity(0.5)),
                              );
                            }
                            return Icon(Icons.restaurant, size: 64, color: textMuted.withOpacity(0.5));
                          },
                        )
                      : Center(child: Icon(Icons.restaurant, size: 64, color: textMuted.withOpacity(0.5))),
                ),

                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Hızlı Bilgi Kartları
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInfoCard('Kategori', _currentRecipe.category, Icons.restaurant_menu, bgLayer1, primaryColor, textDark, textMuted),
                          _buildInfoCard('Porsiyon', '${_currentRecipe.servings} Kişi', Icons.people_outline, bgLayer1, Colors.orange, textDark, textMuted),
                          _buildInfoCard('Hazırlık', '${_currentRecipe.prepTime} Dk', Icons.timer_outlined, bgLayer1, Colors.teal, textDark, textMuted),
                          _buildInfoCard('Pişirme', '${_currentRecipe.cookTime} Dk', Icons.local_fire_department_outlined, bgLayer1, Colors.redAccent, textDark, textMuted),
                          _buildInfoCard('Zorluk', _currentRecipe.difficulty ?? 'Belirtilmedi', Icons.speed, bgLayer1, Colors.purpleAccent, textDark, textMuted),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // 3. Başlık ve Aksiyon Butonları
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentRecipe.title,
                                  style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w900, color: textDark, height: 1.1),
                                ),
                                if (_currentRecipe.shortDescription != null && _currentRecipe.shortDescription!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentRecipe.shortDescription!,
                                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: textMuted),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: bgLayer1,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _currentRecipe.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
                                    color: _currentRecipe.isFavorite == 1 ? Colors.redAccent : textMuted,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: bgLayer1,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit_outlined, color: textMuted),
                                  onPressed: () async {
                                     final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditRecipeScreen(recipe: _currentRecipe),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {});
                                      }
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: _deleteRecipe,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // 4. İçerik ve Besin Değerleri (Grid Yapısı)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Malzemeler',
                                  style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: textDark),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: bgLayer1,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: _currentRecipe.ingredients != null && _currentRecipe.ingredients!.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: _currentRecipe.ingredients!
                                              .split('\n')
                                              .where((item) => item.trim().isNotEmpty)
                                              .map((ingredient) => Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 6, right: 12),
                                                          width: 6,
                                                          height: 6,
                                                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            ingredient.trim(),
                                                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: textDark),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        )
                                      : Text('Malzeme listesi bulunamadı.', style: TextStyle(color: textMuted)),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 32),
                          
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Besin Değerleri',
                                  style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: textDark),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: bgLayer1,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildNutritionRow('Kalori', '${_currentRecipe.calories ?? '-'} kcal', textDark, textMuted, isBold: true),
                                      Divider(color: borderColor, height: 24),
                                      _buildNutritionRow('Protein', '${_currentRecipe.protein ?? '-'} g', textDark, textMuted),
                                      _buildNutritionRow('Yağ', '${_currentRecipe.fat ?? '-'} g', textDark, textMuted),
                                      _buildNutritionRow('Karbonhidrat', '${_currentRecipe.carbs ?? '-'} g', textDark, textMuted),
                                      
                                      if (_currentRecipe.tags != null && _currentRecipe.tags!.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Etiket / Alerjen', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.orange)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _currentRecipe.tags!,
                                                      style: GoogleFonts.nunito(fontSize: 13, color: textDark),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),

                      // 5. Hazırlanış Adımları (MÜHENDİSLİK ÇÖZÜMÜ: YENİ TASARIM)
                      Row(
                        children: [
                          Text(
                            'Pişirme ',
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: textDark),
                          ),
                          Text(
                            'Adımları',
                            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: bgLayer1,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: _currentRecipe.instructions != null && _currentRecipe.instructions!.isNotEmpty
                            // Düz metin yerine yeni metodu çağırıyoruz:
                            ? _buildInstructionSteps(_currentRecipe.instructions!, textDark, primaryColor, borderColor)
                            : Text('Tarif adımları bulunamadı.', style: TextStyle(color: textMuted)),
                      ),
                      
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}