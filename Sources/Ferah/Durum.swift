import Foundation
import AppKit
import FerahCore

/// Arka plan işlerinin iptali için iş parçacığı güvenli bayrak.
final class IptalBayragi: @unchecked Sendable {
    private var deger = false
    private let kilit = NSLock()
    var iptalMi: Bool { kilit.lock(); defer { kilit.unlock() }; return deger }
    func iptalEt() { kilit.lock(); deger = true; kilit.unlock() }
}

enum Adim: Int, CaseIterable, Identifiable {
    case guvenli = 1, buyuk, uygulamalar, sistem, ozet
    var id: Int { rawValue }
    var baslik: String {
        switch self {
        case .guvenli: return T(.adimGuvenli)
        case .buyuk: return T(.adimBuyuk)
        case .uygulamalar: return T(.adimUyg)
        case .sistem: return T(.adimSistem)
        case .ozet: return T(.adimOzet)
        }
    }
    var altBaslik: String {
        switch self {
        case .guvenli: return T(.adimGuvenliAlt)
        case .buyuk: return T(.adimBuyukAlt)
        case .uygulamalar: return T(.adimUygAlt)
        case .sistem: return T(.adimSistemAlt)
        case .ozet: return T(.adimOzetAlt)
        }
    }
    var sonraki: Adim? { Adim(rawValue: rawValue + 1) }
}

enum UygulamaSuzgeci: String, CaseIterable, Identifiable {
    case altiAy, ucAy, birYil, hicAcilmamis, tumu
    var id: String { rawValue }
    var etiket: String {
        switch self {
        case .altiAy: return T(.suzAltiAy)
        case .ucAy: return T(.suzUcAy)
        case .birYil: return T(.suzBirYil)
        case .hicAcilmamis: return T(.suzKayitYok)
        case .tumu: return T(.suzTumu)
        }
    }
    /// "6 aydır açılmayan 6 uygulama · 8 MB"
    func ozet(_ n: Int, _ bayt: Int64) -> String {
        let a: M
        switch self {
        case .altiAy: a = .uOzetAlti
        case .ucAy: a = .uOzetUc
        case .birYil: a = .uOzetYil
        case .hicAcilmamis: a = .uOzetKayitsiz
        case .tumu: a = .uOzetTumu
        }
        return T(a, .sayi(n), .bayt(bayt))
    }
    var gun: Int? {
        switch self {
        case .altiAy: return 180
        case .ucAy: return 90
        case .birYil: return 365
        default: return nil
        }
    }
}

enum UygulamaSiralama: String, CaseIterable, Identifiable {
    case kullanim, boyut, ad
    var id: String { rawValue }
    var etiket: String {
        switch self {
        case .kullanim: return T(.sirEskiKullanim)
        case .boyut: return T(.sirBoyut)
        case .ad: return T(.sirAd)
        }
    }
}

enum Karar: Equatable {
    case cop
    case sakla
    case hata(Metin)
}

@MainActor
final class Durum: ObservableObject {
    let ev: String
    let ortam: Ortam
    let depo: Depo
    let silici: Silici

    @Published var adim: Adim = .guvenli
    @Published var disk: DiskBilgisi?
    let ilkDisk: DiskBilgisi?

    // MARK: Adım 1
    @Published var kategoriler: [KategoriSonuc] = []
    @Published var secili: Set<String> = []
    @Published var acik: Set<String> = []
    @Published var tarama1 = false
    @Published var tarama1Yapildi = false
    /// Son tarama sonuna kadar bitti mi (iptal edilen yarım taramayla temizlik yapılmaz).
    @Published var tarama1Tamam = false
    @Published var bitenKategori = 0
    @Published var temizleniyor = false
    @Published var temizlikIlerleme: (Int, Int) = (0, 0)
    @Published var sonRapor: TemizlikRaporu?
    @Published var uygulamaAdlari: [String: String] = [:]
    private var iptal1 = IptalBayragi()

