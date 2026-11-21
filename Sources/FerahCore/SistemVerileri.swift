import Foundation
import Darwin

/// Sistem verileri sayfasında bir kalem için ne yapılabileceği.
public enum SistemEylemi: String, Codable, Sendable {
    case ferahTemizler = "ferah_temizler"
    case adim1 = "adim_1"
    case uygulamaIcinden = "uygulama_icinden"
    case yenidenBaslat = "yeniden_baslatinca"
    case dokunma
    case bilgi

    public var anahtar: M {
        switch self {
        case .ferahTemizler: return .svEylemFerah
        case .adim1: return .svEylemAdim1
        case .uygulamaIcinden: return .svEylemUyg
        case .yenidenBaslat: return .svEylemYeniden
        case .dokunma: return .svEylemDokunma
        case .bilgi: return .svEylemBilgi
        }
    }

    public func etiket(_ dil: Dil) -> String { Metin(anahtar)(dil) }
}

public enum Sahiplik: Equatable, Sendable {
    case sahipli(String)
    case sahipsiz
    case belirsiz
}

public struct SistemKalemi: Codable, Identifiable, Hashable, Sendable {
    public var id: String { yol }
    public let yol: String
    public let grup: String
    public let boyut: Int64
    /// Ölçülemediyse nedeni (boyut 0 kabul edilir, toplama girmez).
    public let olculemedi: Metin?
    /// Bazı alt klasörler okunamadı; boyut eksik olabilir.
    public let kismen: Bool
    public let evIcinde: Bool
    /// Bir düzey aşağı inilmiş alt kalemse üst kalemin yolu.
    public let ust: String?
    public let sahip: String?
    public let sahipsiz: Bool
    public let aciklama: Aciklama
    public let eylem: SistemEylemi
    public let eylemMetni: Metin?

    public init(yol: String, grup: String, boyut: Int64, olculemedi: Metin?, kismen: Bool, evIcinde: Bool, ust: String?,
                sahip: String?, sahipsiz: Bool, aciklama: Aciklama, eylem: SistemEylemi, eylemMetni: Metin?) {
        self.yol = yol; self.grup = grup; self.boyut = boyut; self.olculemedi = olculemedi; self.kismen = kismen
        self.evIcinde = evIcinde; self.ust = ust; self.sahip = sahip; self.sahipsiz = sahipsiz
        self.aciklama = aciklama; self.eylem = eylem; self.eylemMetni = eylemMetni
    }

    public var ad: String { Yol.ad(yol) }
    /// Yalnız ev içi, ölçülmüş ve "Ferah temizleyebilir" kalemlerde taşıma düğmesi olur.
    public var tasinabilir: Bool { eylem == .ferahTemizler && evIcinde && olculemedi == nil }
}

public struct SistemDokumu: Codable, Sendable {
    public var kalemler: [SistemKalemi]
    public var digerBayt: Int64
    public var digerSayi: Int
    /// Üst düzey kalemlerin (alt kalemler hariç, ölçülemeyenler hariç) ve "diğer"in toplamı.
    public var olculen: Int64
    public var kullanilan: Int64?
    /// kullanılan − ölçülen; kaba tahmin.
    public var tahminiOlculemeyen: Int64?
    public var anlikGoruntuler: [String]
    public var tamDiskErisimi: Bool
    public var esik: Int64
}

// MARK: - Açıklama kuralları (saf)

extension AciklamaMotoru {
    public struct SistemKarari: Sendable {
        public let aciklama: Aciklama
        public let eylem: SistemEylemi
        public let eylemMetni: Metin?
    }

    static func sk(_ tur: Metin, _ risk: Risk, _ ne: Metin, geri: Metin? = nil, _ eylem: SistemEylemi, _ metin: Metin? = nil,
                   oneri: Oneri? = nil) -> SistemKarari {
        let o: Oneri = oneri ?? {
            switch eylem {
            case .ferahTemizler: return risk == .guvenli ? .silinebilir : .bakVeKararVer
            case .adim1, .uygulamaIcinden, .yenidenBaslat: return .bakVeKararVer
            case .dokunma: return .dokunma
            case .bilgi: return .sakla
            }
        }()
        return SistemKarari(aciklama: Aciklama(tur: tur, risk: risk, neOlur: ne, geriNasil: geri, oneri: o, oneriMetni: metin),
                            eylem: eylem, eylemMetni: metin)
    }

