import Foundation

public struct GecmisKaydi: Codable, Sendable, Identifiable, Hashable {
    public var id: String { "\(tarih.timeIntervalSince1970)-\(yol)" }
    public let tarih: Date
    public let yol: String
    public let boyut: Int64
    public let yontem: Yontem

    public init(tarih: Date, yol: String, boyut: Int64, yontem: Yontem) {
        self.tarih = tarih
        self.yol = yol
        self.boyut = boyut
        self.yontem = yontem
    }
}

/// ~/Library/Application Support/Ferah/ altında geçmiş ve "sakla" kararları.
public final class Depo: @unchecked Sendable {
    public let klasor: String
    private let kilit = NSLock()

    public static var varsayilanKlasor: String {
        Yol.ekle(NSHomeDirectory(), "Library/Application Support/Ferah")
    }

    public init(klasor: String = Depo.varsayilanKlasor) {
        self.klasor = klasor
    }

    private var gecmisYolu: String { Yol.ekle(klasor, "gecmis.json") }
    private var saklananYolu: String { Yol.ekle(klasor, "saklananlar.json") }

    private func klasoruHazirla() {
        try? FileManager.default.createDirectory(atPath: klasor, withIntermediateDirectories: true)
    }

    private static func kodlayici() -> JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private static func cozucu() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: Geçmiş

    public func gecmis() -> [GecmisKaydi] {
        kilit.lock(); defer { kilit.unlock() }
        return gecmisOku()
    }

    private func gecmisOku() -> [GecmisKaydi] {
        guard let d = FileManager.default.contents(atPath: gecmisYolu) else { return [] }
        return (try? Depo.cozucu().decode([GecmisKaydi].self, from: d)) ?? []
    }

    public func gecmiseEkle(_ kayitlar: [GecmisKaydi]) {
        guard !kayitlar.isEmpty else { return }
        kilit.lock(); defer { kilit.unlock() }
        klasoruHazirla()
        var hepsi = gecmisOku()
        hepsi.append(contentsOf: kayitlar)
        if let d = try? Depo.kodlayici().encode(hepsi) {
            try? d.write(to: URL(fileURLWithPath: gecmisYolu), options: .atomic)
        }
    }

    // MARK: Saklananlar

    public func saklananlar() -> Set<String> {
        kilit.lock(); defer { kilit.unlock() }
        return saklananOku()
    }

    private func saklananOku() -> Set<String> {
        guard let d = FileManager.default.contents(atPath: saklananYolu),
              let l = try? JSONDecoder().decode([String].self, from: d) else { return [] }
        return Set(l)
    }

    private func saklananYaz(_ s: Set<String>) {
        klasoruHazirla()
        if let d = try? Depo.kodlayici().encode(s.sorted()) {
            try? d.write(to: URL(fileURLWithPath: saklananYolu), options: .atomic)
        }
    }

    public func sakla(_ yol: String) {
        kilit.lock(); defer { kilit.unlock() }
        var s = saklananOku()
        s.insert(yol)
        saklananYaz(s)
    }

    public func saklamayiKaldir(_ yol: String) {
        kilit.lock(); defer { kilit.unlock() }
        var s = saklananOku()
        s.remove(yol)
        saklananYaz(s)
    }
}
