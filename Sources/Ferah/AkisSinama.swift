import Foundation
import Darwin
import FerahCore

/// `--akis-sinama`: geçici dizinde deneme evi kurar ve ARAYÜZÜN KULLANDIĞI `Durum` görünüm modelini,
/// düğmelerin çağırdığı yöntemlerle uçtan uca sürer. Her adımdan sonra dosya sistemini doğrular.
@MainActor
final class AkisSinama {
    var gecen = 0
    var kalan = 0
    var atlanan = 0
    var ev = ""
    var disari = ""

    func kontrol(_ ad: String, _ kosul: Bool, _ ayrinti: @autoclosure () -> String = "") {
        if kosul { gecen += 1; print("GEÇTİ  \(ad)") }
        else { kalan += 1; let a = ayrinti(); print("KALDI  \(ad)" + (a.isEmpty ? "" : "  → \(a)")) }
    }

    func atla(_ ad: String, _ neden: String) {
        atlanan += 1
        print("ATLANDI \(ad)  → \(neden)")
    }

    /// Ana iş parçacığının çalışma döngüsünü döndürerek koşulu bekler (arka plan işleri main.async ile döner).
    @discardableResult
    func bekle(_ sure: TimeInterval = 120, _ kosul: () -> Bool) -> Bool {
        let son = Date().addingTimeInterval(sure)
        while !kosul() {
            if Date() > son { return false }
            RunLoop.main.run(mode: .default, before: Date().addingTimeInterval(0.02))
        }
        return true
    }

    func biraz(_ s: TimeInterval = 0.3) { _ = bekle(s) { false } }

    func var_(_ p: String) -> Bool { Yol.varMi(p) }
    func p(_ r: String) -> String { Yol.ekle(ev, r) }
    func copteMi(_ ad: String) -> Bool {
        ((try? FileManager.default.contentsOfDirectory(atPath: p(".Trash"))) ?? []).contains { $0 == ad || $0.hasPrefix((ad as NSString).deletingPathExtension + " ") }
    }

    func calistir() -> Int32 {
        let gecici = Yol.gercek(NSTemporaryDirectory()) ?? NSTemporaryDirectory()
        let kok = Yol.ekle(gecici, "ferah-akis-\(UUID().uuidString)")
        guard case .success(let e) = DenemeEvi.kur(kok) else {
            print("KALDI  Deneme evi kurulamadı")
            return 1
        }
        ev = e
        disari = e + "-disari"
        print("Deneme evi: \(ev)")
        // FERAH_AKIS_SAKLA=1: hata ayıklamak için deneme evi silinmez.
        defer { if ProcessInfo.processInfo.environment["FERAH_AKIS_SAKLA"] == nil { DenemeEvi.kaldir(ev) } }

        guvenlik()
        let d = Durum(ortam: Ortam.deneme(ev))
        kontrol("Durum deneme ortamında: ev, uygulama kökü, depo sahte evde",
                d.ev == ev && d.silici.bekci.uygulamaKokleri == [p("Applications")] && d.depo.klasor.hasPrefix(ev))
        iptalVeYaris(d)
        adim1(d)
        adim2(d)
        adim3(d)
        adim4(d)
        adim5(d)

        print("")
        print("Sonuç: \(gecen) geçti, \(kalan) kaldı, \(atlanan) atlandı.")
        return kalan == 0 ? 0 : 1
    }

    // MARK: - Deneme kipi güvenliği

