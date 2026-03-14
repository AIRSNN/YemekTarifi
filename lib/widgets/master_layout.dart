import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// YENİ EKLENDİ: Tüm uygulamada karanlık/aydınlık modu kontrol edecek global tetikleyici
class AppTheme {
  static ValueNotifier<bool> isDark = ValueNotifier<bool>(false);
}

class MasterLayout extends StatelessWidget {
  final Widget child; // Ortada gösterilecek asıl ekran içeriği
  final String title; // Üst menüde yazacak başlık
  final String activeMenu; // Sol menüde hangi sekmenin aktif görüneceği
  final Widget? floatingActionButton;
  final VoidCallback? onBack; // Geri tuşu (Detay veya Ekleme sayfalarında kullanılacak)

  const MasterLayout({
    Key? key,
    required this.child,
    required this.title,
    required this.activeMenu,
    this.floatingActionButton,
    this.onBack,
  }) : super(key: key);

  Widget _buildMenuItem(BuildContext context, String menuTitle, IconData icon, bool isDark) {
    bool isActive = activeMenu == menuTitle;
    Color primaryColor = const Color(0xFFE07A5F);
    Color textColor = isActive ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    Color bgColor = isActive 
        ? (isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1)) 
        : Colors.transparent;

    return InkWell(
      onTap: () {
        // İleride sayfalar arası geçiş router'ı buraya eklenebilir
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
              menuTitle,
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
    // ValueListenableBuilder: Tema değiştiğinde tüm iskeleti anında günceller
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final Color textDark = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

        return Scaffold(
          backgroundColor: bgColor,
          floatingActionButton: floatingActionButton,
          body: Row(
            children: [
              // ==========================================
              // 1. SOL MENÜ (SIDEBAR)
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
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_menu, color: Color(0xFFE07A5F), size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Master Şef',
                            style: GoogleFonts.nunito(color: textDark, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuItem(context, 'Giriş', Icons.dashboard_outlined, isDark),
                    _buildMenuItem(context, 'Yemek Tarifleri', Icons.receipt_long_outlined, isDark),
                    _buildMenuItem(context, 'Listeleri', Icons.format_list_bulleted, isDark),
                    _buildMenuItem(context, 'Ayarlar', Icons.settings_outlined, isDark),
                  ],
                ),
              ),

              // ==========================================
              // 2. ÜST MENÜ VE İÇERİK
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
                          // Sol taraf: Geri butonu (Varsa) ve Başlık
                          Row(
                            children: [
                              if (onBack != null) ...[
                                InkWell(
                                  onTap: onBack,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.arrow_back, color: textDark, size: 20),
                                  ),
                                ),
                              ],
                              Text(
                                title,
                                style: GoogleFonts.nunito(color: textDark, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          // Sağ taraf: Tema ve Çıkış
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  // Global temayı tersine çevirir
                                  AppTheme.isDark.value = !AppTheme.isDark.value;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        isDark ? 'Karanlık Mod' : 'Aydınlık Mod',
                                        style: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isDark ? Icons.dark_mode : Icons.light_mode,
                                        color: isDark ? Colors.blue[300] : Colors.orange,
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
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}