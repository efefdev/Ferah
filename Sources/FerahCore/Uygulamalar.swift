import Foundation
import CoreServices

public enum UygulamaKaynagi: String, Codable, Sendable {
    case appStore = "app_store"
    case gelistirici
    case apple

    public var anahtar: M {
        switch self {
        case .appStore: return .uKaynakAppStore
        case .gelistirici: return .uKaynakGelistirici
        case .apple: return .uKaynakApple
        }
    }

    public func etiket(_ dil: Dil) -> String { Metin(anahtar)(dil) }
}

/// Uygulamayla birlikte kaldırılabilecek veri (yalnız tam ad eşleşmesiyle bulunur).
public struct Artik: Codable, Hashable, Sendable, Identifiable {
    public var id: String { yol }
    public let yol: String
    public let tur: Metin
    public let boyut: Int64
    /// macOS izin penceresi açmamak için ölçülmedi ya da okunamadı.
    public let erisilemedi: Bool
}

/// Açıklama motorunun uygulama girdisi.
public struct UygulamaGirdisi: Codable, Hashable, Sendable {
    public var yol: String
    public var ad: String
    public var kimlik: String?
    public var surum: String?
    public var boyut: Int64
    public var sonKullanilma: Date?
    public var eklenme: Date?
    public var kaynak: UygulamaKaynagi
    public var yalnizIntel: Bool
    public var calisiyor: Bool
    public var kendisi: Bool
    public var sembolikBag: Bool
    /// Sistem uzantısı, sürücü ya da ayrıcalıklı yardımcı kuruyor.
    public var sistemBileseni: Bool
    /// Bulunan kendi kaldırıcısının yolu.
    public var kaldirici: String?
    public var artiklar: [Artik]
    /// Boyut güvenilir ölçülemediyse nedeni (ör. Contents başka yeri gösteren bir sembolik bağ).
    public var boyutNotu: Metin? = nil
    /// Son kullanım ve eklenme tarihi yoksa paketin değişme tarihi (yalnız yedek bilgi).
    public var degisme: Date? = nil

    public init(yol: String, ad: String, kimlik: String?, surum: String? = nil, boyut: Int64 = 0,
                sonKullanilma: Date? = nil, eklenme: Date? = nil, kaynak: UygulamaKaynagi = .gelistirici,
                yalnizIntel: Bool = false, calisiyor: Bool = false, kendisi: Bool = false, sembolikBag: Bool = false,
                sistemBileseni: Bool = false, kaldirici: String? = nil, artiklar: [Artik] = [],
                boyutNotu: Metin? = nil, degisme: Date? = nil) {
        self.yol = yol; self.ad = ad; self.kimlik = kimlik; self.surum = surum; self.boyut = boyut
        self.sonKullanilma = sonKullanilma; self.eklenme = eklenme; self.kaynak = kaynak
        self.yalnizIntel = yalnizIntel; self.calisiyor = calisiyor; self.kendisi = kendisi
        self.sembolikBag = sembolikBag; self.sistemBileseni = sistemBileseni; self.kaldirici = kaldirici
        self.artiklar = artiklar
        self.boyutNotu = boyutNotu
        self.degisme = degisme
    }

    public var apple: Bool { kimlik?.lowercased().hasPrefix("com.apple.") ?? false }
    public var artikBoyutu: Int64 { artiklar.reduce(0) { $0 + $1.boyut } }

    /// Çöp'e taşınamıyorsa nedeni (Bekçi'nin kurallarıyla aynı).
    public var silinemezNedeni: Metin? {
        if apple { return Metin(.uSilApple) }
        if kendisi { return Metin(.bKendisi) }
        if sembolikBag { return Metin(.uSilKisayol) }
        if kimlik == nil { return Metin(.bInfoPlistYok) }
        if calisiyor { return Metin(.uSilCalisiyor) }
        return nil
    }
}

public struct UygulamaBilgisi: Codable, Hashable, Sendable, Identifiable {
    public var id: String { girdi.yol }
    public let girdi: UygulamaGirdisi
    public var yol: String { girdi.yol }
    public var ad: String { girdi.ad }
    public var silinebilir: Bool { girdi.silinemezNedeni == nil }
}

// MARK: - Açıklama kuralları (saf)

