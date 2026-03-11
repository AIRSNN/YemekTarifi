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

## Faz 2: Veritabani ve Model Katmani
- Durum: Tamamlandi
- `lib/database/database_helper.dart` dosyasi eklendi.
- SQLite icin `DatabaseHelper` sinifi olusturuldu ve `sqflite_common_ffi` tabanli yerel veritabani kurulumu yapildi.
- `recipes` tablosu; `id`, `title`, `ingredients`, `instructions`, `image_name` ve `created_at` alanlariyla tanimlandi.
- Tarifler icin `create`, `readAll`, `update` ve `delete` islemleri eklendi.
- Yerel resim yolu uretimi ve resim dosyalarini uygulama klasorune kopyalama altyapisi eklendi.
- V1 yerel mod ve V2 web tabanli gecis icin temel mimari kontrol sabitleri tanimlandi.
- `lib/models/recipe_model.dart` dosyasi eklendi.
- `Recipe` modeli; tarif kaydinin alanlarini temsil edecek sekilde tanimlandi.
- Veritabani ile veri alisverisi icin `toMap` ve `fromMap` donusumleri eklendi.

## Faz 3: Ana Ekran Arayuzu ve SQLite Baslatma
- Durum: Tamamlandi
- `lib/main.dart` dosyasi guncellenerek Windows ve Linux masaustu icin `sqflite_common_ffi` baslatma ayarlari eklendi.
- Uygulama temasi `deepOrange` tabanli Material 3 yapiya tasindi ve ana giris ekrani `HomeScreen` olarak ayarlandi.
- `lib/screens/home_screen.dart` dosyasi eklendi.
- Ana ekran icin uygulama cubugu, bos durum mesaji, yuklenme gostergesi ve tarif listesi altyapisi hazirlandi.
- Tarifleri veritabanindan okumak icin `FutureBuilder<List<Recipe>>` tabanli listeleme akisi kuruldu.
- Yeni tarif ekleme ve detay ekranina gecis icin temel buton ve TODO noktalarina sahip iskelet olusturuldu.

## Faz 4: Tarif Ekleme Ekrani ve Veri Kayit Islemleri
- Durum: Tamamlandi
- `lib/screens/add_recipe_screen.dart` dosyasi eklendi.
- Yeni tarif ekleme formu; yemek adi, malzemeler ve hazirlanis alanlariyla olusturuldu.
- Form icin `GlobalKey<FormState>` tabanli dogrulama kurallari eklendi.
- Girilen verilerden `Recipe` nesnesi uretilerek `DatabaseHelper.instance.createRecipe(...)` ile SQLite veritabanina kayit akisi baglandi.
- Kayit sonrasi kullaniciya `SnackBar` ile durum mesaji gosterildi ve ekrandan sonuc dondurulerek cikis saglandi.
- `lib/screens/home_screen.dart` guncellenerek `AddRecipeScreen` yonlendirmesi eklendi.
- Tarif ekleme ekranindan basarili donus sonrasinda ana listedeki verilerin yenilenmesi icin `_refreshRecipes()` entegrasyonu yapildi.

## Faz 5: Uygulama Akisi ve Ozellikler
- Durum: Tamamlandi
- `lib/screens/recipe_detail_screen.dart` dosyasi eklendi.
- Tarif detay ekrani; baslik, malzemeler ve hazirlanis bolumlerini gostercek sekilde olusturuldu.
- Detay ekranina, ileride eklenecek tarif gorselleri icin yer tutucu resim alani eklendi.
- Icerik, uzun tarif metinlerini desteklemek icin `SingleChildScrollView` yapisina tasindi.
- `lib/screens/home_screen.dart` dosyasi guncellenerek liste ogesine tiklandiginda `RecipeDetailScreen` ekranina gecis akisi baglandi.
- Ana listedeki kart yapsi detay ekranina gecisle birlestirilerek temel gezinme akisi tamamlandi.

## Faz 6: Test ve V2 Hazirliklari
- Durum: Tamamlandi
- `pubspec.yaml` dosyasina `image_picker` bagimliligi eklendi ve `flutter pub get` calistirilarak paketler guncellendi.
- `lib/screens/add_recipe_screen.dart` dosyasi guncellenerek galeriden resim secme akisi eklendi.
- Secilen resim, form ekraninda onizleme olarak gosterilecek sekilde `File` tabanli yapi kuruldu.
- Tarif kaydi sirasinda secilen resim `DatabaseHelper.instance.saveImageLocally(...)` ile uygulama klasorune kopyalanip sadece dosya adi veritabanina yazilacak sekilde baglandi.
- `lib/screens/recipe_detail_screen.dart` dosyasi guncellenerek tarif resmini dinamik olarak yukleyen yapi eklendi.
- Detay ekraninda, yerel mod icin `Image.file`, ilerideki web modu icin `Image.network` kullanan V1/V2 uyumlu gorsel gosterim akisi kuruldu.
- Resim bulunamadigi veya yuklenemedigi durumlar icin yer tutucu gorsel geri donus yapi korundu.
