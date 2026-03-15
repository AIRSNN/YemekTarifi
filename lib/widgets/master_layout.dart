import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart'; // Veritabanı bağlantısı eklendi

// Tüm uygulamada karanlık/aydınlık modu kontrol edecek global tetikleyici
class AppTheme {
  static ValueNotifier<bool> isDark = ValueNotifier<bool>(false);
}

class MasterLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String activeMenu;
  final Widget? floatingActionButton;
  final VoidCallback? onBack;

  const MasterLayout({
    Key? key,
    required this.child,
    required this.title,
    required this.activeMenu,
    this.floatingActionButton,
    this.onBack,
  }) : super(key: key);

  @override
  State<MasterLayout> createState() => _MasterLayoutState();
}

class _MasterLayoutState extends State<MasterLayout> {
  // Uygulamanın kapanış sürecinde olup olmadığını takip eden state
  bool _isExiting = false;

  Widget _buildMenuItem(
      BuildContext context, String menuTitle, IconData icon, bool isDark) {
    bool isActive = widget.activeMenu == menuTitle;
    Color primaryColor = const Color(0xFFE07A5F);
    Color textColor = isActive
        ? primaryColor
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    Color bgColor = isActive
        ? (isDark
            ? primaryColor.withOpacity(0.2)
            : primaryColor.withOpacity(0.1))
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

  // Güvenli ve Asenkron Kapatma Metodu
  Future<void> _closeApp(BuildContext context) async {
    if (_isExiting) return; // Arka arkaya çift tıklamayı önle

    setState(() {
      _isExiting = true; // Kapanış overlay'ini aktif et
    });

    // 1. Veritabanı I/O işlemlerinin tamamlanmasını bekle ve güvenle kapat
    await DatabaseHelper.instance.close();

    // 2. Platforma göre doğru sonlandırma
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      // Masaüstü (Windows/Linux/Mac): Veritabanı kapandığı için artık exit(0) güvenli
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDark,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
        final Color surfaceColor =
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
        final Color borderColor =
            isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final Color textDark =
            isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

        return Scaffold(
          backgroundColor: bgColor,
          floatingActionButton: widget.floatingActionButton,
          body: Stack(
            children: [
              // ==========================================
              // ANA DÜZEN (MENÜ VE İÇERİK)
              // ==========================================
              Row(
                children: [
                  // --- 1. SOL MENÜ (SIDEBAR) ---
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border:
                          Border(right: BorderSide(color: borderColor, width: 1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: borderColor, width: 1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant_menu,
                                  color: Color(0xFFE07A5F), size: 28),
                              const SizedBox(width: 10),
                              Text(
                                'Master Şef',
                                style: GoogleFonts.nunito(
                                    color: textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildMenuItem(
                            context, 'Giriş', Icons.dashboard_outlined, isDark),
                        _buildMenuItem(context, 'Yemek Tarifleri',
                            Icons.receipt_long_outlined, isDark),
                        _buildMenuItem(context, 'Listeleri',
                            Icons.format_list_bulleted, isDark),
                        _buildMenuItem(context, 'Ayarlar',
                            Icons.settings_outlined, isDark),
                      ],
                    ),
                  ),

                  // --- 2. ÜST MENÜ VE İÇERİK ---
                  Expanded(
                    child: Column(
                      children: [
                        // ÜST MENÜ (TOPBAR)
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            border: Border(
                                bottom: BorderSide(color: borderColor, width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Sol taraf: Geri butonu ve Başlık
                              Row(
                                children: [
                                  if (widget.onBack != null) ...[
                                    InkWell(
                                      onTap: widget.onBack,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.arrow_back,
                                            color: textDark, size: 20),
                                      ),
                                    ),
                                  ],
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.nunito(
                                        color: textDark,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              // Sağ taraf: Tema ve Kapatma
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      AppTheme.isDark.value =
                                          !AppTheme.isDark.value;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(12),
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF8FAFC),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            isDark ? 'Karanlık Mod' : 'Aydınlık Mod',
                                            style: GoogleFonts.nunito(
                                                color: textDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isDark
                                                ? Icons.dark_mode
                                                : Icons.light_mode,
                                            color: isDark
                                                ? Colors.blue[300]
                                                : Colors.orange,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // GÜVENLİ KAPATMA BUTONU
                                  InkWell(
                                    onTap: () => _closeApp(context),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1F2),
                                        border: Border.all(
                                            color: const Color(0xFFFECDD3)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.power_settings_new,
                                          color: Color(0xFFF43F5E), size: 20),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        // ANA İÇERİK
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              ),

              // ==========================================
              // GÜVENLİ ÇIKIŞ BEKLEME EKRANI (OVERLAY)
              // ==========================================
              if (_isExiting)
                Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.85)
                      : Colors.white.withOpacity(0.85),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFE07A5F),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Sistem Güvenle Kapatılıyor...',
                          style: GoogleFonts.nunito(
                            color: textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Veritabanı bağlantısı sonlandırılıyor',
                          style: GoogleFonts.nunito(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}