extension AciklamaMotoru {
    static let kendiKaldiricisiOlanlar = ["com.adobe.", "com.microsoft.word", "com.microsoft.excel", "com.microsoft.powerpoint",
                                          "com.microsoft.outlook", "com.microsoft.onenote", "com.microsoft.teams"]
    static let guvenlikAdlari = ["vpn", "antivirus", "norton", "avast", "avg ", "malwarebytes", "sophos", "bitdefender",
                                 "kaspersky", "eset", "intego", "mcafee", "little snitch", "lulu", "nordvpn", "expressvpn",
                                 "protonvpn", "surfshark", "tunnelblick", "cisco", "globalprotect", "forticlient"]

    /// Uzun süredir kullanılmıyor mu? Son kullanılma yoksa uydurmaz: yalnız eklenmesinin üstünden
    /// eşikten fazla zaman geçtiyse "kullanılmıyor" sayar (yeni eklenmiş, hiç açılmamış uygulama önerilmez).
    public static func kullanilmiyorMu(_ g: UygulamaGirdisi, gun: Int, simdi: Date = Date()) -> Bool {
        let esik = TimeInterval(gun) * 86_400
        if let s = g.sonKullanilma { return simdi.timeIntervalSince(s) > esik }
        if let e = g.eklenme ?? g.degisme { return simdi.timeIntervalSince(e) > esik }
        return false
    }

    public static func uygulamaAcikla(_ g: UygulamaGirdisi, verilerDahil: Bool, simdi: Date = Date()) -> Aciklama {
        if let neden = g.silinemezNedeni, g.apple || g.kendisi || g.sembolikBag || g.kimlik == nil {
            return Aciklama(tur: m(.aUygTur), risk: .dokunma, neOlur: neden, oneri: .dokunma)
        }
        let kk = (g.kimlik ?? "").lowercased()
        let adK = Yol.katla(g.ad)
        var risk: Risk = .guvenli
        var oneri: Oneri = .silinebilir
        var oneriMetni: Metin? = nil
        var baglam: [Metin] = []

        var ne: [Metin] = [m(.uNeTasinir)]
        if verilerDahil && !g.artiklar.isEmpty {
            ne.append(m(.uNeVeriGider, .bayt(g.artikBoyutu)))
        } else if !g.artiklar.isEmpty {
            ne.append(m(.uNeVeriKalir))
        }
        let neOlur = Metin.birles(ne)
        let geri = g.kaynak == .appStore ? m(.uGeriAppStore) : m(.uGeriGelistirici)

        let guvenlik = guvenlikAdlari.contains { adK.contains($0) }
        if kendiKaldiricisiOlanlar.contains(where: { kk.hasPrefix($0) }) || g.kaldirici != nil || g.sistemBileseni || guvenlik {
            risk = .dikkat
            oneri = .bakVeKararVer
            var neden = m(.uNedenSistem)
            if guvenlik { neden = m(.uNedenGuvenlik) }
            else if kk.hasPrefix("com.adobe.") { neden = m(.uNedenAdobe) }
            else if kk.hasPrefix("com.microsoft.") { neden = m(.uNedenOffice) }
            var parcalar = [m(.uOneriKaldirici, .metin(neden))]
            if let k = g.kaldirici { parcalar.append(m(.uOneriKaldiriciAdi, y(Yol.ad(k)))) }
            oneriMetni = Metin.birles(parcalar)
        }

        if g.yalnizIntel {
            baglam.append(m(.uBglIntel))
        }
        switch kk {
        case "com.docker.docker":
            baglam.append(m(.uBglDocker))
        case "com.valvesoftware.steam", "com.epicgames.epicgameslauncher", "net.battle.app", "com.gog.galaxy":
            baglam.append(m(.uBglOyun))
        case let x where x.hasPrefix("com.adobe.acc") || x.contains("creativecloud"):
            baglam.append(m(.uBglCC))
        case let x where x.contains("parallels") || x.contains("vmware") || x.contains("utm") || x.contains("virtualbox"):
            baglam.append(m(.uBglVm))
        case let x where x.contains("android.studio"):
            baglam.append(m(.uBglAndroid))
        default:
            break
        }
        if let s = g.sonKullanilma {
            baglam.append(m(.uBglSonKullanim, .goreli(s, simdi)))
        } else if let e = g.eklenme {
            baglam.append(m(.uBglHicEklendi, .goreli(e, simdi)))
            if simdi.timeIntervalSince(e) < 90 * 86_400 {
                oneri = .bakVeKararVer
                oneriMetni = oneriMetni ?? m(.uOneriYeni)
            }
        } else if let d = g.degisme {
            baglam.append(m(.uBglDegisme, .goreli(d, simdi)))
        } else {
            baglam.append(m(.uBglBilinmiyor))
            oneri = .bakVeKararVer
        }
        if let n = g.boyutNotu { baglam.append(n) }
        if g.artiklar.contains(where: \.erisilemedi) {
            baglam.append(m(.uBglErisilemedi))
        }
        return Aciklama(tur: m(.uTur, .metin(m(g.kaynak.anahtar))), risk: risk, neOlur: neOlur, geriNasil: geri,
                        oneri: oneri, oneriMetni: oneriMetni, baglam: baglam)
    }
}

