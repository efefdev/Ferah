import Foundation
import Darwin

public struct BuyukAday: Codable, Identifiable, Hashable, Sendable {
    public var id: String { girdi.yol }
    public let girdi: AdayGirdisi
    public let sinyaller: Sinyaller
    public let aciklama: Aciklama
    /// Daha önce "Sakla" denmiş.
    public var saklandi: Bool

    public var yol: String { girdi.yol }
    public var ad: String { girdi.ad }
    public var boyut: Int64 { girdi.boyut }
    public var silinebilir: Bool { aciklama.risk != .dokunma }
}

public struct BuyukTaramaAyari: Sendable {
    public var ev: String
    public var esik: Int64
    public var saklananlar: Set<String>
    public var kuruluUygulamalar: [String]
    public var simdi: Date

    public init(ev: String = NSHomeDirectory(), esik: Int64 = 100 * 1_000_000, saklananlar: Set<String> = [],
                kuruluUygulamalar: [String]? = nil, simdi: Date = Date()) {
        let e = Yol.gercek(ev) ?? ev
        self.ev = e
        self.esik = esik
        self.saklananlar = saklananlar
        self.kuruluUygulamalar = kuruluUygulamalar ?? SinyalToplayici.kuruluUygulamalar(ev: e)
        self.simdi = simdi
    }
}

/// Ev dizinindeki büyük dosyaları ve büyük/yeniden üretilebilir klasörleri bulur. Salt okunur.
public final class BuyukTarayici {
    /// İçine girilmeyen, tek öğe sayılan paket uzantıları.
    public static let paketUzantilari: Set<String> = [
        "app", "photoslibrary", "musiclibrary", "tvlibrary", "photolibrary", "migratedphotolibrary", "aplibrary",
        "fcpbundle", "logicx", "band", "imovielibrary", "theater", "sparsebundle", "bundle", "framework",
        "xcarchive", "pvm", "utm", "vmwarevm", "rtfd", "pages", "numbers", "key", "playground", "xcodeproj",
        "xcworkspace", "lrlibrary", "lrdata", "dsym", "docarchive", "plugin", "kext", "appex", "mlpackage",
        "photoboothlibrary", "abbu", "backupdb", "musicx", "component", "vst", "vst3", "aaxplugin", "prefpane",
    ]
    static let projeDosyalari = [
        "package.json", "Cargo.toml", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "Makefile",
        "CMakeLists.txt", "setup.py", "pyproject.toml", "Package.swift", "go.mod", "tsconfig.json", "next.config.js",
        "next.config.mjs", "next.config.ts", "vite.config.js", "vite.config.ts", "angular.json", "composer.json",
        "Gemfile", "mix.exs", "build.zig",
    ]

    let ayar: BuyukTaramaAyari
    let ev: String
    let inodlar = InodeKumesi()
    let iptal: () -> Bool
    let ilerleme: (Int, String) -> Void
    let bulundu: (BuyukAday) -> Void
    var adaylar: [BuyukAday] = []
    var sayac = 0
    var durduruldu = false

    init(_ ayar: BuyukTaramaAyari, iptal: @escaping () -> Bool, ilerleme: @escaping (Int, String) -> Void,
         bulundu: @escaping (BuyukAday) -> Void) {
        self.ayar = ayar
        self.ev = ayar.ev
        self.iptal = iptal
        self.ilerleme = ilerleme
        self.bulundu = bulundu
    }

    /// Taramayı yapar (çağıran iş parçacığında, bloklayarak) ve sıralı listeyi döndürür.
    public static func tara(_ ayar: BuyukTaramaAyari, iptal: @escaping () -> Bool = { false },
                            ilerleme: @escaping (Int, String) -> Void = { _, _ in },
                            bulundu: @escaping (BuyukAday) -> Void = { _ in }) -> [BuyukAday] {
        let t = BuyukTarayici(ayar, iptal: iptal, ilerleme: ilerleme, bulundu: bulundu)
        t.calistir()
        return sirala(t.adaylar)
    }

    /// Önce sıradakiler boyuta göre; "Dokunma" ve daha önce saklananlar sona.
    public static func sirala(_ l: [BuyukAday]) -> [BuyukAday] {
        l.sorted { a, b in
            if a.saklandi != b.saklandi { return !a.saklandi }
            let ad = a.aciklama.risk == .dokunma, bd = b.aciklama.risk == .dokunma
            if ad != bd { return !ad }
            return a.boyut > b.boyut
        }
    }