    func guvenlik() {
        let gercekEv = Yol.gercek(NSHomeDirectory()) ?? NSHomeDirectory()
        func red(_ y: String) -> Bool { if case .failure = DenemeEvi.dogrula(y, varOlmali: false) { return true }; return false }
        kontrol("Deneme evi: gerçek ev dizini reddedilir", red(gercekEv))
        kontrol("Deneme evi: gerçek ev altındaki klasör reddedilir (geçici dizin değil)", red(Yol.ekle(gercekEv, "Desktop")))
        kontrol("Deneme evi: / , /Applications, /Users reddedilir", red("/") && red("/Applications") && red("/Users"))
        kontrol("Deneme evi: geçici dizinin kendisi reddedilir", red(Yol.gercek(NSTemporaryDirectory()) ?? NSTemporaryDirectory()))
        kontrol("Deneme evi: göreli yol reddedilir", red("ferah-deneme"))
        kontrol("Deneme evi: '..' ile geçici dizinden kaçış reddedilir", red(Yol.ekle(ev, "../../../..")))
        kontrol("Deneme evi: kurulan klasör kabul edilir", !red(ev))
        if case .failure = DenemeEvi.kur(gercekEv) {
            kontrol("Deneme evi kurulumu gerçek evi reddeder", true)
        } else {
            kontrol("Deneme evi kurulumu gerçek evi reddeder", false)
        }
        let o = Ortam.deneme(ev)
        let b = Bekci(ev: ev, uygulamaKokleri: o.uygulamaKokleri, calisanKimlikler: o.calisanKimlikler, kendiPaketi: o.kendiPaketi)
        func reddedildi(_ y: String, _ i: Islem) -> Bool { if case .failure = b.denetle(y, i) { return true }; return false }
        kontrol("Deneme bekçisi: gerçek ev dizinindeki dosya reddedilir", reddedildi(Yol.ekle(gercekEv, "Desktop"), .copeTasi))
        kontrol("Deneme bekçisi: gerçek /Applications uygulaması reddedilir",
                reddedildi("/Applications/Safari.app", .uygulamaCopeTasi)
                && ((try? FileManager.default.contentsOfDirectory(atPath: "/Applications"))?.first { $0.hasSuffix(".app") })
                    .map { reddedildi("/Applications/\($0)", .uygulamaCopeTasi) } ?? true)
        kontrol("Deneme bekçisi: deneme evinin dışındaki tuzak hedefi reddedilir", reddedildi(Yol.ekle(disari, "degerli.txt"), .copeTasi))
    }

    // MARK: - İptal, çift çağrı, yarış

    func iptalVeYaris(_ d: Durum) {
        let hedef = p("Library/Caches/com.deneme.uygulama/veri1.bin")
        d.tara1()
        d.iptal1Et()
        biraz(1.5)
        kontrol("İptal: tarama durdu, yarım tarama 'tamam' sayılmıyor", !d.tarama1 && !d.tarama1Tamam)
        kontrol("İptal: yarım taramanın seçimleri temizlendi", d.secili.isEmpty, "\(d.secili.count) seçili")
        d.secili.insert(Yol.ekle(ev, "Library/Caches/com.deneme.uygulama"))
        d.temizle1()
        biraz(0.5)
        kontrol("İptal: yarım sonuçla temizlik yapılamıyor", !d.temizleniyor && var_(hedef) && d.kaliciBayt == 0)

        d.tara1()
        d.temizle1()   // tarama sürerken
        kontrol("Yarış: tarama sürerken temizle çağrısı yok sayılır", !d.temizleniyor)
        bekle { d.tarama1Tamam }
        kontrol("Yarış: tarama sonrası dosyalar yerinde", var_(hedef))
    }

    // MARK: - Adım 1

