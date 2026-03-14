import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // YENİ EKLENDİ: Okunabilirliği artırmak için Master UI fontu eklendi.

class RecipeCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String difficulty;
  final String imagePath;
  final VoidCallback onTap;

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // YENİ EKLENDİ: Master UI Surface (Beyaz Kart Arka Planı)
          borderRadius: BorderRadius.circular(12.0), // YENİ EKLENDİ: Master UI Standart Kavis (12px)
          border: Border.all(
            color: const Color(0xFFE2E8F0), // YENİ EKLENDİ: Master UI Standart Kenarlık Rengi
            width: 1.0,
          ),
          boxShadow: [
            // YENİ EKLENDİ: Dikkati dağıtmayan çok hafif kart gölgesi
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                child: Image.asset( 
                  imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
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
                        color: const Color(0xFF1E293B), // YENİ EKLENDİ: Master UI Koyu Metin Rengi
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
                        color: const Color(0xFF64748B), // YENİ EKLENDİ: Master UI Pasif Metin Rengi
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.bar_chart, size: 14, color: Color(0xFFE07A5F)), // YENİ EKLENDİ: Mutfak temasına uygun kiremit rengi vurgu
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 3. Sağ Ok İkonu
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}