import Foundation
import Darwin

/// `--oz-sinama`: geçici dizinde sahte bir ev kurar ve bekçiyi, silmeyi, kuru çalıştırmayı,
/// tarayıcıları ve açıklama motorunu sınar. Gerçek ev dizinine dokunmaz.
public final class OzSinama {
    var gecen = 0
    var kalan = 0
    var atlanan = 0
    let cikti: (String) -> Void
    /// Metinlerin işlendiği dil (sınamalar her iki dilde de geçmeli).
    let dil: Dil

    public init(dil: Dil = .tr, cikti: @escaping (String) -> Void = { print($0) }) {
        self.dil = dil
        self.cikti = cikti
    }

    /// Metni seçili dilde yazar.
    func t(_ x: Metin?) -> String { x?(dil) ?? "" }

    /// Metin ya da birleşik metnin parçalarından biri bu anahtar mı.
    func icerir(_ x: Metin?, _ a: M) -> Bool {
        guard let x else { return false }
        if x.a == a { return true }
        return x.args.contains { arg in
            if case .metin(let alt) = arg { return icerir(alt, a) }
            return false
        }
    }

    func kontrol(_ ad: String, _ kosul: Bool, _ ayrinti: @autoclosure () -> String = "") {
        if kosul {
            gecen += 1
            cikti("GEÇTİ  \(ad)")
        } else {
            kalan += 1
            let a = ayrinti()
            cikti("KALDI  \(ad)" + (a.isEmpty ? "" : "  → \(a)"))
        }
    }

    func atla(_ ad: String, _ neden: String) {
        atlanan += 1
        cikti("ATLANDI \(ad)  → \(neden)")
    }

    // MARK: Sahte ağaç yardımcıları

    var tmp = ""
    var ev = ""
    var disari = ""

    func dizin(_ p: String) { try? FileManager.default.createDirectory(atPath: p, withIntermediateDirectories: true) }

    /// Gerçek veriyle (diske ayrılmış) dosya.
    func dosya(_ p: String, _ bayt: Int, dolgu: UInt8 = 0x5A) {
        dizin(Yol.ebeveyn(p))
        FileManager.default.createFile(atPath: p, contents: Data(repeating: dolgu, count: bayt))
    }

    /// Seyrek dosya: mantıksal boyutu büyük, diskte neredeyse yer kaplamaz.
    func seyrek(_ p: String, _ bayt: UInt64) {
        dizin(Yol.ebeveyn(p))
        FileManager.default.createFile(atPath: p, contents: nil)
        if let h = FileHandle(forWritingAtPath: p) {
            try? h.truncate(atOffset: bayt)
            try? h.close()
        }
    }

    func bag(_ hedef: String, _ p: String) {
        dizin(Yol.ebeveyn(p))
        _ = symlink(hedef, p)
    }

    func var_(_ p: String) -> Bool { Yol.varMi(p) }

    func reddedildi(_ b: Bekci, _ p: String, _ i: Islem) -> Bool {
        if case .failure = b.denetle(p, i) { return true }
        return false
    }

    func kabul(_ b: Bekci, _ p: String, _ i: Islem) -> Bool {
        if case .success = b.denetle(p, i) { return true }
        return false
    }

    // MARK: Çalıştır

    public func calistir() -> Int32 {
        let kokTmp = Yol.gercek(FileManager.default.temporaryDirectory.path) ?? FileManager.default.temporaryDirectory.path
        tmp = Yol.ekle(kokTmp, "ferah-sinama-\(UUID().uuidString)")
        ev = Yol.ekle(tmp, "ev")
        disari = Yol.ekle(tmp, "disari")
        dizin(ev)
        dizin(disari)
        cikti("Sahte ev: \(ev)")
        defer { temizle() }

        agaciKur()
        bekciSinamalari()
        kuruCalistirSinamalari()
        silmeSinamalari()
        copeTasimaSinamalari()
        kategoriSinamalari()
        buyukTaramaSinamalari()
        aciklamaSinamalari()
        depoSinamalari()
        uygulamaSinamalari()
        sistemSinamalari()
        klonSinamalari()
        kusurSinamalari()
        dilSinamalari()

        cikti("")
        cikti("Sonuç: \(gecen) geçti, \(kalan) kaldı, \(atlanan) atlandı.")
        return kalan == 0 ? 0 : 1
    }

    func temizle() {
        // Kilitli dosyaların kilidini aç, sonra yalnız kendi geçici dizinimizi sil.
        Gezgin.gez(tmp) { g in
            if g.st != nil { _ = lchflags(g.yolC, 0) }
            return .devam
        }
        try? FileManager.default.removeItem(atPath: tmp)
    }

    func agaciKur() {
        let lib = Yol.ekle(ev, "Library")
        for k in Koruma.standartKlasorler { dizin(Yol.ekle(ev, k)) }
        // Önbellekler
        dosya("\(lib)/Caches/com.ornek.uygulama/a.bin", 300_000)
        dosya("\(lib)/Caches/com.ornek.uygulama/alt/b.bin", 200_000)
        dosya("\(lib)/Caches/com.ornek.calisan/c.bin", 100_000)
        dosya("\(lib)/Caches/Google/Chrome/Default/Cache/d.bin", 400_000)
        dosya("\(lib)/Caches/Homebrew/downloads/e.tar.gz", 250_000)
        seyrek("\(lib)/Caches/com.ornek.seyrek/seyrek.img", 1_000_000_000)
        // Hard link: aynı veri iki kez sayılmamalı
        dosya("\(lib)/Caches/com.ornek.hardlink/asil.bin", 1_000_000)
        _ = link("\(lib)/Caches/com.ornek.hardlink/asil.bin", "\(lib)/Caches/com.ornek.hardlink/ikinci.bin")
        // Chrome profili: önbellek ve korunan profil dosyaları
        dosya("\(lib)/Application Support/Google/Chrome/Default/Preferences", 100)
        dosya("\(lib)/Application Support/Google/Chrome/Default/History", 50_000)
        dosya("\(lib)/Application Support/Google/Chrome/Default/Code Cache/js/f.bin", 150_000)
        // Günlükler, Çöp
        dosya("\(lib)/Logs/DiagnosticReports/cokme.ips", 20_000)
        dosya("\(ev)/.Trash/eski.txt", 10_000)
        // Korunanlar
        dosya("\(lib)/Keychains/login.keychain-db", 1_000)
        dosya("\(lib)/Preferences/com.ornek.plist", 1_000)
        dizin("\(ev)/Pictures/Photos Library.photoslibrary/originals")
        dizin("\(ev)/Applications/Ornek.app/Contents")
        dizin("\(lib)/Mobile Documents/com~apple~CloudDocs")
        dizin("\(lib)/Containers/com.apple.mail/Data")
        dosya("\(ev)/.ssh/id_ed25519", 400)
        // Dışarıdaki hedefler (silinmemeli)
        dosya("\(disari)/degerli.txt", 5_000)
        dosya("\(disari)/klasor/icerik.txt", 5_000)
        // Sembolik bağ tuzakları
        bag("\(disari)/degerli.txt", "\(lib)/Caches/com.ornek.uygulama/tuzak-dosya")
        bag("\(disari)/klasor", "\(lib)/Caches/com.ornek.uygulama/tuzak-klasor")
        bag("\(disari)", "\(lib)/Caches/disari-bag")
        bag("\(ev)/Documents", "\(lib)/Caches/belgeler-bag")
        dosya("\(ev)/Documents/onemli.txt", 5_000)
        dosya("\(ev)/Desktop.yedek/not.txt", 1_000)
    }

    // MARK: Bekçi

    func bekciSinamalari() {
        let b = Bekci(ev: ev)
        let lib = Yol.ekle(ev, "Library")
        let onbellek = Islem.kaliciSil(kokler: [Yol.ekle(lib, "Caches")])
        let cop = Islem.copeTasi

        kontrol("Bekçi: ev dizininin kendisi reddedilir", reddedildi(b, ev, cop))
        kontrol("Bekçi: ev dizini + '/' reddedilir", reddedildi(b, ev + "/", cop))
        kontrol("Bekçi: ev dizini + '/.' reddedilir", reddedildi(b, ev + "/.", cop))
        for k in ["Desktop", "Documents", "Downloads", "Library", "Pictures", "Movies", "Music"] {
            kontrol("Bekçi: ~/\(k) reddedilir", reddedildi(b, Yol.ekle(ev, k), cop))
        }
        kontrol("Bekçi: büyük harf taklidi ~/DESKTOP reddedilir", reddedildi(b, Yol.ekle(ev, "DESKTOP"), cop))
        kontrol("Bekçi: ~/Desktop/ (sondaki /) reddedilir", reddedildi(b, Yol.ekle(ev, "Desktop/"), cop))
        kontrol("Bekçi: ~/Documents/../Desktop reddedilir", reddedildi(b, Yol.ekle(ev, "Documents/../Desktop"), cop))
        kontrol("Bekçi: ~/Desktop/./ reddedilir", reddedildi(b, Yol.ekle(ev, "Desktop/./"), cop))
        kontrol("Bekçi: benzer ad ~/Desktop.yedek kabul edilir (korunan değil)", kabul(b, Yol.ekle(ev, "Desktop.yedek"), cop))
        kontrol("Bekçi: ev dışı yol reddedilir", reddedildi(b, Yol.ekle(disari, "degerli.txt"), cop))
        kontrol("Bekçi: ~/../disari ile dışarı kaçış reddedilir", reddedildi(b, Yol.ekle(ev, "../disari/degerli.txt"), cop))
        kontrol("Bekçi: ~/Library/Caches/../../../disari kaçışı reddedilir",
                reddedildi(b, Yol.ekle(ev, "Library/Caches/../../../disari/degerli.txt"), onbellek))
        kontrol("Bekçi: göreli yol reddedilir", reddedildi(b, "Library/Caches/com.ornek.uygulama", cop))
        kontrol("Bekçi: boş yol reddedilir", reddedildi(b, "", cop))
        kontrol("Bekçi: NUL içeren yol reddedilir", reddedildi(b, Yol.ekle(ev, "Library/Caches/x\0y"), cop))
        kontrol("Bekçi: kök '/' reddedilir", reddedildi(b, "/", cop))
        kontrol("Bekçi: anahtar zinciri reddedilir", reddedildi(b, "\(lib)/Keychains/login.keychain-db", cop))
        kontrol("Bekçi: Preferences altı reddedilir", reddedildi(b, "\(lib)/Preferences/com.ornek.plist", cop))
        kontrol("Bekçi: Fotoğraflar kitaplığı reddedilir", reddedildi(b, "\(ev)/Pictures/Photos Library.photoslibrary", cop))
        kontrol("Bekçi: Fotoğraflar kitaplığının içi reddedilir", reddedildi(b, "\(ev)/Pictures/Photos Library.photoslibrary/originals", cop))
        kontrol("Bekçi: ~/Applications içindeki .app reddedilir", reddedildi(b, "\(ev)/Applications/Ornek.app", cop))
        kontrol("Bekçi: Mobile Documents kökü reddedilir", reddedildi(b, "\(lib)/Mobile Documents", cop))
        kontrol("Bekçi: iCloud Drive kökü reddedilir", reddedildi(b, "\(lib)/Mobile Documents/com~apple~CloudDocs", cop))
        kontrol("Bekçi: korunanı içeren üst klasör reddedilir (~/Library/Containers ⊃ com.apple.mail)",
                var_("\(lib)/Containers/com.apple.mail") && reddedildi(b, "\(lib)/Containers", cop))
        kontrol("Bekçi: Mail kapsayıcısının içi reddedilir", reddedildi(b, "\(lib)/Containers/com.apple.mail/Data", cop))
        kontrol("Bekçi: ~/.ssh reddedilir", reddedildi(b, "\(ev)/.ssh", cop))
        kontrol("Bekçi: kategori kökünün kendisi (~/Library/Caches) reddedilir",
                reddedildi(b, "\(lib)/Caches", onbellek))
        kontrol("Bekçi: kategori kökü altındaki önbellek kabul edilir",
                kabul(b, "\(lib)/Caches/com.ornek.uygulama", onbellek))
        kontrol("Bekçi: kategori dışı (~/Documents/onemli.txt) kalıcı silmede reddedilir",
                reddedildi(b, "\(ev)/Documents/onemli.txt", onbellek))
        kontrol("Bekçi: Caches/../Preferences kaçışı reddedilir",
                reddedildi(b, "\(lib)/Caches/../Preferences/com.ornek.plist", onbellek))
        kontrol("Bekçi: dışarıyı gösteren bağın İÇİNDEN geçen yol reddedilir",
                reddedildi(b, "\(lib)/Caches/disari-bag/degerli.txt", onbellek))
        kontrol("Bekçi: ~/Documents'ı gösteren bağ üzerinden belgeye ulaşma reddedilir",
                reddedildi(b, "\(lib)/Caches/belgeler-bag/onemli.txt", onbellek))
        if case .success(let k) = b.denetle("\(lib)/Caches/com.ornek.uygulama/tuzak-dosya", onbellek) {
            kontrol("Bekçi: sembolik bağın kendisi hedeflenir (hedefi değil)", k.hasSuffix("tuzak-dosya") && Yol.altinda(k, ev), k)
        } else {
            kontrol("Bekçi: sembolik bağın kendisi hedeflenir (hedefi değil)", false, "reddedildi")
        }
        kontrol("Bekçi: olmayan yol reddedilir", reddedildi(b, "\(lib)/Caches/yok-boyle-bir-sey", onbellek))
        kontrol("Bekçi: ev dışında kalan kategori kökü işe yaramaz",
                reddedildi(b, "\(lib)/Caches/com.ornek.uygulama", .kaliciSil(kokler: [disari])))
    }