    func adim1(_ d: Durum) {
        if !d.tarama1Tamam { d.tara1(); bekle { d.tarama1Tamam } }
        func kat(_ k: KategoriKimlik) -> KategoriSonuc? { d.kategoriler.first { $0.kimlik == k } }
        func oge(_ son: String) -> TemizlikOgesi? { d.kategoriler.flatMap(\.ogeler).first { $0.yol.hasSuffix(son) } }

        kontrol("Adım 1: tüm kategoriler tarandı", d.kategoriler.count == KategoriKimlik.allCases.count)
        kontrol("Adım 1: Güvenli öğe varsayılan seçili", d.secili.contains(oge("Caches/com.deneme.uygulama")?.yol ?? "-"))
        let calisan = oge("Caches/\(DenemeEvi.calisanKimlik)")
        kontrol("Adım 1: çalışan uygulamanın önbelleği işaretli ve seçili değil",
                calisan?.calisiyor == true && !d.secili.contains(calisan?.yol ?? "-"))
        kontrol("Adım 1: Dikkat kategorileri (Çöp, eski kurulum) seçili değil",
                (kat(.copKutusu)?.ogeler ?? []).allSatisfy { !d.secili.contains($0.yol) }
                && (kat(.eskiKurulum)?.ogeler ?? []).allSatisfy { !d.secili.contains($0.yol) })
        kontrol("Adım 1: 30 günden eski .dmg bulundu, yeni .pkg bulunmadı",
                oge("EskiKurulum.dmg") != nil && oge("YeniKurulum.pkg") == nil)
        kontrol("Adım 1: tarayıcı profili (History) öğe değil", oge("History") == nil && oge("Code Cache") != nil)

        // TOCTOU: taramadan sonra bir seçili klasörü sil, birini dışarıyı gösteren bağla değiştir
        let toctou1 = p("Library/Caches/com.deneme.toctou1"), toctou2 = p("Library/Caches/com.deneme.toctou2")
        DenemeEvi.dosya("\(toctou1)/a.bin", 50_000, dolgu: 90)
        DenemeEvi.dosya("\(toctou2)/b.bin", 50_000, dolgu: 91)
        d.tara1(); bekle { d.tarama1Tamam }
        let secilenler = d.kategoriler.flatMap(\.ogeler).filter { d.secili.contains($0.yol) }
        kontrol("Adım 1: TOCTOU klasörleri seçildi", d.secili.contains(toctou1) && d.secili.contains(toctou2))
        try? FileManager.default.removeItem(atPath: toctou1)
        try? FileManager.default.removeItem(atPath: toctou2)
        _ = symlink(disari, toctou2)

        // Silinecek öğelerin şu anki ayrılmış boyutu (kilitli dosya dahil)
        let once = secilenler.reduce(Int64(0)) { $0 + Olcer.olc($1.yol).bayt }
        let kaliciOnce = d.kaliciBayt
        d.temizle1()
        d.temizle1()   // çift tıklama
        kontrol("Adım 1: çift tıklamada ikinci temizlik başlamıyor", d.temizleniyor)
        bekle { !d.temizleniyor && d.tarama1Tamam }
        guard let r = d.sonRapor else { kontrol("Adım 1: temizlik raporu var", false); return }
        let sonra = secilenler.reduce(Int64(0)) { $0 + (Yol.varMi($1.yol) && !Yol.bagMi($1.yol) ? Olcer.olc($1.yol).bayt : 0) }
        let gercekGiden = once - sonra
        let fark = abs(Double(r.serbestBayt - gercekGiden)) / Double(max(gercekGiden, 1))
        kontrol("Adım 1: kazanılan bayt diskten gerçekten giden ayrılmış boyuta eşit (±%1)", fark <= 0.01,
                "rapor=\(r.serbestBayt) gerçek=\(gercekGiden)")
        kontrol("Adım 1: kalıcı silinen sayaç rapora eşit (çift sayılmadı)", d.kaliciBayt - kaliciOnce == r.serbestBayt)
        kontrol("Adım 1: seçilen önbellek içerikleri gitti",
                !var_(p("Library/Caches/com.deneme.uygulama/veri1.bin")) && !var_(p("Library/Caches/com.deneme.uygulama/alt"))
                && !var_(p("Library/Caches/Homebrew/downloads")) && !var_(p("Library/Logs/DiagnosticReports/Ornek-2024.ips"))
                && !var_(p("Library/Application Support/Google/Chrome/Default/Code Cache/js")))
        kontrol("Adım 1: önbellek klasörlerinin kendisi duruyor",
                Yol.dizinMi(p("Library/Caches/com.deneme.uygulama")) && Yol.dizinMi(p("Library/Caches/Homebrew")))
        kontrol("Adım 1: seçilmeyenler duruyor (çalışan önbelleği, Çöp, eski .dmg)",
                var_(p("Library/Caches/\(DenemeEvi.calisanKimlik)/acik.bin")) && var_(p(".Trash/eski-belge.txt"))
                && var_(p("Downloads/EskiKurulum.dmg")))
        kontrol("Adım 1: kategori dışı dosyalar ve tarayıcı profili duruyor",
                var_(p("Library/Application Support/Google/Chrome/Default/History"))
                && var_(p("Library/Application Support/Google/Chrome/Default/Preferences")) && var_(p("Movies/Tatil.mov")))
        kontrol("Adım 1: kilitli dosya atlandı ve sayıldı", r.atlanan == 1 && var_(p("Library/Caches/com.deneme.kilitli/kilitli.bin"))
                && !var_(p("Library/Caches/com.deneme.kilitli/serbest.bin")), "atlanan=\(r.atlanan)")
        kontrol("Adım 1: dışarıyı gösteren tuzakların hedefi yerinde, bağlar silindi",
                var_(Yol.ekle(disari, "degerli.txt")) && var_(Yol.ekle(disari, "klasor/icerik.txt"))
                && !var_(p("Library/Caches/com.deneme.uygulama/tuzak-dosya")))
        kontrol("Adım 1 TOCTOU: kaybolan klasör çökmeden hata, bağa dönüşen klasör reddedildi, dışarısı sağlam",
                r.sonuclar.contains { $0.yol.hasSuffix("toctou1") && $0.durum == .hata }
                && r.sonuclar.contains { $0.yol.hasSuffix("toctou2") && $0.durum == .reddedildi }
                && var_(Yol.ekle(disari, "degerli.txt")) && Yol.bagMi(toctou2))
        try? FileManager.default.removeItem(atPath: toctou2)
        kontrol("Adım 1: yeniden taramada temizlenen kalem 0'a inip listeden düştü",
                oge("Caches/com.deneme.uygulama") == nil && oge("Caches/Homebrew") == nil)

        // Çöp Kutusu kategorisini seçip temizle
        guard let cop = kat(.copKutusu), !cop.ogeler.isEmpty else { kontrol("Adım 1: Çöp Kutusu kategorisi görünüyor", false); return }
        d.secili = Set(cop.ogeler.map(\.yol))
        let copOnce = cop.boyut
        let k2 = d.kaliciBayt
        d.temizle1()
        bekle { !d.temizleniyor && d.tarama1Tamam }
        kontrol("Adım 1: Çöp Kutusu öğeleri temizlenince sahte Çöp boşaldı",
                ((try? FileManager.default.contentsOfDirectory(atPath: p(".Trash"))) ?? ["x"]).isEmpty)
        kontrol("Adım 1: Çöp temizliğinin sayacı Çöp boyutuyla tutuyor",
                abs(Double(d.kaliciBayt - k2 - copOnce)) <= Double(copOnce) * 0.01, "\(d.kaliciBayt - k2) vs \(copOnce)")
    }