// MARK: - Tarama (salt okunur)

public struct UygulamaTaramaAyari: Sendable {
    public var kokler: [String]
    public var ev: String
    public var calisanKimlikler: Set<String>
    public var kendiPaketi: String?

    public init(kokler: [String]? = nil, ev: String = NSHomeDirectory(), calisanKimlikler: Set<String> = [],
                kendiPaketi: String? = Bundle.main.bundlePath) {
        let e = Yol.gercek(ev) ?? ev
        self.ev = e
        self.kokler = (kokler ?? ["/Applications", Yol.ekle(e, "Applications")]).compactMap { Yol.gercek($0) }
        self.calisanKimlikler = Set(calisanKimlikler.map { $0.lowercased() })
        self.kendiPaketi = kendiPaketi.flatMap { Yol.gercek($0) }
    }
}

public enum UygulamaTarayici {
    /// Köklerin birinci düzeyindeki ve bir alt klasöründeki .app paketleri.
    public static func paketleriBul(_ kokler: [String]) -> [String] {
        var sonuc: [String] = []
        for kok in kokler {
            guard let l = try? FileManager.default.contentsOfDirectory(atPath: kok) else { continue }
            for x in l.sorted() where !x.hasPrefix(".") {
                let p = Yol.ekle(kok, x)
                if Yol.uzanti(x) == "app" { sonuc.append(p); continue }
                guard Yol.dizinMi(p), let alt = try? FileManager.default.contentsOfDirectory(atPath: p) else { continue }
                for y in alt.sorted() where Yol.uzanti(y) == "app" && !y.hasPrefix(".") {
                    sonuc.append(Yol.ekle(p, y))
                }
            }
        }
        // Kısayollar: listede zaten bulunan bir paketi gösteren sembolik bağlar ayrı satır olmaz
        // (ör. /Applications/X.app -> /Applications/X/X.app).
        let gercekler = Set(sonuc.filter { !Yol.bagMi($0) }.map { Yol.katla($0) })
        return sonuc.filter { p in
            guard Yol.bagMi(p), let hedef = Yol.gercek(p) else { return true }
            return !gercekler.contains(Yol.katla(hedef))
        }
    }

