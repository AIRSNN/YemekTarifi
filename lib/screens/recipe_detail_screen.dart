import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_model.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart'; 

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {

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
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color primaryColor = const Color(0xFFE07A5F);

        return MasterLayout(
          title: widget.recipe.title,
          activeMenu: 'Yemek Tarifleri',
          onBack: () => Navigator.pop(context), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kapak Fotoğrafı Alanı (GÜNCELLENDİ: Sinematik Oran + Gradient)
                Container(
                  width: double.infinity,
                  height: 220, // 300'den 220'ye düşürüldü (İştah kapatmaması için daha zarif bir sinematik oran)
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Arka Plandaki Resim (Dinamik Yükleyici eklendi)
                        widget.recipe.coverImage != null
                            ? FutureBuilder<String>(
                                future: DatabaseHelper.instance.getImagePath(widget.recipe.coverImage!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasData) {
                                    return Image.file(
                                      File(snapshot.data!),
                                      fit: BoxFit.cover,
                                      // Eğer resim bozuksa veya bulunamazsa hata ikonu göster
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 64, color: textMuted),
                                    );
                                  }
                                  return Icon(Icons.restaurant, size: 64, color: textMuted);
                                },
                              )
                            : Icon(Icons.restaurant, size: 64, color: textMuted),
                        
                        // YENİ EKLENDİ: Premium Dergi Efekti (Alt kısıma siyah degrade)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4), // Resmin altını tatlıca koyulaştırır
                              ],
                              stops: const [0.6, 1.0], // Degrade sadece son %40'lık dilimde başlar
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Diğer her şey aynı kalıyor...
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: textMuted),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: const Color(0xFFF43F5E)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
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
                    height: 1.6, 
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 40),

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
                
                const SizedBox(height: 60), 
              ],
            ),
          ),
        );
      },
    );
  }
}