    // MARK: Adım 2
    @Published var esikMB = 100
    @Published var adaylar: [BuyukAday] = []
    @Published var konum = 0
    @Published var kararlar: [String: Karar] = [:]
    @Published var tarama2 = false
    @Published var tarama2Yapildi = false
    @Published var incelenen = 0
    @Published var tarananYol = ""
    @Published var listeGorunumu = false
    /// Adım 2'de bu oturumda Çöp'e taşınanlar (yeniden taramada sıfırlanmaz).
    @Published var adim2Oge = 0
    @Published var adim2Bayt: Int64 = 0
    @Published var tasiniyor = false
    private var iptal2 = IptalBayragi()

    // MARK: Özet
    @Published var kaliciBayt: Int64 = 0
    @Published var kaliciOge = 0
    @Published var atlananDosya = 0
    @Published var reddedilen: [RedKaydi] = []
    @Published var copBayt: Int64 = 0
    @Published var copOge = 0
    @Published var saklananOge = 0
    @Published var copBosaltildi = false
    @Published var copBosaltmaBayt: Int64 = 0

    // MARK: Adım 3 — Uygulamalar
    @Published var uygulamalar: [UygulamaBilgisi] = []
    @Published var tarama3 = false
    @Published var tarama3Yapildi = false
    @Published var tarama3Ilerleme: (Int, Int) = (0, 0)
    @Published var suzgec: UygulamaSuzgeci = .altiAy
    @Published var siralama: UygulamaSiralama = .kullanim
    @Published var arama = ""
    @Published var appleGoster = false
    @Published var uygulamaSecimi = Set<String>()
    /// Uygulama başına "Verilerini de kaldır" (varsayılan kapalı).
    @Published var verilerDahil: [String: Bool] = [:]
    @Published var uygulamaKararlari: [String: Karar] = [:]
    @Published var kaldirilanUygulama = 0
    @Published var kaldirilanUygulamaBayt: Int64 = 0
    @Published var kaldirilanArtikBayt: Int64 = 0

    // MARK: Adım 4 — Sistem verileri
    @Published var dokum: SistemDokumu?
    @Published var tarama4 = false
    @Published var tarama4Ilerleme: (Int, Int) = (0, 0)
    @Published var sistemKararlari: [String: Karar] = [:]
    @Published var sistemCopBayt: Int64 = 0

    // MARK: Dil
    /// Uygulama içi dil seçimi (Sistem / Türkçe / English). Değişince arayüz yeniden çizilir.
    @Published var dilTercihi: DilTercihi = DilSecimi.kayitliTercih() {
        didSet {
            DilSecimi.kaydet(dilTercihi)
            dil = DilSecimi.hesapla(dilTercihi)
        }
    }
    @Published var dil: Dil = DilSecimi.hesapla(DilSecimi.kayitliTercih()) {
        didSet { EtkinDil.deger = dil }
    }

    init(ortam: Ortam = EtkinOrtam.deger) {
        self.ortam = ortam
        let e = Yol.gercek(ortam.ev) ?? ortam.ev
        ev = e
        depo = Depo(klasor: ortam.depoKlasoru)
        esikMB = ortam.varsayilanEsikMB
        // Bekçi çalışan uygulamaları her denetimde yeniden okur.
        let bekci = Bekci(ev: e, uygulamaKokleri: ortam.uygulamaKokleri, calisanKimlikler: ortam.calisanKimlikler,
                          kendiPaketi: ortam.kendiPaketi)
        silici = Silici(bekci: bekci, depo: depo, copeTasiyici: ortam.copeTasiyici)
        let d = DiskBilgisi.oku(e)
        disk = d
        ilkDisk = d
        EtkinDil.deger = dil
    }

    func diskiYenile() {
        let e = ev
        DispatchQueue.global(qos: .utility).async {
            let d = DiskBilgisi.oku(e)
            DispatchQueue.main.async { self.disk = d }
        }
    }

    /// Bu oturumda gerçekten boşalan yer (Çöp'e taşınanlar ancak Çöp boşalınca yer açar).
    var kazanilan: Int64 { kaliciBayt + copBosaltmaBayt }

    // MARK: - Adım 1

