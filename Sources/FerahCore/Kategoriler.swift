import Foundation

public enum KategoriKimlik: String, Codable, CaseIterable, Sendable {
    case uygulamaOnbellek = "uygulama_onbellek"
    case gunlukler
    case tarayici
    case gelistirici
    case copKutusu = "cop_kutusu"
    case eskiKurulum = "eski_kurulum"
    case xcodeArsiv = "xcode_arsiv"
    case simulator

    public var adAnahtari: M {
        switch self {
        case .uygulamaOnbellek: return .katUygulamaOnbellek
        case .gunlukler: return .katGunlukler
        case .tarayici: return .katTarayici
        case .gelistirici: return .katGelistirici
        case .copKutusu: return .katCop
        case .eskiKurulum: return .katEskiKurulum
        case .xcodeArsiv: return .katXcodeArsiv
        case .simulator: return .katSimulator
        }
    }

    public var aciklamaAnahtari: M {
        switch self {
        case .uygulamaOnbellek: return .katUygulamaOnbellekAc
        case .gunlukler: return .katGunluklerAc
        case .tarayici: return .katTarayiciAc
        case .gelistirici: return .katGelistiriciAc
        case .copKutusu: return .katCopAc
        case .eskiKurulum: return .katEskiKurulumAc
        case .xcodeArsiv: return .katXcodeArsivAc
        case .simulator: return .katSimulatorAc
        }
    }

    public func ad(_ dil: Dil) -> String { Metin(adAnahtari)(dil) }
    public func aciklama(_ dil: Dil) -> String { Metin(aciklamaAnahtari)(dil) }

    public var risk: Risk {
        switch self {
        case .uygulamaOnbellek, .gunlukler, .tarayici, .gelistirici: return .guvenli
        case .copKutusu, .eskiKurulum, .xcodeArsiv, .simulator: return .dikkat
        }
    }
}

public struct TemizlikOgesi: Codable, Identifiable, Hashable, Sendable {
    public var id: String { yol }
    public let yol: String
    /// Ham kimlik: klasör ya da dosya adı (uygulama önbelleklerinde paket kimliği).
    public let ad: String
    /// Gösterilecek ad (dile göre).
    public let baslik: Metin
    public var boyut: Int64
    public var dosyaSayisi: Int
    public var calisiyor: Bool
    public var varsayilanSecili: Bool
    /// Klasörün kendisi kalır, içi silinir.
    public var yalnizIcerik: Bool
    public var not: Metin?

    public init(yol: String, ad: String, baslik: Metin? = nil, boyut: Int64, dosyaSayisi: Int, calisiyor: Bool,
                varsayilanSecili: Bool, yalnizIcerik: Bool, not: Metin?) {
        self.yol = yol; self.ad = ad; self.baslik = baslik ?? Metin(.ham, .yazi(ad)); self.boyut = boyut
        self.dosyaSayisi = dosyaSayisi; self.calisiyor = calisiyor; self.varsayilanSecili = varsayilanSecili
        self.yalnizIcerik = yalnizIcerik; self.not = not
    }
}

public enum ErisimDurumu: String, Codable, Sendable {
    case tamam
    case erisimYok = "erisim_yok"
    case yok
}

public struct KategoriSonuc: Codable, Identifiable, Sendable {
    public var id: String { kimlik.rawValue }
    public let kimlik: KategoriKimlik
    public var durum: ErisimDurumu
    /// Bekçi'nin bu kategori için kabul edeceği kökler.
    public var kokler: [String]
    public var ogeler: [TemizlikOgesi]
    /// Okunamayan (izin verilmeyen) alt klasör sayısı.
    public var erisilemeyen: Int

    public var risk: Risk { kimlik.risk }
    public var boyut: Int64 { ogeler.reduce(0) { $0 + $1.boyut } }
    public var gorunur: Bool { durum == .erisimYok || boyut > 0 }
}

