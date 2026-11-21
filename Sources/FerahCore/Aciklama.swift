import Foundation

/// Bilinen, bütün olarak ele alınan büyük klasör türleri.
public enum OzelTur: String, Codable, Sendable {
    case nodeModules = "node_modules"
    case sanalOrtam = "python_sanal_ortam"
    case pods
    case derlemeCiktisi = "derleme_ciktisi"
    case iosYedegi = "ios_yedegi"
    case dockerRaw = "docker_raw"
    case hfModeli = "huggingface_modeli"
    case ollamaModelleri = "ollama_modelleri"
    case steamOyunu = "steam_oyunu"
}

/// Açıklama motorunun girdisi: dosyanın kendisine dair bilgiler.
public struct AdayGirdisi: Codable, Sendable, Hashable {
    public var yol: String
    public var boyut: Int64
    public var dizinMi: Bool
    public var paketMi: Bool
    public var ozelTur: OzelTur?
    public var sonDegisme: Date?
    public var sonAcilma: Date?

    public init(yol: String, boyut: Int64, dizinMi: Bool = false, paketMi: Bool = false, ozelTur: OzelTur? = nil,
                sonDegisme: Date? = nil, sonAcilma: Date? = nil) {
        self.yol = yol
        self.boyut = boyut
        self.dizinMi = dizinMi
        self.paketMi = paketMi
        self.ozelTur = ozelTur
        self.sonDegisme = sonDegisme
        self.sonAcilma = sonAcilma
    }

    public var ad: String { Yol.ad(yol) }
}

/// Bağlam sinyalleri (dosya sisteminden önceden toplanır; motor bunlara bakarak karar verir).
public struct Sinyaller: Codable, Sendable, Hashable {
    /// Kurulum dosyasıyla eşleşen kurulu uygulamanın adı.
    public var kuruluUygulama: String?
    /// Arşivin yanında aynı adlı açılmış klasör var mı.
    public var acilmisHaliYaninda = false
    /// .blend1 gibi yedeğin asıl dosyası yanında mı.
    public var asilDosyaYaninda = false
    /// Eşitlenen bulut sağlayıcısı (iCloud Drive, Dropbox…).
    public var bulut: String?
    /// Git deposunda izlenen dosya/klasör mü.
    public var gitIzleniyor = false
    /// node_modules vb. için projenin son değişme tarihi.
    public var projeSonDegisme: Date?
    /// iOS yedeği için cihaz adı ve son yedek tarihi.
    public var cihazAdi: String?
    public var sonYedek: Date?
    /// Disk imajı şifreli mi (encrcdsa başlığı).
    public var sifreliImaj = false
    /// Aynı içerikte başka bir dosyanın yolu (ad + boyut + örneklenmiş içerik eşleşmesi).
    public var kopyaYolu: String?
    /// APFS klonlarıyla paylaşılan, bu öğe tek başına silinince boşalmayacak bayt.
    public var klonPaylasimi: Int64 = 0

    public init() {}
}

public enum Oneri: String, Codable, Sendable {
    case silinebilir
    case bakVeKararVer = "bak_ve_karar_ver"
    case sakla
    case dokunma

    public func etiket(_ dil: Dil) -> String {
        switch self {
        case .silinebilir: return Metin(.oneriSilinebilir)(dil)
        case .bakVeKararVer: return Metin(.oneriBakVeKararVer)(dil)
        case .sakla: return Metin(.oneriSakla)(dil)
        case .dokunma: return Metin(.oneriDokunma)(dil)
        }
    }
}

/// Açıklama motorunun çıktısı. Metinler dilden bağımsızdır; gösterilirken seçili dile çevrilir.
public struct Aciklama: Codable, Sendable, Hashable {
    public var tur: Metin
    public var risk: Risk
    public var neOlur: Metin
    public var geriNasil: Metin?
    public var oneri: Oneri
    public var oneriMetni: Metin?
    public var baglam: [Metin] = []

    public init(tur: Metin, risk: Risk, neOlur: Metin, geriNasil: Metin? = nil, oneri: Oneri, oneriMetni: Metin? = nil,
                baglam: [Metin] = []) {
        self.tur = tur; self.risk = risk; self.neOlur = neOlur; self.geriNasil = geriNasil
        self.oneri = oneri; self.oneriMetni = oneriMetni; self.baglam = baglam
    }
}

/// Kısaltma: argümansız ya da yazı argümanlı metin.
@inline(__always) func m(_ a: M, _ args: MetinArg...) -> Metin { Metin(a, dizi: args) }
@inline(__always) func y(_ s: String) -> MetinArg { .yazi(s) }