    // MARK: Kuru çalıştırma

    func kuruCalistirSinamalari() {
        let b = Bekci(ev: ev)
        let s = Silici(bekci: b, kuruCalistir: true)
        let kok = Yol.ekle(ev, "Library/Caches")
        let r = s.uygula(SilmeIstegi(yol: "\(kok)/com.ornek.uygulama", islem: .kaliciSil(kokler: [kok]), yalnizIcerik: true))
        kontrol("Kuru çalıştırma: durum 'kuru'", r.durum == .kuru, r.durum.rawValue)
        kontrol("Kuru çalıştırma: hiçbir dosya silinmez",
                var_("\(kok)/com.ornek.uygulama/a.bin") && var_("\(kok)/com.ornek.uygulama/alt/b.bin"))
        kontrol("Kuru çalıştırma: silinecek boyut raporlanır (≥ 500 KB)", r.serbestBayt >= 500_000, "\(r.serbestBayt)")
        kontrol("Kuru çalıştırma: silinecek yollar listelenir", r.silinecekler.count >= 2, "\(r.silinecekler)")
        let c = s.uygula(SilmeIstegi(yol: "\(ev)/Desktop.yedek", islem: .copeTasi))
        kontrol("Kuru çalıştırma: Çöp'e taşıma da yapılmaz", c.durum == .kuru && var_("\(ev)/Desktop.yedek"))
    }

    // MARK: Kalıcı silme

    func silmeSinamalari() {
        let b = Bekci(ev: ev)
        let depo = Depo(klasor: Yol.ekle(tmp, "destek"))
        let s = Silici(bekci: b, depo: depo)
        let kok = Yol.ekle(ev, "Library/Caches")
        let r = s.uygula(SilmeIstegi(yol: "\(kok)/com.ornek.uygulama", islem: .kaliciSil(kokler: [kok]), yalnizIcerik: true))
        kontrol("Silme: önbellek içeriği silinir", !var_("\(kok)/com.ornek.uygulama/a.bin") && !var_("\(kok)/com.ornek.uygulama/alt"))
        kontrol("Silme: önbellek klasörünün kendisi kalır", Yol.dizinMi("\(kok)/com.ornek.uygulama"))
        kontrol("Silme: dışarıdaki bağ hedefi (dosya) yerinde", var_("\(disari)/degerli.txt"))
        kontrol("Silme: dışarıdaki bağ hedefi (klasör içeriği) yerinde", var_("\(disari)/klasor/icerik.txt"))
        kontrol("Silme: sembolik bağların kendisi silinir", !var_("\(kok)/com.ornek.uygulama/tuzak-dosya") && !var_("\(kok)/com.ornek.uygulama/tuzak-klasor"))
        kontrol("Silme: serbest kalan boyut raporlanır (≥ 500 KB)", r.serbestBayt >= 500_000, "\(r.serbestBayt)")
        kontrol("Silme: geçmişe yazılır", depo.gecmis().contains { $0.yol.hasSuffix("com.ornek.uygulama") && $0.yontem == .kalici })

        // ~/Documents'ı gösteren bağ: bağ silinir, belgeler kalır
        let r2 = s.uygula(SilmeIstegi(yol: "\(kok)/belgeler-bag", islem: .kaliciSil(kokler: [kok])))
        kontrol("Silme: ~/Documents'a giden bağ silinir, belgeler kalır",
                r2.durum == .tamam && !var_("\(kok)/belgeler-bag") && var_("\(ev)/Documents/onemli.txt"), "\(r2.durum) \(t(r2.neden))")

        // Kilitli (kullanımda gibi) dosya atlanır ve sayılır
        let kilitli = "\(kok)/com.ornek.calisan/c.bin"
        dosya("\(kok)/com.ornek.calisan/serbest.bin", 50_000)
        _ = chflags(kilitli, UInt32(UF_IMMUTABLE))
        let r3 = s.uygula(SilmeIstegi(yol: "\(kok)/com.ornek.calisan", islem: .kaliciSil(kokler: [kok]), yalnizIcerik: true))
        kontrol("Silme: silinemeyen dosya sessizce atlanır ve sayılır", r3.atlanan == 1 && var_(kilitli) && !var_("\(kok)/com.ornek.calisan/serbest.bin"),
                "atlanan=\(r3.atlanan) durum=\(r3.durum)")
        kontrol("Silme: kısmi sonuç 'kismen' olarak raporlanır", r3.durum == .kismen, r3.durum.rawValue)
        _ = chflags(kilitli, 0)

        // Bekçinin reddettiği şeyler gerçekten silinmez
        let r4 = s.uygula(SilmeIstegi(yol: "\(ev)/Documents/onemli.txt", islem: .kaliciSil(kokler: [kok])))
        kontrol("Silme: kategori dışı dosya reddedilir ve yerinde kalır", r4.durum == .reddedildi && var_("\(ev)/Documents/onemli.txt"))
        let r5 = s.uygula(SilmeIstegi(yol: "\(kok)/../../Documents/onemli.txt", islem: .kaliciSil(kokler: [kok])))
        kontrol("Silme: '..' ile kaçış reddedilir ve dosya yerinde kalır", r5.durum == .reddedildi && var_("\(ev)/Documents/onemli.txt"))
        let r6 = s.uygula(SilmeIstegi(yol: "\(kok)/disari-bag", islem: .kaliciSil(kokler: [kok]), yalnizIcerik: true))
        kontrol("Silme: dışarıyı gösteren bağın içi boşaltılmaz", r6.durum == .reddedildi && var_("\(disari)/degerli.txt"), "\(r6.durum) \(t(r6.neden))")
        let r7 = s.uygula(SilmeIstegi(yol: kok, islem: .kaliciSil(kokler: [kok])))
        kontrol("Silme: kategori kökünün kendisi silinmez", r7.durum == .reddedildi && Yol.dizinMi(kok))
    }

    // MARK: Çöp'e taşıma (sahte Çöp; gerçek Çöp Kutusu kullanılmaz)

    func copeTasimaSinamalari() {
        let b = Bekci(ev: ev)
        let sahteCop = Yol.ekle(tmp, "sahte-cop")
        dizin(sahteCop)
        let depo = Depo(klasor: Yol.ekle(tmp, "destek"))
        let s = Silici(bekci: b, depo: depo, copeTasiyici: { url in
            let hedef = URL(fileURLWithPath: Yol.ekle(sahteCop, url.lastPathComponent))
            try FileManager.default.moveItem(at: url, to: hedef)
            return hedef
        })
        dosya("\(ev)/Movies/buyuk.mov", 300_000)
        let r = s.uygula(SilmeIstegi(yol: "\(ev)/Movies/buyuk.mov", islem: .copeTasi))
        kontrol("Çöp'e taşı: dosya taşınır", r.durum == .tamam && !var_("\(ev)/Movies/buyuk.mov") && var_("\(sahteCop)/buyuk.mov"))
        kontrol("Çöp'e taşı: geçmişe 'cop' olarak yazılır", depo.gecmis().contains { $0.yontem == .cop && $0.yol.hasSuffix("buyuk.mov") })
        let r2 = s.uygula(SilmeIstegi(yol: "\(ev)/Pictures/Photos Library.photoslibrary", islem: .copeTasi))
        kontrol("Çöp'e taşı: Fotoğraflar kitaplığı reddedilir", r2.durum == .reddedildi && var_("\(ev)/Pictures/Photos Library.photoslibrary"))
        let r3 = s.uygula(SilmeIstegi(yol: "\(ev)/Desktop", islem: .copeTasi))
        kontrol("Çöp'e taşı: ~/Desktop reddedilir", r3.durum == .reddedildi && Yol.dizinMi("\(ev)/Desktop"))
        let r4 = s.uygula(SilmeIstegi(yol: "\(ev)/Movies/klasor", islem: .copeTasi, yalnizIcerik: true))
        kontrol("Çöp'e taşı: 'yalnız içerik' kipi reddedilir", r4.durum == .reddedildi)
    }

    // MARK: Kategori taraması

    func kategoriSinamalari() {
        let lib = Yol.ekle(ev, "Library")
        // Silme sınamasında boşalan önbelleği yeniden doldur
        dosya("\(lib)/Caches/com.ornek.uygulama/a.bin", 300_000)
        dosya("\(lib)/Caches/com.ornek.calisan/c.bin", 100_000)
        let bg = TaramaBaglami(ev: ev, calisanKimlikler: ["com.ornek.calisan"])
        let hepsi = KategoriTarayici.taraHepsi(bg)
        func kat(_ k: KategoriKimlik) -> KategoriSonuc? { hepsi.first { $0.kimlik == k } }

        let uyg = kat(.uygulamaOnbellek)
        kontrol("Tarama: tüm kategoriler döner", hepsi.count == KategoriKimlik.allCases.count)
        kontrol("Tarama: uygulama önbelleği bulunur", uyg?.ogeler.contains { $0.ad == "com.ornek.uygulama" } == true)
        let calisan = uyg?.ogeler.first { $0.ad == "com.ornek.calisan" }
        kontrol("Tarama: çalışan uygulamanın önbelleği işaretlenir ve varsayılan seçilmez",
                calisan?.calisiyor == true && calisan?.varsayilanSecili == false)
        kontrol("Tarama: Chrome önbelleği uygulama önbelleklerinde çift sayılmaz",
                uyg?.ogeler.contains { $0.ad == "Google" } == false)
        kontrol("Tarama: Homebrew uygulama önbelleklerinde çift sayılmaz",
                uyg?.ogeler.contains { $0.ad == "Homebrew" } == false)
        let tar = kat(.tarayici)
        kontrol("Tarama: tarayıcı önbellekleri bulunur (Caches + Code Cache)",
                (tar?.ogeler.contains { $0.yol.hasSuffix("Caches/Google/Chrome") } ?? false)
                && (tar?.ogeler.contains { $0.yol.hasSuffix("Default/Code Cache") } ?? false), "\(tar?.ogeler.map(\.ad) ?? [])")
        kontrol("Tarama: tarayıcı profil dosyaları (History) öğe değildir",
                tar?.ogeler.contains { $0.yol.hasSuffix("History") || $0.yol.hasSuffix("/Default") } == false)
        kontrol("Tarama: geliştirici önbelleği (Homebrew) bulunur", kat(.gelistirici)?.ogeler.contains { $0.baslik.a == .katIndirmeleri } == true)
        let seyrek = uyg?.ogeler.first { $0.ad == "com.ornek.seyrek" }
        kontrol("Boyut: 1 GB seyrek dosya diskte ayrılan boyutla ölçülür (< 1 MB)", (seyrek?.boyut ?? 0) < 1_000_000, "\(seyrek?.boyut ?? -1)")
        let hl = uyg?.ogeler.first { $0.ad == "com.ornek.hardlink" }
        kontrol("Boyut: hard link iki kez sayılmaz (~1 MB, 2 MB değil)",
                (hl?.boyut ?? 0) >= 1_000_000 && (hl?.boyut ?? 0) < 1_500_000, "\(hl?.boyut ?? -1)")
        kontrol("Tarama: Çöp Kutusu riski 'Dikkat' ve varsayılan seçili değil",
                kat(.copKutusu)?.risk == .dikkat && kat(.copKutusu)?.ogeler.allSatisfy { !$0.varsayilanSecili } == true)
        kontrol("Tarama: olmayan kategori 'yok' olarak döner ve gizlenir", kat(.xcodeArsiv)?.durum == .yok && kat(.xcodeArsiv)?.gorunur == false)

        // Erişim reddi: okunamayan kök çökme yerine 'erişim yok' verir
        let kilitliKok = Yol.ekle(ev, ".Trash")
        chmod(kilitliKok, 0o000)
        let copTekrar = KategoriTarayici.tara(.copKutusu, bg)
        chmod(kilitliKok, 0o755)
        kontrol("Tarama: okunamayan kategori 'erisim_yok' döner", copTekrar.durum == .erisimYok, copTekrar.durum.rawValue)

        // Adım 1 temizliği uçtan uca (Temizleyici + Bekçi)
        let silici = Silici(bekci: Bekci(ev: ev))
        if let t = tar {
            let rap = Temizleyici.temizle([(t, t.ogeler)], silici: silici)
            kontrol("Temizlik: tarayıcı önbellekleri silinir, profil dosyaları kalır",
                    rap.reddedilen.isEmpty
                    && !var_("\(lib)/Application Support/Google/Chrome/Default/Code Cache/js")
                    && var_("\(lib)/Application Support/Google/Chrome/Default/History")
                    && var_("\(lib)/Application Support/Google/Chrome/Default/Preferences"), "\(rap.reddedilen)")
        }
    }