public struct TaramaBaglami: Sendable {
    public var ev: String
    /// Çalışan uygulamaların paket kimlikleri (küçük harf).
    public var calisanKimlikler: Set<String>
    public var simdi: Date

    public init(ev: String = NSHomeDirectory(), calisanKimlikler: Set<String> = [], simdi: Date = Date()) {
        self.ev = Yol.gercek(ev) ?? ev
        self.calisanKimlikler = Set(calisanKimlikler.map { $0.lowercased() })
        self.simdi = simdi
    }
}

public enum KategoriTarayici {
    // Tarayıcıların ~/Library/Caches altındaki klasörleri (uygulama önbelleklerinde çift sayılmasın diye ayrılır).
    // anahtar: Caches altındaki göreli yol → (görünen ad, paket kimliği)
    static let tarayiciCacheYollari: [(String, String, String)] = [
        ("Google/Chrome", "Chrome", "com.google.chrome"),
        ("Google/Chrome Beta", "Chrome Beta", "com.google.chrome.beta"),
        ("Google/Chrome Canary", "Chrome Canary", "com.google.chrome.canary"),
        ("com.google.Chrome", "Chrome", "com.google.chrome"),
        ("Microsoft Edge", "Edge", "com.microsoft.edgemac"),
        ("com.microsoft.edgemac", "Edge", "com.microsoft.edgemac"),
        ("BraveSoftware/Brave-Browser", "Brave", "com.brave.browser"),
        ("com.brave.Browser", "Brave", "com.brave.browser"),
        ("company.thebrowser.Browser", "Arc", "company.thebrowser.browser"),
        ("Arc", "Arc", "company.thebrowser.browser"),
        ("Firefox", "Firefox", "org.mozilla.firefox"),
        ("org.mozilla.firefox", "Firefox", "org.mozilla.firefox"),
        ("com.apple.Safari", "Safari", "com.apple.safari"),
        ("Vivaldi", "Vivaldi", "com.vivaldi.vivaldi"),
        ("com.vivaldi.Vivaldi", "Vivaldi", "com.vivaldi.vivaldi"),
        ("com.operasoftware.Opera", "Opera", "com.operasoftware.opera"),
    ]

    // Chromium tabanlı tarayıcıların Application Support altındaki kullanıcı verisi klasörleri.
    static let chromiumTabanlari: [(String, String, String)] = [
        ("Google/Chrome", "Chrome", "com.google.chrome"),
        ("Google/Chrome Beta", "Chrome Beta", "com.google.chrome.beta"),
        ("Microsoft Edge", "Edge", "com.microsoft.edgemac"),
        ("BraveSoftware/Brave-Browser", "Brave", "com.brave.browser"),
        ("Arc/User Data", "Arc", "company.thebrowser.browser"),
        ("Vivaldi", "Vivaldi", "com.vivaldi.vivaldi"),
    ]
    /// Profil içindeki YALNIZ önbellek klasörleri. Profil, geçmiş, çerez, parola dosyalarına dokunulmaz.
    static let profilOnbellekleri = ["Cache", "Code Cache", "GPUCache", "DawnCache", "DawnGraphiteCache", "DawnWebGPUCache"]
    static let tabanOnbellekleri = ["GrShaderCache", "ShaderCache", "GraphiteDawnCache"]