    // MARK: - Adım 2

    func adim2(_ d: Durum) {
        d.esikMB = 1
        d.tara2()
        bekle { !d.tarama2 }
        let l = d.adaylar
        func bul(_ son: String) -> BuyukAday? { d.adaylar.first { $0.yol.hasSuffix(son) } }
        let siradakiler = l.prefix { !$0.saklandi && $0.aciklama.risk != .dokunma }
        kontrol("Adım 2: aday bulundu ve kartlar boyuta göre sıralı",
                l.count >= 6 && zip(siradakiler, siradakiler.dropFirst()).allSatisfy { $0.boyut >= $1.boyut }, "\(l.count) aday")
        kontrol("Adım 2: node_modules tek kart", bul("site/node_modules")?.girdi.ozelTur == .nodeModules)

        // Sakla
        guard let ilk = d.siradaki else { kontrol("Adım 2: ilk kart var", false); return }
        d.sakla(ilk)
        kontrol("Adım 2: 'Sakla' saklananlar.json'a yazıldı ve sonraki karta geçildi",
                d.depo.saklananlar().contains(ilk.yol) && d.konum == 1 && var_(ilk.yol)
                && var_(Yol.ekle(d.depo.klasor, "saklananlar.json")))

        // Çöpe taşı (kart)
        guard let kayit = bul("Ekran Kaydı 2024-01-01 10.00.00.mov") else { kontrol("Adım 2: ekran kaydı adayı", false); return }
        let gecmisOnce = d.depo.gecmis().count
        d.copeTasi([kayit])
        bekle { !d.tasiniyor }
        kontrol("Adım 2: 'Çöpe taşı' dosyayı sahte Çöp'e taşıdı, kaynakta yok, geçmişe yazıldı",
                !var_(kayit.yol) && copteMi("Ekran Kaydı 2024-01-01 10.00.00.mov")
                && d.depo.gecmis().count == gecmisOnce + 1 && d.depo.gecmis().last?.yontem == .cop)
        d.copeTasi([kayit])
        bekle { !d.tasiniyor }
        kontrol("Adım 2: aynı kartı ikinci kez taşımak yok sayılır", d.adim2Oge == 1 && d.depo.gecmis().count == gecmisOnce + 1)

        // Dokunma
        if let foto = bul("Photos Library.photoslibrary") {
            d.copeTasi([foto])
            bekle { !d.tasiniyor }
            let r = d.silici.uygula(SilmeIstegi(yol: foto.yol, islem: .copeTasi))
            kontrol("Adım 2: Dokunma öğesi taşınamıyor, yerinde", !foto.silinebilir && r.durum == .reddedildi
                    && var_(foto.yol) && d.kararlar[foto.yol] == nil)
        } else {
            kontrol("Adım 2: Fotoğraflar kitaplığı Dokunma olarak listelendi", false)
        }

        // Toplu taşıma (liste görünümü) ve TOCTOU: biri taşınmadan önce dışarıyı gösteren bağa dönüşsün
        guard let zip = bul("Downloads/arsiv.zip"), let sql = bul("Documents/veri.sqlite") else {
            kontrol("Adım 2: arşiv ve veritabanı adayları", false); return
        }
        try? FileManager.default.removeItem(atPath: sql.yol)
        _ = symlink(Yol.ekle(disari, "degerli.txt"), sql.yol)
        d.copeTasi([zip, sql], ilerle: false)
        bekle { !d.tasiniyor }
        kontrol("Adım 2: listeden toplu taşıma iki öğeyi de taşıdı", !var_(zip.yol) && !var_(sql.yol) && copteMi("arsiv.zip"))
        kontrol("Adım 2 TOCTOU: bağa dönüşen öğede yalnız bağ taşındı, hedefi yerinde",
                var_(Yol.ekle(disari, "degerli.txt")) && Yol.bagMi(p(".Trash/veri.sqlite")))

        // Kopya uyarısı
        if let t1 = bul("Movies/Tatil.mov"), let k = t1.sinyaller.kopyaYolu, let t2 = d.adaylar.first(where: { $0.yol == k }) {
            d.copeTasi([t2], ilerle: false)
            bekle { !d.tasiniyor }
            kontrol("Adım 2: kopyası taşınan kartta 'diğer kopyayı Çöp'e taşıdın' koşulu doğru",
                    d.kararlar[t1.sinyaller.kopyaYolu ?? ""] == .cop && var_(t1.yol))
        } else {
            kontrol("Adım 2: aynı videonun iki kopyası birbirini gösteriyor", false)
        }

        // APFS klonu: klon çifti tek tek ~0, birlikte tam boyut
        if let o = bul("klon-ozgun.mov"), let k = bul("klon-kopya.mov") {
            if o.sinyaller.klonPaylasimi > 0 {
                kontrol("Adım 2: APFS klonu tek başına ~0 yer açar diye gösteriliyor",
                        o.boyut < 100_000 && k.boyut < 100_000 && o.aciklama.baglam.contains { $0.a == .aBglKlon },
                        "özgün=\(o.boyut) klon=\(k.boyut)")
            } else {
                atla("Adım 2: APFS klon gösterimi", "geçici dizinde klonlama desteklenmedi")
            }
        }

        // Yeniden tarama: saklanan sona
        d.tara2()
        bekle { !d.tarama2 }
        kontrol("Adım 2: yeniden taramada saklanan sona gitti", d.adaylar.last?.yol == ilk.yol && d.adaylar.last?.saklandi == true,
                d.adaylar.last?.yol ?? "")
        kontrol("Adım 2: yeniden tarama sayaçları sıfırlamadı", d.adim2Oge == 4, "adim2Oge=\(d.adim2Oge)")
    }

