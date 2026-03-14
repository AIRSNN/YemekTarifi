import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart'; // YENİ EKLENDİ: Ortak Kapsayıcı

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // --- YENİ EKLENDİ: Master UI Yardımcı Metodu ---
  // Süre, Porsiyon gibi küçük istatistikleri göstermek için
  Widget _buildInfoColumn(String value, String label, IconData icon, Color isDarkColor, Color textMuted, Color primaryColor) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDarkColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema uyumu için ValueListenableBuilder
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

        // YENİ EKLENDİ: Tüm ekran MasterLayout içine alındı
        return MasterLayout(
          title: widget.recipe.title,
          activeMenu: 'Yemek Tarifleri',
          // Geri dönüş butonunu MasterLayout yönetir
          onBack: () => Navigator.pop(context), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kapak Fotoğrafı Alanı
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(24.0), // Master UI Kavis
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: widget.recipe.coverImage != null
                        // Eğer lokal resim sistemi tam çalışıyorsa buraya Image.file gelebilir.
                        // Şimdilik sorun çıkmaması için asset kullanıyoruz.
                        ? Image.asset(
                            widget.recipe.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 64, color: textMuted),
                          )
                        : Icon(Icons.restaurant, size: 64, color: textMuted),
                  ),
                ),
                
                const SizedBox(height: 32),

                // 2. Başlık ve Kategori
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipe.title,
                            style: GoogleFonts.nunito(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.recipe.category,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sağ üst köşede Düzenle/Sil ikonları eklenebilir
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: textMuted),
                          onPressed: () {
                            // İleride Edit ekranına yönlendirme
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: const Color(0xFFF43F5E)),
                          onPressed: () {
                            // İleride silme işlemi
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. İstatistikler (Süre, Zorluk, Porsiyon, Kalori)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoColumn('${widget.recipe.prepTime ?? 0} dk', 'Hazırlık', Icons.timer_outlined, textDark, textMuted, primaryColor),
                      _buildInfoColumn(widget.recipe.difficulty ?? '-', 'Zorluk', Icons.speed, textDark, textMuted, primaryColor),
                      _buildInfoColumn('${widget.recipe.servings ?? 0} Kişi', 'Porsiyon', Icons.restaurant, textDark, textMuted, primaryColor),
                      _buildInfoColumn('${widget.recipe.calories ?? 0} kcal', 'Enerji', Icons.local_fire_department_outlined, textDark, textMuted, primaryColor),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Malzemeler
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Malzemeler',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.recipe.ingredients ?? 'Malzeme bilgisi bulunamadı.',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.6, // Satır arası boşluk okunabilirliği artırır
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 40),

                // 5. Hazırlanışı
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Hazırlanışı',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.recipe.instructions ?? 'Hazırlanış bilgisi bulunamadı.',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.6,
                    color: textDark,
                  ),
                ),
                
                const SizedBox(height: 60), // En altta biraz nefes alma boşluğu
              ],
            ),
          ),
        );
      },
    );
  }
}