    /// Sistem verileri sayfası için saf kural fonksiyonu.
    public static func sistemAcikla(yol: String, ev: String, sahiplik: Sahiplik = .belirsiz) -> SistemKarari {
        let evIci = Yol.altinda(yol, ev)
        let g = evIci ? String(yol.dropFirst(ev.count + 1)) : yol
        let gk = Yol.katla(g)
        let ad = Yol.katla(Yol.ad(yol))
        func bas(_ p: String) -> Bool { gk == Yol.katla(p) || gk.hasPrefix(Yol.katla(p) + "/") }

        if evIci, let ilk = g.split(separator: "/").first, ilk != "Library", !ilk.hasPrefix(".") {
            return sk(m(.svKisiselTur), .riskli, m(.svKisiselNe),
                      .bilgi, m(.svKisiselMetin), oneri: .sakla)
        }
        if evIci {
            // Bilinen somut kalemler
            if bas("Library/Application Support/Claude/vm_bundles") {
                return sk(m(.svClaudeVmTur), .dikkat,
                          m(.svClaudeVmNe),
                          geri: m(.svClaudeVmGeri), .ferahTemizler,
                          m(.svClaudeVmMetin))
            }
            if gk == Yol.katla("Library/Application Support/Claude") {
                return sk(m(.svClaudeTur), .dikkat, m(.svClaudeNe),
                          .uygulamaIcinden, m(.svClaudeMetin))
            }
            if bas(".claude/projects") {
                return sk(m(.svClaudeCodeProjeTur), .dikkat,
                          m(.svClaudeCodeProjeNe),
                          geri: m(.svGeriGelmez), .ferahTemizler, m(.svClaudeCodeProjeMetin))
            }
            if gk == ".claude" {
                return sk(m(.svClaudeCodeTur), .dikkat, m(.svClaudeCodeNe),
                          .uygulamaIcinden, m(.svClaudeCodeMetin), oneri: .sakla)
            }
            if ad.contains("whatsapp") {
                return sk(m(.svWhatsappTur), .riskli, m(.svWhatsappNe),
                          .uygulamaIcinden, m(.svWhatsappMetin))
            }
            if ad.contains("telegram") {
                return sk(m(.svTelegramTur), .dikkat, m(.svTelegramNe),
                          .uygulamaIcinden, m(.svTelegramMetin))
            }
            if ad.contains("signal") && !ad.contains("signalr") {
                return sk(m(.svSignalTur), .riskli, m(.svSignalNe),
                          .uygulamaIcinden, m(.svSignalMetin))
            }
            if ad.contains("docker") {
                return sk(m(.svDockerTur), .riskli, m(.svDockerNe),
                          .uygulamaIcinden, m(.svDockerMetin))
            }
            if bas("Library/Application Support/Google/DriveFS") {
                return sk(m(.svDriveTur), .dikkat, m(.svDriveNe),
                          .uygulamaIcinden, m(.svDriveMetin))
            }
            let profiller = ["Library/Application Support/Google/Chrome", "Library/Application Support/Microsoft Edge",
                             "Library/Application Support/BraveSoftware", "Library/Application Support/Arc", "Library/Application Support/Vivaldi"]
            if profiller.contains(where: { bas($0) }) {
                return sk(m(.svProfilTur), .dokunma, m(.svProfilNe),
                          .dokunma, m(.svProfilMetin))
            }
            if gk == Yol.katla("Library/Application Support/Google") {
                return sk(m(.svGoogleTur), .dikkat, m(.svGoogleNe),
                          .uygulamaIcinden, m(.svGoogleMetin), oneri: .sakla)
            }
            if bas("Library/Developer/Xcode") {
                return sk(m(.svXcodeTur), .dikkat, m(.svXcodeNe),
                          .uygulamaIcinden, m(.svXcodeMetin))
            }
            if bas("Library/Developer/CoreSimulator") {
                return sk(m(.svSimTur), .dikkat, m(.svSimNe),
                          .uygulamaIcinden, m(.svSimMetin))
            }
            if gk == Yol.katla("Library/Developer") {
                return sk(m(.svGelistiriciTur), .dikkat, m(.svGelistiriciNe), .adim1)
            }
            if bas("Library/Application Support/MobileSync") {
                return sk(m(.svIosYedekTur), .riskli, m(.svIosYedekNe),
                          .uygulamaIcinden, m(.svIosYedekMetin))
            }
            if bas("Library/Mail") {
                return sk(m(.svMailTur), .dokunma, m(.svMailNe), .dokunma,
                          m(.svMailMetin))
            }
            if bas("Library/Messages") {
                return sk(m(.svMesajTur), .dokunma, m(.svMesajNe), .uygulamaIcinden,
                          m(.svMesajMetin))
            }
            if bas("Library/Containers/com.apple.photolibraryd") || bas("Library/Containers/com.apple.Photos") || gk.contains("photoanalysisd") {
                return sk(m(.svFotoTur), .dokunma, m(.svFotoNe), .dokunma)
            }
            if bas("Library/Caches") { return sk(m(.svOnbellekTur), .guvenli, m(.svOnbellekNe), .adim1) }
            if bas("Library/Logs") { return sk(m(.svGunlukTur), .guvenli, m(.svGunlukNe), .adim1) }
            if bas("Library/Application Support/Steam") || ad == "minecraft" || ad == ".minecraft" || ad.contains("tlauncher")
                || bas("Library/Application Support/Epic") || ad.contains("battle.net") {
                return sk(m(.svOyunTur), .dikkat, m(.svOyunNe),
                          .uygulamaIcinden, m(.svOyunMetin))
            }
            if bas("Library/Application Support/CrossOver") {
                return sk(m(.svCrossoverTur), .dikkat, m(.svCrossoverNe),
                          .uygulamaIcinden, m(.svCrossoverMetin))
            }
            if [".rustup", ".pyenv", ".nvm", ".sdkman", ".bun", ".deno", ".volta", ".fnm"].contains(ad) && !g.contains("/") {
                return sk(m(.svAracTur), .dikkat, m(.svAracNe, y(Yol.ad(yol))),
                          geri: m(.svAracGeri), .ferahTemizler,
                          m(.svAracMetin))
            }
            if gk == ".npm" || gk == ".gradle" || gk == ".cargo" {
                return sk(m(.svPaketYonTur), .dikkat, m(.svPaketYonNe), .adim1)
            }
            if gk == ".cache" || gk.hasPrefix(".cache/") {
                return sk(m(.svCacheTur), .guvenli, m(.svCacheNe),
                          geri: m(.svCacheGeri), .ferahTemizler)
            }
            if gk == ".ollama" || gk.hasPrefix(".ollama/") {
                return sk(m(.svOllamaTur), .dikkat, m(.svOllamaNe), .uygulamaIcinden, m(.svOllamaMetin))
            }
            if bas("Library/Group Containers") || bas("Library/Containers") {
                if gk == Yol.katla("Library/Group Containers") || gk == Yol.katla("Library/Containers") {
                    return sk(m(.svKapsayiciTur), .dokunma, m(.svKapsayiciNe), .dokunma)
                }
            }
            // Sahiplik
            switch sahiplik {
            case .sahipli(let app):
                return sk(m(.svSahipliTur, y(app)), .dikkat, m(.svSahipliNe, y(app)),
                          .uygulamaIcinden, m(.svSahipliMetin), oneri: .sakla)
            case .sahipsiz:
                let k = Koruma.neden(yol, ev: ev)
                return sk(m(.svSahipsizTur), .dikkat,
                          m(.svSahipsizNe),
                          k == nil ? .ferahTemizler : .dokunma,
                          k ?? m(.svSahipsizMetin), oneri: .bakVeKararVer)
            case .belirsiz:
                break
            }
            if let k = Koruma.neden(yol, ev: ev) {
                return sk(m(.svKorunanTur), .dokunma, k, .dokunma, k)
            }
            if Yol.katla(Yol.ebeveyn(yol)) == Yol.katla(Yol.ekle(ev, "Library")) {
                return sk(m(.svLibKokTur), .dokunma,
                          m(.svLibKokNe),
                          .dokunma, m(.svLibKokMetin))
            }
            // Bilinmeyen: düğme yok (yanlış pozitif burada tehlikeli), dürüst metin, öneri sakla.
            return sk(m(.svBilinmeyenTur), .dikkat, m(.aBilinmeyenNe),
                      .bilgi, m(.svBilinmeyenMetin), oneri: .sakla)
        }

        // Ev dışı: yalnız bilgi
        if gk.hasPrefix("/library/updates") {
            return sk(m(.svGuncellemeTur), .dokunma, m(.svGuncellemeNe),
                      .uygulamaIcinden, m(.svGuncellemeMetin))
        }
        if gk.hasPrefix("/private/var/vm") {
            return sk(m(.svTakasTur), .dokunma, m(.svTakasNe),
                      .yenidenBaslat, m(.svTakasMetin))
        }
        if gk.hasPrefix("/private/var/folders") {
            return sk(m(.svFoldersTur), .dokunma,
                      m(.svFoldersNe),
                      .yenidenBaslat, m(.svFoldersMetin))
        }
        if gk.hasPrefix("/private/tmp") {
            return sk(m(.svTmpTur), .dokunma, m(.svTmpNe), .yenidenBaslat, m(.svTmpMetin))
        }
        if gk.hasPrefix("/library/developer") {
            return sk(m(.svCltTur), .dokunma, m(.svCltNe),
                      .uygulamaIcinden, m(.svCltMetin))
        }
        if gk.hasPrefix("/private/var/db") || gk.hasPrefix("/private/var/log") {
            return sk(m(.svDbTur), .dokunma, m(.svDbNe), .dokunma, m(.svDbMetin))
        }
        if gk.hasPrefix("/library") {
            return sk(m(.svLibTur), .dokunma, m(.svLibNe), .dokunma,
                      m(.svLibMetin))
        }
        if gk.hasPrefix("/applications") {
            return sk(m(.svAppsTur), .dikkat, m(.svAppsNe), .uygulamaIcinden, m(.svAppsMetin))
        }
        return sk(m(.svSistemTur), .dokunma, m(.svSistemNe), .dokunma)
    }
}

