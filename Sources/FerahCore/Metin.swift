import Foundation

/// Arayüz dili. Türkçe varsayılan ve yedek dildir.
public enum Dil: String, Codable, CaseIterable, Sendable {
    case tr, en

    public var yerel: Locale { Locale(identifier: self == .tr ? "tr_TR" : "en_US") }

    /// Sistemin dil tercihlerinden: ilk tercih Türkçe ise Türkçe, İngilizce ya da başka bir dilse İngilizce.
    /// Tercih listesi boşsa Türkçe (yedek dil).
    public static func sistemden(_ tercihler: [String]) -> Dil {
        guard let ilk = tercihler.first?.lowercased(), !ilk.isEmpty else { return .tr }
        return ilk.hasPrefix("tr") ? .tr : .en
    }

    /// Öncelik: komut satırı (`--dil`) > uygulama içi seçim > sistem.
    public static func sec(zorla: Dil?, elle: Dil?, sistem: [String]) -> Dil {
        zorla ?? elle ?? sistemden(sistem)
    }
}

/// Bir metin parçasına geçen argüman. Biçimlendirme (boyut, tarih, sayı) gösterim anında, seçili dile göre yapılır.
public indirect enum MetinArg: Hashable, Codable, Sendable {
    /// Çevrilmeyen değer: dosya adı, yol, uygulama adı, uzantı.
    case yazi(String)
    case sayi(Int)
    case bayt(Int64)
    /// "3 ay önce" / "3 months ago"
    case goreli(Date, Date)
    /// "8 aydır" / "8 months" (bir tarihten bu yana geçen süre)
    case sure(Date, Date)
    case tarih(Date)
    case metin(Metin)
}

/// Dilden bağımsız metin: anahtar + argümanlar. Gösterilirken `metin(dil)` ile çevrilir.
public struct Metin: Hashable, Codable, Sendable {
    public let a: M
    public let args: [MetinArg]

    public init(_ a: M, _ args: MetinArg...) {
        self.a = a
        self.args = args
    }

    public init(_ a: M, dizi: [MetinArg]) {
        self.a = a
        self.args = dizi
    }

    /// Birden çok cümleyi aralarında boşlukla birleştirir.
    public static func birles(_ parcalar: [Metin]) -> Metin {
        Metin(.birlesim, dizi: parcalar.map { .metin($0) })
    }

    public func callAsFunction(_ dil: Dil) -> String { Ceviri.yaz(self, dil) }
}

public enum Ceviri {
    /// İngilizce çoğul biçimleri ayıran dizge: "1 item||{0} items".
    public static let cogulAyraci = "||"

    /// Ham şablon (sınama ve denetim için).
    public static func sablon(_ a: M, _ dil: Dil) -> String {
        let c = a.cift
        return dil == .tr ? c.0 : c.1
    }

    public static func yaz(_ m: Metin, _ dil: Dil) -> String {
        if m.a == .birlesim {
            return m.args.map { arg($0, dil) }.filter { !$0.isEmpty }.joined(separator: " ")
        }
        var s = sablon(m.a, dil)
        // Çoğul: "tekil||çoğul" biçimindeki şablonlarda ilk sayısal argümana göre seçilir.
        if s.contains(Ceviri.cogulAyraci) {
            let parcalar = s.components(separatedBy: Ceviri.cogulAyraci)
            let n: Int = m.args.lazy.compactMap { a -> Int? in
                if case .sayi(let x) = a { return x }
                if case .sure(let d, let simdi) = a { return Bicim.sureSayisi(d, simdi: simdi)?.0 }
                return nil
            }.first ?? 2
            s = parcalar[n == 1 ? 0 : min(1, parcalar.count - 1)]
        }
        for (i, a) in m.args.enumerated() {
            s = s.replacingOccurrences(of: "{\(i)}", with: arg(a, dil))
        }
        return s
    }

    static func arg(_ a: MetinArg, _ dil: Dil) -> String {
        switch a {
        case .yazi(let s): return s
        case .sayi(let n): return Bicim.sayi(n, dil)
        case .bayt(let b): return Bicim.bayt(b, dil)
        case .goreli(let d, let simdi): return Bicim.goreli(d, simdi: simdi, dil)
        case .sure(let d, let simdi): return Bicim.sure(d, simdi: simdi, dil) ?? ""
        case .tarih(let d): return Bicim.tarih(d, dil)
        case .metin(let m): return yaz(m, dil)
        }
    }

    /// Şablondaki yer tutucu numaraları ({0}, {1}…), sınamalar için.
    public static func yerTutucular(_ s: String) -> [Int] {
        var sonuc: [Int] = []
        var i = s.startIndex
        while let ac = s[i...].firstIndex(of: "{") {
            guard let kapa = s[ac...].firstIndex(of: "}") else { break }
            if let n = Int(s[s.index(after: ac)..<kapa]) { sonuc.append(n) }
            i = s.index(after: kapa)
        }
        return sonuc.sorted()
    }
}

extension Risk {
    public func etiket(_ dil: Dil) -> String {
        switch self {
        case .guvenli: return Metin(.riskGuvenli)(dil)
        case .dikkat: return Metin(.riskDikkat)(dil)
        case .riskli: return Metin(.riskRiskli)(dil)
        case .dokunma: return Metin(.riskDokunma)(dil)
        }
    }
}
