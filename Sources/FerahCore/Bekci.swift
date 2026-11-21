import Foundation
import Darwin

/// Hangi işlem için izin isteniyor.
public enum Islem: Sendable {
    /// Adım 1: kalıcı silme. Yol, verilen beyaz liste köklerinden birinin KESİNLİKLE altında olmalı.
    case kaliciSil(kokler: [String])
    /// Adım 2: Çöp Kutusu'na taşıma.
    case copeTasi
    /// Adım 3: bir uygulama paketini Çöp Kutusu'na taşıma. Ev dizini dışına (yalnız izinli
    /// uygulama köklerine) çıkabilen TEK işlem; kuralları çok daha dardır.
    case uygulamaCopeTasi
}

public struct BekciHatasi: Error, CustomStringConvertible, Sendable {
    public let neden: Metin
    public init(neden: Metin) { self.neden = neden }
    public init(_ a: M, _ args: MetinArg...) { self.neden = Metin(a, dizi: args) }
    public var description: String { neden(.tr) }
}

/// "Dokunma" listesi. Saf fonksiyon: dosya sistemine bakmaz, yalnız yolu değerlendirir.
public enum Koruma {
    /// Ev dizininin birinci düzeyindeki standart klasörler (kendileri silinemez, içleri değerlendirilir).
    public static let standartKlasorler = [
        "Desktop", "Documents", "Downloads", "Library", "Pictures", "Movies", "Music",
        "Public", "Applications", "Sites", ".Trash",
    ]

    /// Kendisi ve altındaki her şey korunur. Ayrıca bunlardan birini içeren bir üst klasör de silinemez.
    static let altAgaclar = [
        "Library/Keychains", "Library/Mail", "Library/Messages", "Library/Safari",
        "Library/Preferences", "Library/Accounts", "Library/Cookies", "Library/Calendars",
        "Library/Application Support/AddressBook", "Library/Application Support/com.apple.TCC",
        "Library/Containers/com.apple.mail", "Library/Group Containers",
        ".ssh", ".gnupg",
    ]

    /// Yalnız kendisi korunur (içindeki tek tek öğeler değerlendirilebilir).
    static let yalnizKendisi = [
        "Library/Mobile Documents", "Library/Mobile Documents/com~apple~CloudDocs",
        "Library/CloudStorage", "Library/Caches", "Library/Logs", "Library/Application Support",
        "Library/Containers", "Library/Developer", "Library/Application Support/MobileSync",
        "Library/Application Support/MobileSync/Backup",
        "Music/Music", "Music/iTunes", "Movies/TV", "Pictures/Photo Booth Library",
    ]

    static let uzantilar: Set<String> = [
        "photoslibrary", "musiclibrary", "tvlibrary", "photolibrary", "migratedphotolibrary",
        "aplibrary", "keychain", "keychain-db",
    ]

    /// Korunuyorsa nedenini döndürür. `kanonik` normalize edilmiş mutlak yol olmalı.
    public static func neden(_ kanonik: String, ev: String) -> Metin? {
        let k = Yol.katla(kanonik)
        let e = Yol.katla(ev)
        if k == e { return m(.bEvKendisi) }
        if Yol.altinda(ev, kanonik) { return m(.bEvUstu) }

        let ebeveyn = Yol.ebeveyn(kanonik)
        let ad = Yol.ad(kanonik)
        if Yol.katla(ebeveyn) == e, standartKlasorler.contains(where: { Yol.katla($0) == Yol.katla(ad) }) {
            return m(.bStandart, y(ad))
        }
        for r in yalnizKendisi where k == Yol.katla(Yol.ekle(ev, r)) {
            return m(.bKokKlasor, y(r))
        }
        for r in altAgaclar {
            let p = Yol.ekle(ev, r)
            if Yol.esitVeyaAltinda(kanonik, p) { return m(.bKorunanVeri, y(r)) }
            if Yol.altinda(p, kanonik) { return m(.bIcindeKorunan, y(r)) }
        }
        let bilesenler = kanonik.split(separator: "/").map(String.init)
        for b in bilesenler {
            let u = Yol.uzanti(b)
            if uzantilar.contains(u) {
                switch u {
                case "photoslibrary", "photolibrary", "migratedphotolibrary", "aplibrary":
                    return m(.bFotoKit)
                case "musiclibrary": return m(.bMuzikKit)
                case "tvlibrary": return m(.bTvKit)
                default: return m(.bAnahtarZinciri)
                }
            }
        }
        if Yol.altinda(kanonik, Yol.ekle(ev, "Applications")), bilesenler.contains(where: { Yol.uzanti($0) == "app" }) {
            return m(.bAppKlasoru)
        }
        return nil
    }
}

/// Tüm silme ve taşımaların geçtiği güvenlik bekçisi.
public final class Bekci: @unchecked Sendable {
    /// İzinli kök (gerçek kullanımda ev dizini; sınamada enjekte edilen sahte ev).
    public let ev: String
    /// `.uygulamaCopeTasi` için izinli kökler (varsayılan /Applications ve ~/Applications).
    public let uygulamaKokleri: [String]
    /// Çalışan uygulamaların paket kimlikleri (küçük harf). Arayüz NSWorkspace'ten verir.
    let calisanKimlikler: () -> Set<String>
    /// Çalışan Ferah'ın kendi paketi.
    let kendiPaketi: String?