    static let gelistiriciKokleri: [(String, Metin)] = [
        ("Library/Developer/Xcode/DerivedData", Metin(.ham, .yazi("Xcode DerivedData"))),
        ("Library/Developer/Xcode/iOS DeviceSupport", Metin(.ham, .yazi("iOS DeviceSupport"))),
        ("Library/Developer/Xcode/watchOS DeviceSupport", Metin(.ham, .yazi("watchOS DeviceSupport"))),
        ("Library/Developer/Xcode/tvOS DeviceSupport", Metin(.ham, .yazi("tvOS DeviceSupport"))),
        ("Library/Developer/Xcode/visionOS DeviceSupport", Metin(.ham, .yazi("visionOS DeviceSupport"))),
        ("Library/Developer/CoreSimulator/Caches", Metin(.katSimOnbellek)),
        (".npm/_cacache", Metin(.katOnbellegi, .yazi("npm"))),
        ("Library/Caches/Yarn", Metin(.katOnbellegi, .yazi("Yarn"))),
        (".yarn/berry/cache", Metin(.katOnbellegi, .yazi("Yarn (Berry)"))),
        ("Library/pnpm/store", Metin(.katDeposu, .yazi("pnpm"))),
        (".local/share/pnpm/store", Metin(.katDeposu, .yazi("pnpm"))),
        (".pnpm-store", Metin(.katDeposu, .yazi("pnpm"))),
        ("Library/Caches/pip", Metin(.katOnbellegi, .yazi("pip"))),
        ("Library/Caches/Homebrew", Metin(.katIndirmeleri, .yazi("Homebrew"))),
        ("Library/Caches/CocoaPods", Metin(.katOnbellegi, .yazi("CocoaPods"))),
        (".gradle/caches", Metin(.katOnbellegi, .yazi("Gradle"))),
        (".cargo/registry/cache", Metin(.katCargo)),
        ("Library/Caches/go-build", Metin(.katGoDerleme)),
        (".bun/install/cache", Metin(.katOnbellegi, .yazi("Bun"))),
    ]

    /// Uygulama önbelleklerinden çıkarılan ~/Library/Caches üst düzey adları (başka kategoride sayılırlar).
    static var ayrilanCacheAdlari: Set<String> {
        var s = Set<String>()
        for (r, _, _) in tarayiciCacheYollari { s.insert(Yol.katla(String(r.split(separator: "/")[0]))) }
        for (r, _) in gelistiriciKokleri where r.hasPrefix("Library/Caches/") {
            s.insert(Yol.katla(String(r.dropFirst("Library/Caches/".count))))
        }
        return s
    }

    static let kurulumUzantilari: Set<String> = ["dmg", "pkg", "mpkg", "ipsw", "xip"]

    // MARK: - Toplu tarama

    /// Kategorileri paralel tarar; her biri bittikçe `bitti` çağrılır (arka plan iş parçacığından).
    @discardableResult
    public static func taraHepsi(_ b: TaramaBaglami, iptal: @escaping () -> Bool = { false },
                                 bitti: @escaping (KategoriSonuc) -> Void = { _ in }) -> [KategoriSonuc] {
        let inodlar = InodeKumesi()
        let kimlikler = KategoriKimlik.allCases
        var sonuclar = [KategoriSonuc?](repeating: nil, count: kimlikler.count)
        let kilit = NSLock()
        DispatchQueue.concurrentPerform(iterations: kimlikler.count) { i in
            let s = tara(kimlikler[i], b, inodlar: inodlar, iptal: iptal)
            kilit.lock(); sonuclar[i] = s; kilit.unlock()
            bitti(s)
        }
        return sonuclar.compactMap { $0 }
    }

    public static func tara(_ k: KategoriKimlik, _ b: TaramaBaglami, inodlar: InodeKumesi = InodeKumesi(),
                            iptal: @escaping () -> Bool = { false }) -> KategoriSonuc {
        var s: KategoriSonuc
        switch k {
        case .uygulamaOnbellek: s = uygulamaOnbellekleri(b, inodlar, iptal)
        case .gunlukler: s = cocukKategorisi(k, kok: Yol.ekle(b.ev, "Library/Logs"), b, inodlar, iptal, butun: false)
        case .tarayici: s = tarayicilar(b, inodlar, iptal)
        case .gelistirici: s = gelistirici(b, inodlar, iptal)
        case .copKutusu: s = cocukKategorisi(k, kok: Yol.ekle(b.ev, ".Trash"), b, inodlar, iptal, butun: true)
        case .eskiKurulum: s = eskiKurulumlar(b, inodlar, iptal)
        case .xcodeArsiv: s = xcodeArsivleri(b, inodlar, iptal)
        case .simulator: s = simulatorler(b, inodlar, iptal)
        }
        // Boş öğeler listede gösterilmez; ama Çöp Kutusu'nda boş klasör ve sembolik bağlar da vardır ve
        // "boşalt" onları da silmelidir, bu yüzden orada hepsi kalır.
        if k != .copKutusu { s.ogeler = s.ogeler.filter { $0.boyut > 0 } }
        s.ogeler.sort { $0.boyut > $1.boyut }
        return s
    }