    /// Yalnız TAM ad eşleşmesiyle artık dosyaları bulur. Önek ya da bulanık eşleşme yok.
    /// `adCakisiyor`: uygulama adı başka bir kurulu uygulamanın adı ya da kimliğiyle çakışıyorsa true.
    public static func artiklariBul(kimlik: String?, ad: String, ev: String, adCakisiyor: Bool,
                                    inodlar: InodeKumesi = InodeKumesi()) -> [Artik] {
        let lib = Yol.ekle(ev, "Library")
        var adaylar: [(String, M, Bool)] = [] // yol, tür, ölçme (false: izin penceresi riski)
        if let k = kimlik, !k.isEmpty, !k.contains("/") {
            adaylar += [
                (Yol.ekle(lib, "Application Support/\(k)"), .uArtikVeri, true),
                (Yol.ekle(lib, "Caches/\(k)"), .uArtikOnbellek, true),
                (Yol.ekle(lib, "Containers/\(k)"), .uArtikKapsayici, false),
                (Yol.ekle(lib, "Saved Application State/\(k).savedState"), .uArtikPencere, true),
                (Yol.ekle(lib, "HTTPStorages/\(k)"), .uArtikAg, true),
                (Yol.ekle(lib, "WebKit/\(k)"), .uArtikWeb, true),
                (Yol.ekle(lib, "Logs/\(k)"), .uArtikGunluk, true),
            ]
        }
        if !adCakisiyor, !ad.isEmpty, !ad.contains("/"), ad.count >= 3 {
            adaylar.append((Yol.ekle(lib, "Application Support/\(ad)"), .uArtikVeri, true))
        }
        var sonuc: [Artik] = []
        var gorulen = Set<String>()
        for (yol, tur, olc) in adaylar {
            // Tam eşleşme: dizin listesinde birebir aynı ad olmalı (büyük/küçük harf duyarsız dosya
            // sisteminde lstat tek başına "com.Foo" ile "com.foo"yu ayırt etmez; listeyle doğrularız).
            let ust = Yol.ebeveyn(yol), son = Yol.ad(yol)
            var st = stat()
            guard lstat(yol, &st) == 0, (st.st_mode & S_IFMT) != S_IFLNK else { continue }
            guard let l = try? FileManager.default.contentsOfDirectory(atPath: ust), l.contains(son) else { continue }
            if gorulen.contains(Yol.katla(yol)) { continue }
            gorulen.insert(Yol.katla(yol))
            if Koruma.neden(yol, ev: ev) != nil { continue }
            if olc {
                let o = Olcer.olc(yol, inodlar: inodlar)
                sonuc.append(Artik(yol: yol, tur: Metin(tur), boyut: o.bayt, erisilemedi: o.kokErisimYok))
            } else {
                sonuc.append(Artik(yol: yol, tur: Metin(tur), boyut: 0, erisilemedi: true))
            }
        }
        return sonuc
    }

    /// 2001 öncesi (ör. yükleyicilerin koyduğu 1980) ya da gelecekteki tarihler kayıt sayılmaz.
    public static func gecerliTarih(_ d: Date?, simdi: Date = Date()) -> Date? {
        guard let d, d > Date(timeIntervalSinceReferenceDate: 0), d < simdi.addingTimeInterval(86_400) else { return nil }
        return d
    }

    static func tarih(_ item: MDItem?, _ anahtar: CFString) -> Date? {
        guard let item, let d = MDItemCopyAttribute(item, anahtar) else { return nil }
        return gecerliTarih(d as? Date)
    }

    public static func tara(_ ayar: UygulamaTaramaAyari, iptal: @escaping () -> Bool = { false },
                            ilerleme: @escaping (Int, Int) -> Void = { _, _ in }) -> [UygulamaBilgisi] {
        let paketler = paketleriBul(ayar.kokler)
        // Ad çakışması denetimi için tüm kurulu adlar ve kimlikler
        var adSayilari: [String: Int] = [:]
        var kimlikler = Set<String>()
        for p in paketler {
            adSayilari[Yol.katla(String(Yol.ad(p).dropLast(4))), default: 0] += 1
            if let k = Bekci.paketKimligi(p) { kimlikler.insert(Yol.katla(k)) }
        }
        let inodlar = InodeKumesi()
        var sonuc = [UygulamaBilgisi?](repeating: nil, count: paketler.count)
        let kilit = NSLock()
        var biten = 0
        DispatchQueue.concurrentPerform(iterations: paketler.count) { i in
            if iptal() { return }
            let g = incele(paketler[i], ayar, inodlar: inodlar, adSayilari: adSayilari, kimlikler: kimlikler)
            kilit.lock()
            sonuc[i] = UygulamaBilgisi(girdi: g)
            biten += 1
            let b = biten
            kilit.unlock()
            ilerleme(b, paketler.count)
        }
        return sonuc.compactMap { $0 }
    }

