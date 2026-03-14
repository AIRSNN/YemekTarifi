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
  
  // YENİ EKLENDİ: Master UI Sekme (Tab) yönetimi için
  int _selectedTabIndex = 0; // 0: Malzemeler, 1: Hazırlanışı

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
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
            style: GoogleFonts.nunito(color: textDark)
          ),
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

  Widget _buildInfoColumn(String value, String label, IconData icon, Color isDarkColor, Color textMuted, Color primaryColor) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDarkColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 12, color: textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ],
    );
  }

  // YENİ EKLENDİ: Master UI v20 - Kesik İlerleme Çubukları (Segmented Bars)
  Widget _buildDifficultyBar(String? difficulty, Color primaryColor, Color surfaceColor, Color borderColor) {
    int level = 1;
    if (difficulty == 'Orta') level = 2;
    if (difficulty == 'Zor') level = 3;

    return Column(
      children: [
        Icon(Icons.speed, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 6, decoration: BoxDecoration(color: level >= 1 ? primaryColor : borderColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Container(width: 12, height: 6, decoration: BoxDecoration(color: level >= 2 ? primaryColor : borderColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Container(width: 12, height: 6, decoration: BoxDecoration(color: level >= 3 ? primaryColor : borderColor, borderRadius: BorderRadius.circular(2))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          difficulty ?? '-',
          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ],
    );
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
          title: _currentRecipe.title,
          activeMenu: 'Yemek Tarifleri',
          onBack: () => Navigator.pop(context), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kapak Fotoğrafı
                Container(
                  width: double.infinity,
                  height: 280, 
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(24.0), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _currentRecipe.coverImage != null && _currentRecipe.coverImage!.isNotEmpty && _currentRecipe.coverImage != 'assets/placeholder.png'
                            ? FutureBuilder<String>(
                                future: DatabaseHelper.instance.getImagePath(_currentRecipe.coverImage!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                                  if (snapshot.hasData) return Image.file(File(snapshot.data!), fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.broken_image, size: 64, color: textMuted));
                                  return Icon(Icons.restaurant, size: 64, color: textMuted);
                                },
                              )
                            : Icon(Icons.restaurant, size: 64, color: textMuted),
                        
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                              stops: const [0.5, 1.0], 
                            ),
                          ),
                        ),
                        // Resmin üzerine bindirilmiş kategori etiketi (Dergi tarzı)
                        Positioned(
                          bottom: 24,
                          left: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _currentRecipe.category.toUpperCase(),
                              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // 2. Başlık ve Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const SizedBox(height: 12),
                            Text(
                              _currentRecipe.shortDescription!,
                              style: GoogleFonts.nunito(fontSize: 16, color: textMuted, fontWeight: FontWeight.w500),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Master UI v20 - İkon Buton (Normal State)
                        Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: textMuted),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditRecipeScreen(recipe: _currentRecipe)),
                              ).then((updatedRecipe) {
                                if (updatedRecipe != null && updatedRecipe is Recipe) {
                                  setState(() => _currentRecipe = updatedRecipe);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Master UI v20 - İkon Buton (Danger)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFF43F5E)),
                            onPressed: () => _deleteRecipe(context, surfaceColor, textDark, primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 3. İstatistikler (Minimalist Düzende)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn('${_currentRecipe.prepTime ?? 0} dk', 'HAZIRLIK', Icons.timer_outlined, textDark, textMuted, primaryColor),
                    _buildDifficultyBar(_currentRecipe.difficulty, primaryColor, surfaceColor, borderColor),
                    _buildInfoColumn('${_currentRecipe.servings ?? 0} Kişi', 'PORSİYON', Icons.people_outline, textDark, textMuted, primaryColor),
                    _buildInfoColumn('${_currentRecipe.calories ?? 0} kcal', 'KALORİ', Icons.local_fire_department_outlined, textDark, textMuted, primaryColor),
                  ],
                ),

                const SizedBox(height: 40),

                // 4. YENİ: Master UI v20 Sekmeler (Tabs)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), // bg-slate-100
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0 ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedTabIndex == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                            ),
                            child: Center(
                              child: Text(
                                'Malzemeler',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedTabIndex == 0 ? Colors.white : textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1 ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedTabIndex == 1 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
                            ),
                            child: Center(
                              child: Text(
                                'Hazırlanışı',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedTabIndex == 1 ? Colors.white : textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Sekme İçeriği (Animasyonlu Geçiş eklenebilir, şimdilik direkt render)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: _selectedTabIndex == 0
                      // Malzemeler İçeriği
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shopping_basket_outlined, color: primaryColor, size: 24),
                                const SizedBox(width: 12),
                                Text('Neler Gerekiyor?', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: textDark)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentRecipe.ingredients ?? 'Malzeme bilgisi bulunamadı.',
                              style: GoogleFonts.nunito(fontSize: 16, height: 1.8, color: textDark),
                            ),
                          ],
                        )
                      // Hazırlanışı İçeriği
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book_outlined, color: primaryColor, size: 24),
                                const SizedBox(width: 12),
                                Text('Adım Adım', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: textDark)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentRecipe.instructions ?? 'Hazırlanış bilgisi bulunamadı.',
                              style: GoogleFonts.nunito(fontSize: 16, height: 1.8, color: textDark),
                            ),
                          ],
                        ),
                ),
                
                const SizedBox(height: 60), 
              ],
            ),
          ),
        );
      },
    );
  }
}