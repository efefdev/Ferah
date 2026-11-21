import Foundation
import FerahCore

// Komut satırı kipleri arayüz açmadan çalışır.
let argumanlar = CommandLine.arguments

// Geliştirme ölçümü: klon bilgisinin okunacağı en küçük dosya boyutu (varsayılan 1 MB).
if let e = ProcessInfo.processInfo.environment["FERAH_KLON_ESIGI"], let v = Int64(e), v >= 0 {
    Olcer.klonEsigi = v
}

func deger(_ bayrak: String) -> String? {
    guard let i = argumanlar.firstIndex(of: bayrak), i + 1 < argumanlar.count else { return nil }
    return argumanlar[i + 1]
}

func hataylaCik(_ s: String, _ kod: Int32 = 2) -> Never {
    FileHandle.standardError.write((s + "\n").data(using: .utf8)!)
    exit(kod)
}

// Dil: --dil > uygulama içi seçim > sistem dili. Sistem tercihleri AppleLanguages değiştirilmeden önce okunur.
DilSecimi.sistemTercihleri = Locale.preferredLanguages
if let d = deger("--dil") {
    guard let dil = Dil(rawValue: d) else {
        hataylaCik(Metin(.cDilHata)(Dil.sistemden(DilSecimi.sistemTercihleri)))
    }
    DilSecimi.zorla = dil
}
let acilisDili = DilSecimi.hesapla(DilSecimi.kayitliTercih())
EtkinDil.deger = acilisDili
DilSecimi.acilisDili = acilisDili
Komutlar.dil = acilisDili
func m(_ a: M, _ args: MetinArg...) -> String { Metin(a, dizi: args)(acilisDili) }

/// Arayüzü açarken kabul edilen bayraklar; değer alanlar ayrıca listelenir. Tanınmayan bir `--` bayrağı arayüzü AÇMAZ.
let arayuzBayraklari: Set<String> = ["--ac-ve-tara", "--ac-buyuk", "--ac-uygulamalar", "--ac-sistem", "--deneme-onay", "--her-masaustu", "--vitrin"]
let degerliBayraklar: Set<String> = ["--deneme-evi", "--tema", "--adim", "--pencere", "--dil"]

if argumanlar.contains("--oz-sinama") {
    exit(OzSinama(dil: acilisDili).calistir())
} else if argumanlar.contains("--akis-sinama") {
    exit(MainActor.assumeIsolated { AkisSinama().calistir() })
} else if argumanlar.contains("--deneme-evi-kur") {
    guard let k = deger("--deneme-evi-kur") else { hataylaCik(m(.cKurKlasorBekler)) }
    switch DenemeEvi.kur(k) {
    case .success(let ev): print(m(.cDenemeKuruldu, .yazi(ev)))
    case .failure(let h): hataylaCik(m(.cReddedildi, .metin(h.neden)))
    }
    exit(0)
} else if argumanlar.contains("--tara-json") {
    Komutlar.taraJSON()
    exit(0)
} else if argumanlar.contains("--uygulamalar-json") {
    Komutlar.uygulamalarJSON()
    exit(0)
} else if argumanlar.contains("--sistem-json") {
    Komutlar.sistemJSON()
    exit(0)
} else if argumanlar.contains("--buyuk-json") {
    exit(Komutlar.buyukJSON(argumanlar))
} else if argumanlar.contains("--yardim") || argumanlar.contains("-h") || argumanlar.contains("--help") {
    print(m(.cYardim))
    exit(0)
}

// Arayüz kipi: bayrakları doğrula
var i = 1
while i < argumanlar.count {
    let a = argumanlar[i]
    if degerliBayraklar.contains(a) {
        guard i + 1 < argumanlar.count else { hataylaCik(m(.cDegerBekler, .yazi(a)) + "\n\n" + m(.cYardim)) }
        i += 2
        continue
    }
    // macOS'un kendi eklediği -NSDocumentRevisionsDebugMode gibi tek tireli argümanlar etkilenmez.
    if a.hasPrefix("--") && !arayuzBayraklari.contains(a) { hataylaCik(m(.cBilinmeyenBayrak, .yazi(a)) + "\n\n" + m(.cYardim)) }
    i += 1
}

if let t = deger("--tema"), t != "acik", t != "koyu" { hataylaCik(m(.cTemaHata)) }
if let k = deger("--deneme-evi") {
    switch DenemeEvi.dogrula(k) {
    case .success(let ev):
        EtkinOrtam.deger = Ortam.deneme(ev)
        DilSecimi.kaydetmeIzni = false   // deneme kipi gerçek uygulamanın ayarlarına yazmaz
    case .failure(let h): hataylaCik(m(.cDenemeReddedildi, .metin(h.neden)))
    }
} else if argumanlar.contains("--deneme-onay") {
    hataylaCik(m(.cDenemeOnayHata))
}

// Menüler ve sistem pencereleri de seçili dilde olsun (yalnız bu süreç için; ayarlara yazılmaz).
DilSecimi.sistemMetinleriniAyarla(acilisDili)
FerahApp.main()
