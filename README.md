# Proje: Flutter Yemek Kitabı (Windows Desktop)
# Durum: Faz 8 Tamamlandı (Kategori & Arama Sistemi)

## 🛠 Teknik Mimari
- **Veritabanı:** SQLite (sqflite_ffi) - Versiyon: v2
- **Model Yapısı:** ID, Başlık, Kategori, Malzemeler, Hazırlanış, Resim Yolu, Tarih.
- **Kategoriler:** Çorba, Ana Yemek, Sebze, Et, Baklagil, Hamur İşi, Pilav, Meze, Salata, Kahvaltılık, Tatlı.

## 📁 Dosya Yapısı ve Mevcut Kodlar:

1. **Model (lib/models/recipe_model.dart):** 'category' sütunu eklenmiş tam model.
2. **Database (lib/database/database_helper.dart):** 'yemek_kitabi_v2.db' üzerinden CRUD ve kategori desteği.
3. **Home Screen (lib/screens/home_screen.dart):** SearchBar (Arama) ve Kategori Chip-Filter (Filtreleme) içeren ana sayfa.
4. **Add/Edit Screens:** Dropdown menü ile kategori seçimi ve yerel resim kaydetme özelliği.
5. **Detail Screen:** Kategori rozeti ve gelişmiş görsel sunum.

## 🚀 Son Durum
Uygulama Windows üzerinde çalışıyor. CRUD döngüsü eksiksiz. Kullanıcı yemek adına veya malzemeye göre arama yapabiliyor, yatay menüden kategori seçerek listeyi daraltabiliyor.

## 🔜 Gelecek Planı (Yarın):
- Tarif paylaşma (Metin olarak kopyalama veya WhatsApp/Email taslağı).
- Belki favorilere ekleme veya pişirme süresi gibi ekstra detaylar.