/// Çevrimdışı, kural tabanlı açıklama motoru. Saf fonksiyon: dosya sistemine dokunmaz, dilden bağımsız metin üretir.
public enum AciklamaMotoru {
    static let videolar: Set<String> = ["mov", "mp4", "m4v", "mkv", "avi", "webm", "mts", "m2ts", "3gp", "wmv", "flv", "mxf", "braw", "r3d"]
    static let fotograflar: Set<String> = ["heic", "heif", "jpg", "jpeg", "png", "tif", "tiff", "raw", "cr2", "cr3", "nef", "arw", "dng", "raf", "orf", "rw2", "psd", "psb", "exr", "kra"]
    static let sesler: Set<String> = ["wav", "aif", "aiff", "flac", "mp3", "m4a", "caf", "alac", "ogg", "opus"]
    static let arsivler: Set<String> = ["zip", "tar", "gz", "tgz", "bz2", "tbz", "xz", "txz", "rar", "7z", "zst"]
    static let sanalDiskler: Set<String> = ["vmdk", "qcow2", "vdi", "vhd", "vhdx", "utm", "pvm", "vmwarevm", "hdd"]
    static let veritabanlari: Set<String> = ["sqlite", "sqlite3", "db", "realm", "mdb", "accdb", "duckdb"]
    static let modeller: Set<String> = ["gguf", "ggml", "safetensors", "ckpt", "pt", "pth", "onnx", "mlmodel", "mlpackage", "bin"]
    static let belgeler: Set<String> = ["pdf", "pages", "numbers", "key", "docx", "xlsx", "pptx", "doc", "xls", "ppt", "indd", "ai", "sketch", "fig"]
    /// Dosya adı kalıpları (macOS'un Türkçe ve İngilizce adlandırması)
    static let ekranKaydiKaliplari = ["ekran kaydı", "screen recording", "cleanshot", "ekran videosu", "simulator screen recording"]

    public static func acikla(_ g: AdayGirdisi, _ s: Sinyaller, ev: String, simdi: Date = Date()) -> Aciklama {
        var a = temelKural(g, s, ev: ev)
        baglamEkle(&a, g, s, ev: ev, simdi: simdi)
        return a
    }

    // MARK: - Temel kurallar

