import Foundation

// MARK: - Risk

public enum Risk: String, Codable, Sendable, CaseIterable, Comparable {
    case guvenli, dikkat, riskli, dokunma

    var derece: Int {
        switch self {
        case .guvenli: return 0
        case .dikkat: return 1
        case .riskli: return 2
        case .dokunma: return 3
        }
    }

    public static func < (a: Risk, b: Risk) -> Bool { a.derece < b.derece }
}

// MARK: - Biçimlendirme (dile duyarlı)

public enum Bicim {
    /// Boyut: ByteCountFormatter'ın "dosya" (ondalık, 1000) biçimiyle aynı kurallar — KB'de tam sayı, MB'de 1,
    /// GB/TB'de 2 ondalık, sondaki sıfırlar atılır, yuvarlanınca bir üst birime geçilir, 1 KB altı "1 KB", sıfır "0 KB" —
    /// ama ondalık ayıraç seçili dile göre (1,5 GB / 1.5 GB). ByteCountFormatter yerel seçtirmediği için elle yapılır.
    public static func bayt(_ b: Int64, _ dil: Dil) -> String {
        let birimler: [(String, Int64, Int)] = [("KB", 1_000, 0), ("MB", 1_000_000, 1), ("GB", 1_000_000_000, 2),
                                                 ("TB", 1_000_000_000_000, 2)]
        if b <= 0 { return "0 KB" }
        // Ondalık (Decimal) hesap: 1.005 gibi değerlerde ikili kayan nokta yuvarlama hatası olmasın.
        func yuvarla(_ i: Int) -> Decimal {
            var d = Decimal(b) / Decimal(birimler[i].1)
            var sonuc = Decimal()
            NSDecimalRound(&sonuc, &d, birimler[i].2, .plain)
            return sonuc
        }
        var i = 0
        while i + 1 < birimler.count && b >= birimler[i + 1].1 { i += 1 }
        var deger = yuvarla(i)
        if deger >= 1000 && i + 1 < birimler.count {
            i += 1
            deger = yuvarla(i)
        }
        let f = NumberFormatter()
        f.locale = dil.yerel
        f.numberStyle = .decimal
        f.usesGroupingSeparator = false
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = birimler[i].2
        return "\(f.string(from: deger as NSDecimalNumber) ?? "\(deger)") \(birimler[i].0)"
    }

    public static func sayi(_ n: Int, _ dil: Dil) -> String {
        n.formatted(.number.locale(dil.yerel))
    }

    /// "3 gün önce" / "3 days ago"
    public static func goreli(_ d: Date, simdi: Date = Date(), _ dil: Dil) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = dil.yerel
        f.unitsStyle = .full
        return f.localizedString(for: d, relativeTo: simdi)
    }

    enum SureBirimi { case gun, hafta, ay, yil }

    /// Bir tarihten bu yana geçen süre (sayı, birim); bir günden kısaysa nil.
    static func sureSayisi(_ d: Date, simdi: Date) -> (Int, SureBirimi)? {
        let gun = Int(simdi.timeIntervalSince(d) / 86_400)
        if gun < 1 { return nil }
        if gun < 14 { return (gun, .gun) }
        if gun < 60 { return (gun / 7, .hafta) }
        if gun < 365 { return (gun / 30, .ay) }
        return (gun / 365, .yil)
    }

    /// "8 aydır" / "8 months"; bir günden kısaysa nil.
    public static func sure(_ d: Date, simdi: Date = Date(), _ dil: Dil) -> String? {
        guard let (n, birim) = sureSayisi(d, simdi: simdi) else { return nil }
        let a: M
        switch birim {
        case .gun: a = .sureGun
        case .hafta: a = .sureHafta
        case .ay: a = .sureAy
        case .yil: a = .sureYil
        }
        return Metin(a, .sayi(n))(dil)
    }

    public static func tarih(_ d: Date, _ dil: Dil) -> String {
        let f = DateFormatter()
        f.locale = dil.yerel
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: d)
    }
}

// MARK: - Yol yardımcıları

public enum Yol {
    /// Karşılaştırma için: Unicode birleşik biçim + küçük harf (APFS büyük/küçük harfe duyarsızdır).
    public static func katla(_ s: String) -> String {
        s.precomposedStringWithCanonicalMapping.lowercased()
    }

    /// Yalnız mutlak yollar. `.` ve `..` bileşenlerini sözcüksel olarak çözer, boş bileşenleri atar.
    public static func sozcukselNormalle(_ p: String) -> String? {
        guard p.hasPrefix("/") else { return nil }
        var parcalar: [Substring] = []
        for c in p.split(separator: "/", omittingEmptySubsequences: true) {
            if c == "." { continue }
            if c == ".." {
                if !parcalar.isEmpty { parcalar.removeLast() }
                continue
            }
            parcalar.append(c)
        }
        return "/" + parcalar.joined(separator: "/")
    }

    /// realpath(3): tüm sembolik bağları çözer. Yol yoksa nil.
    public static func gercek(_ p: String) -> String? {
        guard let r = realpath(p, nil) else { return nil }
        defer { free(r) }
        return String(cString: r)
    }

    /// p, kok'un kesinlikle altında mı (eşit değil).
    public static func altinda(_ p: String, _ kok: String) -> Bool {
        let a = katla(p)
        var k = katla(kok)
        if !k.hasSuffix("/") { k += "/" }
        return a.hasPrefix(k) && a.count > k.count
    }

    public static func esitVeyaAltinda(_ p: String, _ kok: String) -> Bool {
        katla(p) == katla(kok) || altinda(p, kok)
    }

    public static func ekle(_ a: String, _ b: String) -> String {
        a.hasSuffix("/") ? a + b : a + "/" + b
    }

    public static func ad(_ p: String) -> String { (p as NSString).lastPathComponent }
    public static func ebeveyn(_ p: String) -> String { (p as NSString).deletingLastPathComponent }
    public static func uzanti(_ p: String) -> String { (p as NSString).pathExtension.lowercased() }

    public static func varMi(_ p: String) -> Bool {
        var st = stat()
        return lstat(p, &st) == 0
    }

    public static func dizinMi(_ p: String) -> Bool {
        var st = stat()
        return lstat(p, &st) == 0 && (st.st_mode & S_IFMT) == S_IFDIR
    }

    public static func bagMi(_ p: String) -> Bool {
        var st = stat()
        return lstat(p, &st) == 0 && (st.st_mode & S_IFMT) == S_IFLNK
    }

    /// Ev dizinine göre kısaltılmış gösterim (~/…).
    public static func kisa(_ p: String, ev: String) -> String {
        if p == ev { return "~" }
        if altinda(p, ev) { return "~" + p.dropFirst(ev.count) }
        return p
    }
}

// MARK: - Disk

public struct DiskBilgisi: Codable, Sendable, Equatable {
    public var toplam: Int64
    public var bos: Int64
    public var kullanilan: Int64 { max(0, toplam - bos) }

    public init(toplam: Int64, bos: Int64) {
        self.toplam = toplam
        self.bos = bos
    }

    public static func oku(_ yol: String = NSHomeDirectory()) -> DiskBilgisi? {
        let url = URL(fileURLWithPath: yol)
        guard let d = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey, .volumeAvailableCapacityKey]),
              let toplam = d.volumeTotalCapacity else { return nil }
        let bos = d.volumeAvailableCapacityForImportantUsage ?? Int64(d.volumeAvailableCapacity ?? 0)
        return DiskBilgisi(toplam: Int64(toplam), bos: bos)
    }
}