    // MARK: Büyük dosya taraması

    func buyukTaramaSinamalari() {
        let mb = 1_000_000
        dosya("\(ev)/Downloads/Firefox 120.0.dmg", 3 * mb)
        dosya("\(ev)/Movies/Ekran Kaydı 2024-01-01.mov", 3 * mb, dolgu: 0x01)
        dosya("\(ev)/Projeler/web/package.json", 100)
        dosya("\(ev)/Projeler/web/node_modules/a/index.js", 2 * mb)
        dosya("\(ev)/Projeler/web/node_modules/b/index.js", 2 * mb)
        dosya("\(ev)/Projeler/kutuphane/build/cikti.o", 3 * mb) // proje dosyası yok → klasör aday değil, dosya aday
        dosya("\(ev)/Projeler/uygulama.pvm/disk.hdd", 3 * mb)
        dosya("\(ev)/Downloads/arsiv.zip", 3 * mb)
        dizin("\(ev)/Downloads/arsiv")
        seyrek("\(ev)/Downloads/seyrek-buyuk.img", 2_000_000_000)
        dosya("\(ev)/Library/Caches/buyuk-onbellek.bin", 3 * mb) // Library taranmaz
        dosya("\(ev)/Library/Application Support/MobileSync/Backup/00008030-ABC/Manifest.db", 3 * mb)
        dosya("\(ev)/Pictures/Photos Library.photoslibrary/originals/IMG_0001.heic", 3 * mb)
        // Gerçek makinede görülen tuzaklar
        dosya("\(ev)/.vscode/extensions/ornek.eklenti-1.0/package.json", 100)
        dosya("\(ev)/.vscode/extensions/ornek.eklenti-1.0/dist/extension.js", 3 * mb)
        dosya("\(ev)/Projeler/site/package.json", 100)
        dosya("\(ev)/Projeler/site/package-lock.json", 100)
        dosya("\(ev)/Projeler/site/dist/bundle.js", 3 * mb)
        dosya("\(ev)/Projeler/ses/.venv-yerel/pyvenv.cfg", 100)
        dosya("\(ev)/Projeler/ses/.venv-yerel/lib/libtorch.dylib", 3 * mb)
        let kasa = "\(ev)/.kasa/kasa.dmg"
        dosya(kasa, 3 * mb)
        if let h = FileHandle(forWritingAtPath: kasa) { h.write(Data("encrcdsa".utf8)); try? h.close() }
        dosya("\(ev)/.cache/huggingface/hub/blobs/12/12d56aa4", 3 * mb)
        dosya("\(ev)/Movies/Telefon/IMG_2279.MOV", 3 * mb, dolgu: 0x02)
        dosya("\(ev)/Movies/Instagram/IMG_2279.MOV", 3 * mb, dolgu: 0x02)
        dosya("\(ev)/Movies/CapCut/User Data/Cache/kirp.mov", 3 * mb, dolgu: 0x03)

        let ayar = BuyukTaramaAyari(ev: ev, esik: Int64(2 * mb), saklananlar: ["\(ev)/Downloads/arsiv.zip"],
                                    kuruluUygulamalar: ["Firefox", "Safari"])
        let l = BuyukTarayici.tara(ayar)
        func bul(_ son: String) -> BuyukAday? { l.first { $0.yol.hasSuffix(son) } }

        kontrol("Büyük: .dmg bulunur ve kurulu Firefox ile eşleşir",
                bul("Firefox 120.0.dmg")?.aciklama.risk == .guvenli && bul("Firefox 120.0.dmg")?.sinyaller.kuruluUygulama == "Firefox")
        kontrol("Büyük: node_modules tek öğe olarak bulunur", bul("web/node_modules")?.girdi.ozelTur == .nodeModules)
        kontrol("Büyük: node_modules içindeki dosyalar ayrıca listelenmez", !l.contains { $0.yol.contains("node_modules/") })
        kontrol("Büyük: proje dosyası olmayan 'build' klasörü yeniden üretilebilir sayılmaz",
                bul("kutuphane/build") == nil && bul("build/cikti.o") != nil)
        kontrol("Büyük: paket (.pvm) içine girilmez, tek öğe sayılır",
                bul("uygulama.pvm")?.girdi.paketMi == true && bul("disk.hdd") == nil)
        kontrol("Büyük: seyrek dosya eşiği geçmez", bul("seyrek-buyuk.img") == nil)
        kontrol("Büyük: ~/Library geneli taranmaz", bul("buyuk-onbellek.bin") == nil)
        kontrol("Büyük: iOS yedeği ~/Library'den aday olur", bul("Backup/00008030-ABC")?.girdi.ozelTur == .iosYedegi)
        kontrol("Büyük: Fotoğraflar kitaplığı 'Dokunma' olarak görünür, silinemez",
                bul("Photos Library.photoslibrary")?.aciklama.risk == .dokunma && bul("Photos Library.photoslibrary")?.silinebilir == false)
        kontrol("Büyük: arşivin açılmış hali yanında algılanır", bul("arsiv.zip")?.sinyaller.acilmisHaliYaninda == true)
        kontrol("Büyük: editör eklentisinin dist'i derleme çıktısı sayılmaz",
                bul("eklenti-1.0/dist") == nil && bul("dist/extension.js")?.aciklama.tur.a == .aEditorTur)
        kontrol("Büyük: kilit dosyalı projenin dist'i derleme çıktısı", bul("site/dist")?.girdi.ozelTur == .derlemeCiktisi)
        kontrol("Büyük: pyvenv.cfg içeren her klasör sanal ortam (ad farklı olsa da)", bul("ses/.venv-yerel")?.girdi.ozelTur == .sanalOrtam)
        kontrol("Büyük: şifreli .dmg kurulum dosyası sayılmaz, Riskli",
                bul("kasa.dmg")?.sinyaller.sifreliImaj == true && bul("kasa.dmg")?.aciklama.risk == .riskli)
        kontrol("Büyük: Hugging Face blobs düzeni tanınır", bul("blobs/12/12d56aa4")?.aciklama.tur.a == .aHfTur)
        let k1 = bul("Telefon/IMG_2279.MOV"), k2 = bul("Instagram/IMG_2279.MOV")
        kontrol("Büyük: aynı videonun iki kopyası birbirini gösterir",
                k1?.sinyaller.kopyaYolu?.hasSuffix("Instagram/IMG_2279.MOV") == true && k2?.sinyaller.kopyaYolu?.hasSuffix("Telefon/IMG_2279.MOV") == true)
        kontrol("Büyük: kopyası olan video Riskli'den Dikkat'e iner", k1?.aciklama.risk == .dikkat && k1?.aciklama.baglam.contains { $0.a == .aBglKopya } == true)
        kontrol("Büyük: aynı boyutlu farklı içerik kopya sayılmaz", bul("Ekran Kaydı 2024-01-01.mov")?.sinyaller.kopyaYolu == nil)
        kontrol("Büyük: önbellek klasöründeki video Dikkat", bul("Cache/kirp.mov")?.aciklama.risk == .dikkat)
        kontrol("Büyük: daha önce saklanan sona atılır", l.last?.yol.hasSuffix("arsiv.zip") == true, l.last?.yol ?? "")
        kontrol("Büyük: Dokunma öğeleri saklanmayanların sonunda",
                l.firstIndex { $0.aciklama.risk == .dokunma }.map { i in l[i...].allSatisfy { $0.aciklama.risk == .dokunma || $0.saklandi } } ?? false)
    }

    // MARK: Açıklama motoru

    func aciklamaSinamalari() {
        let simdi = Date()
        let ikiYilOnce = simdi.addingTimeInterval(-2 * 365 * 86_400)
        let sekizAyOnce = simdi.addingTimeInterval(-245 * 86_400)
        func a(_ yol: String, dizin: Bool = false, paket: Bool = false, ozel: OzelTur? = nil, acilma: Date? = nil,
               degisme: Date? = nil, _ s: Sinyaller = Sinyaller()) -> Aciklama {
            AciklamaMotoru.acikla(AdayGirdisi(yol: Yol.ekle(ev, yol), boyut: 500_000_000, dizinMi: dizin, paketMi: paket,
                                              ozelTur: ozel, sonDegisme: degisme, sonAcilma: acilma), s, ev: ev, simdi: simdi)
        }
        var kurulu = Sinyaller(); kurulu.kuruluUygulama = "Firefox"
        kontrol("Motor: kurulu uygulamanın .dmg'si Güvenli", a("Downloads/Firefox.dmg", kurulu).risk == .guvenli)
        kontrol("Motor: eşleşmeyen .pkg Dikkat", a("Downloads/bilinmez.pkg").risk == .dikkat)
        kontrol("Motor: .ipsw Güvenli, yeniden indirilebilir", a("Downloads/iPhone.ipsw").risk == .guvenli && a("Downloads/iPhone.ipsw").geriNasil != nil)
        kontrol("Motor: kişisel video Riskli", a("Movies/tatil.mp4").risk == .riskli)
        kontrol("Motor: ekran kaydı tanınır", a("Desktop/Ekran Kaydı 2024-03-01 12.00.00.mov").tur.a == .aEkranKaydiTur)
        kontrol("Motor: 'Screen Recording' tanınır", a("Desktop/Screen Recording 2024-03-01.mov").tur.a == .aEkranKaydiTur)
        kontrol("Motor: .wav Riskli", a("Music/kayit.wav").risk == .riskli)
        var acilmis = Sinyaller(); acilmis.acilmisHaliYaninda = true
        let ars = a("Downloads/proje.zip", acilmis)
        kontrol("Motor: açılmış hali yanında olan arşiv fazlalık sayılır", ars.risk == .guvenli && ars.neOlur.a == .aArsivAcilmisNe)
        kontrol("Motor: tek başına arşiv Dikkat", a("Downloads/proje.tar.gz").risk == .dikkat)
        var proje = Sinyaller(); proje.projeSonDegisme = sekizAyOnce
        let nm = a("Projeler/web/node_modules", dizin: true, ozel: .nodeModules, proje)
        kontrol("Motor: node_modules Güvenli ve npm install ile geri gelir", nm.risk == .guvenli && nm.geriNasil?.a == .aNodeGeri && t(nm.geriNasil).contains("npm install"))
        kontrol("Motor: projeye kaç aydır dokunulmadığı söylenir", nm.baglam.contains { $0.a == .aBglProje && t($0).contains(dil == .tr ? "8 aydır" : "8 months") }, nm.baglam.map(t).joined(separator: " | "))
        kontrol("Motor: Python sanal ortamı Güvenli", a("p/.venv", dizin: true, ozel: .sanalOrtam).risk == .guvenli)
        kontrol("Motor: Pods → pod install", a("p/Pods", dizin: true, ozel: .pods).geriNasil?.a == .aPodsGeri)
        let dr = a("Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw", ozel: .dockerRaw)
        kontrol("Motor: Docker.raw Riskli ve Docker temizliği önerilir", dr.risk == .riskli && dr.oneriMetni?.a == .aDockerOneri && t(dr.oneriMetni).contains("prune"))
        kontrol("Motor: sanal makine diski Riskli", a("VM/disk.qcow2").risk == .riskli && a("Parallels/Win.pvm", dizin: true, paket: true).risk == .riskli)
        var yedek = Sinyaller(); yedek.cihazAdi = "Efe'nin iPhone'u"
        let iy = a("Library/Application Support/MobileSync/Backup/X", dizin: true, ozel: .iosYedegi, yedek)
        kontrol("Motor: iOS yedeği Riskli, iCloud yedeğinden söz eder", iy.risk == .riskli && iy.geriNasil?.a == .aIosYedekGeri)
        kontrol("Motor: Fotoğraflar kitaplığı Dokunma", a("Pictures/Photos Library.photoslibrary", dizin: true, paket: true).risk == .dokunma)
        kontrol("Motor: Müzik kitaplığı Dokunma", a("Music/Music/Music Library.musiclibrary", dizin: true, paket: true).risk == .dokunma)
        kontrol("Motor: ~/Applications içindeki .app Dokunma", a("Applications/Oyun.app", dizin: true, paket: true).risk == .dokunma)
        kontrol("Motor: İndirilenler'deki .app Dikkat", a("Downloads/Oyun.app", dizin: true, paket: true).risk == .dikkat)
        kontrol("Motor: Mobile Documents kökü Dokunma", a("Library/Mobile Documents", dizin: true).risk == .dokunma)
        var bulut = Sinyaller(); bulut.bulut = "iCloud Drive"
        let bl = a("Library/Mobile Documents/com~apple~CloudDocs/Ekran Kaydı 1.mov", bulut)
        kontrol("Motor: iCloud Drive'daki dosyada buluttan da silinir uyarısı", bl.baglam.contains { $0.a == .aBglBulut })
        var git = Sinyaller(); git.gitIzleniyor = true
        let gt = a("Projeler/x/veri.log", git)
        kontrol("Motor: Git'te izlenen dosya en az Dikkat olur", gt.risk >= .dikkat && gt.baglam.contains { $0.a == .aBglGit })
        kontrol("Motor: .sqlite Riskli", a("Projeler/x/veri.sqlite").risk == .riskli)
        kontrol("Motor: .sparsebundle Riskli", a("Yedek.sparsebundle", dizin: true, paket: true).risk == .riskli)
        kontrol("Motor: .gguf model Dikkat ve yeniden indirilebilir", a(".lmstudio/models/x.gguf").risk == .dikkat && a(".lmstudio/models/x.gguf").geriNasil?.a == .aModelGeri)
        kontrol("Motor: Ollama modelleri tanınır", a(".ollama/models", dizin: true, ozel: .ollamaModelleri).tur.a == .aOllamaTur)
        kontrol("Motor: Hugging Face önbelleği 'büyük indirme' der", a(".cache/huggingface/hub/models--x", dizin: true, ozel: .hfModeli).geriNasil?.a == .aHfGeri)
        var blend = Sinyaller(); blend.asilDosyaYaninda = true
        kontrol("Motor: asıl dosyası yanında olan .blend1 Güvenli", a("3D/sahne.blend1", blend).risk == .guvenli)
        kontrol("Motor: tek başına .blend1 Dikkat", a("3D/sahne.blend1").risk == .dikkat)
        kontrol("Motor: Final Cut kitaplığı Riskli", a("Movies/Kurgu.fcpbundle", dizin: true, paket: true).risk == .riskli)
        kontrol("Motor: Steam oyunu Dikkat", a("Library/Application Support/Steam/steamapps/common/Oyun", dizin: true, ozel: .steamOyunu).risk == .dikkat)
        let eski = a("Downloads/eski.bin", acilma: ikiYilOnce)
        kontrol("Motor: 1 yıldan uzun açılmamışsa bağlama eklenir", eski.baglam.contains { $0.a == .aBglAcilmamis })
        kontrol("Motor: gizli klasördeki .dmg kurulum dosyası sayılmaz (kurulu uygulamayla eşleşse bile)",
                a(".kasa/ornek-kasa.dmg", kurulu).risk == .riskli)
        kontrol("Motor: .dylib program kütüphanesi, saklanması önerilir", a("x/lib/libtorch.dylib").oneri == .sakla)
        let bilinmez = a("Belgeler/gizemli.xyz")
        kontrol("Motor: kural yoksa dürüst genel metin ve 'sakla' önerisi",
                bilinmez.oneri == .sakla && bilinmez.neOlur.a == .aBilinmeyenNe)
        kontrol("Motor: tüm metinler 3 cümleyi geçmez",
                [nm, dr, iy, ars, bilinmez, bl].allSatisfy { t($0.neOlur).components(separatedBy: ". ").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count <= 3 })
        kontrol("Eşleştirme: 'googlechrome.dmg' → Google Chrome",
                SinyalToplayici.eslesenUygulama("googlechrome.dmg", kurulu: ["Google Chrome", "Safari"]) == "Google Chrome")
        kontrol("Eşleştirme: 'Firefox 120.0.dmg' → Firefox",
                SinyalToplayici.eslesenUygulama("Firefox 120.0.dmg", kurulu: ["Firefox"]) == "Firefox")
        kontrol("Eşleştirme: ilgisiz ad eşleşmez",
                SinyalToplayici.eslesenUygulama("rapor.dmg", kurulu: ["Firefox", "Safari"]) == nil)
    }