    static func temelKural(_ g: AdayGirdisi, _ s: Sinyaller, ev: String) -> Aciklama {
        let ad = g.ad
        let adK = Yol.katla(ad)
        let u = Yol.uzanti(ad)

        // 1. Dokunma listesi — Bekçi ile aynı kurallar.
        if let neden = Koruma.neden(g.yol, ev: ev) {
            return dokunma(u: u, neden: neden)
        }

        // 2. Bilinen klasör türleri
        if let o = g.ozelTur { return ozelTurKurali(o, g, s) }

        // 3. Konum kuralları
        let goreli = Yol.altinda(g.yol, ev) ? String(g.yol.dropFirst(ev.count + 1)) : g.yol
        let bilesenler = goreli.split(separator: "/").map { Yol.katla(String($0)) }
        if goreli.hasPrefix(".cache/huggingface/") {
            return ozelTurKurali(.hfModeli, g, s)
        }
        let editorler = [".vscode", ".vscode-insiders", ".cursor", ".windsurf", ".antigravity", ".vscode-oss"]
        if bilesenler.count > 2, editorler.contains(bilesenler[0]), bilesenler[1] == "extensions" {
            return Aciklama(tur: m(.aEditorTur), risk: .dikkat,
                            neOlur: m(.aEditorNe, y(String(goreli.split(separator: "/")[2]))),
                            geriNasil: m(.aEditorGeri), oneri: .sakla, oneriMetni: m(.aEditorOneri))
        }

        // 4. Uzantı kuralları
        let gizliKlasorde = bilesenler.dropLast().contains { $0.hasPrefix(".") }
        if u == "dmg" || u == "sparseimage", s.sifreliImaj || (gizliKlasorde && u == "dmg") {
            return Aciklama(tur: s.sifreliImaj ? m(.aSifreliImajTur, y(u)) : m(.aDiskImajiTur, y(u)), risk: .riskli,
                            neOlur: s.sifreliImaj ? m(.aSifreliImajNe) : m(.aGizliDmgNe),
                            geriNasil: m(.aYedekYoksaGelmez), oneri: .sakla)
        }
        if ["dmg", "pkg", "mpkg", "xip"].contains(u) {
            let tur = u == "xip" ? m(.aXipTur) : m(.aKurulumTur, y(u))
            if let app = s.kuruluUygulama {
                return Aciklama(tur: tur, risk: .guvenli, neOlur: m(.aKurulumKuruluNe, y(app)),
                                geriNasil: m(.aKurulumKuruluGeri), oneri: .silinebilir)
            }
            return Aciklama(tur: tur, risk: .dikkat, neOlur: m(.aKurulumNe), geriNasil: m(.aKurulumGeri), oneri: .bakVeKararVer)
        }
        if u == "ipsw" {
            return Aciklama(tur: m(.aIpswTur), risk: .guvenli, neOlur: m(.aIpswNe), geriNasil: m(.aIpswGeri), oneri: .silinebilir)
        }
        if u == "iso" {
            return Aciklama(tur: m(.aIsoTur), risk: .dikkat, neOlur: m(.aIsoNe), geriNasil: m(.aIsoGeri), oneri: .bakVeKararVer)
        }
        if sanalDiskler.contains(u) {
            return Aciklama(tur: m(.aVmTur, y(u)), risk: .riskli, neOlur: m(.aVmNe), geriNasil: m(.aYedekYoksaGelmez),
                            oneri: .sakla, oneriMetni: m(.aVmOneri))
        }
        if u == "sparsebundle" || u == "sparseimage" {
            return Aciklama(tur: m(.aDiskImajiTur, y(u)), risk: .riskli, neOlur: m(.aSparseNe), geriNasil: m(.aYedekYoksaGelmez),
                            oneri: .sakla, oneriMetni: m(.aSparseOneri))
        }
        if u == "fcpbundle" {
            return Aciklama(tur: m(.aFcpTur), risk: .riskli, neOlur: m(.aFcpNe), geriNasil: m(.aYedekYoksaGelmez),
                            oneri: .sakla, oneriMetni: m(.aFcpOneri))
        }
        if u == "logicx" || u == "band" {
            return Aciklama(tur: u == "logicx" ? m(.aLogicTur) : m(.aBandTur), risk: .riskli, neOlur: m(.aMuzikProjeNe),
                            geriNasil: m(.aYedekYoksaGelmez), oneri: .sakla)
        }
        if u == "imovielibrary" || u == "theater" {
            return Aciklama(tur: m(.aImovieTur), risk: .riskli, neOlur: m(.aImovieNe), geriNasil: m(.aYedekYoksaGelmez), oneri: .sakla)
        }
        if u == "blend1" || u == "blend2" || u == "blend3" {
            if s.asilDosyaYaninda {
                return Aciklama(tur: m(.aBlendYedekTur, y(u)), risk: .guvenli, neOlur: m(.aBlendYedekVarNe), oneri: .silinebilir)
            }
            return Aciklama(tur: m(.aBlendYedekTur, y(u)), risk: .dikkat, neOlur: m(.aBlendYedekYokNe),
                            geriNasil: m(.aSilinirseGelmez), oneri: .bakVeKararVer)
        }
        if u == "blend" {
            return Aciklama(tur: m(.aBlendTur), risk: .riskli, neOlur: m(.aBlendNe), geriNasil: m(.aYedekYoksaGelmez), oneri: .sakla)
        }
        if veritabanlari.contains(u) {
            return Aciklama(tur: m(.aDbTur, y(u)), risk: .riskli, neOlur: m(.aDbNe), geriNasil: m(.aYedekYoksaGelmez), oneri: .sakla)
        }
        if modeller.contains(u) && (u != "bin" || g.boyut > 500_000_000) {
            return Aciklama(tur: m(.aModelTur, y(u)), risk: .dikkat, neOlur: m(.aModelNe), geriNasil: m(.aModelGeri),
                            oneri: .bakVeKararVer)
        }
        if videolar.contains(u) {
            if ekranKaydiKaliplari.contains(where: { adK.hasPrefix($0) || adK.contains($0) }) {
                return Aciklama(tur: m(.aEkranKaydiTur), risk: .dikkat, neOlur: m(.aEkranKaydiNe),
                                geriNasil: m(.aBaskaKopyaYoksa), oneri: .bakVeKararVer)
            }
            return Aciklama(tur: m(.aVideoTur, y(u)), risk: .riskli, neOlur: m(.aVideoNe), geriNasil: m(.aYalnizKopyaVarsa),
                            oneri: .bakVeKararVer, oneriMetni: m(.aVideoOneri))
        }
        if fotograflar.contains(u) {
            return Aciklama(tur: u == "psd" || u == "psb" ? m(.aPsdTur) : m(.aGorselTur, y(u)), risk: .riskli,
                            neOlur: m(.aGorselNe), geriNasil: m(.aYalnizKopyaVarsa), oneri: .bakVeKararVer)
        }
        if sesler.contains(u) {
            return Aciklama(tur: m(.aSesTur, y(u)), risk: .riskli, neOlur: m(.aSesNe), geriNasil: m(.aYalnizKopyaVarsa),
                            oneri: .bakVeKararVer)
        }
        if arsivler.contains(u) {
            if s.acilmisHaliYaninda {
                return Aciklama(tur: m(.aArsivTur, y(u)), risk: .guvenli, neOlur: m(.aArsivAcilmisNe),
                                geriNasil: m(.aArsivAcilmisGeri), oneri: .silinebilir, oneriMetni: m(.aArsivAcilmisOneri))
            }
            return Aciklama(tur: m(.aArsivTur, y(u)), risk: .dikkat, neOlur: m(.aArsivNe), geriNasil: m(.aArsivGeri),
                            oneri: .bakVeKararVer, oneriMetni: m(.aArsivOneri))
        }
        if u == "app" {
            return Aciklama(tur: m(.aAppTur), risk: .dikkat, neOlur: m(.aAppNe), geriNasil: m(.aAppGeri), oneri: .bakVeKararVer)
        }
        if u == "xcarchive" {
            return Aciklama(tur: m(.aXcarchiveTur), risk: .dikkat, neOlur: m(.aXcarchiveNe), geriNasil: m(.aXcarchiveGeri),
                            oneri: .bakVeKararVer)
        }
        if u == "log" || u == "trace" {
            return Aciklama(tur: m(.aLogTur, y(u)), risk: .guvenli, neOlur: m(.aLogNe), oneri: .silinebilir)
        }
        if ["dylib", "so", "a", "node"].contains(u) {
            return Aciklama(tur: m(.aKutuphaneTur, y(u)), risk: .dikkat, neOlur: m(.aKutuphaneNe), geriNasil: m(.aKutuphaneGeri),
                            oneri: .sakla, oneriMetni: m(.aKutuphaneOneri))
        }
        if belgeler.contains(u) {
            return Aciklama(tur: m(.aBelgeTur, y(u)), risk: .riskli, neOlur: m(.aBelgeNe), geriNasil: m(.aYalnizKopyaVarsa),
                            oneri: .bakVeKararVer)
        }

        // 5. Hiçbir kural tutmadı.
        let tur = g.dizinMi ? (g.paketMi ? m(.aPaketTur, y(u)) : m(.aKlasorTur))
                            : (u.isEmpty ? m(.aUzantisizTur) : m(.aBilinmeyenTur, y(u)))
        return Aciklama(tur: tur, risk: .dikkat, neOlur: m(.aBilinmeyenNe), oneri: .sakla, oneriMetni: m(.aBilinmeyenOneri))
    }