    // MARK: - Adım 3

    func adim3(_ d: Durum) {
        d.tara3()
        d.tara3()   // çift çağrı
        bekle { !d.tarama3 }
        func u(_ ad: String) -> UygulamaBilgisi? { d.uygulamalar.first { $0.ad == ad } }
        kontrol("Adım 3: kısayol (sembolik bağ) ayrı satır değil", u("Kisayol") == nil)
        d.suzgec = .altiAy
        d.appleGoster = false
        let alti = Set(d.gorunenUygulamalar.map(\.ad))
        kontrol("Adım 3: '6 aydan uzun' eski uygulamaları içeriyor, yeni ekleneni ve Apple'ı değil",
                alti.isSuperset(of: ["Ornek", "Arac", "Kaldiricili"]) && !alti.contains("YeniEklenen") && !alti.contains("Safari Taklit"),
                "\(alti.sorted())")
        d.suzgec = .birYil
        let yil = Set(d.gorunenUygulamalar.map(\.ad))
        kontrol("Adım 3: '1 yıl' süzgeci daha dar (Arac var, Kaldiricili yok)", yil.contains("Arac") && !yil.contains("Kaldiricili"))
        d.suzgec = .tumu
        d.appleGoster = true
        kontrol("Adım 3: 'Tümü' + Apple göster → Apple taklidi listede", d.gorunenUygulamalar.contains { $0.ad == "Safari Taklit" })
        kontrol("Adım 3: App Store makbuzu ve kaldırıcı tanındı",
                u("Ornek")?.girdi.kaynak == .appStore && u("Kaldiricili")?.girdi.kaldirici != nil
                && AciklamaMotoru.uygulamaAcikla(u("Kaldiricili")!.girdi, verilerDahil: false).risk == .dikkat)
        kontrol("Adım 3: içeriği başka yerde olan paket 0 KB değil 'ölçülemedi'",
                u("Bagli")?.girdi.boyutNotu != nil && u("Bagli")?.girdi.boyut == 0)

        // Veriler KAPALI
        guard let arac = u("Arac"), let ornek = u("Ornek") else { kontrol("Adım 3: sahte uygulamalar bulundu", false); return }
        d.verilerDahil[arac.yol] = false
        d.uygulamalariCopeTasi([arac])
        bekle { !d.tasiniyor }
        kontrol("Adım 3: veriler KAPALI → .app Çöp'te, artıklar yerinde",
                !var_(arac.yol) && copteMi("Arac.app") && var_(p("Library/Application Support/com.deneme.arac/veri.bin"))
                && var_(p("Library/Preferences/com.deneme.arac.plist")))

        // Veriler AÇIK
        let artikYollari = ornek.girdi.artiklar.map(\.yol)
        kontrol("Adım 3: Ornek artıkları yalnız tam eşleşenler",
                Set(artikYollari.map { Yol.kisa($0, ev: ev) }) == ["~/Library/Application Support/com.deneme.ornek",
                    "~/Library/Caches/com.deneme.ornek", "~/Library/Saved Application State/com.deneme.ornek.savedState",
                    "~/Library/Application Support/Ornek"], "\(artikYollari.map { Yol.kisa($0, ev: ev) })")
        d.verilerDahil[ornek.yol] = true
        d.uygulamalariCopeTasi([ornek])
        bekle { !d.tasiniyor }
        kontrol("Adım 3: veriler AÇIK → .app ve tam eşleşen artıklar Çöp'te",
                !var_(ornek.yol) && copteMi("Ornek.app") && artikYollari.allSatisfy { !var_($0) })
        kontrol("Adım 3: benzer adlı klasörler ve Preferences yerinde",
                var_(p("Library/Application Support/com.deneme.ornekler/veri.db")) && var_(p("Library/Application Support/Ornekler/ayarlar.json"))
                && var_(p("Library/Preferences/com.deneme.ornek.plist")))

        // Reddedilenler
        let red = ["Safari Taklit", "Calisan", "Ferah"].compactMap { u($0) }
        d.uygulamalariCopeTasi(red)
        bekle { !d.tasiniyor }
        kontrol("Adım 3: Apple / çalışan / kendisi silinebilir değil ve yerinde",
                red.count == 3 && red.allSatisfy { !$0.silinebilir && var_($0.yol) })
        let rk = d.silici.uygula(SilmeIstegi(yol: p("Applications/Kisayol.app"), islem: .uygulamaCopeTasi))
        kontrol("Adım 3: kısayol bekçide reddedilir", rk.durum == .reddedildi && Yol.bagMi(p("Applications/Kisayol.app")))
        for x in red {
            let r = d.silici.uygula(SilmeIstegi(yol: x.yol, islem: .uygulamaCopeTasi))
            kontrol("Adım 3: bekçi \(x.ad) için de reddediyor", r.durum == .reddedildi, r.neden?.s ?? "")
        }

        // Yetki hatası (root sahipli taklidi: üst klasör salt okunur)
        if let k = u("Kaldiricili") {
            let ust = Yol.ebeveyn(k.yol)
            chmod(ust, 0o555)
            d.uygulamalariCopeTasi([k])
            bekle { !d.tasiniyor }
            chmod(ust, 0o755)
            if case .hata(let m) = d.uygulamaKararlari[k.yol] {
                kontrol("Adım 3: yetki hatası çökmeden anlaşılır mesaj ve 'Finder'da göster' önerisi",
                        m.a == .sTasimaIzniYok && var_(k.yol), m.s)
            } else {
                kontrol("Adım 3: yetki hatası taklit edildi", false, "\(String(describing: d.uygulamaKararlari[k.yol]))")
            }
        }
    }

