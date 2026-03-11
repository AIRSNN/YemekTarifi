# Proje Faz Takibi

## Faz 1: Kurulum
- Durum: Tamamlandi
- Flutter projesi `flutter create . --project-name yemektarifi` komutuyla mevcut dizinde olusturuldu.
- `pubspec.yaml` dosyasina `sqflite_common_ffi`, `path_provider` ve `path` bagimliliklari eklendi.
- `flutter pub get` ile paketler indirildi ve kilit dosyalari guncellendi.
- `lib/database`, `lib/models`, `lib/screens` ve `lib/widgets` klasorleri olusturuldu.
- `lib/main.dart` dosyasindaki varsayilan sayac uygulamasi kaldirildi.
- Uygulama, sadece temel `MaterialApp` ve `Scaffold` iskeleti iceren "Yemek Kitabi" baslikli yapıya indirildi.
- `dokumanlar` klasoru ve bu faz takip dosyasi olusturuldu.

## Faz 2: Veritabani Mimarisi
- Durum: Tamamlandi
- `lib/database/database_helper.dart` dosyasi eklendi.
- SQLite icin `DatabaseHelper` sinifi olusturuldu ve `sqflite_common_ffi` tabanli yerel veritabani kurulumu yapildi.
- `recipes` tablosu; `id`, `title`, `ingredients`, `instructions`, `image_name` ve `created_at` alanlariyla tanimlandi.
- Tarifler icin `create`, `readAll`, `update` ve `delete` islemleri eklendi.
- Yerel resim yolu uretimi ve resim dosyalarini uygulama klasorune kopyalama altyapisi eklendi.
- V1 yerel mod ve V2 web tabanli gecis icin temel mimari kontrol sabitleri tanimlandi.

## Faz 3: Veri Modelleri
- Durum: Tamamlandi
- `lib/models/recipe_model.dart` dosyasi eklendi.
- `Recipe` modeli; tarif kaydinin alanlarini temsil edecek sekilde tanimlandi.
- Veritabani ile veri alisverisi icin `toMap` ve `fromMap` donusumleri eklendi.

## Faz 4: UI Tasarimi
- Durum: Bekliyor

## Faz 5: Uygulama Akisi ve Ozellikler
- Durum: Bekliyor

## Faz 6: Test ve V2 Hazirliklari
- Durum: Bekliyor
