# Ferah

macOS için yerel, çevrimdışı bir disk temizlik uygulaması. Farkı: hiçbir şeyi sormadan silmez ve her öğe için **"Silersen ne olur?"** sorusunu yanıtlar.

[English](README.md) · **Türkçe**

> [!WARNING]
> Ferah dosya siler. Hiçbir garanti verilmez (bkz. [LICENSE](LICENSE)). Önemli verilerinin yedeği olmadan kullanma. Aşağıdaki [Durum](#durum) bölümünü oku.

## Ne yapar

Beş adımda çalışır:

1. **Güvenli temizlik.** Bilinen gereksizleri tarar: uygulama ve tarayıcı önbellekleri, günlükler, geliştirici önbellekleri (Xcode DerivedData, npm, pip, Homebrew…), Çöp Kutusu, İndirilenler'deki eski kurulum dosyaları. Her kategoride ne olduğu ve silinince ne olacağı yazar. Güvenli olanlar seçili gelir, "Dikkat" olanlar gelmez. Bu adımdakiler onaydan sonra **kalıcı olarak silinir**.
2. **Büyük dosyalar.** Ev klasöründeki büyük dosyaları ve yeniden üretilebilir klasörleri (`node_modules`, `.venv`, `Pods`, derleme çıktıları) tek tek kart olarak sorar. Bu adımdakiler **Çöp Kutusu'na taşınır**, geri alınabilir.
3. **Uygulamalar.** Uzun süredir açmadığın uygulamaları son kullanım tarihi, boyut ve geride bıraktığı verilerle listeler. **Çöp Kutusu'na taşınır.**
4. **Sistem verileri.** Depolama ekranındaki "Sistem Verileri"nin nereye gittiğini ölçer ve her kalem için ne yapılabileceğini söyler.
5. **Özet.** Kazanılan yer, yapılan işlemler ve işlem geçmişi.

### "Silersen ne olur?"

Açıklamaları kural tabanlı, çevrimdışı bir motor üretir; hiçbir veri bilgisayarından çıkmaz. Birkaç örnek:

| Öğe | Ferah ne der |
|---|---|
| `node_modules` | `npm install` ile geri gelir; proje bozulmaz, ilk çalıştırma uzar |
| Kişisel video | Başka yerde kopyası yoksa geri gelmez |
| `Docker.raw` | Tüm imaj, konteyner ve volume'lar gider |
| Şifreli `.dmg` | Büyük olasılıkla bir kasa; saklaman önerilir |
| iCloud'daki dosya | Tüm cihazlarından ve buluttan da silinir |
| App Store uygulaması | Satın Alınanlar'dan ücretsiz yeniden indirilir |

Hiçbir kural tutmazsa bunu açıkça söyler ve saklamayı önerir.

## Güvenlik

Tüm silme ve taşıma işlemleri tek bir denetim noktasından geçer ([Bekci.swift](Sources/FerahCore/Bekci.swift)). Şunları reddeder:

- ev klasörü dışındaki yollar;
- standart klasörlerin kendisi (Masaüstü, Belgeler, İndirilenler…);
- korunan veriler: Fotoğraflar kitaplığı, anahtar zinciri, Mail, Mesajlar, `.ssh`…;
- sembolik bağ ya da `..` ile kaçış denemeleri;
- Adım 1'de, o kategorinin izinli köklerinin dışındaki her yol.

Ev klasörü dışına yalnız uygulama kaldırma işlemi çıkabilir; o da yalnız `/Applications` ve `~/Applications` içindeki gerçek `.app` paketleri için. Apple uygulamaları, o an çalışan uygulamalar ve Ferah'ın kendisi reddedilir.

Bu kurallar `--oz-sinama` ile geçici bir klasörde sınanır (273 sınama). Arayüzün görünüm modeli de `--akis-sinama` ile sahte bir ev üzerinde uçtan uca sürülür (82 sınama). İki takım da Türkçe ve İngilizce (`--dil tr`, `--dil en`) ayrı ayrı çalıştırılıp geçirildi.

## Kurulum

Şimdilik yalnız kaynak koddan derlenir. Xcode gerekmez; Command Line Tools yeter.

**Gerekenler:** macOS 14 ya da üstü, Swift 6 (`xcode-select --install`).

```bash
git clone <depo adresi>
```

```bash
cd Ferah && ./paketle.sh
```

```bash
open build/Ferah.app
```

`paketle.sh`, `build/Ferah.app` paketini üretir ve ad-hoc imzalar. İstersen `/Applications` klasörüne taşıyabilirsin.

### Tam Disk Erişimi

macOS bazı klasörleri izin olmadan okutmaz: Çöp Kutusu, Safari önbelleği, iOS yedekleri ve diğer uygulamaların kapsayıcıları. Ferah bu kalemlerde çökmez, "erişim izni yok" der ve başka uygulamaların kapsayıcılarını hiç ölçmez.

Hepsini görmek için **Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi** bölümünde Ferah'ı ekle. Uygulamadaki "Tam Disk Erişimi ver…" düğmesi bu bölmeyi açar. Uygulama ad-hoc imzalı olduğundan her yeniden derlemeden sonra izni yeniden vermen gerekebilir.

## Durum

Neyin sınandığı, neyin sınanmadığı:

- **Otomatik olarak sınananlar:** güvenlik kuralları, silme katmanı ve açıklama motoru (`--oz-sinama`). Arayüzün görünüm modeli de sahte bir ev üzerinde, düğmelerin çağırdığı yöntemlerle sürülüyor (`--akis-sinama`). Bu sınama şunları kapsıyor:
  - Adım 1 temizliği;
  - Çöp Kutusu'nu boşaltma;
  - uygulama kaldırma ("Verilerini de kaldır" açık ve kapalı);
  - Sistem verileri kalemini taşıma;
  - tarama iptali ve çift tıklama;
  - tarama ile silme arasında dosyanın kaybolması ya da sembolik bağa dönüşmesi.
- **Elle denenenler:** Her sayfa deneme kipinde, yöntemler doğrudan çağrılarak değil, gerçek düğmelere macOS Erişilebilirlik üzerinden basılarak baştan sona da denendi: Adım 1 temizliği ve onayı, Büyük dosyalarda sakla / Çöp'e taşı / klavyeyle onay / liste görünümünde toplu taşıma, "Verilerini de kaldır" kapalı ve açıkken uygulama kaldırma, bir Sistem verileri kalemini taşıma, Çöp'ü boşaltma, Geçmiş ve dili anında değiştirme. Her adımdan sonra diskteki dosyalar kontrol edildi.
- **Görsel denetim:** açık ve koyu tema deneme kipinde, Türkçe ve İngilizce, beş sayfa, bir onay penceresi ve en küçük pencere boyutunda gözle kontrol edildi. "Göz at" (Quick Look) görsel olarak kontrol edilmedi.
- **Tek Mac:** yalnız tek bir Mac'te (Apple Silicon, macOS 26) çalıştırıldı.
- **APFS klonları:** gösterilen boyut, silinince gerçekten açılacak yerdir (`ATTR_CMNEXT_PRIVATESIZE`). Bir dosyanın klonu tek başına ~0 gösterilir; klon ailesinin tüm üyeleri aynı ölçümdeyse paylaşılan kısım bir kez sayılır. Sınırları:
  - Kısmen değiştirilmiş klonların ortak kısmı hiç "açılacak" sayılmaz (tutucu).
  - Klon bilgisi hız için yalnız 1 MB'tan büyük dosyalarda okunur.
- **Tam Disk Erişimi olmadan:** başka uygulamaların kapsayıcıları (ör. WhatsApp) izin penceresi açmamak için ölçülmez. Sistem verileri sayfasındaki "tahmini ölçülemeyen" değeri kaba bir farktır.
- **Son kullanım tarihi:** Spotlight'tan gelir. 2001 öncesi tarihler (bazı yükleyiciler 1980 yazar) "kayıt yok" sayılır; Spotlight yanlış bir tarih tutuyorsa öneri de yanlış olabilir.
- **"Geri Koy":** Çöp'e taşınan öğelerde Finder'ın "Geri Koy" komutunun çalıştığı doğrulanmadı.
- **Dil:** Türkçe ve İngilizce. Uygulama içinden dil değiştirilince Ferah'ın kendi metinleri hemen değişir; macOS'un menüleri ve sistem pencereleri yeniden başlatınca değişir. macOS'un kendi verdiği hata metinleri (ör. bazı taşıma hataları) sistem dilinde kalır.

Hata bulursan ya da bir açıklama yanlışsa issue aç; yanlış "güvenli" denen bir öğe en önemli hata türüdür.

## Geliştirme

```
Sources/FerahCore/            tarama, kurallar, açıklama motoru, güvenlik denetimi, silme (arayüzden bağımsız)
Sources/Ferah/                SwiftUI arayüzü ve komut satırı kipleri
araclar/metinler.tsv          bütün arayüz ve açıklama metinleri (anahtar, Türkçe, İngilizce)
araclar/metinleri-uret.py     metinler.tsv'den Sources/FerahCore/Metinler.swift'i üretir
araclar/simge.swift           uygulama simgesini çizer
paketle.sh                    derler, .app paketini kurar, imzalar
```

Komut satırı kipleri arayüz açmaz ve (öz-sınama dışında) salt okunurdur:

```bash
.build/release/Ferah --oz-sinama
```

```bash
.build/release/Ferah --tara-json
```

```bash
.build/release/Ferah --buyuk-json --esik 500
```

```bash
.build/release/Ferah --uygulamalar-json
```

```bash
.build/release/Ferah --sistem-json
```

- `--oz-sinama`: geçici bir klasörde sahte dosya ağacı kurar ve güvenlik, silme ve açıklama kurallarını sınar. Gerçek dosyalara dokunmaz.
- Diğerleri ilgili adımın taramasını JSON olarak basar. Çıktı kendi diskinin dökümüdür; paylaşmadan önce bak.
- Arayüzü bir taramayla açmak için: `--ac-ve-tara`, `--ac-buyuk`, `--ac-uygulamalar`, `--ac-sistem`. Görünümü zorlamak için `--tema acik|koyu`.
- `--dil tr|en` her kipte dili zorlar (arayüz, JSON'daki insan-okur metinler, sınamaların işlediği dil). JSON alan adları dilden bağımsızdır.

### Dil ve metinler

Kullanıcıya görünen her metin `araclar/metinler.tsv` dosyasında tek bir satırdır: `anahtar<TAB>Türkçe<TAB>English`. Kod yalnız anahtarı kullanır; açıklama motorları dilden bağımsız `Metin` değerleri üretir ve metin gösterilirken seçili dile çevrilir.

- Yer tutucular `{0}`, `{1}`… her dilde aynı olmalı. İngilizce çoğul `tekil||çoğul` biçimindedir.
- Değişiklikten sonra `python3 araclar/metinleri-uret.py` çalıştır; `Metinler.swift` yeniden üretilir.
- Bir dilde metin eksikse derleme bozulur. `--oz-sinama` ayrıca yer tutucuları ve İngilizce çıktıda Türkçe harf ya da sözcük kalmadığını denetler.
- Dil seçimi: `--dil` > uygulama içi seçim (kenar çubuğunun altındaki dünya simgesi) > sistem dili (Türkçe ise Türkçe, değilse İngilizce).

Yeni bir dil eklemek için:

1. `metinler.tsv`'ye bir sütun ekle.
2. `metinleri-uret.py`'nin bu sütunu `cift` çıktısına eklemesini sağla.
3. `Dil` türüne bir vaka ve `yerel` değeri ekle; `Ceviri.sablon` seçimini genişlet.
4. `Dil.sistemden` kuralını güncelle.
5. `paketle.sh`'deki `CFBundleLocalizations` listesine dili ve bir `.lproj` klasörü ekle.
6. `--oz-sinama --dil <yeni>` çalıştır.

### Deneme kipi

Uygulamanın tamamını gerçek dosyalarına dokunmadan, geçici dizindeki sahte bir ev üzerinde çalıştırır:

```bash
.build/release/Ferah --deneme-evi-kur "$TMPDIR/ferah-deneme"
```

```bash
.build/release/Ferah --deneme-evi "$TMPDIR/ferah-deneme"
```

- İlk komut, sahte evin içine gerçekçi bir ağaç kurar: önbellekler, kilitli bir dosya, dolu bir Çöp, eski `.dmg`, büyük dosyalar, bir APFS klonu, `node_modules`'lü proje, sahte uygulamalar ve artıkları, korunan taklitler, dışarıyı gösteren sembolik bağ tuzakları.
- Deneme kipinde ev, uygulama klasörü (`<klasör>/Applications`), Çöp (`<klasör>/.Trash`) ve geçmiş sahte evin içindedir. Ev dışındaki sistem yolları taranmaz. Büyük dosya eşiği 1 MB'a kadar iner.
- Pencerenin üstünde sarı bir "DENEME KİPİ" şeridi durur.
- Klasör geçici dizin (`$TMPDIR`) altında değilse ya da gerçek ev dizinini, `/`, `/Applications` ya da `/Users`'ı içeriyorsa Ferah başlamayı reddeder.

```bash
.build/release/Ferah --akis-sinama
```

`--akis-sinama` kendi deneme evini kurar, arayüzün kullandığı görünüm modelini beş adım boyunca sürer, her adımdan sonra dosya sistemini doğrular ve sonunda deneme evini siler.

Silme koduna dokunan her değişiklikten sonra `--oz-sinama` çalıştır; yeni bir silme yolu ekliyorsan sınamasını da ekle.

## Veriler

Ferah yalnız şu klasöre yazar: `~/Library/Application Support/Ferah/` (deneme kipinde sahte evin içindeki karşılığına).

- `gecmis.json`: yapılan her işlem (tarih, yol, boyut, yöntem)
- `saklananlar.json`: "Sakla" dediğin dosyalar (sonraki taramada sona alınır)

Uygulama içi dil seçimi macOS'un uygulama ayarlarında (`FerahDil` anahtarı) tutulur; deneme kipinde ve `--dil` ile kaydedilmez. Pencere boyutunu macOS kendisi hatırlar.

Ağ bağlantısı kurmaz, hiçbir veri göndermez.

## Lisans

[MIT](LICENSE)