    var gorunenKategoriler: [KategoriSonuc] {
        kategoriler.filter(\.gorunur).sorted { a, b in
            if a.risk != b.risk { return a.risk < b.risk }
            return a.boyut > b.boyut
        }
    }

    var seciliBoyut: Int64 {
        kategoriler.flatMap(\.ogeler).filter { secili.contains($0.yol) }.reduce(0) { $0 + $1.boyut }
    }

    var seciliSayi: Int {
        kategoriler.flatMap(\.ogeler).filter { secili.contains($0.yol) }.count
    }

    func tara1() {
        guard !temizleniyor else { return }
        iptal1.iptalEt()
        let bayrak = IptalBayragi()
        iptal1 = bayrak
        tarama1 = true
        tarama1Yapildi = true
        tarama1Tamam = false
        kategoriler = []
        secili = []
        bitenKategori = 0
        let b = TaramaBaglami(ev: ev, calisanKimlikler: ortam.calisanKimlikler())
        DispatchQueue.global(qos: .userInitiated).async {
            KategoriTarayici.taraHepsi(b, iptal: { bayrak.iptalMi }) { k in
                let adlar = k.kimlik == .uygulamaOnbellek ? Durum.uygulamaAdlari(k.ogeler.map(\.ad)) : [:]
                DispatchQueue.main.async {
                    guard !bayrak.iptalMi else { return }
                    self.kategoriler.append(k)
                    self.uygulamaAdlari.merge(adlar) { a, _ in a }
                    for o in k.ogeler where o.varsayilanSecili { self.secili.insert(o.yol) }
                    self.bitenKategori += 1
                }
            }
            DispatchQueue.main.async {
                if !bayrak.iptalMi {
                    self.tarama1 = false
                    self.tarama1Tamam = true
                }
            }
        }
    }

    func iptal1Et() {
        iptal1.iptalEt()
        tarama1 = false
        tarama1Tamam = false
        // Yarım taramanın seçimleriyle temizlik yapılmasın.
        secili = []
    }

    /// Adım 1 onay penceresi (görünüm buna bağlı).
    @Published var adim1Onay = false

