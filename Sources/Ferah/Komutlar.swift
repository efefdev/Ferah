import Foundation
import AppKit
import FerahCore

/// Komut satırı kipleri. JSON alan adları sabittir; insan-okur metin değerleri `dil` ile yazılır,
/// makine değerleri (risk, öneri, eylem kodları, yollar, baytlar) dilden bağımsızdır.
enum Komutlar {
    nonisolated(unsafe) static var dil: Dil = .tr

    static func calisanKimlikler() -> Set<String> {
        Set(NSWorkspace.shared.runningApplications.compactMap { $0.bundleIdentifier?.lowercased() })
    }

    static func yaz<T: Encodable>(_ d: T) {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        e.dateEncodingStrategy = .iso8601
        if let v = try? e.encode(d), let s = String(data: v, encoding: .utf8) { print(s) }
    }

    static func hata(_ s: String) {
        FileHandle.standardError.write((s + "\n").data(using: .utf8)!)
    }

    static func bayt(_ b: Int64) -> String { Bicim.bayt(b, dil) }
    static func t(_ m: Metin?) -> String? { m.map { $0(dil) } }

    /// Açıklamanın JSON hali: alan adları önceki sürümle aynı; risk/öneri ham kod.
    struct AciklamaJSON: Encodable {
        let tur: String
        let risk: Risk
        let neOlur: String
        let geriNasil: String?
        let oneri: Oneri
        let oneriMetni: String?
        let baglam: [String]

        init(_ a: Aciklama) {
            tur = a.tur(dil); risk = a.risk; neOlur = a.neOlur(dil); geriNasil = t(a.geriNasil)
            oneri = a.oneri; oneriMetni = t(a.oneriMetni); baglam = a.baglam.map { $0(dil) }
        }
    }

    // MARK: --tara-json

    struct OgeJSON: Encodable {
        let ad: String
        let yol: String
        let boyut: Int64
        let boyutMetin: String
        let calisiyor: Bool
        let varsayilanSecili: Bool
        let not: String?
    }

    struct KategoriJSON: Encodable {
        let kimlik: String
        let ad: String
        let aciklama: String
        let risk: String
        let erisim: String
        let gorunur: Bool
        let boyut: Int64
        let boyutMetin: String
        let ogeSayisi: Int
        let erisilemeyenOge: Int
        let varsayilanSeciliBoyut: Int64
        let enBuyukler: [OgeJSON]
    }

    struct TaramaJSON: Encodable {
        let ev: String
        let sureSaniye: Double
        let toplamBoyut: Int64
        let toplamMetin: String
        let disk: DiskBilgisi?
        let kategoriler: [KategoriJSON]
    }

    static func taraJSON() {
        let bas = Date()
        let b = TaramaBaglami(calisanKimlikler: calisanKimlikler())
        let sonuc = KategoriTarayici.taraHepsi(b)
        let kj = sonuc.map { k -> KategoriJSON in
            let enBuyukler = k.ogeler.prefix(5).map { o in
                OgeJSON(ad: o.baslik(dil), yol: o.yol, boyut: o.boyut, boyutMetin: bayt(o.boyut),
                        calisiyor: o.calisiyor, varsayilanSecili: o.varsayilanSecili, not: t(o.not))
            }
            let secili: Int64 = k.ogeler.filter(\.varsayilanSecili).reduce(0) { $0 + $1.boyut }
            return KategoriJSON(kimlik: k.kimlik.rawValue, ad: k.kimlik.ad(dil), aciklama: k.kimlik.aciklama(dil),
                                risk: k.risk.etiket(dil), erisim: k.durum.rawValue, gorunur: k.gorunur, boyut: k.boyut,
                                boyutMetin: bayt(k.boyut), ogeSayisi: k.ogeler.count, erisilemeyenOge: k.erisilemeyen,
                                varsayilanSeciliBoyut: secili, enBuyukler: Array(enBuyukler))
        }
        let toplam = sonuc.reduce(0) { $0 + $1.boyut }
        yaz(TaramaJSON(ev: b.ev, sureSaniye: (Date().timeIntervalSince(bas) * 10).rounded() / 10, toplamBoyut: toplam,
                       toplamMetin: bayt(toplam), disk: DiskBilgisi.oku(), kategoriler: kj))
    }

    // MARK: --buyuk-json

    struct AdayJSON: Encodable {
        let yol: String
        let boyut: Int64
        let boyutMetin: String
        let tur: String
        let risk: String
        let neOlur: String
        let geriNasil: String?
        let oneri: String
        let oneriMetni: String?
        let baglam: [String]
        let ozelTur: String?
        let saklandi: Bool
        let sonDegisme: Date?
        let sonAcilma: Date?
    }

