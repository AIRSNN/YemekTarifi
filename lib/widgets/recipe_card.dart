import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../widgets/master_layout.dart'; // AppTheme için

class RecipeCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String difficulty;
  final String imagePath;
  final VoidCallback onTap;

  // Global AppTheme.isDark.value okunduğu için isDarkMode parametresi kaldırıldı.

  const RecipeCard({
    Key? key,
    required this.title,
    required this.category,
    required this.time,
    required this.difficulty,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tema durumu doğrudan global yapıdan okunuyor
    final bool isDarkMode = AppTheme.isDark.value;

    final Color surfaceColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final Color borderColor =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textDark =
        isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final Color textMuted =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 1. Resim Alanı
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imagePath != 'assets/placeholder.png' &&
                        imagePath.isNotEmpty
                    ? FutureBuilder<String>(
                        future: DatabaseHelper.instance.getImagePath(imagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: isDarkMode
                                  ? const Color(0xFF334155)
                                  : Colors.grey[200],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            return Image.file(
                              File(snapshot.data!),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 70,
                                height: 70,
                                color: isDarkMode
                                    ? const Color(0xFF334155)
                                    : Colors.grey[200],
                                child:
                                    Icon(Icons.broken_image, color: textMuted),
                              ),
                            );
                          }
                          return Container(
                            width: 70,
                            height: 70,
                            color: isDarkMode
                                ? const Color(0xFF334155)
                                : Colors.grey[200],
                            child: Icon(Icons.restaurant, color: textMuted),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: isDarkMode
                            ? const Color(0xFF334155)
                            : Colors.grey[200],
                        child: Icon(Icons.restaurant, color: textMuted),
                      ),
              ),
              const SizedBox(width: 16),

              // 2. Metin İçeriği
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: textMuted),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.bar_chart,
                            size: 14, color: Color(0xFFE07A5F)),
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Sağ Ok İkonu
              Icon(Icons.chevron_right, color: textMuted),
            ],
          ),
        ),
      ),
    );
  }
}