    static func dokunma(u: String, neden: Metin) -> Aciklama {
        switch u {
        case "photoslibrary", "photolibrary", "migratedphotolibrary":
            return Aciklama(tur: m(.aFotoKitTur), risk: .dokunma, neOlur: m(.aFotoKitNe), oneri: .dokunma, oneriMetni: m(.aFotoKitOneri))
        case "musiclibrary":
            return Aciklama(tur: m(.aMuzikKitTur), risk: .dokunma, neOlur: m(.aMuzikKitNe), oneri: .dokunma, oneriMetni: m(.aMuzikKitOneri))
        case "tvlibrary":
            return Aciklama(tur: m(.aTvKitTur), risk: .dokunma, neOlur: m(.aTvKitNe), oneri: .dokunma, oneriMetni: m(.aTvKitOneri))
        case "app":
            return Aciklama(tur: m(.aUygTur), risk: .dokunma, neOlur: m(.aUygKorunanNe), oneri: .dokunma, oneriMetni: m(.aUygKorunanOneri))
        default:
            return Aciklama(tur: m(.aKorunanTur), risk: .dokunma, neOlur: .birles([neden, m(.aFerahSilmez)]), oneri: .dokunma)
        }
    }

    static func ozelTurKurali(_ o: OzelTur, _ g: AdayGirdisi, _ s: Sinyaller) -> Aciklama {
        switch o {
        case .nodeModules:
            return Aciklama(tur: m(.aNodeTur), risk: .guvenli, neOlur: m(.aNodeNe), geriNasil: m(.aNodeGeri), oneri: .silinebilir)
        case .sanalOrtam:
            return Aciklama(tur: m(.aVenvTur), risk: .guvenli, neOlur: m(.aVenvNe), geriNasil: m(.aVenvGeri), oneri: .silinebilir)
        case .pods:
            return Aciklama(tur: m(.aPodsTur), risk: .guvenli, neOlur: m(.aPodsNe), geriNasil: m(.aPodsGeri), oneri: .silinebilir)
        case .derlemeCiktisi:
            return Aciklama(tur: m(.aDerlemeTur, y(g.ad)), risk: .guvenli, neOlur: m(.aDerlemeNe), geriNasil: m(.aDerlemeGeri),
                            oneri: .silinebilir)
        case .iosYedegi:
            return Aciklama(tur: m(.aIosYedekTur), risk: .riskli,
                            neOlur: s.cihazAdi.map { m(.aIosYedekCihazNe, y($0)) } ?? m(.aIosYedekNe),
                            geriNasil: m(.aIosYedekGeri), oneri: .bakVeKararVer, oneriMetni: m(.aIosYedekOneri))
        case .dockerRaw:
            return Aciklama(tur: m(.aDockerTur), risk: .riskli, neOlur: m(.aDockerNe), geriNasil: m(.aDockerGeri),
                            oneri: .sakla, oneriMetni: m(.aDockerOneri))
        case .hfModeli:
            return Aciklama(tur: m(.aHfTur), risk: .guvenli, neOlur: m(.aHfNe), geriNasil: m(.aHfGeri), oneri: .silinebilir)
        case .ollamaModelleri:
            return Aciklama(tur: m(.aOllamaTur), risk: .dikkat, neOlur: m(.aOllamaNe), geriNasil: m(.aOllamaGeri),
                            oneri: .bakVeKararVer, oneriMetni: m(.aOllamaOneri))
        case .steamOyunu:
            return Aciklama(tur: m(.aSteamTur), risk: .dikkat, neOlur: m(.aSteamNe), geriNasil: m(.aSteamGeri),
                            oneri: .bakVeKararVer, oneriMetni: m(.aSteamOneri))
        }
    }