    struct BuyukJSON: Encodable {
        let esikMB: Int
        let sureSaniye: Double
        let incelenenOge: Int
        let adaySayisi: Int
        let toplamBoyut: Int64
        let toplamMetin: String
        let adaylar: [AdayJSON]
    }

    static func buyukJSON(_ args: [String]) -> Int32 {
        var esikMB = 100
        if let i = args.firstIndex(of: "--esik"), i + 1 < args.count {
            guard let v = Int(args[i + 1]), v > 0 else {
                hata(Metin(.cEsikHata)(dil))
                return 2
            }
            esikMB = v
        }
        let bas = Date()
        var incelenen = 0
        let ayar = BuyukTaramaAyari(esik: Int64(esikMB) * 1_000_000, saklananlar: Depo().saklananlar())
        let l = BuyukTarayici.tara(ayar, ilerleme: { n, _ in incelenen = n })
        let aj = l.map { c -> AdayJSON in
            let a = c.aciklama
            return AdayJSON(yol: c.yol, boyut: c.boyut, boyutMetin: bayt(c.boyut), tur: a.tur(dil),
                            risk: a.risk.etiket(dil), neOlur: a.neOlur(dil), geriNasil: t(a.geriNasil),
                            oneri: a.oneri.etiket(dil), oneriMetni: t(a.oneriMetni), baglam: a.baglam.map { $0(dil) },
                            ozelTur: c.girdi.ozelTur?.rawValue, saklandi: c.saklandi,
                            sonDegisme: c.girdi.sonDegisme, sonAcilma: c.girdi.sonAcilma)
        }
        let toplam = l.reduce(0) { $0 + $1.boyut }
        yaz(BuyukJSON(esikMB: esikMB, sureSaniye: (Date().timeIntervalSince(bas) * 10).rounded() / 10,
                      incelenenOge: incelenen, adaySayisi: l.count, toplamBoyut: toplam,
                      toplamMetin: bayt(toplam), adaylar: aj))
        return 0
    }

    // MARK: --uygulamalar-json

    struct ArtikJSON: Encodable {
        let yol: String
        let tur: String
        let boyut: Int64
        let erisilemedi: Bool
    }

    struct UygulamaJSON: Encodable {
        let ad: String
        let yol: String
        let kimlik: String?
        let surum: String?
        let boyut: Int64
        let boyutMetin: String
        let sonKullanilma: Date?
        let eklenme: Date?
        let kaynak: String
        let mimari: String
        let calisiyor: Bool
        let artiklar: [ArtikJSON]
        let artikBoyutu: Int64
        let silinebilir: Bool
        let silinemezNedeni: String?
        let altiAydirKullanilmiyor: Bool
        let aciklama: AciklamaJSON
    }

    struct UygulamalarJSON: Encodable {
        let sureSaniye: Double
        let uygulamaSayisi: Int
        let sonKullanilmaVar: Int
        let sonKullanilmaYok: Int
        let altiAydirKullanilmayan: Int
        let altiAydirKullanilmayanAppleHaric: Int
        let altiAydirKullanilmayanBoyut: String
        let uygulamalar: [UygulamaJSON]
    }