    func calistir() {
        gez(ev, evKoku: true)
        let lib = Yol.ekle(ev, "Library")
        // ~/Library içinde yalnız bilinen büyük adaylar
        let yedekler = Yol.ekle(lib, "Application Support/MobileSync/Backup")
        if let l = try? FileManager.default.contentsOfDirectory(atPath: yedekler) {
            for y in l where !durduruldu { birim(Yol.ekle(yedekler, y), paket: false, ozel: .iosYedegi) }
        }
        for d in ["Containers/com.docker.docker/Data/vms/0/data/Docker.raw", "Containers/com.docker.docker/Data/vms/0/Docker.raw"] {
            let p = Yol.ekle(lib, d)
            if Yol.varMi(p) { birim(p, paket: false, ozel: .dockerRaw) }
        }
        let steam = Yol.ekle(lib, "Application Support/Steam/steamapps/common")
        if let l = try? FileManager.default.contentsOfDirectory(atPath: steam) {
            for o in l where !durduruldu { birim(Yol.ekle(steam, o), paket: false, ozel: .steamOyunu) }
        }
        // Eşitlenen bulut klasörleri (yalnız yerelde duran dosyalar aday olur)
        let icloud = Yol.ekle(lib, "Mobile Documents/com~apple~CloudDocs")
        if !durduruldu, Yol.dizinMi(icloud) { gez(icloud, evKoku: false) }
        let bulut = Yol.ekle(lib, "CloudStorage")
        if let l = try? FileManager.default.contentsOfDirectory(atPath: bulut) {
            for b in l where !durduruldu {
                let p = Yol.ekle(bulut, b)
                if Yol.dizinMi(p) { gez(p, evKoku: false) }
            }
        }
        if !durduruldu { kopyalariBul() }
    }

    /// Aynı ad uzantısı ve mantıksal boyuttaki dosya adaylarını örnekleyerek karşılaştırır;
    /// eşleşenlerin açıklamasına "bir kopyası daha var" bağlamı eklenir.
    func kopyalariBul() {
        var gruplar: [String: [Int]] = [:]
        for (i, c) in adaylar.enumerated() where !c.girdi.dizinMi && c.aciklama.risk != .dokunma {
            var st = stat()
            guard lstat(c.yol, &st) == 0 else { continue }
            gruplar["\(st.st_size).\(Yol.uzanti(c.ad))", default: []].append(i)
        }
        for (_, l) in gruplar where l.count > 1 {
            for i in l where adaylar[i].sinyaller.kopyaYolu == nil {
                for j in l where j != i {
                    if SinyalToplayici.ayniIcerikMi(adaylar[i].yol, adaylar[j].yol) {
                        var s = adaylar[i].sinyaller
                        s.kopyaYolu = adaylar[j].yol
                        let a = AciklamaMotoru.acikla(adaylar[i].girdi, s, ev: ev, simdi: ayar.simdi)
                        adaylar[i] = BuyukAday(girdi: adaylar[i].girdi, sinyaller: s, aciklama: a, saklandi: adaylar[i].saklandi)
                        break
                    }
                }
            }
        }
    }

    func ozelTurBul(_ yol: String, ad: String) -> OzelTur? {
        let ebeveyn = Yol.ebeveyn(yol)
        switch ad {
        case "node_modules":
            return .nodeModules
        case ".venv", "venv", "env", ".env":
            return Yol.varMi(Yol.ekle(yol, "pyvenv.cfg")) ? .sanalOrtam : nil
        case "Pods":
            return Yol.varMi(Yol.ekle(ebeveyn, "Podfile")) ? .pods : nil
        case "build", "dist", ".next", "target":
            return projeMi(ebeveyn) ? .derlemeCiktisi : nil
        default:
            break
        }
        // Adı ne olursa olsun pyvenv.cfg içeren klasör bir Python sanal ortamıdır.
        if Yol.varMi(Yol.ekle(yol, "pyvenv.cfg")) { return .sanalOrtam }
        if Yol.katla(yol) == Yol.katla(Yol.ekle(ev, ".ollama/models")) { return .ollamaModelleri }
        if Yol.katla(ebeveyn) == Yol.katla(Yol.ekle(ev, ".cache/huggingface/hub")),
           ad.hasPrefix("models--") || ad.hasPrefix("datasets--") {
            return .hfModeli
        }
        return nil
    }

    static let projeIzleri = [
        ".git", "src", "app", "pages", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock",
        "Cargo.lock", "go.sum", "poetry.lock", "uv.lock", "Gemfile.lock", "composer.lock", "requirements.txt",
    ]