    // MARK: Depo

    func depoSinamalari() {
        let d = Depo(klasor: Yol.ekle(tmp, "destek2"))
        d.sakla("/x/y")
        d.sakla("/x/z")
        d.saklamayiKaldir("/x/z")
        kontrol("Depo: 'sakla' kararları kalıcı", Depo(klasor: d.klasor).saklananlar() == ["/x/y"])
        d.gecmiseEkle([GecmisKaydi(tarih: Date(), yol: "/a", boyut: 10, yontem: .kalici)])
        d.gecmiseEkle([GecmisKaydi(tarih: Date(), yol: "/b", boyut: 20, yontem: .cop)])
        kontrol("Depo: geçmiş eklenerek büyür ve okunur", Depo(klasor: d.klasor).gecmis().count == 2)
        kontrol("Depo: gecmis.json dosyası oluşur", var_(Yol.ekle(d.klasor, "gecmis.json")))
    }

    // MARK: Uygulamalar (sahte uygulama kökü; gerçek /Applications kullanılmaz)

    func sahteUygulama(_ yol: String, kimlik: String?, appStore: Bool = false) {
        dizin(Yol.ekle(yol, "Contents/MacOS"))
        dosya(Yol.ekle(yol, "Contents/MacOS/calistirilabilir"), 200_000)
        if let k = kimlik {
            let pl: NSDictionary = ["CFBundleIdentifier": k, "CFBundleShortVersionString": "1.2.3"]
            pl.write(toFile: Yol.ekle(yol, "Contents/Info.plist"), atomically: true)
        }
        if appStore { dosya(Yol.ekle(yol, "Contents/_MASReceipt/receipt"), 100) }
    }

    func uygulamaSinamalari() {
        let kok = Yol.ekle(tmp, "Uygulamalar")
        let evApps = Yol.ekle(ev, "Applications")
        sahteUygulama("\(kok)/Ornek.app", kimlik: "com.foo.bar", appStore: true)
        sahteUygulama("\(kok)/Utilities/Alt.app", kimlik: "com.foo.alt")
        sahteUygulama("\(kok)/Klasor/Derin/Cok.app", kimlik: "com.foo.cok")
        sahteUygulama("\(kok)/Safari Taklit.app", kimlik: "com.apple.Safari")
        sahteUygulama("\(kok)/Calisan.app", kimlik: "com.foo.Calisan")
        sahteUygulama("\(kok)/Ferah.app", kimlik: "network.akca.ferah")
        sahteUygulama("\(kok)/Plistsiz.app", kimlik: nil)
        sahteUygulama("\(kok)/Ornek.app/Contents/Helpers/Yardimci.app", kimlik: "com.foo.yardimci")
        sahteUygulama("\(disari)/Disarida.app", kimlik: "com.foo.disari")
        sahteUygulama("\(evApps)/EvUyg.app", kimlik: "com.foo.ev")
        sahteUygulama("\(kok)/Ortak.app", kimlik: "com.foo.ortak")
        sahteUygulama("\(kok)/Utilities/Ortak.app", kimlik: "com.foo.ortak2")
        dizin("\(kok)/Klasor.app.yedek")
        bag("\(kok)/Ornek.app", "\(kok)/Kisayol.app")
        bag(disari, "\(kok)/DisariBag")
        sahteUygulama("\(disari)/BagUzerinden.app", kimlik: "com.foo.bag")

        let b = Bekci(ev: ev, uygulamaKokleri: [kok, evApps], calisanKimlikler: { ["com.foo.calisan"] },
                      kendiPaketi: "\(kok)/Ferah.app")
        let u = Islem.uygulamaCopeTasi
        kontrol("Uygulama bekçisi: kökteki .app kabul edilir", kabul(b, "\(kok)/Ornek.app", u))
        kontrol("Uygulama bekçisi: bir alt klasördeki .app kabul edilir", kabul(b, "\(kok)/Utilities/Alt.app", u))
        kontrol("Uygulama bekçisi: ~/Applications içindeki .app kabul edilir", kabul(b, "\(evApps)/EvUyg.app", u))
        kontrol("Uygulama bekçisi: iki alt klasör derinlik reddedilir", reddedildi(b, "\(kok)/Klasor/Derin/Cok.app", u))
        kontrol("Uygulama bekçisi: kökün kendisi reddedilir", reddedildi(b, kok, u))
        kontrol("Uygulama bekçisi: alt klasörün kendisi reddedilir", reddedildi(b, "\(kok)/Utilities", u))
        kontrol("Uygulama bekçisi: .app içindeki alt yol reddedilir", reddedildi(b, "\(kok)/Ornek.app/Contents", u))
        kontrol("Uygulama bekçisi: .app içindeki yardımcı .app reddedilir", reddedildi(b, "\(kok)/Ornek.app/Contents/Helpers/Yardimci.app", u))
        kontrol("Uygulama bekçisi: kök dışındaki .app reddedilir", reddedildi(b, "\(disari)/Disarida.app", u))
        kontrol("Uygulama bekçisi: '..' kaçışı reddedilir", reddedildi(b, "\(kok)/../disari/Disarida.app", u))
        kontrol("Uygulama bekçisi: sembolik bağ .app reddedilir", reddedildi(b, "\(kok)/Kisayol.app", u) && var_("\(kok)/Ornek.app"))
        kontrol("Uygulama bekçisi: bağlı klasör üzerinden kaçış reddedilir", reddedildi(b, "\(kok)/DisariBag/BagUzerinden.app", u))
        kontrol("Uygulama bekçisi: com.apple. kimlikli uygulama reddedilir", reddedildi(b, "\(kok)/Safari Taklit.app", u))
        kontrol("Uygulama bekçisi: çalışan uygulama reddedilir (kimlik büyük/küçük harf)", reddedildi(b, "\(kok)/Calisan.app", u))
        kontrol("Uygulama bekçisi: Ferah'ın kendisi reddedilir", reddedildi(b, "\(kok)/Ferah.app", u))
        kontrol("Uygulama bekçisi: Info.plist'siz paket reddedilir", reddedildi(b, "\(kok)/Plistsiz.app", u))
        kontrol("Uygulama bekçisi: .app olmayan klasör reddedilir", reddedildi(b, "\(kok)/Klasor.app.yedek", u))
        kontrol("Uygulama bekçisi: /Applications diğer işlemlere kapalı (copeTasi)", reddedildi(b, "\(kok)/Ornek.app", .copeTasi))
        kontrol("Uygulama bekçisi: /Applications diğer işlemlere kapalı (kaliciSil)", reddedildi(b, "\(kok)/Ornek.app", .kaliciSil(kokler: [kok])))
        kontrol("Uygulama bekçisi: ~/Applications .app hâlâ copeTasi ile reddedilir", reddedildi(b, "\(evApps)/EvUyg.app", .copeTasi))

        // Kuru çalıştırma ve sahte Çöp'e taşıma
        let kuru = Silici(bekci: b, kuruCalistir: true)
        let rk = kuru.uygula(SilmeIstegi(yol: "\(kok)/Ornek.app", islem: u))
        kontrol("Uygulama: kuru çalıştırmada taşınmaz, boyut raporlanır", rk.durum == .kuru && var_("\(kok)/Ornek.app") && rk.serbestBayt > 0)
        let sahteCop = Yol.ekle(tmp, "sahte-cop-uyg")
        dizin(sahteCop)
        let depo = Depo(klasor: Yol.ekle(tmp, "destek-uyg"))
        let s = Silici(bekci: b, depo: depo, copeTasiyici: { url in
            let h = URL(fileURLWithPath: Yol.ekle(sahteCop, url.lastPathComponent))
            try FileManager.default.moveItem(at: url, to: h)
            return h
        })
        let r = s.uygula(SilmeIstegi(yol: "\(kok)/Utilities/Alt.app", islem: u))
        kontrol("Uygulama: Çöp'e taşınır ve geçmişe 'cop' yazılır",
                r.durum == .tamam && !var_("\(kok)/Utilities/Alt.app") && var_("\(sahteCop)/Alt.app")
                && depo.gecmis().contains { $0.yol.hasSuffix("Alt.app") && $0.yontem == .cop })
        let r2 = s.uygula(SilmeIstegi(yol: "\(kok)/Calisan.app", islem: u))
        kontrol("Uygulama: çalışan uygulama taşınmaz", r2.durum == .reddedildi && var_("\(kok)/Calisan.app"))
        let izinsiz = Silici(bekci: b, copeTasiyici: { _ in
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteNoPermissionError)
        })
        let r3 = izinsiz.uygula(SilmeIstegi(yol: "\(kok)/Ornek.app", islem: u))
        kontrol("Uygulama: yetki hatası çökmeden anlaşılır mesaj verir",
                r3.durum == .hata && r3.neden?.a == .sTasimaIzniYok, t(r3.neden))