    static func uygulamalarJSON() {
        let bas = Date()
        let simdi = Date()
        let l = UygulamaTarayici.tara(UygulamaTaramaAyari(calisanKimlikler: calisanKimlikler()))
        var eskiSayi = 0, eskiAppleHaric = 0
        var eskiBoyut: Int64 = 0
        let uj = l.map { u -> UygulamaJSON in
            let g = u.girdi
            let eski = AciklamaMotoru.kullanilmiyorMu(g, gun: 180, simdi: simdi)
            if eski {
                eskiSayi += 1
                eskiBoyut += g.boyut
                if g.kaynak != .apple { eskiAppleHaric += 1 }
            }
            let artiklar = g.artiklar.map { ArtikJSON(yol: $0.yol, tur: $0.tur(dil), boyut: $0.boyut, erisilemedi: $0.erisilemedi) }
            return UygulamaJSON(ad: g.ad, yol: g.yol, kimlik: g.kimlik, surum: g.surum, boyut: g.boyut,
                                boyutMetin: bayt(g.boyut), sonKullanilma: g.sonKullanilma, eklenme: g.eklenme,
                                kaynak: g.kaynak.etiket(dil),
                                mimari: Metin(g.yalnizIntel ? .cMimariIntel : .cMimariEvrensel)(dil),
                                calisiyor: g.calisiyor, artiklar: artiklar, artikBoyutu: g.artikBoyutu,
                                silinebilir: u.silinebilir, silinemezNedeni: t(g.silinemezNedeni),
                                altiAydirKullanilmiyor: eski,
                                aciklama: AciklamaJSON(AciklamaMotoru.uygulamaAcikla(g, verilerDahil: false, simdi: simdi)))
        }
        let sirali = uj.sorted { ($0.sonKullanilma ?? $0.eklenme ?? .distantPast) < ($1.sonKullanilma ?? $1.eklenme ?? .distantPast) }
        yaz(UygulamalarJSON(sureSaniye: (Date().timeIntervalSince(bas) * 10).rounded() / 10,
                            uygulamaSayisi: uj.count,
                            sonKullanilmaVar: uj.filter { $0.sonKullanilma != nil }.count,
                            sonKullanilmaYok: uj.filter { $0.sonKullanilma == nil }.count,
                            altiAydirKullanilmayan: eskiSayi, altiAydirKullanilmayanAppleHaric: eskiAppleHaric,
                            altiAydirKullanilmayanBoyut: bayt(eskiBoyut), uygulamalar: sirali))
    }

    // MARK: --sistem-json

    static func kuruluUygulamaListesi() -> [(String?, String)] {
        UygulamaTarayici.paketleriBul(["/Applications", Yol.ekle(NSHomeDirectory(), "Applications"),
                                       "/System/Applications", "/System/Applications/Utilities"])
            .map { (Bekci.paketKimligi($0), String(Yol.ad($0).dropLast(4))) }
    }

    struct SistemKalemiJSON: Encodable {
        let yol: String
        let grup: String
        let boyut: Int64
        let olculemedi: String?
        let kismen: Bool
        let evIcinde: Bool
        let ust: String?
        let sahip: String?
        let sahipsiz: Bool
        let aciklama: AciklamaJSON
        let eylem: SistemEylemi
        let eylemMetni: String?
    }

    struct SistemDokumuJSON: Encodable {
        let kalemler: [SistemKalemiJSON]
        let digerBayt: Int64
        let digerSayi: Int
        let olculen: Int64
        let kullanilan: Int64?
        let tahminiOlculemeyen: Int64?
        let anlikGoruntuler: [String]
        let tamDiskErisimi: Bool
        let esik: Int64
    }

    struct SistemJSON: Encodable {
        let sureSaniye: Double
        let olculen: String
        let kullanilan: String?
        let tahminiOlculemeyen: String?
        let tamDiskErisimi: Bool
        let anlikGoruntuSayisi: Int
        let anlikGoruntuler: [String]
        let digerMetin: String
        let dokum: SistemDokumuJSON
    }

    static func sistemJSON() {
        let bas = Date()
        let d = SistemTarayici.tara(SistemTaramaAyari(kurulu: kuruluUygulamaListesi()))
        let kalemler = d.kalemler.map { k in
            SistemKalemiJSON(yol: k.yol, grup: k.grup, boyut: k.boyut, olculemedi: t(k.olculemedi), kismen: k.kismen,
                             evIcinde: k.evIcinde, ust: k.ust, sahip: k.sahip, sahipsiz: k.sahipsiz,
                             aciklama: AciklamaJSON(k.aciklama), eylem: k.eylem, eylemMetni: t(k.eylemMetni))
        }
        let dokum = SistemDokumuJSON(kalemler: kalemler, digerBayt: d.digerBayt, digerSayi: d.digerSayi, olculen: d.olculen,
                                     kullanilan: d.kullanilan, tahminiOlculemeyen: d.tahminiOlculemeyen,
                                     anlikGoruntuler: d.anlikGoruntuler, tamDiskErisimi: d.tamDiskErisimi, esik: d.esik)
        yaz(SistemJSON(sureSaniye: (Date().timeIntervalSince(bas) * 10).rounded() / 10, olculen: bayt(d.olculen),
                       kullanilan: d.kullanilan.map(bayt), tahminiOlculemeyen: d.tahminiOlculemeyen.map(bayt),
                       tamDiskErisimi: d.tamDiskErisimi, anlikGoruntuSayisi: d.anlikGoruntuler.count,
                       anlikGoruntuler: d.anlikGoruntuler,
                       digerMetin: Metin(.cDiger, .sayi(d.digerSayi), .bayt(d.digerBayt))(dil), dokum: dokum))
    }
}