    /// Derleme çıktısı sayılabilmesi için: bir proje dosyası VE bir geliştirme izi (kilit dosyası, src, .git…) olmalı,
    /// ayrıca editör eklentisi ya da paket klasörü içinde olmamalı (oradaki dist eklentinin kendisidir).
    func projeMi(_ d: String) -> Bool {
        let goreli = Yol.altinda(d, ev) ? String(d.dropFirst(ev.count + 1)) : d
        let b = goreli.split(separator: "/").map { Yol.katla(String($0)) }
        if b.contains("node_modules") || b.contains("site-packages") { return false }
        if b.count >= 2, b[0].hasPrefix("."), b[1] == "extensions" { return false }
        guard projeDosyasiVar(d) else { return false }
        if BuyukTarayici.projeIzleri.contains(where: { Yol.varMi(Yol.ekle(d, $0)) }) { return true }
        if let l = try? FileManager.default.contentsOfDirectory(atPath: d) {
            return l.contains { $0.hasSuffix(".xcodeproj") }
        }
        return false
    }

    func projeDosyasiVar(_ d: String) -> Bool {
        if BuyukTarayici.projeDosyalari.contains(where: { Yol.varMi(Yol.ekle(d, $0)) }) { return true }
        if let l = try? FileManager.default.contentsOfDirectory(atPath: d) {
            return l.contains { $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".sln") || $0.hasSuffix(".csproj") }
        }
        return false
    }

    func gez(_ kok: String, evKoku: Bool) {
        let lib = Yol.ekle(ev, "Library")
        let cop = Yol.ekle(ev, ".Trash")
        Gezgin.gez(kok) { g in
            sayac += 1
            if sayac % 4096 == 0 {
                if iptal() { durduruldu = true; return .dur }
                ilerleme(sayac, g.yol)
            }
            switch g.tur {
            case .dizin:
                if g.seviye == 0 { return .devam }
                guard let st = g.st else { return .atla }
                if st.st_flags & dosyaVerisizBayragi != 0 { return .atla }
                let yol = g.yol
                if evKoku && g.seviye == 1 && (yol == lib || yol == cop) { return .atla }
                let ad = Yol.ad(yol)
                if ad == ".git" { return .atla }
                let u = Yol.uzanti(ad)
                if BuyukTarayici.paketUzantilari.contains(u) {
                    birim(yol, paket: true, ozel: nil)
                    return .atla
                }
                if let o = ozelTurBul(yol, ad: ad) {
                    birim(yol, paket: false, ozel: o)
                    return .atla
                }
                return .devam
            case .dosya:
                guard let st = g.st else { return .devam }
                let b = Int64(st.st_blocks) * 512
                guard b >= ayar.esik else { return .devam }
                if st.st_flags & dosyaVerisizBayragi != 0 { return .devam }
                if st.st_nlink > 1, !inodlar.ekle(dev: st.st_dev, ino: st.st_ino) { return .devam }
                // Aday eşiği ayrılmış boyuta göre; gösterilen boyut silinince gerçekten açılacak yer (APFS klonu farkında).
                let kazanc = Olcer.dosyaKazanci(g.yol)
                aday(g.yol, boyut: kazanc, paylasilan: b - kazanc, dizin: false, paket: false, ozel: nil, st: st)
                return .devam
            default:
                return .devam
            }
        }
    }

    func birim(_ yol: String, paket: Bool, ozel: OzelTur?) {
        var st = stat()
        guard lstat(yol, &st) == 0 else { return }
        if st.st_flags & dosyaVerisizBayragi != 0 { return }
        let dizin = (st.st_mode & S_IFMT) == S_IFDIR
        let o: Olcum
        if dizin {
            o = Olcer.olc(yol, inodlar: inodlar, iptal: iptal)
        } else {
            var t = Olcum()
            let b = Olcer.ayrilmis(st, inodlar)
            t.bayt = b > 0 ? Olcer.dosyaKazanci(yol) : 0
            t.paylasilan = b - t.bayt
            o = t
        }
        guard o.bayt + o.paylasilan >= ayar.esik else { return }
        aday(yol, boyut: o.bayt, paylasilan: o.paylasilan, dizin: dizin, paket: paket, ozel: ozel, st: st)
    }

    func aday(_ yol: String, boyut: Int64, paylasilan: Int64 = 0, dizin: Bool, paket: Bool, ozel: OzelTur?, st: stat) {
        let degisme = Date(timeIntervalSince1970: TimeInterval(st.st_mtimespec.tv_sec))
        let g = AdayGirdisi(yol: yol, boyut: boyut, dizinMi: dizin, paketMi: paket, ozelTur: ozel,
                            sonDegisme: degisme, sonAcilma: SinyalToplayici.sonKullanilma(yol))
        var s = SinyalToplayici.topla(g, ev: ev, kurulu: ayar.kuruluUygulamalar)
        s.klonPaylasimi = max(0, paylasilan)
        let a = AciklamaMotoru.acikla(g, s, ev: ev, simdi: ayar.simdi)
        let c = BuyukAday(girdi: g, sinyaller: s, aciklama: a, saklandi: ayar.saklananlar.contains(yol))
        adaylar.append(c)
        bulundu(c)
    }
}