    static func incele(_ yol: String, _ ayar: UygulamaTaramaAyari, inodlar: InodeKumesi,
                       adSayilari: [String: Int], kimlikler: Set<String>) -> UygulamaGirdisi {
        let ad = String(Yol.ad(yol).dropLast(4))
        var st = stat()
        let bag = lstat(yol, &st) == 0 && (st.st_mode & S_IFMT) == S_IFLNK
        let plist = NSDictionary(contentsOfFile: Yol.ekle(yol, "Contents/Info.plist"))
        let kimlik = plist?["CFBundleIdentifier"] as? String
        let surum = (plist?["CFBundleShortVersionString"] as? String) ?? (plist?["CFBundleVersion"] as? String)
        let kk = kimlik?.lowercased() ?? ""

        let kaynak: UygulamaKaynagi
        if kk.hasPrefix("com.apple.") { kaynak = .apple }
        else if Yol.varMi(Yol.ekle(yol, "Contents/_MASReceipt/receipt")) { kaynak = .appStore }
        else { kaynak = .gelistirici }

        var yalnizIntel = false
        if !bag, let mimariler = Bundle(path: yol)?.executableArchitectures?.map(\.intValue) {
            yalnizIntel = mimariler.contains(NSBundleExecutableArchitectureX86_64)
                && !mimariler.contains(NSBundleExecutableArchitectureARM64)
        }

        let md = MDItemCreate(kCFAllocatorDefault, yol as CFString)
        let son = tarih(md, kMDItemLastUsedDate)
        var eklenme = tarih(md, kMDItemDateAdded)
        if eklenme == nil {
            eklenme = (try? URL(fileURLWithPath: yol).resourceValues(forKeys: [.addedToDirectoryDateKey, .creationDateKey]))
                .flatMap { gecerliTarih($0.addedToDirectoryDate) ?? gecerliTarih($0.creationDate) }
        }

        var boyut: Int64 = 0
        var boyutNotu: Metin? = nil
        let icerik = Yol.ekle(yol, "Contents")
        if bag {
            boyutNotu = Metin(.uBoyutKisayol)
        } else if Yol.bagMi(icerik) {
            // Multipass gibi: paketin içi başka bir yerde. Bağı izlemeyiz; boyutu uydurmayız.
            boyutNotu = Yol.gercek(icerik).map { Metin(.uBoyutBaskaYer, .yazi($0)) } ?? Metin(.uBoyutBaskaYer, .metin(Metin(.uBilinmiyor)))
        } else {
            boyut = Olcer.olc(yol, inodlar: inodlar).bayt
        }
        let degisme = gecerliTarih((try? URL(fileURLWithPath: yol).resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate)
        let sistemBileseni = ["Contents/Library/SystemExtensions", "Contents/Library/LaunchServices", "Contents/Library/Extensions"]
            .contains { Yol.varMi(Yol.ekle(yol, $0)) }

        // Kendi kaldırıcısı: aynı alt klasörde ya da paketin Resources'ında "Uninstall/Kaldır" adlı uygulama
        var kaldirici: String? = nil
        let ebeveyn = Yol.ebeveyn(yol)
        var aranacak: [String] = [Yol.ekle(yol, "Contents/Resources")]
        if !ayar.kokler.contains(where: { Yol.katla($0) == Yol.katla(ebeveyn) }) { aranacak.append(ebeveyn) }
        for d in aranacak {
            if let l = try? FileManager.default.contentsOfDirectory(atPath: d),
               let k = l.first(where: { x in
                   let xk = Yol.katla(x)
                   return Yol.uzanti(x) == "app" && (xk.contains("uninstall") || xk.contains("kaldır")) && Yol.ekle(d, x) != yol
               }) {
                kaldirici = Yol.ekle(d, k)
                break
            }
        }

        let adK = Yol.katla(ad)
        let adCakisiyor = (adSayilari[adK] ?? 0) > 1 || kimlikler.contains(adK)
        let artiklar = (bag || kk.hasPrefix("com.apple.")) ? [] :
            UygulamaTarayici.artiklariBul(kimlik: kimlik, ad: ad, ev: ayar.ev, adCakisiyor: adCakisiyor, inodlar: inodlar)
        let kendisi = ayar.kendiPaketi.map { Yol.esitVeyaAltinda($0, yol) } ?? false

        return UygulamaGirdisi(yol: yol, ad: ad, kimlik: kimlik, surum: surum, boyut: boyut, sonKullanilma: son,
                               eklenme: eklenme, kaynak: kaynak, yalnizIntel: yalnizIntel,
                               calisiyor: ayar.calisanKimlikler.contains(kk), kendisi: kendisi, sembolikBag: bag,
                               sistemBileseni: sistemBileseni, kaldirici: kaldirici, artiklar: artiklar,
                               boyutNotu: boyutNotu, degisme: degisme)
    }
}