    // MARK: - Yardımcılar

    enum Listeleme { case tamam([String]), erisimYok, yok }

    static func listele(_ yol: String) -> Listeleme {
        do {
            return .tamam(try FileManager.default.contentsOfDirectory(atPath: yol))
        } catch {
            let e = error as NSError
            if e.code == NSFileReadNoSuchFileError || e.code == NSFileNoSuchFileError { return .yok }
            if let alt = e.userInfo[NSUnderlyingErrorKey] as? NSError, alt.domain == NSPOSIXErrorDomain,
               alt.code == Int(ENOENT) || alt.code == Int(ENOTDIR) { return .yok }
            return .erisimYok
        }
    }

    /// Bir öğeyi ölçer; kökü okunamıyorsa nil.
    static func olcOge(_ yol: String, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> Olcum? {
        let o = Olcer.olc(yol, inodlar: inodlar, iptal: iptal)
        if o.kokErisimYok || o.yok { return nil }
        return o
    }

    /// Kökün her çocuğu bir öğe. butun=true ise öğe bütünüyle silinir; false ise klasörlerin içi silinir.
    static func cocukKategorisi(_ k: KategoriKimlik, kok: String, _ b: TaramaBaglami, _ inodlar: InodeKumesi,
                                _ iptal: @escaping () -> Bool, butun: Bool, haric: Set<String> = [],
                                calismaDenetimi: Bool = false) -> KategoriSonuc {
        var s = KategoriSonuc(kimlik: k, durum: .tamam, kokler: [kok], ogeler: [], erisilemeyen: 0)
        switch listele(kok) {
        case .yok: s.durum = .yok
        case .erisimYok: s.durum = .erisimYok
        case .tamam(let adlar):
            for ad in adlar where !haric.contains(Yol.katla(ad)) && ad != ".DS_Store" && ad != ".localized" {
                if iptal() { break }
                let yol = Yol.ekle(kok, ad)
                guard let o = olcOge(yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
                let dizin = Yol.dizinMi(yol)
                var calisiyor = false
                var secili = k.risk == .guvenli
                var not: Metin? = nil
                if calismaDenetimi {
                    calisiyor = b.calisanKimlikler.contains(ad.lowercased())
                    if calisiyor { secili = false; not = Metin(.katNotCalisiyor) }
                    else if ad.lowercased().hasPrefix("com.apple.") { secili = false; not = Metin(.katNotMacos) }
                }
                s.ogeler.append(TemizlikOgesi(yol: yol, ad: ad, boyut: o.bayt, dosyaSayisi: o.dosya,
                                              calisiyor: calisiyor, varsayilanSecili: secili,
                                              yalnizIcerik: !butun && dizin, not: not))
                if o.okunamayan > 0 { s.erisilemeyen += 1 }
            }
        }
        return s
    }

    // MARK: - Kategoriler

    static func uygulamaOnbellekleri(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        cocukKategorisi(.uygulamaOnbellek, kok: Yol.ekle(b.ev, "Library/Caches"), b, inodlar, iptal,
                        butun: false, haric: ayrilanCacheAdlari, calismaDenetimi: true)
    }

    static func tarayicilar(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        var s = KategoriSonuc(kimlik: .tarayici, durum: .tamam, kokler: [], ogeler: [], erisilemeyen: 0)
        var adaylar: [(yol: String, ad: Metin, kimlik: String)] = []
        let caches = Yol.ekle(b.ev, "Library/Caches")
        for (r, ad, kimlik) in tarayiciCacheYollari {
            adaylar.append((Yol.ekle(caches, r), Metin(.katTarayiciOnbellek, .yazi(ad)), kimlik))
        }
        let destek = Yol.ekle(b.ev, "Library/Application Support")
        for (r, ad, kimlik) in chromiumTabanlari {
            let taban = Yol.ekle(destek, r)
            guard case .tamam(let cocuklar) = listele(taban) else { continue }
            for t in tabanOnbellekleri where cocuklar.contains(t) {
                adaylar.append((Yol.ekle(taban, t), Metin(.ikili, .yazi(ad), .yazi(t)), kimlik))
            }
            for p in cocuklar.sorted() {
                let profil = Yol.ekle(taban, p)
                // Yalnız gerçek profil klasörleri (içinde Preferences dosyası olan).
                guard Yol.varMi(Yol.ekle(profil, "Preferences")) else { continue }
                for o in profilOnbellekleri {
                    adaylar.append((Yol.ekle(profil, o), Metin(.uclu, .yazi(ad), .yazi(p), .yazi(o)), kimlik))
                }
            }
        }
        var gorulen = Set<String>()
        for a in adaylar {
            if iptal() { break }
            guard Yol.dizinMi(a.yol) else { continue }
            let gercek = Yol.gercek(a.yol) ?? a.yol
            if gorulen.contains(gercek) { continue }
            gorulen.insert(gercek)
            s.kokler.append(a.yol)
            guard let o = olcOge(a.yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
            let calisiyor = b.calisanKimlikler.contains(a.kimlik)
            s.ogeler.append(TemizlikOgesi(yol: a.yol, ad: Yol.ad(a.yol), baslik: a.ad, boyut: o.bayt, dosyaSayisi: o.dosya,
                                          calisiyor: calisiyor, varsayilanSecili: !calisiyor, yalnizIcerik: true,
                                          not: calisiyor ? Metin(.katNotTarayiciAcik) : nil))
        }
        if s.kokler.isEmpty { s.durum = .yok }
        return s
    }

    static func gelistirici(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        var s = KategoriSonuc(kimlik: .gelistirici, durum: .tamam, kokler: [], ogeler: [], erisilemeyen: 0)
        var gorulen = Set<String>()
        for (r, ad) in gelistiriciKokleri {
            if iptal() { break }
            let yol = Yol.ekle(b.ev, r)
            guard Yol.dizinMi(yol) else { continue }
            let gercek = Yol.gercek(yol) ?? yol
            if gorulen.contains(gercek) { continue }
            gorulen.insert(gercek)
            s.kokler.append(yol)
            guard let o = olcOge(yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
            var not: Metin? = nil
            if ad.a == .katDeposu {
                not = Metin(.katNotPnpm)
            }
            s.ogeler.append(TemizlikOgesi(yol: yol, ad: Yol.ad(yol), baslik: ad, boyut: o.bayt, dosyaSayisi: o.dosya,
                                          calisiyor: false, varsayilanSecili: true, yalnizIcerik: true, not: not))
        }
        if s.kokler.isEmpty { s.durum = .yok }
        return s
    }

    static func eskiKurulumlar(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        let kok = Yol.ekle(b.ev, "Downloads")
        var s = KategoriSonuc(kimlik: .eskiKurulum, durum: .tamam, kokler: [kok], ogeler: [], erisilemeyen: 0)
        let sinir = b.simdi.addingTimeInterval(-30 * 86_400)
        func incele(_ klasor: String, derinlik: Int) {
            guard case .tamam(let adlar) = listele(klasor) else {
                if derinlik == 0 { s.durum = Yol.varMi(klasor) ? .erisimYok : .yok }
                return
            }
            for ad in adlar {
                if iptal() { return }
                let yol = Yol.ekle(klasor, ad)
                let u = Yol.uzanti(ad)
                if kurulumUzantilari.contains(u) {
                    let url = URL(fileURLWithPath: yol)
                    let v = try? url.resourceValues(forKeys: [.addedToDirectoryDateKey, .contentModificationDateKey])
                    let tarih = v?.addedToDirectoryDate ?? v?.contentModificationDate ?? b.simdi
                    guard tarih < sinir else { continue }
                    guard let o = olcOge(yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
                    s.ogeler.append(TemizlikOgesi(yol: yol, ad: ad, boyut: o.bayt, dosyaSayisi: max(1, o.dosya),
                                                  calisiyor: false, varsayilanSecili: false, yalnizIcerik: false,
                                                  not: Metin(.katNotIndirildi, .goreli(tarih, b.simdi))))
                } else if derinlik < 1, u.isEmpty, Yol.dizinMi(yol), !ad.hasPrefix(".") {
                    incele(yol, derinlik: derinlik + 1)
                }
            }
        }
        incele(kok, derinlik: 0)
        return s
    }

    static func xcodeArsivleri(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        let kok = Yol.ekle(b.ev, "Library/Developer/Xcode/Archives")
        var s = KategoriSonuc(kimlik: .xcodeArsiv, durum: .tamam, kokler: [kok], ogeler: [], erisilemeyen: 0)
        guard case .tamam(let gunler) = listele(kok) else { s.durum = .yok; return s }
        for g in gunler {
            let gk = Yol.ekle(kok, g)
            guard case .tamam(let arsivler) = listele(gk) else { continue }
            for a in arsivler where Yol.uzanti(a) == "xcarchive" {
                if iptal() { break }
                let yol = Yol.ekle(gk, a)
                guard let o = olcOge(yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
                s.ogeler.append(TemizlikOgesi(yol: yol, ad: a, baslik: Metin(.parantez, .yazi(a), .yazi(g)), boyut: o.bayt, dosyaSayisi: o.dosya,
                                              calisiyor: false, varsayilanSecili: false, yalnizIcerik: false, not: nil))
            }
        }
        return s
    }

    static func yukluSimRuntimeleri() -> Set<String> {
        var dizinler = ["/Library/Developer/CoreSimulator/Profiles/Runtimes"]
        if case .tamam(let hacimler) = listele("/Library/Developer/CoreSimulator/Volumes") {
            for h in hacimler {
                dizinler.append("/Library/Developer/CoreSimulator/Volumes/\(h)/Library/Developer/CoreSimulator/Profiles/Runtimes")
            }
        }
        if case .tamam(let uygulamalar) = listele("/Applications") {
            for x in uygulamalar where x.hasPrefix("Xcode") && x.hasSuffix(".app") {
                let pl = "/Applications/\(x)/Contents/Developer/Platforms"
                if case .tamam(let platformlar) = listele(pl) {
                    for p in platformlar {
                        dizinler.append("\(pl)/\(p)/Library/Developer/CoreSimulator/Profiles/Runtimes")
                    }
                }
            }
        }
        var s = Set<String>()
        for d in dizinler {
            guard case .tamam(let rl) = listele(d) else { continue }
            for r in rl where r.hasSuffix(".simruntime") {
                if let pl = NSDictionary(contentsOfFile: "\(d)/\(r)/Contents/Info.plist"),
                   let id = pl["CFBundleIdentifier"] as? String {
                    s.insert(id)
                }
            }
        }
        return s
    }

    static func bagliOlmayanImajVar() -> Bool {
        if let pl = NSDictionary(contentsOfFile: "/Library/Developer/CoreSimulator/Images/images.plist"),
           let imajlar = pl["images"] as? [Any], !imajlar.isEmpty {
            return true
        }
        if case .tamam(let l) = listele("/Library/Developer/CoreSimulator/Cryptex/Images/bundle"),
           l.contains(where: { !$0.hasPrefix(".") }) {
            return true
        }
        return false
    }

    static func simulatorler(_ b: TaramaBaglami, _ inodlar: InodeKumesi, _ iptal: @escaping () -> Bool) -> KategoriSonuc {
        let kok = Yol.ekle(b.ev, "Library/Developer/CoreSimulator/Devices")
        var s = KategoriSonuc(kimlik: .simulator, durum: .tamam, kokler: [kok], ogeler: [], erisilemeyen: 0)
        guard case .tamam(let cihazlar) = listele(kok) else { s.durum = .yok; return s }
        // Kayıtlı ama şu an bağlanmamış bir çalışma ortamı imajı varsa hangi cihazın kullanılamaz
        // olduğunu güvenle bilemeyiz; o durumda hiçbirini önermeyiz.
        if bagliOlmayanImajVar() { return s }
        let yuklu = yukluSimRuntimeleri()
        for c in cihazlar {
            if iptal() { break }
            let yol = Yol.ekle(kok, c)
            guard let pl = NSDictionary(contentsOfFile: Yol.ekle(yol, "device.plist")),
                  let runtime = pl["runtime"] as? String else { continue }
            if yuklu.contains(runtime) { continue }
            let ad = (pl["name"] as? String) ?? c
            var surum = runtime.components(separatedBy: "SimRuntime.").last ?? runtime
            if let i = surum.firstIndex(of: "-") {
                surum = String(surum[..<i]) + " " + surum[surum.index(after: i)...].replacingOccurrences(of: "-", with: ".")
            }
            guard let o = olcOge(yol, inodlar, iptal) else { s.erisilemeyen += 1; continue }
            s.ogeler.append(TemizlikOgesi(yol: yol, ad: c, baslik: Metin(.parantez, .yazi(ad), .yazi(surum)), boyut: o.bayt, dosyaSayisi: o.dosya,
                                          calisiyor: false, varsayilanSecili: false, yalnizIcerik: false,
                                          not: Metin(.katNotSimulator)))
        }
        return s
    }
}

// MARK: - Adım 1 temizliği

public struct TemizlikRaporu: Codable, Sendable {
    public var serbestBayt: Int64 = 0
    public var silinenDosya = 0
    public var atlanan = 0
    public var reddedilen: [RedKaydi] = []
    public var sonuclar: [IslemSonucu] = []
    public init() {}
}

public enum Temizleyici {
    /// Seçilen öğeleri kategori kökleriyle birlikte Silici'ye gönderir.
    public static func temizle(_ secimler: [(KategoriSonuc, [TemizlikOgesi])], silici: Silici,
                               ilerleme: (Int, Int) -> Void = { _, _ in }) -> TemizlikRaporu {
        var r = TemizlikRaporu()
        let toplam = secimler.reduce(0) { $0 + $1.1.count }
        var i = 0
        for (kat, ogeler) in secimler {
            for o in ogeler {
                let s = silici.uygula(SilmeIstegi(yol: o.yol, islem: .kaliciSil(kokler: kat.kokler), yalnizIcerik: o.yalnizIcerik))
                r.serbestBayt += s.serbestBayt
                r.silinenDosya += s.silinenDosya
                r.atlanan += s.atlanan
                if s.durum == .reddedildi { r.reddedilen.append(RedKaydi(yol: o.yol, neden: s.neden)) }
                r.sonuclar.append(s)
                i += 1
                ilerleme(i, toplam)
            }
        }
        return r
    }
}

/// Bekçinin ya da silicinin reddettiği bir işlem (yol + dilden bağımsız neden).
public struct RedKaydi: Codable, Hashable, Sendable {
    public let yol: String
    public let neden: Metin?
    public init(yol: String, neden: Metin?) { self.yol = yol; self.neden = neden }
    public func metin(_ dil: Dil) -> String { neden.map { "\(yol): \($0(dil))" } ?? yol }
}