// MARK: - Tarama (salt okunur)

public struct SistemTaramaAyari: Sendable {
    public var ev: String
    public var esik: Int64
    /// Aşağı inme eşiği (bu boyutun üstündeki klasörlerin bir düzey altı da listelenir).
    public var inmeEsigi: Int64
    /// Kurulu uygulamalar (kimlik, ad) — sahiplik eşleştirmesi için.
    public var kurulu: [(String?, String)]
    public var disKokler: Bool

    public init(ev: String = NSHomeDirectory(), esik: Int64 = 100_000_000, inmeEsigi: Int64 = 1_000_000_000,
                kurulu: [(String?, String)] = [], disKokler: Bool = true) {
        self.ev = Yol.gercek(ev) ?? ev
        self.esik = esik
        self.inmeEsigi = inmeEsigi
        self.kurulu = kurulu
        self.disKokler = disKokler
    }
}

public enum SistemTarayici {
    /// Tam Disk Erişimi var mı (TCC veritabanı yalnız onunla okunur).
    public static func tamDiskErisimi(ev: String = NSHomeDirectory()) -> Bool {
        let fd = open(Yol.ekle(ev, "Library/Application Support/com.apple.TCC/TCC.db"), O_RDONLY)
        if fd >= 0 { close(fd); return true }
        return false
    }