    /// Yalnız deneme kipi görsel denetimi için: tarama bitince onay penceresini açar.
    func taramaBitinceOnayGoster() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.tarama1Tamam { if self.temizlenebilir { self.adim1Onay = true } } else { self.taramaBitinceOnayGoster() }
        }
    }

    /// "Seçilenleri temizle" şu an kullanılabilir mi.
    var temizlenebilir: Bool { !temizleniyor && !tarama1 && tarama1Tamam && seciliSayi > 0 }

    nonisolated static func uygulamaAdlari(_ kimlikler: [String]) -> [String: String] {
        var s: [String: String] = [:]
        for k in kimlikler {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: k) {
                s[k] = FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
            }
        }
        return s
    }

    func gorunenAd(_ o: TemizlikOgesi) -> String {
        uygulamaAdlari[o.ad] ?? o.baslik.s
    }

    enum KutuDurumu { case hepsi, biraz, hic }

    func kategoriKutusu(_ k: KategoriSonuc) -> KutuDurumu {
        let n = k.ogeler.filter { secili.contains($0.yol) }.count
        if n == 0 { return .hic }
        return n == k.ogeler.count ? .hepsi : .biraz
    }

    func kategoriyiDegistir(_ k: KategoriSonuc) {
        if kategoriKutusu(k) == .hic {
            // Çalışan uygulamalar yalnız tek tek seçilir.
            for o in k.ogeler where !o.calisiyor { secili.insert(o.yol) }
            if k.ogeler.allSatisfy(\.calisiyor) { for o in k.ogeler { secili.insert(o.yol) } }
        } else {
            for o in k.ogeler { secili.remove(o.yol) }
        }
    }

    func temizle1() {
        // Çift tıklama, tarama sürerken ya da iptal edilmiş yarım taramadan sonra temizlik yapılmaz.
        guard temizlenebilir else { return }
        let secimler: [(KategoriSonuc, [TemizlikOgesi])] = kategoriler.compactMap { k in
            let o = k.ogeler.filter { secili.contains($0.yol) }
            return o.isEmpty ? nil : (k, o)
        }
        guard !secimler.isEmpty else { return }
        temizleniyor = true
        temizlikIlerleme = (0, secimler.reduce(0) { $0 + $1.1.count })
        let s = silici
        DispatchQueue.global(qos: .userInitiated).async {
            let r = Temizleyici.temizle(secimler, silici: s) { i, n in
                DispatchQueue.main.async { self.temizlikIlerleme = (i, n) }
            }
            DispatchQueue.main.async {
                self.temizleniyor = false
                self.sonRapor = r
                self.kaliciBayt += r.serbestBayt
                self.kaliciOge += r.sonuclar.filter { $0.durum == .tamam || $0.durum == .kismen }.count
                self.atlananDosya += r.atlanan
                self.reddedilen += r.reddedilen
                self.diskiYenile()
                self.tara1()
            }
        }
    }

    // MARK: - Adım 2

    func tara2() {
        iptal2.iptalEt()
        let bayrak = IptalBayragi()
        iptal2 = bayrak
        tarama2 = true
        tarama2Yapildi = true
        adaylar = []
        kararlar = [:]
        konum = 0
        incelenen = 0
        let ayar = BuyukTaramaAyari(ev: ev, esik: Int64(esikMB) * 1_000_000, saklananlar: depo.saklananlar(),
                                    kuruluUygulamalar: ortam.kuruluUygulamalar().map(\.1))
        DispatchQueue.global(qos: .userInitiated).async {
            let l = BuyukTarayici.tara(ayar, iptal: { bayrak.iptalMi }, ilerleme: { n, yol in
                DispatchQueue.main.async {
                    guard !bayrak.iptalMi else { return }
                    self.incelenen = n
                    self.tarananYol = yol
                }
            }, bulundu: { c in
                DispatchQueue.main.async {
                    guard !bayrak.iptalMi else { return }
                    self.adaylar.append(c)
                }
            })
            DispatchQueue.main.async {
                guard !bayrak.iptalMi else { return }
                self.adaylar = l
                self.tarama2 = false
            }
        }
    }

    func iptal2Et() {
        iptal2.iptalEt()
        tarama2 = false
        adaylar = BuyukTarayici.sirala(adaylar)
    }

    var siradaki: BuyukAday? {
        konum < adaylar.count ? adaylar[konum] : nil
    }

    var copeTasinanBu: Int64 {
        adaylar.filter { kararlar[$0.yol] == .cop }.reduce(0) { $0 + $1.boyut }
    }

    func sakla(_ c: BuyukAday, ilerle: Bool = true) {
        depo.sakla(c.yol)
        if kararlar[c.yol] != .sakla { saklananOge += 1 }
        kararlar[c.yol] = .sakla
        if ilerle { sonrakine() }
    }

    func copeTasi(_ liste: [BuyukAday], ilerle: Bool = true) {
        let tasinacak = liste.filter { $0.silinebilir && kararlar[$0.yol] != .cop }
        guard !tasinacak.isEmpty, !tasiniyor, !tarama2 else { return }
        tasiniyor = true
        let s = silici
        DispatchQueue.global(qos: .userInitiated).async {
            var sonuclar: [(String, IslemSonucu)] = []
            for c in tasinacak {
                sonuclar.append((c.yol, s.uygula(SilmeIstegi(yol: c.yol, islem: .copeTasi))))
            }
            DispatchQueue.main.async {
                for (yol, r) in sonuclar {
                    if r.durum == .tamam {
                        self.kararlar[yol] = .cop
                        self.copBayt += r.serbestBayt
                        self.copOge += 1
                        self.adim2Oge += 1
                        self.adim2Bayt += r.serbestBayt
                        self.depo.saklamayiKaldir(yol)
                    } else {
                        self.kararlar[yol] = .hata(r.neden ?? Metin(.gTasinamadi))
                        self.reddedilen.append(RedKaydi(yol: yol, neden: r.neden))
                    }
                }
                self.tasiniyor = false
                if ilerle { self.sonrakine() }
            }
        }
    }

    func sonrakine() {
        if konum < adaylar.count { konum += 1 }
    }

    func oncekine() {
        if konum > 0 { konum -= 1 }
    }

    // MARK: - Adım 3: Uygulamalar

    func tara3() {
        guard !tarama3 else { return }
        tarama3 = true
        tarama3Yapildi = true
        uygulamaSecimi = []
        let ayar = UygulamaTaramaAyari(kokler: ortam.uygulamaKokleri, ev: ev, calisanKimlikler: ortam.calisanKimlikler(),
                                       kendiPaketi: ortam.kendiPaketi)
        DispatchQueue.global(qos: .userInitiated).async {
            let l = UygulamaTarayici.tara(ayar, ilerleme: { i, n in
                DispatchQueue.main.async { self.tarama3Ilerleme = (i, n) }
            })
            DispatchQueue.main.async {
                self.uygulamalar = l
                self.tarama3 = false
            }
        }
    }

    func kullanimTarihi(_ u: UygulamaBilgisi) -> Date {
        u.girdi.sonKullanilma ?? u.girdi.eklenme ?? .distantPast
    }

    var gorunenUygulamalar: [UygulamaBilgisi] {
        let simdi = Date()
        var l = uygulamalar.filter { u in
            if u.girdi.apple && !appleGoster { return false }
            switch suzgec {
            case .tumu: return true
            case .hicAcilmamis: return u.girdi.sonKullanilma == nil
            default: return AciklamaMotoru.kullanilmiyorMu(u.girdi, gun: suzgec.gun ?? 180, simdi: simdi)
            }
        }
        let q = Yol.katla(arama.trimmingCharacters(in: .whitespaces))
        if !q.isEmpty {
            l = l.filter { Yol.katla($0.ad).contains(q) || Yol.katla($0.girdi.kimlik ?? "").contains(q) }
        }
        switch siralama {
        case .kullanim: l.sort { kullanimTarihi($0) < kullanimTarihi($1) }
        case .boyut: l.sort { $0.girdi.boyut > $1.girdi.boyut }
        case .ad: l.sort { $0.ad.localizedStandardCompare($1.ad) == .orderedAscending }
        }
        return l
    }

    func verileriDahil(_ u: UygulamaBilgisi) -> Bool { verilerDahil[u.yol] ?? false }

    func tasinacakBoyut(_ u: UygulamaBilgisi) -> Int64 {
        u.girdi.boyut + (verileriDahil(u) ? u.girdi.artiklar.filter { !$0.erisilemedi }.reduce(0) { $0 + $1.boyut } : 0)
    }

    func uygulamalariCopeTasi(_ liste: [UygulamaBilgisi]) {
        let tasinacak = liste.filter { $0.silinebilir && uygulamaKararlari[$0.yol] != .cop }
        guard !tasinacak.isEmpty, !tasiniyor, !tarama3 else { return }
        tasiniyor = true
        let s = silici
        let veriler = verilerDahil
        DispatchQueue.global(qos: .userInitiated).async {
            var sonuclar: [(String, IslemSonucu, Int64)] = []
            for u in tasinacak {
                let r = s.uygula(SilmeIstegi(yol: u.yol, islem: .uygulamaCopeTasi))
                var artik: Int64 = 0
                // Veriler yalnız uygulama gerçekten taşındıysa ve kullanıcı istediyse; Koruma'lı .copeTasi yolundan.
                if r.durum == .tamam, veriler[u.yol] ?? false {
                    for a in u.girdi.artiklar {
                        let ar = s.uygula(SilmeIstegi(yol: a.yol, islem: .copeTasi))
                        if ar.durum == .tamam { artik += ar.serbestBayt }
                    }
                }
                sonuclar.append((u.yol, r, artik))
            }
            DispatchQueue.main.async {
                for (yol, r, artik) in sonuclar {
                    if r.durum == .tamam {
                        self.uygulamaKararlari[yol] = .cop
                        self.kaldirilanUygulama += 1
                        self.kaldirilanUygulamaBayt += r.serbestBayt
                        self.kaldirilanArtikBayt += artik
                        self.copBayt += r.serbestBayt + artik
                    } else {
                        self.uygulamaKararlari[yol] = .hata(r.neden ?? Metin(.gTasinamadi))
                        self.reddedilen.append(RedKaydi(yol: yol, neden: r.neden))
                    }
                }
                self.uygulamaSecimi.subtract(sonuclar.filter { $0.1.durum == .tamam }.map(\.0))
                self.tasiniyor = false
            }
        }
    }

    // MARK: - Adım 4: Sistem verileri

    func tara4() {
        guard !tarama4 else { return }
        tarama4 = true
        let e = ev
        let o = ortam
        DispatchQueue.global(qos: .userInitiated).async {
            let ayar = SistemTaramaAyari(ev: e, esik: o.sistemEsik, inmeEsigi: o.sistemInmeEsigi,
                                         kurulu: o.kuruluUygulamalar(), disKokler: o.disKokler)
            let d = SistemTarayici.tara(ayar, ilerleme: { i, n in
                DispatchQueue.main.async { self.tarama4Ilerleme = (i, n) }
            })
            DispatchQueue.main.async {
                self.dokum = d
                self.tarama4 = false
            }
        }
    }

    func sistemKaleminiCopeTasi(_ k: SistemKalemi) {
        guard k.tasinabilir, !tasiniyor, !tarama4, sistemKararlari[k.yol] != .cop else { return }
        tasiniyor = true
        let s = silici
        DispatchQueue.global(qos: .userInitiated).async {
            let r = s.uygula(SilmeIstegi(yol: k.yol, islem: .copeTasi))
            DispatchQueue.main.async {
                if r.durum == .tamam {
                    self.sistemKararlari[k.yol] = .cop
                    self.sistemCopBayt += r.serbestBayt
                    self.copBayt += r.serbestBayt
                    self.copOge += 1
                } else {
                    self.sistemKararlari[k.yol] = .hata(r.neden ?? Metin(.gTasinamadi))
                    self.reddedilen.append(RedKaydi(yol: k.yol, neden: r.neden))
                }
                self.tasiniyor = false
            }
        }
    }

    // MARK: - Özet

    @Published var copBilgisi: KategoriSonuc?

    func copuOku() {
        let b = TaramaBaglami(ev: ev)
        DispatchQueue.global(qos: .userInitiated).async {
            let k = KategoriTarayici.tara(.copKutusu, b)
            DispatchQueue.main.async { self.copBilgisi = k }
        }
    }

    /// Çöp Kutusu'nu boşaltır; erişim yoksa false döner (arayüz Finder'da açar).
    @Published var bosaltiliyor = false

    func copuBosalt(tamam: @escaping (Bool) -> Void) {
        // Çift tıklama ya da başka bir silme sürerken ikinci boşaltma yapılmaz.
        guard !bosaltiliyor, !temizleniyor else { return }
        bosaltiliyor = true
        let b = TaramaBaglami(ev: ev)
        let s = silici
        DispatchQueue.global(qos: .userInitiated).async {
            let k = KategoriTarayici.tara(.copKutusu, b)
            guard k.durum == .tamam else {
                DispatchQueue.main.async { self.bosaltiliyor = false; tamam(false) }
                return
            }
            let r = Temizleyici.temizle([(k, k.ogeler)], silici: s)
            DispatchQueue.main.async {
                self.bosaltiliyor = false
                self.copBosaltildi = true
                self.copBosaltmaBayt += r.serbestBayt
                self.atlananDosya += r.atlanan
                self.reddedilen += r.reddedilen
                self.diskiYenile()
                self.copuOku()
                tamam(true)
            }
        }
    }

    func copuFinderdaAc() {
        NSWorkspace.shared.open(URL(fileURLWithPath: Yol.ekle(ev, ".Trash")))
    }

    func tamDiskErisimiAc() {
        if let u = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(u)
        }
    }
}