    // MARK: - Bağlam

    static func yukselt(_ a: inout Aciklama, _ r: Risk) {
        if a.risk < r {
            a.risk = r
            if a.oneri == .silinebilir { a.oneri = .bakVeKararVer }
        }
    }

    static let onbellekAdlari: Set<String> = ["cache", "caches", ".cache", "cachedata", "cachestorage", "gpucache"]

    static func baglamEkle(_ a: inout Aciklama, _ g: AdayGirdisi, _ s: Sinyaller, ev: String, simdi: Date) {
        guard a.risk != .dokunma else { return }
        let ozelDegil = g.ozelTur == nil
        // Bir uygulamanın önbellek klasöründeki kişisel görünümlü dosya: büyük olasılıkla türetilmiş kopya.
        if ozelDegil, a.risk == .riskli, Yol.altinda(g.yol, ev) {
            let bilesenler = g.yol.dropFirst(ev.count + 1).split(separator: "/").dropLast().map { Yol.katla(String($0)) }
            if bilesenler.contains(where: { onbellekAdlari.contains($0) }) {
                a.risk = .dikkat
                a.baglam.append(m(.aBglOnbellek))
            }
        }
        if s.klonPaylasimi > 0 {
            a.baglam.append(m(.aBglKlon, .bayt(s.klonPaylasimi)))
        }
        if ozelDegil, let k = s.kopyaYolu, !g.dizinMi {
            a.baglam.append(m(.aBglKopya, y(Yol.kisa(k, ev: ev))))
            if a.risk == .riskli { a.risk = .dikkat }
        }
        if let b = s.bulut {
            a.baglam.append(m(.aBglBulut, y(b)))
            yukselt(&a, .dikkat)
        }
        if s.gitIzleniyor {
            a.baglam.append(m(.aBglGit))
            yukselt(&a, .dikkat)
        }
        if let p = s.projeSonDegisme, Bicim.sureSayisi(p, simdi: simdi) != nil {
            a.baglam.append(m(.aBglProje, .sure(p, simdi)))
        }
        if g.ozelTur == .iosYedegi, let yd = s.sonYedek {
            a.baglam.append(m(.aBglSonYedek, .goreli(yd, simdi)))
        }
        let birYil: TimeInterval = 365 * 86_400
        if let ac = g.sonAcilma {
            if simdi.timeIntervalSince(ac) > birYil {
                a.baglam.append(m(.aBglAcilmamis, .goreli(ac, simdi)))
            }
        } else if let d = g.sonDegisme, simdi.timeIntervalSince(d) > birYil, g.ozelTur == nil {
            a.baglam.append(m(.aBglDegismemis, .goreli(d, simdi)))
        }
    }
}