    static func ters(_ s: String) -> [String] { Yol.katla(s).split(separator: ".").map(String.init) }

    /// Bir Application Support / Containers / Group Containers klasör adının sahibini bulur.
    /// Yalnız TAM eşleşme "sahipli"dir. Sahipsiz yalnız açıkça ters-DNS biçimli, Apple'a ait olmayan ve hiçbir
    /// kurulu uygulamayla üretici öneki bile paylaşmayan adlar için söylenir; gerisi belirsizdir.
    public static func sahiplik(_ ad: String, kurulu: [(String?, String)]) -> Sahiplik {
        let a = Yol.katla(ad)
        for (k, n) in kurulu {
            if let k, Yol.katla(k) == a { return .sahipli(n) }
            if Yol.katla(n) == a { return .sahipli(n) }
        }
        // Sahipsiz demek için katı koşullar
        if a.hasPrefix("com.apple.") || a.hasPrefix("group.") || a.hasPrefix("systemgroup.") { return .belirsiz }
        var p = ters(a)
        // Takım kimliği öneki (ör. "ABCDE12345.com.foo") → belirsiz
        if let ilk = ad.split(separator: ".").first, ilk.count == 10,
           ilk.allSatisfy({ ($0.isUppercase && $0.isLetter) || $0.isNumber }), ilk.contains(where: \.isNumber) {
            return .belirsiz
        }
        guard p.count >= 3, ["com", "org", "net", "io", "app", "dev", "co", "me", "de", "tr", "ru", "jp", "uk", "us", "ai"].contains(p[0]) else {
            return .belirsiz   // ters-DNS değil (ör. komut satırı aracının klasörü)
        }
        p = Array(p.prefix(2))
        let ureticiOnek = p.joined(separator: ".") + "."
        for (k, n) in kurulu {
            if let k {
                let kk = Yol.katla(k)
                if kk.hasPrefix(ureticiOnek) || a.hasPrefix(kk + ".") || kk.hasPrefix(a + ".") { return .belirsiz }
            }
            let son = ters(a).last ?? ""
            if !son.isEmpty, Yol.katla(n).replacingOccurrences(of: " ", with: "") == son { return .belirsiz }
        }
        return .sahipsiz
    }