        // Artık eşleştirme: yalnız tam eşleşme
        let lib = Yol.ekle(ev, "Library")
        dosya("\(lib)/Application Support/com.foo.bar/veri.db", 50_000)
        dosya("\(lib)/Application Support/com.foo.barista/veri.db", 50_000)
        dosya("\(lib)/Application Support/com.foo/veri.db", 50_000)
        dosya("\(lib)/Caches/com.foo.bar/onbellek", 30_000)
        dosya("\(lib)/Caches/com.foo.bar.yardimci/onbellek", 30_000)
        dosya("\(lib)/Saved Application State/com.foo.bar.savedState/pencere", 1_000)
        dosya("\(lib)/HTTPStorages/com.foo.bar/x", 1_000)
        dosya("\(lib)/Application Support/Ornek/ayar", 5_000)
        dosya("\(lib)/Application Support/Ornekler/ayar", 5_000)
        dosya("\(lib)/Application Support/Ortak/ayar", 5_000)
        dizin("\(lib)/Containers/com.foo.bar/Data")
        dosya("\(lib)/Preferences/com.foo.bar.plist", 500)
        let a = UygulamaTarayici.artiklariBul(kimlik: "com.foo.bar", ad: "Ornek", ev: ev, adCakisiyor: false)
        let adlar = Set(a.map { Yol.kisa($0.yol, ev: ev) })
        let beklenen: Set<String> = ["~/Library/Application Support/com.foo.bar", "~/Library/Caches/com.foo.bar",
                                     "~/Library/Saved Application State/com.foo.bar.savedState",
                                     "~/Library/HTTPStorages/com.foo.bar", "~/Library/Application Support/Ornek",
                                     "~/Library/Containers/com.foo.bar"]
        kontrol("Artık: yalnız tam eşleşenler alınır (barista, com.foo, .yardimci, Ornekler, Preferences yok)",
                adlar == beklenen, "\(adlar.sorted())")
        kontrol("Artık: kapsayıcı ölçülmeden 'erişilemedi' işaretlenir",
                a.first { $0.yol.hasSuffix("Containers/com.foo.bar") }?.erisilemedi == true)
        kontrol("Artık: diğerleri ölçülür", a.first { $0.yol.hasSuffix("Support/com.foo.bar") }.map { $0.boyut >= 50_000 } == true)
        let a2 = UygulamaTarayici.artiklariBul(kimlik: "com.foo.ortak", ad: "Ortak", ev: ev, adCakisiyor: true)
        kontrol("Artık: adı başka uygulamayla çakışan klasör alınmaz", !a2.contains { $0.yol.hasSuffix("Support/Ortak") })
        let a3 = UygulamaTarayici.artiklariBul(kimlik: "com.foo.BAR", ad: "x", ev: ev, adCakisiyor: false)
        kontrol("Artık: büyük/küçük harf farklı kimlik tam eşleşme sayılmaz", a3.isEmpty, "\(a3.map(\.yol))")
        // Artıklar copeTasi ile geçer; Preferences korunur
        kontrol("Artık: Application Support/<kimlik> copeTasi ile kabul", kabul(b, "\(lib)/Application Support/com.foo.bar", .copeTasi))
        kontrol("Artık: Preferences plist'i reddedilir", reddedildi(b, "\(lib)/Preferences/com.foo.bar.plist", .copeTasi))

        // Tarayıcı
        let ayar = UygulamaTaramaAyari(kokler: [kok, evApps], ev: ev, calisanKimlikler: ["com.foo.Calisan"],
                                       kendiPaketi: "\(kok)/Ferah.app")
        let l = UygulamaTarayici.tara(ayar)
        func bul(_ son: String) -> UygulamaBilgisi? { l.first { $0.yol.hasSuffix(son) } }
        kontrol("Uygulama taraması: kök ve bir alt klasör bulunur, derindeki ve içteki yardımcı bulunmaz",
                bul("/Ornek.app") != nil && bul("Utilities/Ortak.app") != nil && bul("Cok.app") == nil && bul("Yardimci.app") == nil
                && bul("EvUyg.app") != nil)
        kontrol("Uygulama taraması: App Store makbuzu tanınır", bul("/Ornek.app")?.girdi.kaynak == .appStore)
        kontrol("Uygulama taraması: sürüm ve kimlik okunur", bul("/Ornek.app")?.girdi.surum == "1.2.3" && bul("/Ornek.app")?.girdi.kimlik == "com.foo.bar")
        kontrol("Uygulama taraması: artıklar bulunur", (bul("/Ornek.app")?.girdi.artiklar.count ?? 0) >= 5)
        kontrol("Uygulama taraması: aynı adlı iki uygulamada ad klasörü alınmaz",
                bul("/Ortak.app")?.girdi.artiklar.contains { $0.yol.hasSuffix("Support/Ortak") } == false)
        kontrol("Uygulama taraması: listedeki bir uygulamayı gösteren kısayol ayrı satır olmaz",
                bul("Kisayol.app") == nil && bul("/Ornek.app") != nil)
        kontrol("Uygulama taraması: Apple, çalışan, kendisi silinemez",
                bul("Safari Taklit.app")?.silinebilir == false && bul("Calisan.app")?.silinebilir == false
                && bul("/Ferah.app")?.silinebilir == false
                && bul("Plistsiz.app")?.silinebilir == false && bul("/Ornek.app")?.silinebilir == true)
        kontrol("Uygulama taraması: çalışan uygulamanın nedeni 'önce kapat'",
                bul("Calisan.app")?.girdi.silinemezNedeni?.a == .uSilCalisiyor)