    // MARK: - Adım 4

    func adim4(_ d: Durum) {
        d.tara4()
        bekle { !d.tarama4 }
        guard let dk = d.dokum else { kontrol("Adım 4: döküm var", false); return }
        func bul(_ son: String) -> SistemKalemi? { dk.kalemler.first { $0.yol.hasSuffix(son) } }
        kontrol("Adım 4: deneme kipinde ev dışı yol taranmadı", dk.kalemler.allSatisfy { $0.evIcinde })
        kontrol("Adım 4: büyük klasörde bir düzey inildi (Claude → vm_bundles)", bul("Claude/vm_bundles")?.ust != nil)
        kontrol("Adım 4: sahipsiz artık işaretlendi", bul("com.eskisirket.silinmis")?.sahipsiz == true)
        if let vm = bul("Claude/vm_bundles"), vm.tasinabilir {
            d.sistemKaleminiCopeTasi(vm)
            bekle { !d.tasiniyor }
            kontrol("Adım 4: 'Ferah temizleyebilir' kalem Çöp'e taşındı", !var_(vm.yol) && copteMi("vm_bundles") && d.sistemCopBayt > 0)
        } else {
            kontrol("Adım 4: vm_bundles taşınabilir", false)
        }
        if let mail = bul("Library/Mail") {
            d.sistemKaleminiCopeTasi(mail)
            bekle { !d.tasiniyor }
            kontrol("Adım 4: Dokunma kalem için işlem yok", !mail.tasinabilir && var_(mail.yol))
        }
        let disKalem = SistemKalemi(yol: "/private/tmp", grup: "", boyut: 1, olculemedi: nil, kismen: false, evIcinde: false, ust: nil,
                                    sahip: nil, sahipsiz: false,
                                    aciklama: AciklamaMotoru.sistemAcikla(yol: "/private/tmp", ev: ev).aciklama,
                                    eylem: .ferahTemizler, eylemMetni: nil)
        let once = d.sistemCopBayt
        d.sistemKaleminiCopeTasi(disKalem)
        biraz(0.3)
        kontrol("Adım 4: ev dışı kalem için düğme yok ve çağrı etkisiz", !disKalem.tasinabilir && d.sistemCopBayt == once && var_("/private/tmp"))
    }