    static func listele(_ d: String) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: d)) ?? []).filter { $0 != ".DS_Store" && $0 != ".localized" }
    }

    struct Aday {
        let yol: String
        let grup: String
        let evIcinde: Bool
        /// İzin penceresi açabilecek yer: Tam Disk Erişimi yoksa ölçülmez.
        let tdeGerekir: Bool
    }

    public static func tara(_ ayar: SistemTaramaAyari, disk: DiskBilgisi? = DiskBilgisi.oku(),
                            iptal: @escaping () -> Bool = { false },
                            ilerleme: @escaping (Int, Int) -> Void = { _, _ in }) -> SistemDokumu {
        let ev = ayar.ev
        let lib = Yol.ekle(ev, "Library")
        let tde = tamDiskErisimi(ev: ev)
        var adaylar: [Aday] = []
        let ozelLib = ["Application Support", "Group Containers", "Containers", "Developer"]
        for alt in ozelLib {
            let d = Yol.ekle(lib, alt)
            let kapsayici = alt.contains("Containers")
            for x in listele(d) {
                adaylar.append(Aday(yol: Yol.ekle(d, x), grup: "~/Library/\(alt)", evIcinde: true,
                                    tdeGerekir: kapsayici && x != "com.docker.docker"))
            }
        }
        for x in listele(lib) where !ozelLib.contains(x) && Yol.dizinMi(Yol.ekle(lib, x)) {
            adaylar.append(Aday(yol: Yol.ekle(lib, x), grup: "~/Library", evIcinde: true, tdeGerekir: false))
        }
        for x in listele(ev) where x.hasPrefix(".") && x != ".Trash" && Yol.dizinMi(Yol.ekle(ev, x)) {
            adaylar.append(Aday(yol: Yol.ekle(ev, x), grup: "~/.*", evIcinde: true, tdeGerekir: false))
        }
        // Yalnız bağlam için: kişisel klasörler ve uygulamalar (tahmini "ölçülemeyen" anlamlı olsun diye)
        for x in listele(ev) where !x.hasPrefix(".") && x != "Library" && Yol.dizinMi(Yol.ekle(ev, x)) {
            adaylar.append(Aday(yol: Yol.ekle(ev, x), grup: "~/*", evIcinde: true, tdeGerekir: false))
        }
        if ayar.disKokler {
            adaylar.append(Aday(yol: "/Applications", grup: "/Applications", evIcinde: false, tdeGerekir: false))
            for x in listele("/Library") where Yol.dizinMi("/Library/\(x)") {
                adaylar.append(Aday(yol: "/Library/\(x)", grup: "/Library", evIcinde: false, tdeGerekir: false))
            }
            // Kullanıcının /var/folders dizini: confstr(_CS_DARWIN_USER_DIR) → …/0/ ; kardeşleri C, T, X
            var tampon = [CChar](repeating: 0, count: 1024)
            if confstr(_CS_DARWIN_USER_DIR, &tampon, tampon.count) > 0,
               let kullanici = Yol.gercek(String(cString: tampon)) {
                let ust = Yol.ebeveyn(kullanici)
                for x in listele(ust) where Yol.dizinMi(Yol.ekle(ust, x)) {
                    adaylar.append(Aday(yol: Yol.ekle(ust, x), grup: "/private/var/folders", evIcinde: false, tdeGerekir: false))
                }
            }
            for p in ["/private/var/vm", "/private/tmp", "/private/var/db", "/private/var/log"] {
                adaylar.append(Aday(yol: p, grup: "/private/var", evIcinde: false, tdeGerekir: false))
            }
        }

        let kapasite = disk?.toplam ?? Int64.max
        var olcumler = [(Olcum?, Metin?)](repeating: (nil, nil), count: adaylar.count)
        let kilit = NSLock()
        var biten = 0
        DispatchQueue.concurrentPerform(iterations: adaylar.count) { i in
            if iptal() { return }
            let a = adaylar[i]
            var sonuc: (Olcum?, Metin?)
            if a.tdeGerekir && !tde {
                sonuc = (nil, Metin(.svOlcTde))
            } else {
                let o = Olcer.olc(a.yol, iptal: iptal)
                if o.yok { sonuc = (nil, Metin(.dKlasorYok)) }
                else if o.kokErisimYok { sonuc = (nil, Metin(.svOlcIzin)) }
                else if o.bayt > kapasite { sonuc = (o, Metin(.svOlcGuvenilmez)) }
                else { sonuc = (o, nil) }
            }
            kilit.lock(); olcumler[i] = sonuc; biten += 1; let b = biten; kilit.unlock()
            ilerleme(b, adaylar.count)
        }

        var kalemler: [SistemKalemi] = []
        var diger: Int64 = 0
        var digerSayi = 0
        var olculen: Int64 = 0
        func kalem(_ yol: String, _ grup: String, _ evIci: Bool, _ o: Olcum?, _ neden: Metin?, ust: String?) -> SistemKalemi {
            var sah: Sahiplik = .belirsiz
            let ebeveynAd = Yol.ad(Yol.ebeveyn(yol))
            if evIci, ust == nil, ["Application Support", "Containers", "Group Containers"].contains(ebeveynAd),
               Yol.katla(Yol.ebeveyn(Yol.ebeveyn(yol))) == Yol.katla(lib) {
                sah = sahiplik(Yol.ad(yol), kurulu: ayar.kurulu)
            }
            let k = AciklamaMotoru.sistemAcikla(yol: yol, ev: ev, sahiplik: sah)
            var sahip: String? = nil
            if case .sahipli(let n) = sah { sahip = n }
            return SistemKalemi(yol: yol, grup: grup, boyut: neden == nil ? (o?.bayt ?? 0) : 0, olculemedi: neden,
                                kismen: (o?.okunamayan ?? 0) > 0, evIcinde: evIci, ust: ust, sahip: sahip,
                                sahipsiz: sah == .sahipsiz, aciklama: k.aciklama, eylem: k.eylem, eylemMetni: k.eylemMetni)
        }
        for (i, a) in adaylar.enumerated() {
            let (o, neden) = olcumler[i]
            if neden == nil, let o {
                olculen += o.bayt
                if o.bayt < ayar.esik { diger += o.bayt; digerSayi += 1; continue }
            } else if neden?.a == .dKlasorYok {
                continue
            }
            kalemler.append(kalem(a.yol, a.grup, a.evIcinde, o, neden, ust: nil))
            // Büyük klasörde bir düzey aşağı in (paket değilse)
            let inilir = a.grup != "~/*" && a.yol != "/Applications"
            if inilir, neden == nil, let o, o.bayt >= ayar.inmeEsigi, !BuyukTarayici.paketUzantilari.contains(Yol.uzanti(a.yol)) {
                for x in listele(a.yol) {
                    if iptal() { break }
                    let p = Yol.ekle(a.yol, x)
                    var st = stat()
                    guard lstat(p, &st) == 0, (st.st_mode & S_IFMT) == S_IFDIR else { continue }
                    let ao = Olcer.olc(p, iptal: iptal)
                    guard !ao.kokErisimYok, ao.bayt >= ayar.esik, ao.bayt <= kapasite else { continue }
                    kalemler.append(kalem(p, a.grup, a.evIcinde, ao, nil, ust: a.yol))
                }
            }
        }
        var anlik: [String] = []
        if ayar.disKokler { anlik = anlikGoruntuler() }
        let kullanilan = disk?.kullanilan
        return SistemDokumu(kalemler: kalemler.sorted { $0.boyut > $1.boyut }, digerBayt: diger, digerSayi: digerSayi,
                            olculen: olculen, kullanilan: kullanilan,
                            tahminiOlculemeyen: kullanilan.map { max(0, $0 - olculen) },
                            anlikGoruntuler: anlik, tamDiskErisimi: tde, esik: ayar.esik)
    }

    /// `tmutil listlocalsnapshots /` çıktısındaki yerel Time Machine anlık görüntüleri.
    public static func anlikGoruntuler() -> [String] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
        p.arguments = ["listlocalsnapshots", "/"]
        let boru = Pipe()
        p.standardOutput = boru
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return [] }
        let v = boru.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return (String(data: v, encoding: .utf8) ?? "").split(separator: "\n").map(String.init)
            .filter { $0.contains("com.apple.TimeMachine") }
    }
}