        // Açıklama kuralları ve öneri mantığı
        let simdi = Date()
        func g(_ kaynak: UygulamaKaynagi = .gelistirici, kimlik: String = "com.foo.x", ad: String = "X", son: Date? = nil,
               ekl: Date? = nil, intel: Bool = false, artik: Bool = false, kaldirici: String? = nil) -> UygulamaGirdisi {
            UygulamaGirdisi(yol: "\(kok)/\(ad).app", ad: ad, kimlik: kimlik, boyut: 1_000_000, sonKullanilma: son,
                            eklenme: ekl, kaynak: kaynak, yalnizIntel: intel,
                            kaldirici: kaldirici,
                            artiklar: artik ? [Artik(yol: "\(lib)/Application Support/\(kimlik)", tur: Metin(.uArtikVeri), boyut: 2_000_000_000, erisilemedi: false)] : [])
        }
        let gun = 86_400.0
        let as_ = AciklamaMotoru.uygulamaAcikla(g(.appStore), verilerDahil: false, simdi: simdi)
        kontrol("Uygulama motoru: App Store → Satın Alınanlar'dan yeniden indirilir", as_.geriNasil?.a == .uGeriAppStore)
        let gl = AciklamaMotoru.uygulamaAcikla(g(), verilerDahil: false, simdi: simdi)
        kontrol("Uygulama motoru: geliştiriciden → lisans anahtarı uyarısı", gl.geriNasil?.a == .uGeriGelistirici)
        let vd = AciklamaMotoru.uygulamaAcikla(g(artik: true), verilerDahil: true, simdi: simdi)
        kontrol("Uygulama motoru: veriler dahilse 'verilerin de gider (boyut)'", icerir(vd.neOlur, .uNeVeriGider) && t(vd.neOlur).contains("GB"))
        let vk = AciklamaMotoru.uygulamaAcikla(g(artik: true), verilerDahil: false, simdi: simdi)
        kontrol("Uygulama motoru: veriler dahil değilse 'yerinde kalır'", icerir(vk.neOlur, .uNeVeriKalir) && !icerir(vk.neOlur, .uNeVeriGider))
        kontrol("Uygulama motoru: yalnız Intel → Rosetta notu",
                AciklamaMotoru.uygulamaAcikla(g(intel: true), verilerDahil: false, simdi: simdi).baglam.contains { $0.a == .uBglIntel })
        let adobe = AciklamaMotoru.uygulamaAcikla(g(kimlik: "com.adobe.Photoshop", ad: "Adobe Photoshop"), verilerDahil: false, simdi: simdi)
        kontrol("Uygulama motoru: Adobe → kendi kaldırıcısı, Dikkat", adobe.risk == .dikkat && icerir(adobe.oneriMetni, .uOneriKaldirici) && icerir(adobe.oneriMetni, .uNedenAdobe))
        kontrol("Uygulama motoru: VPN → Dikkat", AciklamaMotoru.uygulamaAcikla(g(ad: "NordVPN"), verilerDahil: false, simdi: simdi).risk == .dikkat)
        kontrol("Uygulama motoru: kaldırıcısı bulunan → Dikkat", AciklamaMotoru.uygulamaAcikla(g(kaldirici: "/x/Uninstall X.app"), verilerDahil: false, simdi: simdi).risk == .dikkat)
        kontrol("Uygulama motoru: Docker için ayrı veri notu",
                AciklamaMotoru.uygulamaAcikla(g(kimlik: "com.docker.docker", ad: "Docker"), verilerDahil: false, simdi: simdi).baglam.contains { $0.a == .uBglDocker })
        kontrol("Uygulama motoru: Apple uygulaması Dokunma",
                AciklamaMotoru.uygulamaAcikla(g(.apple, kimlik: "com.apple.Safari"), verilerDahil: false, simdi: simdi).risk == .dokunma)
        let hicYeni = g(ekl: simdi.addingTimeInterval(-10 * gun))
        kontrol("Öneri: yeni eklenmiş ve hiç açılmamış uygulama 'kullanılmıyor' sayılmaz",
                !AciklamaMotoru.kullanilmiyorMu(hicYeni, gun: 180, simdi: simdi))
        kontrol("Öneri: yeni eklenmiş, hiç açılmamış → 'bakıp karar ver' ve kayıt yok denir",
                AciklamaMotoru.uygulamaAcikla(hicYeni, verilerDahil: false, simdi: simdi).oneri == .bakVeKararVer
                && AciklamaMotoru.uygulamaAcikla(hicYeni, verilerDahil: false, simdi: simdi).baglam.contains { $0.a == .uBglHicEklendi })
        kontrol("Öneri: 2 yıl önce eklenmiş, hiç açılmamış → kullanılmıyor",
                AciklamaMotoru.kullanilmiyorMu(g(ekl: simdi.addingTimeInterval(-730 * gun)), gun: 180, simdi: simdi))
        kontrol("Öneri: 8 ay önce kullanılmış → 6 ay süzgecinde var, 1 yıl süzgecinde yok",
                AciklamaMotoru.kullanilmiyorMu(g(son: simdi.addingTimeInterval(-245 * gun), ekl: simdi.addingTimeInterval(-900 * gun)), gun: 180, simdi: simdi)
                && !AciklamaMotoru.kullanilmiyorMu(g(son: simdi.addingTimeInterval(-245 * gun)), gun: 365, simdi: simdi))
        kontrol("Öneri: dün kullanılmış, eski eklenmiş → kullanılmıyor sayılmaz",
                !AciklamaMotoru.kullanilmiyorMu(g(son: simdi.addingTimeInterval(-1 * gun), ekl: simdi.addingTimeInterval(-900 * gun)), gun: 90, simdi: simdi))
        kontrol("Öneri: hiçbir tarih yoksa uydurulmaz (kullanılmıyor sayılmaz)", !AciklamaMotoru.kullanilmiyorMu(g(), gun: 180, simdi: simdi))
        kontrol("Tarih: 1980 gibi sahte Spotlight tarihi kayıt sayılmaz",
                UygulamaTarayici.gecerliTarih(Date(timeIntervalSince1970: 315_446_400)) == nil
                && UygulamaTarayici.gecerliTarih(simdi.addingTimeInterval(-gun)) != nil
                && UygulamaTarayici.gecerliTarih(simdi.addingTimeInterval(30 * gun)) == nil)
    }

    // MARK: Sistem verileri

    func sistemSinamalari() {
        let lib = Yol.ekle(ev, "Library")
        let mb = 1_000_000
        func karar(_ yol: String, _ s: Sahiplik = .belirsiz) -> AciklamaMotoru.SistemKarari {
            AciklamaMotoru.sistemAcikla(yol: yol, ev: ev, sahiplik: s)
        }

        // Kurallar
        let vm = karar("\(lib)/Application Support/Claude/vm_bundles")
        kontrol("Sistem: Claude vm_bundles → Ferah temizleyebilir, Dikkat", vm.eylem == .ferahTemizler && vm.aciklama.risk == .dikkat
                && vm.aciklama.neOlur.a == .svClaudeVmNe)
        let pr = karar("\(ev)/.claude/projects")
        kontrol("Sistem: ~/.claude/projects → eski konuşmalara dönülemez, Dikkat",
                pr.aciklama.risk == .dikkat && pr.aciklama.neOlur.a == .svClaudeCodeProjeNe)
        let wa = karar("\(lib)/Group Containers/group.net.whatsapp.WhatsApp.shared")
        kontrol("Sistem: WhatsApp → uygulamanın kendi içinden (Ayarlar > Depolama)",
                wa.eylem == .uygulamaIcinden && wa.eylemMetni?.a == .svWhatsappMetin)
        kontrol("Sistem: Docker → Clean / Purge", karar("\(lib)/Containers/com.docker.docker").eylemMetni?.a == .svDockerMetin)
        kontrol("Sistem: Chrome profili Dokunma, önbellek Adım 1",
                karar("\(lib)/Application Support/Google/Chrome").eylem == .dokunma && karar("\(lib)/Caches/Google").eylem == .adim1)
        kontrol("Sistem: Xcode → Settings > Platforms", karar("\(lib)/Developer/Xcode").eylemMetni?.a == .svXcodeMetin)
        kontrol("Sistem: iOS yedekleri Riskli", karar("\(lib)/Application Support/MobileSync").aciklama.risk == .riskli)
        kontrol("Sistem: Mail Dokunma", karar("\(lib)/Mail").eylem == .dokunma)
        kontrol("Sistem: Mesajlar → uygulamanın kendi içinden", karar("\(lib)/Messages").eylem == .uygulamaIcinden)
        kontrol("Sistem: Steam/minecraft → başlatıcıdan", karar("\(lib)/Application Support/minecraft").eylem == .uygulamaIcinden
                && karar("\(lib)/Application Support/Steam").eylem == .uygulamaIcinden)
        kontrol("Sistem: CrossOver şişeleri tanınır", karar("\(lib)/Application Support/CrossOver").aciklama.tur.a == .svCrossoverTur)
        kontrol("Sistem: rustup/pyenv/nvm yeniden kurulabilir araç zinciri",
                [".rustup", ".pyenv", ".nvm"].allSatisfy { karar("\(ev)/\($0)").eylem == .ferahTemizler && karar("\(ev)/\($0)").aciklama.geriNasil != nil })
        kontrol("Sistem: /Library/Updates → güncellemeyi kurunca gider", karar("/Library/Updates").aciklama.neOlur.a == .svGuncellemeNe)
        kontrol("Sistem: takas → yeniden başlatınca", karar("/private/var/vm").eylem == .yenidenBaslat)
        kontrol("Sistem: /private/var/folders ve /private/tmp → yeniden başlatınca",
                karar("/private/var/folders/ab/cd/T").eylem == .yenidenBaslat && karar("/private/tmp").eylem == .yenidenBaslat)
        kontrol("Sistem: /private/var/db Dokunma", karar("/private/var/db").eylem == .dokunma)
        let bil = karar("\(lib)/Application Support/GizemliKlasor")
        kontrol("Sistem: bilinmeyen kalemde düğme yok, öneri sakla", bil.eylem == .bilgi && bil.aciklama.oneri == .sakla)
        kontrol("Sistem: ~/Library'nin bilinmeyen kök klasörü Dokunma", karar("\(lib)/Fonts").eylem == .dokunma)
        kontrol("Sistem: kişisel klasörler yalnız bilgi", karar("\(ev)/Desktop").eylem == .bilgi)
        kontrol("Sistem: sahipli klasör uygulamaya bağlanır, sahipsiz Dikkat",
                t(karar("\(lib)/Application Support/com.foo.bar", .sahipli("Ornek")).aciklama.tur).contains("Ornek")
                && karar("\(lib)/Containers/com.zzz.eski", .sahipsiz).aciklama.risk == .dikkat)
        kontrol("Sistem: Group Containers içindeki sahipsiz bile Dokunma (Koruma)",
                karar("\(lib)/Group Containers/com.zzz.eski", .sahipsiz).eylem == .dokunma)

        // Sahiplik
        let kurulu: [(String?, String)] = [("com.foo.bar", "Ornek"), ("com.google.Chrome", "Google Chrome"), (nil, "Araç")]
        kontrol("Sahiplik: tam kimlik eşleşmesi sahipli", SistemTarayici.sahiplik("com.foo.bar", kurulu: kurulu) == .sahipli("Ornek"))
        kontrol("Sahiplik: tam ad eşleşmesi sahipli", SistemTarayici.sahiplik("Ornek", kurulu: kurulu) == .sahipli("Ornek"))
        kontrol("Sahiplik: önek benzerliği (com.foo.barista) sahipsiz DEĞİL", SistemTarayici.sahiplik("com.foo.barista", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: alt kimlik (com.foo.bar.helper) sahipsiz DEĞİL", SistemTarayici.sahiplik("com.foo.bar.helper", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: aynı üretici (com.google.Keystone) sahipsiz DEĞİL", SistemTarayici.sahiplik("com.google.Keystone", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: com.apple.* sahipsiz DEĞİL", SistemTarayici.sahiplik("com.apple.yok", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: group.* sahipsiz DEĞİL", SistemTarayici.sahiplik("group.com.zzz.yok", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: takım kimliği önekli sahipsiz DEĞİL", SistemTarayici.sahiplik("ABCDE12345.com.zzz.yok", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: komut satırı aracı klasörü (pnpm) sahipsiz DEĞİL", SistemTarayici.sahiplik("pnpm", kurulu: kurulu) == .belirsiz)
        kontrol("Sahiplik: ilgisiz ters-DNS ad sahipsiz", SistemTarayici.sahiplik("com.zzz.eskiuygulama", kurulu: kurulu) == .sahipsiz)

        // Tarama (yalnız sahte ev; ev dışı kökler kapalı)
        dosya("\(lib)/Application Support/Claude/vm_bundles/imaj.img", 3 * mb)
        dosya("\(lib)/Application Support/Claude/ayar.json", 1_000)
        dosya("\(lib)/Application Support/com.zzz.eskiuygulama/veri", 2 * mb)
        dosya("\(lib)/Containers/com.zzz.kapsayici/Data/veri", 2 * mb)
        dosya("\(ev)/.claude/projects/p1/oturum.jsonl", 2 * mb)
        let ayar = SistemTaramaAyari(ev: ev, esik: Int64(mb), inmeEsigi: Int64(2 * mb), kurulu: kurulu, disKokler: false)
        let dk = SistemTarayici.tara(ayar, disk: DiskBilgisi(toplam: 10_000_000_000, bos: 1_000_000_000))
        func bul(_ son: String) -> SistemKalemi? { dk.kalemler.first { $0.yol.hasSuffix(son) } }
        kontrol("Sistem taraması: büyük klasörde bir düzey inilir (Claude → vm_bundles)",
                bul("Claude/vm_bundles")?.ust?.hasSuffix("Application Support/Claude") == true && bul("Claude/vm_bundles")?.eylem == .ferahTemizler)
        kontrol("Sistem taraması: sahipsiz artık işaretlenir", bul("com.zzz.eskiuygulama")?.sahipsiz == true)
        kontrol("Sistem taraması: Tam Disk Erişimi yokken başka uygulamanın kapsayıcısı ölçülmez",
                bul("Containers/com.zzz.kapsayici")?.olculemedi != nil && bul("Containers/com.zzz.kapsayici")?.boyut == 0)
        kontrol("Sistem taraması: eşik altı kalemler 'diğer'de toplanır", dk.digerSayi > 0 && dk.digerBayt > 0)
        kontrol("Sistem taraması: ölçülen = üst kalemler + diğer (alt kalemler iki kez sayılmaz)",
                dk.olculen == dk.kalemler.filter { $0.ust == nil && $0.olculemedi == nil }.reduce(0) { $0 + $1.boyut } + dk.digerBayt)
        let kucukDisk = SistemTarayici.tara(ayar, disk: DiskBilgisi(toplam: Int64(2 * mb), bos: 0))
        let asan = kucukDisk.kalemler.filter { $0.olculemedi?.a == .svOlcGuvenilmez }
        kontrol("Sistem taraması: kapasiteyi aşan kalem 'güvenilir ölçülemedi' olur ve toplamı bozmaz",
                !asan.isEmpty && asan.allSatisfy { $0.boyut == 0 } && kucukDisk.olculen <= Int64(2 * mb) * 10)
        kontrol("Sistem taraması: ev dışı kalem asla taşınabilir değil",
                !SistemKalemi(yol: "/private/tmp/x", grup: "", boyut: 1, olculemedi: nil, kismen: false, evIcinde: false, ust: nil,
                              sahip: nil, sahipsiz: false, aciklama: vm.aciklama, eylem: .ferahTemizler, eylemMetni: nil).tasinabilir)
        let s = Silici(bekci: Bekci(ev: ev, uygulamaKokleri: [], kendiPaketi: nil), kuruCalistir: true)
        kontrol("Sistem: ev dışı kalem için taşıma isteği reddedilir",
                s.uygula(SilmeIstegi(yol: "\(disari)/degerli.txt", islem: .copeTasi)).durum == .reddedildi
                && s.uygula(SilmeIstegi(yol: tmp, islem: .copeTasi)).durum == .reddedildi)
        kontrol("Sistem: ev içi temizlenebilir kalem mevcut .copeTasi yolundan geçer (kuru)",
                s.uygula(SilmeIstegi(yol: "\(lib)/Application Support/Claude/vm_bundles", islem: .copeTasi)).durum == .kuru)
    }

    // MARK: APFS klonları

    func klonSinamalari() {
        let k = Yol.ekle(tmp, "klon")
        let ab = Yol.ekle(k, "ab"), yalniz = Yol.ekle(k, "yalniz")
        let mb = 1_000_000
        DenemeEvi.dosya("\(ab)/ozgun.bin", 5 * mb, dolgu: 7)
        guard clonefile("\(ab)/ozgun.bin", "\(ab)/klon.bin", 0) == 0,
              let bilgi = "\(ab)/klon.bin".withCString({ Klon.oku($0) }), bilgi.paylasabilir else {
            atla("APFS klonu sınamaları", "geçici dizinde klonlama (clonefile) ya da klon bilgisi desteklenmiyor")
            return
        }
        let tam = Olcer.dosyaKazanci("\(ab)/ozgun.bin") + Olcer.olc("\(ab)/ozgun.bin").paylasilan
        func yakin(_ a: Int64, _ b: Int64) -> Bool { abs(Double(a - b)) <= Double(max(b, 1)) * 0.01 + 16_384 }
        kontrol("Klon: klonun tek başına kazanılacak boyutu ~0", Olcer.dosyaKazanci("\(ab)/klon.bin") < 64_000,
                "\(Olcer.dosyaKazanci("\(ab)/klon.bin"))")
        kontrol("Klon: özgünün de tek başına kazanılacak boyutu ~0 (blokları paylaşıyor)", Olcer.dosyaKazanci("\(ab)/ozgun.bin") < 64_000)
        let ikisi = Olcer.olc(ab)
        kontrol("Klon: özgün + klon birlikte ölçülünce tek dosya kadar (5 MB, 10 değil)", yakin(ikisi.bayt, 5_001_984),
                "\(ikisi.bayt)")
        _ = tam
        // Klonu ayrı klasöre al: tek başına ölçülen klasör ~0
        dizin(yalniz)
        _ = rename("\(ab)/klon.bin", "\(yalniz)/klon.bin")
        let tek = Olcer.olc(yalniz)
        kontrol("Klon: yalnız klonu içeren klasör ~0 ölçülür, paylaşılan kısım ayrıca raporlanır",
                tek.bayt < 64_000 && tek.paylasilan > 4 * mb, "bayt=\(tek.bayt) paylaşılan=\(tek.paylasilan)")
        // Kuru çalıştırma da aynı ölçeri kullanır
        let b = Bekci(ev: tmp, uygulamaKokleri: [], kendiPaketi: nil)
        let kuru = Silici(bekci: b, kuruCalistir: true).uygula(SilmeIstegi(yol: yalniz, islem: .kaliciSil(kokler: [k])))
        kontrol("Klon: kuru çalıştırma klon klasörü için ~0 açılacak der", kuru.serbestBayt < 64_000, "\(kuru.serbestBayt)")
        // Gerçek silme: önce klon (~0 açar), sonra özgün (artık tam boyut açar)
        let s = Silici(bekci: b)
        let r1 = s.uygula(SilmeIstegi(yol: yalniz, islem: .kaliciSil(kokler: [k])))
        let r2 = s.uygula(SilmeIstegi(yol: ab, islem: .kaliciSil(kokler: [k])))
        kontrol("Klon: silinince klon ~0, ardından özgün tam boyut açtı (toplam tek dosya)",
                r1.serbestBayt < 64_000 && yakin(r2.serbestBayt, 5_001_984) && !var_(yalniz) && !var_(ab),
                "klon=\(r1.serbestBayt) özgün=\(r2.serbestBayt)")
        // İkisi aynı işlemde silinince tam boyut
        DenemeEvi.dosya("\(ab)/o2.bin", 3 * mb, dolgu: 8)
        _ = clonefile("\(ab)/o2.bin", "\(ab)/k2.bin", 0)
        let r3 = s.uygula(SilmeIstegi(yol: ab, islem: .kaliciSil(kokler: [k])))
        kontrol("Klon: ikisi birlikte silinince tam boyut raporlanır", yakin(r3.serbestBayt, 3_002_368), "\(r3.serbestBayt)")
        // Kısmi klon: 1 MB değiştirilmiş klon yalnız kendine ait 1 MB'ı açar
        DenemeEvi.dosya("\(ab)/o3.bin", 3 * mb, dolgu: 9)
        _ = clonefile("\(ab)/o3.bin", "\(ab)/k3.bin", 0)
        if let h = FileHandle(forWritingAtPath: "\(ab)/k3.bin") {
            h.write(Data(repeating: 0xEE, count: 1 << 20)); try? h.synchronize(); try? h.close()
        }
        let kismi = Olcer.dosyaKazanci("\(ab)/k3.bin")
        kontrol("Klon: kısmi klon yalnız değişen kısmı (~1 MB) gösterir", kismi > 900_000 && kismi < 1_200_000, "\(kismi)")
    }

    // MARK: Bilinen kusurların düzeltmeleri

    func kusurSinamalari() {
        let kok = Yol.ekle(tmp, "Uygulamalar2")
        // Contents'i sembolik bağ olan paket (Multipass benzeri)
        DenemeEvi.dosya("\(disari)/Ic/Contents/MacOS/x", 2_000_000, dolgu: 3)
        let pl: NSDictionary = ["CFBundleIdentifier": "com.foo.bagli"]
        pl.write(toFile: "\(disari)/Ic/Contents/Info.plist", atomically: true)
        dizin("\(kok)/Bagli.app")
        _ = symlink("\(disari)/Ic/Contents", "\(kok)/Bagli.app/Contents")
        let l = UygulamaTarayici.tara(UygulamaTaramaAyari(kokler: [kok], ev: ev, kendiPaketi: nil))
        let bagli = l.first { $0.ad == "Bagli" }
        kontrol("Kusur: Contents'i başka yerde olan uygulama 0 KB değil 'ölçülemedi'",
                bagli?.girdi.boyutNotu?.a == .uBoyutBaskaYer, t(bagli?.girdi.boyutNotu))
        // Geçersiz tarih: eklenme de yoksa değişme tarihine düşülür
        let simdi = Date()
        let g = UygulamaGirdisi(yol: "\(kok)/X.app", ad: "X", kimlik: "com.foo.x", sonKullanilma: nil, eklenme: nil,
                                degisme: simdi.addingTimeInterval(-800 * 86_400))
        kontrol("Kusur: son kullanım ve eklenme yoksa değişme tarihi yedek olur", AciklamaMotoru.kullanilmiyorMu(g, gun: 180, simdi: simdi)
                && AciklamaMotoru.uygulamaAcikla(g, verilerDahil: false, simdi: simdi).baglam.contains { $0.a == .uBglDegisme })
        let hic = UygulamaGirdisi(yol: "\(kok)/Y.app", ad: "Y", kimlik: "com.foo.y")
        kontrol("Kusur: hiçbir tarih yoksa 'bilinmiyor' denir ve önerilmez",
                !AciklamaMotoru.kullanilmiyorMu(hic, gun: 180, simdi: simdi)
                && AciklamaMotoru.uygulamaAcikla(hic, verilerDahil: false, simdi: simdi).baglam.contains { $0.a == .uBglBilinmiyor })
        // Root sahipli taklidi: üst klasör salt okunur → trashItem/moveItem yetki hatası → anlaşılır mesaj
        DenemeEvi.dosya("\(kok)/Kilitli/Kok.app/Contents/MacOS/k", 100_000, dolgu: 4)
        (["CFBundleIdentifier": "com.foo.kok"] as NSDictionary).write(toFile: "\(kok)/Kilitli/Kok.app/Contents/Info.plist", atomically: true)
        chmod("\(kok)/Kilitli", 0o555)
        let b = Bekci(ev: ev, uygulamaKokleri: [kok], kendiPaketi: nil)
        let s = Silici(bekci: b, copeTasiyici: { url in try DenemeEvi.copeTasi(url, cop: Yol.ekle(self.tmp, "sahte-cop-kok")) })
        let r = s.uygula(SilmeIstegi(yol: "\(kok)/Kilitli/Kok.app", islem: .uygulamaCopeTasi))
        chmod("\(kok)/Kilitli", 0o755)
        kontrol("Kusur: yetki hatası çökmeden 'Finder'da göster' öneren mesaj verir",
                r.durum == .hata && r.neden?.a == .sTasimaIzniYok && var_("\(kok)/Kilitli/Kok.app"), t(r.neden))
        // Deneme evi güvenliği
        func red(_ y: String) -> Bool { if case .failure = DenemeEvi.dogrula(y, varOlmali: false) { return true }; return false }
        let gercekEv = Yol.gercek(NSHomeDirectory()) ?? NSHomeDirectory()
        kontrol("Deneme evi: gerçek ev, /, /Applications, /Users ve geçici dizin dışı reddedilir",
                red(gercekEv) && red("/") && red("/Applications") && red("/Users") && red(Yol.ekle(gercekEv, "Desktop/x"))
                && red(Yol.ekle(tmp, "../../../../..")))
        kontrol("Deneme evi: geçici dizin altındaki klasör kabul edilir", !red(Yol.ekle(tmp, "deneme-evi")))
        // Çöp kategorisi boş klasör ve bağları da listeler (boşaltma hepsini silsin)
        dizin("\(ev)/.Trash/bos-klasor")
        _ = symlink("\(disari)/degerli.txt", "\(ev)/.Trash/bag")
        let cop = KategoriTarayici.tara(.copKutusu, TaramaBaglami(ev: ev))
        kontrol("Kusur: Çöp Kutusu taraması boş klasör ve sembolik bağı da içerir",
                cop.ogeler.contains { $0.ad == "bos-klasor" } && cop.ogeler.contains { $0.ad == "bag" })
        let rc = Temizleyici.temizle([(cop, cop.ogeler)], silici: Silici(bekci: Bekci(ev: ev, uygulamaKokleri: [], kendiPaketi: nil)))
        kontrol("Kusur: Çöp boşaltınca boş klasör ve bağ da gider, bağın hedefi kalır",
                !var_("\(ev)/.Trash/bos-klasor") && !var_("\(ev)/.Trash/bag") && var_("\(disari)/degerli.txt") && rc.reddedilen.isEmpty)
        // Yok olan klasör: çökmeden hata
        let kaybolan = Silici(bekci: Bekci(ev: ev, uygulamaKokleri: [], kendiPaketi: nil))
            .uygula(SilmeIstegi(yol: "\(ev)/Library/Caches/yok-artik", islem: .kaliciSil(kokler: [Yol.ekle(ev, "Library/Caches")]), yalnizIcerik: true))
        kontrol("Kusur: tarama sonrası kaybolan klasör anlaşılır hata verir", kaybolan.durum == .hata && kaybolan.neden?.a == .sArtikYok)
    }

    // MARK: Dil

    /// Türkçeye özgü harfler ve bilinen Türkçe sözcükler (İngilizce çıktıda bulunmamalı).
    static let turkceHarfler = Set("çğıİöşüÇĞÖŞÜ")
    static let turkceSozcukler: Set<String> = ["silersen", "silinir", "önce", "klasör", "klasor", "çöp", "cop", "yedek",
        "yedeği", "uygulama", "uygulamalar", "dosya", "dosyası", "kalıcı", "kalici", "geri", "değil", "degil", "için", "icin",
        "olarak", "yok", "ve", "ile", "bu", "bir", "sakla", "tara", "ya", "da", "de", "gelir", "gider", "kaldır", "önbellek",
        "onbellek", "veri", "verileri", "boş", "seçili", "secili", "adım", "adim", "özet", "ozet", "sistem", "hiç"]

    /// Yazı argümanlarını (dosya adı, yol, uygulama adı) nötr bir değerle değiştirir; bunlar denetimden muaftır.
    func notr(_ m: Metin) -> Metin {
        Metin(m.a, dizi: m.args.map { arg in
            switch arg {
            case .yazi: return .yazi("X")
            case .metin(let alt): return .metin(notr(alt))
            default: return arg
            }
        })
    }

    /// İngilizce metinde Türkçe iz: Türkçe harf ya da sözcük. Yol gibi '/' içeren ve '~' ile başlayan parçalar muaf.
    func turkceIz(_ s: String) -> String? {
        let parcalar = s.split(whereSeparator: { $0 == " " || $0 == "\n" })
            .map(String.init)
            .filter { !$0.contains("/") && !$0.hasPrefix("~") && !$0.hasPrefix("--") }
        for p in parcalar {
            if p.contains(where: { OzSinama.turkceHarfler.contains($0) }) { return p }
            let sade = p.lowercased().trimmingCharacters(in: CharacterSet.letters.inverted)
            if OzSinama.turkceSozcukler.contains(sade) { return p }
        }
        return nil
    }

    func dilSinamalari() {
        // 1. Tablo bütünlüğü
        var bos: [String] = [], yerTutucu: [String] = [], cogulHata: [String] = []
        for k in M.allCases where k != .birlesim {
            let tr = Ceviri.sablon(k, .tr), en = Ceviri.sablon(k, .en)
            if tr.isEmpty || en.isEmpty { bos.append(k.rawValue) }
            if tr.contains(Ceviri.cogulAyraci) { cogulHata.append(k.rawValue) }
            let ptr = Ceviri.yerTutucular(tr)
            for parca in en.components(separatedBy: Ceviri.cogulAyraci) where Set(Ceviri.yerTutucular(parca)) != Set(ptr) {
                yerTutucu.append(k.rawValue)
            }
            if en.components(separatedBy: Ceviri.cogulAyraci).count > 2 { cogulHata.append(k.rawValue) }
        }
        kontrol("Dil: \(M.allCases.count) anahtarın hepsi iki dilde dolu", bos.isEmpty, bos.joined(separator: ", "))
        kontrol("Dil: yer tutucular iki dilde (ve İngilizce çoğul biçimlerinde) aynı", yerTutucu.isEmpty, yerTutucu.joined(separator: ", "))
        kontrol("Dil: çoğul ayracı yalnız İngilizcede ve en çok iki biçim", cogulHata.isEmpty, cogulHata.joined(separator: ", "))

        // 2. İngilizce çıktıda Türkçe kalmamış: tablonun tamamı (nötr argümanlarla) …
        var izler: [String] = []
        for k in M.allCases where k != .birlesim {
            let ornek = Metin(k, dizi: Ceviri.yerTutucular(Ceviri.sablon(k, .tr)).map { _ in MetinArg.sayi(2) })
            for n in [1, 2] {
                let m = Metin(k, dizi: ornek.args.map { _ in .sayi(n) })
                if let iz = turkceIz(m(.en)) { izler.append("\(k.rawValue): \(iz)") }
            }
        }
        kontrol("Dil: İngilizce tabloda Türkçe harf ya da sözcük yok", izler.isEmpty, izler.prefix(8).joined(separator: " | "))

        // … ve motorların gerçek çıktıları (tüm sınama girdileri, kategoriler, uygulama ve sistem kuralları)
        let simdi = Date()
        var ciktilar: [Metin] = []
        func ekle(_ a: Aciklama) { ciktilar += [a.tur, a.neOlur] + [a.geriNasil, a.oneriMetni].compactMap { $0 } + a.baglam }
        var tumSinyal = Sinyaller()
        tumSinyal.bulut = "iCloud Drive"; tumSinyal.gitIzleniyor = true; tumSinyal.kopyaYolu = Yol.ekle(ev, "Kopya.mov")
        tumSinyal.klonPaylasimi = 5_000_000; tumSinyal.projeSonDegisme = simdi.addingTimeInterval(-245 * 86_400)
        tumSinyal.sonYedek = simdi.addingTimeInterval(-40 * 86_400); tumSinyal.cihazAdi = "iPhone"
        let ornekler = ["a.dmg", "a.pkg", "a.xip", "a.ipsw", "a.iso", "a.qcow2", "a.sparsebundle", "a.fcpbundle", "a.logicx", "a.band",
                        "a.imovielibrary", "a.blend1", "a.blend", "a.sqlite", "a.gguf", "Ekran Kaydı.mov", "a.mov", "a.psd", "a.jpg",
                        "a.wav", "a.zip", "a.app", "a.xcarchive", "a.log", "a.dylib", "a.pdf", "a.xyz", "a", ".vscode/extensions/e/x.js",
                        ".kasa/k.dmg", "Library/Caches/x/Cache/a.mov", "Pictures/P.photoslibrary", "Music/M.musiclibrary",
                        "Movies/T.tvlibrary", "Applications/A.app", "Library/Keychains/x"]
        for yol in ornekler {
            for (dizin, paket) in [(false, false), (true, true), (true, false)] {
                for s in [Sinyaller(), tumSinyal] {
                    var s2 = s
                    s2.kuruluUygulama = "X"; s2.acilmisHaliYaninda = true; s2.asilDosyaYaninda = true; s2.sifreliImaj = yol.hasSuffix("k.dmg")
                    ekle(AciklamaMotoru.acikla(AdayGirdisi(yol: Yol.ekle(ev, yol), boyut: 900_000_000, dizinMi: dizin, paketMi: paket,
                                                           sonDegisme: simdi.addingTimeInterval(-800 * 86_400),
                                                           sonAcilma: simdi.addingTimeInterval(-800 * 86_400)), s2, ev: ev, simdi: simdi))
                }
            }
        }
        for o in [OzelTur.nodeModules, .sanalOrtam, .pods, .derlemeCiktisi, .iosYedegi, .dockerRaw, .hfModeli, .ollamaModelleri, .steamOyunu] {
            ekle(AciklamaMotoru.acikla(AdayGirdisi(yol: Yol.ekle(ev, "p/x"), boyut: 1, dizinMi: true, ozelTur: o), tumSinyal, ev: ev, simdi: simdi))
        }
        for k in KategoriKimlik.allCases { ciktilar += [Metin(k.adAnahtari), Metin(k.aciklamaAnahtari)] }
        for (kimlik, ad) in [("com.adobe.Photoshop", "Adobe Photoshop"), ("com.docker.docker", "Docker"), ("com.valvesoftware.steam", "Steam"),
                             ("com.adobe.acc.x", "CC"), ("com.parallels.x", "P"), ("com.google.android.studio", "AS"), ("com.microsoft.Word", "W"),
                             ("com.foo.x", "NordVPN"), ("com.apple.Safari", "Safari")] {
            for kaynak in [UygulamaKaynagi.appStore, .gelistirici] {
                for tarih in [(simdi.addingTimeInterval(-400 * 86_400), nil), (nil, simdi.addingTimeInterval(-5 * 86_400)), (nil, nil)] as [(Date?, Date?)] {
                    let g = UygulamaGirdisi(yol: "/Applications/\(ad).app", ad: ad, kimlik: kimlik, sonKullanilma: tarih.0, eklenme: tarih.1,
                                            kaynak: kaynak, yalnizIntel: true, sistemBileseni: true, kaldirici: "/x/Uninstall.app",
                                            artiklar: [Artik(yol: "/x", tur: Metin(.uArtikVeri), boyut: 10, erisilemedi: true)],
                                            boyutNotu: Metin(.uBoyutBaskaYer, .metin(Metin(.uBilinmiyor))), degisme: simdi)
                    for v in [true, false] { ekle(AciklamaMotoru.uygulamaAcikla(g, verilerDahil: v, simdi: simdi)) }
                    if let n = g.silinemezNedeni { ciktilar.append(n) }
                }
            }
        }
        let lib = Yol.ekle(ev, "Library")
        let sistemYollari = ["Desktop", "Library/Application Support/Claude/vm_bundles", "Library/Application Support/Claude", ".claude/projects",
            ".claude", "Library/Group Containers/group.net.whatsapp.x", "Library/Application Support/Telegram", "Library/Application Support/Signal",
            "Library/Containers/com.docker.docker", "Library/Application Support/Google/DriveFS", "Library/Application Support/Google/Chrome",
            "Library/Application Support/Google", "Library/Developer/Xcode", "Library/Developer/CoreSimulator", "Library/Developer",
            "Library/Application Support/MobileSync", "Library/Mail", "Library/Messages", "Library/Containers/com.apple.Photos", "Library/Caches",
            "Library/Logs", "Library/Application Support/Steam", "Library/Application Support/CrossOver", ".rustup", ".npm", ".cache", ".ollama",
            "Library/Containers", "Library/Fonts", "Library/Keychains", "Library/Application Support/Bilinmez"]
        for r in sistemYollari {
            for sah in [Sahiplik.belirsiz, .sahipli("X"), .sahipsiz] {
                let k = AciklamaMotoru.sistemAcikla(yol: Yol.ekle(ev, r), ev: ev, sahiplik: sah)
                ekle(k.aciklama); if let e = k.eylemMetni { ciktilar.append(e) }
            }
        }
        for r in ["/Library/Updates", "/private/var/vm", "/private/var/folders/a/b/T", "/private/tmp", "/Library/Developer", "/private/var/db",
                  "/Library/Audio", "/Applications", "/Volumes/x"] {
            let k = AciklamaMotoru.sistemAcikla(yol: r, ev: ev)
            ekle(k.aciklama); if let e = k.eylemMetni { ciktilar.append(e) }
        }
        _ = lib
        var motorIzleri: [String] = []
        for c in ciktilar {
            let en = notr(c)(.en)
            if let iz = turkceIz(en) { motorIzleri.append("\(c.a.rawValue): \(iz) ← \(en.prefix(60))") }
        }
        kontrol("Dil: \(ciktilar.count) motor çıktısının İngilizcesinde Türkçe kalmamış", motorIzleri.isEmpty,
                motorIzleri.prefix(6).joined(separator: " | "))

        // 3. Türkçe gerileme: temsilî metinler bugünküyle birebir aynı
        let beklenen: [(Metin, String)] = [
            (Metin(.aNodeGeri), "Proje klasöründe npm install (ya da yarn / pnpm install) ile geri gelir; ilk çalıştırma uzar."),
            (Metin(.katUygulamaOnbellekAc), "Uygulamaların hızlanmak için tuttuğu geçici dosyalar. Silinince uygulama gerekenleri yeniden oluşturur; ilk açılış biraz yavaş olabilir."),
            (Metin(.aKurulumKuruluNe, .yazi("Firefox")), "Bir uygulamanın kurulum dosyası. Firefox zaten Uygulamalar klasöründe kurulu görünüyor; kurulum dosyasına artık gerek kalmaz."),
            (Metin(.uOzetAlti, .sayi(6), .bayt(8_000_000)), "6 aydır açılmayan 6 uygulama · 8 MB"),
            (Metin(.g1OnayMesaj, .sayi(9), .bayt(2_100_000)), "9 öğe, toplam 2,1 MB silinecek. Bu adımdakiler Çöp Kutusu'na gitmez, geri alınamaz. Kullanımda olan dosyalar atlanır."),
            (Metin(.aBglProje, .sure(simdi.addingTimeInterval(-245 * 86_400), simdi)), "Bu projeye 8 aydır dokunulmamış."),
            (Metin(.sTasimaIzniYok), "Taşıma izni yok (dosya yönetici ya da sistem tarafından sahiplenilmiş olabilir). Finder'da göster ile bulup Çöp'e kendin sürükleyebilirsin; Finder parolanı sorar."),
            (Metin.birles([Metin(.uNeTasinir), Metin(.uNeVeriKalir)]), "Uygulama Çöp Kutusu'na taşınır; Çöp'ü boşaltana kadar geri alabilirsin. Ayarların ve verilerin yerinde kalır; yeniden kurarsan kaldığın yerden devam edersin."),
        ]
        let farkli = beklenen.filter { $0.0(.tr) != $0.1 }
        kontrol("Dil: Türkçe temsilî metinler değişmemiş", farkli.isEmpty, farkli.map { $0.0(.tr) }.joined(separator: " | "))
        kontrol("Dil: İngilizce boyut biçimi (1.5 GB, 553 KB)",
                Bicim.bayt(1_500_000_000, .en) == "1.5 GB" && Bicim.bayt(553_000, .en) == "553 KB",
                "\(Bicim.bayt(1_500_000_000, .en)) / \(Bicim.bayt(553_000, .en))")
        // Kıyas noktası 1: bugünkü Türkçe arayüzde görülen değerler (ekran görüntülerinden)
        let ekrandakiler: [(Int64, String)] = [(0, "0 KB"), (131_000, "131 KB"), (475_000, "475 KB"), (553_000, "553 KB"),
            (1_100_000, "1,1 MB"), (2_100_000, "2,1 MB"), (59_600_000, "59,6 MB"), (1_500_000_000, "1,5 GB"), (245_110_000_000, "245,11 GB")]
        let boyutFark = ekrandakiler.filter { Bicim.bayt($0.0, .tr) != $0.1 }
        kontrol("Dil: Türkçe boyutlar bugünkü arayüzdekiyle birebir", boyutFark.isEmpty,
                boyutFark.map { "\($0.0): \(Bicim.bayt($0.0, .tr)) ≠ \($0.1)" }.joined(separator: " | "))
        // Kıyas noktası 2: eski ByteCountFormatter (sistem yereli; ondalık ayıracı buna göre karşılaştırılır)
        let eski = ByteCountFormatter()
        eski.countStyle = .file
        eski.allowsNonnumericFormatting = false
        eski.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        let sistemDili: Dil = (Locale.current.decimalSeparator == ",") ? .tr : .en
        var degerler: [Int64] = [1, 499, 500, 512, 999, 1_000, 1_499, 1_500, 4_096, 99_499, 99_500, 999_499, 999_500, 999_999,
                                 1_000_000, 1_049_999, 1_050_000, 9_999_999, 99_950_000, 999_949_999, 999_950_000,
                                 1_004_999_999, 1_005_000_000, 999_995_000_000, 1_000_000_000_000, 3_456_789_012_345]
        var tohum: UInt64 = 0x9E3779B97F4A7C15
        for _ in 0..<2_000 {
            tohum = tohum &* 6364136223846793005 &+ 1442695040888963407
            let ust = Int64(1) << Int64(10 + (tohum >> 59) % 33)
            degerler.append(Int64(tohum >> 20) % ust + 1)
        }
        let eskiFark = degerler.filter { eski.string(fromByteCount: $0).replacingOccurrences(of: "\u{00A0}", with: " ") != Bicim.bayt($0, sistemDili) }
        kontrol("Dil: boyut biçimi eski ByteCountFormatter ile \(degerler.count) değerde aynı", eskiFark.isEmpty,
                eskiFark.prefix(5).map { "\($0): \(eski.string(fromByteCount: $0)) ≠ \(Bicim.bayt($0, sistemDili))" }.joined(separator: " | "))

        // 4. Çoğul ve göreli tarih
        let cogul = [(0, "0 items"), (1, "1 item"), (2, "2 items")].allSatisfy { Metin(.g1OgeSayisi, .sayi($0.0))(.en) == $0.1 }
        kontrol("Dil: İngilizce çoğul 0/1/2 (0 items, 1 item, 2 items)", cogul,
                [0, 1, 2].map { Metin(.g1OgeSayisi, .sayi($0))(.en) }.joined(separator: ", "))
        kontrol("Dil: Türkçede çoğul eki yok (1 öğe, 2 öğe)", Metin(.g1OgeSayisi, .sayi(1))(.tr) == "1 öğe" && Metin(.g1OgeSayisi, .sayi(2))(.tr) == "2 öğe")
        let gun: TimeInterval = 86_400
        let sureler = [(30.0, "4 weeks"), (65, "2 months"), (7, "7 days"), (14, "2 weeks"), (400, "1 year"), (800, "2 years"), (3, "3 days"), (1, "1 day"), (20, "2 weeks")]
        let sureHata = sureler.filter { Bicim.sure(simdi.addingTimeInterval(-$0.0 * gun), simdi: simdi, .en) != $0.1 }
        kontrol("Dil: İngilizce süre (1 month / 2 months / 1 year / 1 day)", sureHata.isEmpty,
                sureHata.map { "\($0.0): \(Bicim.sure(simdi.addingTimeInterval(-$0.0 * gun), simdi: simdi, .en) ?? "nil")" }.joined(separator: ", "))
        let goreliler = [1.0, 31, 61, 400, 800].map { Bicim.goreli(simdi.addingTimeInterval(-$0 * gun), simdi: simdi, .en) }
        let tekilHata = goreliler.filter { $0.range(of: #"\b1 (days|weeks|months|years)\b"#, options: .regularExpression) != nil }
        kontrol("Dil: göreli tarih İngilizce ve '1 months ago' gibi hata yok", tekilHata.isEmpty && goreliler.allSatisfy { $0.hasSuffix("ago") },
                goreliler.joined(separator: ", "))
        kontrol("Dil: göreli tarih Türkçe (… önce)", Bicim.goreli(simdi.addingTimeInterval(-400 * gun), simdi: simdi, .tr).hasSuffix("önce"))
        let tekilMetinler = M.allCases.filter { Ceviri.sablon($0, .en).contains(Ceviri.cogulAyraci) }
            .map { Metin($0, dizi: Ceviri.yerTutucular(Ceviri.sablon($0, .tr)).map { _ in .sayi(1) })(.en) }
        let tekilYanlis = tekilMetinler.filter { $0.range(of: #"\b1 [a-z]+s\b"#, options: .regularExpression) != nil
            && !$0.contains("1 is") }
        kontrol("Dil: 1 için İngilizce tekil biçim seçiliyor (\(tekilMetinler.count) çoğullu anahtar)", tekilYanlis.isEmpty,
                tekilYanlis.prefix(4).joined(separator: " | "))

        // 5. Dil seçimi
        kontrol("Dil seçimi: sistem tr → tr, en → en, de → en, boş → tr",
                Dil.sistemden(["tr-TR", "en-US"]) == .tr && Dil.sistemden(["en-GB"]) == .en && Dil.sistemden(["de-DE", "tr-TR"]) == .en
                && Dil.sistemden([]) == .tr)
        kontrol("Dil seçimi: elle seçim sistemi ezer, --dil hepsini ezer",
                Dil.sec(zorla: nil, elle: .en, sistem: ["tr"]) == .en && Dil.sec(zorla: nil, elle: .tr, sistem: ["en"]) == .tr
                && Dil.sec(zorla: .tr, elle: .en, sistem: ["en"]) == .tr && Dil.sec(zorla: .en, elle: nil, sistem: ["tr"]) == .en
                && Dil.sec(zorla: nil, elle: nil, sistem: ["tr-TR"]) == .tr)
    }
}
