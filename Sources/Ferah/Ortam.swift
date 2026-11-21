import Foundation
import AppKit
import FerahCore

/// Uygulamanın üzerinde çalıştığı dünya: gerçek ev dizini ya da deneme kipinde sahte bir klasör.
struct Ortam {
    let ev: String
    let deneme: Bool
    let uygulamaKokleri: [String]
    let depoKlasoru: String
    /// nil: gerçek Çöp Kutusu (FileManager.trashItem).
    let copeTasiyici: ((URL) throws -> URL?)?
    let kendiPaketi: String?
    let calisanKimlikler: () -> Set<String>
    /// Sistem verilerinde ev dışı yollar ölçülsün mü.
    let disKokler: Bool
    let esikSecenekleriMB: [Int]
    let varsayilanEsikMB: Int
    let sistemEsik: Int64
    let sistemInmeEsigi: Int64

    static func calisanlar() -> Set<String> {
        Set(NSWorkspace.shared.runningApplications.compactMap { $0.bundleIdentifier?.lowercased() })
    }

    static func gercek() -> Ortam {
        let e = Yol.gercek(NSHomeDirectory()) ?? NSHomeDirectory()
        return Ortam(ev: e, deneme: false, uygulamaKokleri: ["/Applications", Yol.ekle(e, "Applications")],
                     depoKlasoru: Depo.varsayilanKlasor, copeTasiyici: nil, kendiPaketi: Bundle.main.bundlePath,
                     calisanKimlikler: calisanlar, disKokler: true, esikSecenekleriMB: [100, 500, 1000],
                     varsayilanEsikMB: 100, sistemEsik: 100_000_000, sistemInmeEsigi: 1_000_000_000)
    }

    /// Deneme kipi: her şey `kok` içinde. Uygulama kökü kok/Applications, Çöp kok/.Trash, depo kok içinde,
    /// ev dışı sistem yolları taranmaz. "com.deneme.calisan" çalışıyormuş gibi davranılır (sınanabilsin diye).
    static func deneme(_ kok: String) -> Ortam {
        let cop = Yol.ekle(kok, ".Trash")
        return Ortam(ev: kok, deneme: true, uygulamaKokleri: [Yol.ekle(kok, "Applications")],
                     depoKlasoru: Yol.ekle(kok, "Library/Application Support/Ferah"),
                     copeTasiyici: { url in try DenemeEvi.copeTasi(url, cop: cop) },
                     kendiPaketi: Yol.ekle(kok, "Applications/Ferah.app"),
                     calisanKimlikler: { calisanlar().union([DenemeEvi.calisanKimlik]) },
                     disKokler: false, esikSecenekleriMB: [1, 100, 500, 1000], varsayilanEsikMB: 1,
                     sistemEsik: 1_000_000, sistemInmeEsigi: 2_500_000)
    }

    func kuruluUygulamalar() -> [(String?, String)] {
        var kokler = uygulamaKokleri
        if !deneme { kokler += ["/System/Applications", "/System/Applications/Utilities"] }
        return UygulamaTarayici.paketleriBul(kokler).map { (Bekci.paketKimligi($0), String(Yol.ad($0).dropLast(4))) }
    }
}

/// Uygulama ömrü boyunca seçili ortam (main.swift ayarlar).
enum EtkinOrtam {
    nonisolated(unsafe) static var deger = Ortam.gercek()
}