    public init(ev: String = NSHomeDirectory(), uygulamaKokleri: [String]? = nil,
                calisanKimlikler: @escaping () -> Set<String> = { [] },
                kendiPaketi: String? = Bundle.main.bundlePath) {
        let e = Yol.gercek(ev) ?? Yol.sozcukselNormalle(ev) ?? ev
        self.ev = e
        self.uygulamaKokleri = (uygulamaKokleri ?? ["/Applications", Yol.ekle(e, "Applications")]).compactMap { Yol.gercek($0) }
        self.calisanKimlikler = calisanKimlikler
        self.kendiPaketi = kendiPaketi.flatMap { Yol.gercek($0) }
    }

    /// Paket kimliği (Contents/Info.plist → CFBundleIdentifier).
    public static func paketKimligi(_ app: String) -> String? {
        NSDictionary(contentsOfFile: Yol.ekle(app, "Contents/Info.plist"))?["CFBundleIdentifier"] as? String
    }

    /// Uygulama paketleri için dar kural kümesi.
    func uygulamaDenetle(_ k: String) -> Result<String, BekciHatasi> {
        func red(_ a: M) -> Result<String, BekciHatasi> { .failure(BekciHatasi(a)) }
        var st = stat()
        guard lstat(k, &st) == 0 else { return red(.bYolYok) }
        if (st.st_mode & S_IFMT) == S_IFLNK { return red(.bSembolikApp) }
        guard (st.st_mode & S_IFMT) == S_IFDIR, Yol.uzanti(k) == "app" else { return red(.bAppDegil) }
        if uygulamaKokleri.contains(where: { Yol.katla($0) == Yol.katla(k) }) { return red(.bAppKoku) }
        let ebeveyn = Yol.ebeveyn(k)
        let dogrudan = uygulamaKokleri.contains { Yol.katla($0) == Yol.katla(ebeveyn) }
        let birAltta = Yol.uzanti(ebeveyn) != "app"
            && uygulamaKokleri.contains { Yol.katla($0) == Yol.katla(Yol.ebeveyn(ebeveyn)) }
        guard dogrudan || birAltta else { return red(.bAppKokDisi) }
        guard let kimlik = Bekci.paketKimligi(k) else { return red(.bInfoPlistYok) }
        let kk = kimlik.lowercased()
        if kk.hasPrefix("com.apple.") { return red(.bApple) }
        if calisanKimlikler().contains(kk) { return red(.bCalisiyor) }
        if let kendi = kendiPaketi, Yol.esitVeyaAltinda(kendi, k) { return red(.bKendisi) }
        return .success(k)
    }

    /// Yolu normalize eder: `..` sözcüksel çözülür, üst klasörün sembolik bağları realpath ile çözülür,
    /// SON bileşen çözülmez (sembolik bağsa bağın kendisi hedeflenir, hedefi değil).
    public func kanonik(_ yol: String) -> Result<String, BekciHatasi> {
        if yol.isEmpty { return .failure(BekciHatasi(.bBosYol)) }
        if yol.contains("\0") { return .failure(BekciHatasi(.bNul)) }
        guard yol.hasPrefix("/") else { return .failure(BekciHatasi(.bGoreli)) }
        guard let soz = Yol.sozcukselNormalle(yol), soz != "/" else {
            return .failure(BekciHatasi(.bKokDizin))
        }
        let son = Yol.ad(soz)
        if son.isEmpty || son == "." || son == ".." { return .failure(BekciHatasi(.bSonBilesen)) }
        guard let gercekEbeveyn = Yol.gercek(Yol.ebeveyn(soz)) else {
            return .failure(BekciHatasi(.bUstYok))
        }
        return .success(Yol.ekle(gercekEbeveyn, son))
    }

    /// Tek denetim noktası. Başarılıysa üzerinde işlem yapılacak kanonik yolu döndürür.
    public func denetle(_ yol: String, _ islem: Islem) -> Result<String, BekciHatasi> {
        let k: String
        switch kanonik(yol) {
        case .failure(let h): return .failure(h)
        case .success(let s): k = s
        }
        if case .uygulamaCopeTasi = islem { return uygulamaDenetle(k) }
        var st = stat()
        guard lstat(k, &st) == 0 else { return .failure(BekciHatasi(.bYolYok)) }
        guard Yol.altinda(k, ev) else { return .failure(BekciHatasi(.bEvDisi)) }
        if let n = Koruma.neden(k, ev: ev) { return .failure(BekciHatasi(neden: n)) }

        switch islem {
        case .copeTasi, .uygulamaCopeTasi:
            break
        case .kaliciSil(let kokler):
            let gercekKokler = kokler.compactMap { Yol.gercek($0) }.filter { Yol.altinda($0, ev) }
            if gercekKokler.isEmpty { return .failure(BekciHatasi(.bKokYok)) }
            guard gercekKokler.contains(where: { Yol.altinda(k, $0) }) else {
                return .failure(BekciHatasi(.bKategoriDisi))
            }
        }
        return .success(k)
    }
}