    // MARK: - Adım 5

    func adim5(_ d: Durum) {
        let copYolu = p(".Trash")
        let copOgeleri = (try? FileManager.default.contentsOfDirectory(atPath: copYolu)) ?? []
        let copBoyutu = Olcer.olc(copYolu).bayt
        let gecmisOnce = d.depo.gecmis().count
        let kaliciOnce = d.kaliciBayt
        var bitti = false
        d.copuBosalt { _ in bitti = true }
        d.copuBosalt { _ in }   // çift tıklama
        bekle { bitti }
        biraz(0.5)
        kontrol("Özet: 'Çöp Kutusu'nu boşalt' sahte Çöp'ü boşalttı",
                ((try? FileManager.default.contentsOfDirectory(atPath: copYolu)) ?? ["x"]).isEmpty,
                "kalan: \((try? FileManager.default.contentsOfDirectory(atPath: copYolu)) ?? []) · reddedilen: \(d.reddedilen.suffix(3))")
        kontrol("Özet: boşaltılan bayt Çöp boyutuyla tutuyor (±%1), çift çağrı iki kez saymadı",
                abs(Double(d.copBosaltmaBayt - copBoyutu)) <= Double(max(copBoyutu, 1)) * 0.01, "\(d.copBosaltmaBayt) vs \(copBoyutu)")
        kontrol("Özet: Çöp boşaltma kalıcı sayacı değiştirmedi", d.kaliciBayt == kaliciOnce)
        kontrol("Özet: kazanılan = kalıcı + Çöp'ten boşaltılan", d.kazanilan == d.kaliciBayt + d.copBosaltmaBayt)
        kontrol("Özet: uygulama sayacı (2 kaldırıldı)", d.kaldirilanUygulama == 2, "\(d.kaldirilanUygulama)")
        kontrol("Özet: Adım 2 sayacı (4 öğe)", d.adim2Oge == 4, "\(d.adim2Oge)")
        kontrol("Özet: atlanan dosya (kilitli 1)", d.atlananDosya == 1, "\(d.atlananDosya)")
        kontrol("Özet: Çöp'e taşınan toplam = Adım 2 + uygulamalar + verileri + sistem",
                d.copBayt == d.adim2Bayt + d.kaldirilanUygulamaBayt + d.kaldirilanArtikBayt + d.sistemCopBayt)
        kontrol("Özet: gecmis.json her Çöp öğesi için bir kayıt ekledi",
                d.depo.gecmis().count == gecmisOnce + copOgeleri.count, "\(d.depo.gecmis().count - gecmisOnce) vs \(copOgeleri.count)")
        let kalici = d.depo.gecmis().filter { $0.yontem == .kalici }.reduce(Int64(0)) { $0 + $1.boyut }
        kontrol("Özet: geçmişteki kalıcı silme toplamı = kalıcı + boşaltılan sayaç",
                kalici == d.kaliciBayt + d.copBosaltmaBayt, "\(kalici) vs \(d.kaliciBayt + d.copBosaltmaBayt)")
        let cop = d.depo.gecmis().filter { $0.yontem == .cop }.count
        kontrol("Özet: geçmişteki Çöp'e taşıma sayısı (4 dosya + 2 uygulama + 4 artık + 1 sistem)", cop == 11, "\(cop)")
    }
}
