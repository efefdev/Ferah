import Foundation
import Darwin

/// Deneme kipi: uygulamanın tamamını geçici dizindeki sahte bir ev üzerinde çalıştırır.
public enum DenemeEvi {
    /// Deneme kipinde "çalışıyormuş gibi" davranılan sahte uygulama kimliği.
    public static let calisanKimlik = "com.deneme.calisan"

    /// Deneme evinin güvenli olup olmadığını denetler; güvenliyse kanonik yolu döndürür.
    /// Kurallar: geçici dizin (NSTemporaryDirectory) altında olmalı; gerçek ev dizini, "/", "/Applications",
    /// "/Users" ya da bunların kendisi/üstü olamaz.
    public static func dogrula(_ yol: String, varOlmali: Bool = true) -> Result<String, BekciHatasi> {
        func red(_ a: M, _ args: MetinArg...) -> Result<String, BekciHatasi> { .failure(BekciHatasi(neden: Metin(a, dizi: args))) }
        guard yol.hasPrefix("/"), let soz = Yol.sozcukselNormalle(yol) else { return red(.dMutlak) }
        let k: String
        if let g = Yol.gercek(soz) {
            k = g
        } else if !varOlmali, let ust = Yol.gercek(Yol.ebeveyn(soz)) {
            k = Yol.ekle(ust, Yol.ad(soz))
        } else {
            return red(.dKlasorYok)
        }
        let gecici = Yol.gercek(NSTemporaryDirectory()) ?? NSTemporaryDirectory()
        let gercekEv = Yol.gercek(NSHomeDirectory()) ?? NSHomeDirectory()
        for yasak in ["/", "/Applications", "/Users", "/System", "/Library", "/private", "/var", gercekEv] {
            let y = Yol.gercek(yasak) ?? yasak
            if Yol.esitVeyaAltinda(y, k) { return red(.dYasak, .yazi(yasak)) }
        }
        guard Yol.altinda(k, gecici) else {
            return red(.dGecici, .yazi(gecici))
        }
        return .success(k)
    }

    /// Sahte Çöp: dosyayı <ev>/.Trash içine taşır (aynı ad varsa numara ekler). Gerçek Çöp Kutusu kullanılmaz.
    public static func copeTasi(_ url: URL, cop: String) throws -> URL {
        try FileManager.default.createDirectory(atPath: cop, withIntermediateDirectories: true)
        let ad = url.lastPathComponent
        var hedef = Yol.ekle(cop, ad)
        var n = 2
        while Yol.varMi(hedef) {
            // Klasörlerde (com.foo.bar gibi) uzantı ayrılmaz; Finder gibi sona numara eklenir.
            let dosyaMi = !Yol.dizinMi(url.path) || ["app", "bundle", "photoslibrary"].contains(Yol.uzanti(ad))
            let govde = dosyaMi ? (ad as NSString).deletingPathExtension : ad
            let u = dosyaMi ? (ad as NSString).pathExtension : ""
            hedef = Yol.ekle(cop, u.isEmpty ? "\(govde) \(n)" : "\(govde) \(n).\(u)")
            n += 1
        }
        try FileManager.default.moveItem(atPath: url.path, toPath: hedef)
        return URL(fileURLWithPath: hedef)
    }

    /// Deneme evini (ve kurulumun dışarıda bıraktığı tuzak hedefini) siler; yalnız doğrulanmış geçici klasörde.
    public static func kaldir(_ kok: String) {
        guard case .success(let k) = dogrula(kok) else { return }
        for p in [k, k + "-disari"] where Yol.varMi(p) {
            Gezgin.gez(p) { g in
                if g.st != nil { _ = lchflags(g.yolC, 0) }
                if case .dizin = g.tur { _ = chmod(g.yolC, 0o755) }
                return .devam
            }
            try? FileManager.default.removeItem(atPath: p)
        }
    }

    // MARK: - Kurulum

    static func dizin(_ p: String) { try? FileManager.default.createDirectory(atPath: p, withIntermediateDirectories: true) }

    /// Gerçek veriyle (diske ayrılmış) dosya. Seyrek değil.
    public static func dosya(_ p: String, _ bayt: Int, dolgu: UInt8 = 0x5A) {
        dizin(Yol.ebeveyn(p))
        // Dosyaya özgü içerik: dolgu + konum karışımı (sıfır değil; seyrek dosya oluşmaz)
        var dizi = [UInt8](repeating: 0, count: bayt)
        for i in 0..<bayt { dizi[i] = UInt8(truncatingIfNeeded: (i &* 2654435761) >> 13) ^ dolgu }
        FileManager.default.createFile(atPath: p, contents: Data(dizi))
    }

    public static func tarihAyarla(_ p: String, _ d: Date) {
        var t = [timeval(tv_sec: Int(d.timeIntervalSince1970), tv_usec: 0), timeval(tv_sec: Int(d.timeIntervalSince1970), tv_usec: 0)]
        _ = lutimes(p, &t)
        // "Eklenme tarihi" (Finder'daki Date Added): ATTR_CMN_ADDEDTIME
        var al = attrlist()
        al.bitmapcount = u_short(ATTR_BIT_MAP_COUNT)
        al.commonattr = attrgroup_t(ATTR_CMN_ADDEDTIME)
        var ts = timespec(tv_sec: Int(d.timeIntervalSince1970), tv_nsec: 0)
        _ = setattrlist(p, &al, &ts, MemoryLayout<timespec>.size, UInt32(FSOPT_NOFOLLOW))
    }

    static func uygulama(_ yol: String, kimlik: String?, surum: String = "1.0", appStore: Bool = false, boyut: Int = 1_500_000) {
        dizin(Yol.ekle(yol, "Contents/MacOS"))
        dosya(Yol.ekle(yol, "Contents/MacOS/\(Yol.ad(yol).dropLast(4))"), boyut, dolgu: UInt8(truncatingIfNeeded: yol.count))
        if let k = kimlik {
            let pl: NSDictionary = ["CFBundleIdentifier": k, "CFBundleShortVersionString": surum,
                                    "CFBundleExecutable": String(Yol.ad(yol).dropLast(4))]
            pl.write(toFile: Yol.ekle(yol, "Contents/Info.plist"), atomically: true)
        }
        if appStore { dosya(Yol.ekle(yol, "Contents/_MASReceipt/receipt"), 1_000) }
    }

    /// Gerçekçi bir sahte ev kurar. Dönen değer: kurulan kanonik kök.
    @discardableResult
    public static func kur(_ kok: String) -> Result<String, BekciHatasi> {
        switch dogrula(kok, varOlmali: false) {
        case .failure(let h): return .failure(h)
        case .success: break
        }
        dizin(kok)
        guard case .success(let ev) = dogrula(kok) else { return .failure(BekciHatasi(.dKurulamadi)) }
        let kb = 1_000, mb = 1_000_000
        let lib = Yol.ekle(ev, "Library")
        let disari = ev + "-disari"
        let simdi = Date()
        let gun: TimeInterval = 86_400
        for k in Koruma.standartKlasorler { dizin(Yol.ekle(ev, k)) }

        // Adım 1: önbellekler, günlükler, tarayıcı, geliştirici, Çöp, eski kurulum
        dosya("\(lib)/Caches/com.deneme.uygulama/veri1.bin", 300 * kb, dolgu: 1)
        dosya("\(lib)/Caches/com.deneme.uygulama/alt/veri2.bin", 200 * kb, dolgu: 2)
        dosya("\(lib)/Caches/\(calisanKimlik)/acik.bin", 150 * kb, dolgu: 3)
        dosya("\(lib)/Caches/com.deneme.kilitli/serbest.bin", 120 * kb, dolgu: 4)
        dosya("\(lib)/Caches/com.deneme.kilitli/kilitli.bin", 80 * kb, dolgu: 5)
        _ = chflags("\(lib)/Caches/com.deneme.kilitli/kilitli.bin", UInt32(UF_IMMUTABLE))
        dosya("\(lib)/Caches/Google/Chrome/Default/Cache/Cache_Data/f_0001", 400 * kb, dolgu: 6)
        dosya("\(lib)/Caches/Homebrew/downloads/paket.tar.gz", 250 * kb, dolgu: 7)
        dosya("\(lib)/Application Support/Google/Chrome/Default/Preferences", 2 * kb, dolgu: 8)
        dosya("\(lib)/Application Support/Google/Chrome/Default/History", 60 * kb, dolgu: 9)
        dosya("\(lib)/Application Support/Google/Chrome/Default/Code Cache/js/kod.bin", 150 * kb, dolgu: 10)
        dosya("\(lib)/Logs/DiagnosticReports/Ornek-2024.ips", 40 * kb, dolgu: 11)
        dosya("\(lib)/Logs/com.deneme.uygulama/gunluk.log", 90 * kb, dolgu: 12)
        dosya("\(ev)/.npm/_cacache/content-v2/sha512/ab/cd", 220 * kb, dolgu: 13)
        dosya("\(ev)/.Trash/eski-belge.txt", 50 * kb, dolgu: 14)
        dosya("\(ev)/.Trash/eski-klasor/a.bin", 100 * kb, dolgu: 15)
        dosya("\(ev)/Downloads/EskiKurulum.dmg", 2 * mb, dolgu: 16)
        tarihAyarla("\(ev)/Downloads/EskiKurulum.dmg", simdi.addingTimeInterval(-60 * gun))
        dosya("\(ev)/Downloads/YeniKurulum.pkg", 1 * mb, dolgu: 17)

        // Adım 2: büyük dosyalar (gerçek ayrılmış veri)
        dosya("\(ev)/Movies/Tatil.mov", 6 * mb, dolgu: 20)
        dosya("\(ev)/Movies/Yedek/Tatil.mov", 6 * mb, dolgu: 20)   // aynı içerik: kopya
        dosya("\(ev)/Desktop/Ekran Kaydı 2024-01-01 10.00.00.mov", 4 * mb, dolgu: 21)
        dosya("\(ev)/Downloads/arsiv.zip", 3 * mb, dolgu: 22)
        dosya("\(ev)/Downloads/arsiv/icerik.txt", 1 * kb, dolgu: 23)
        dosya("\(ev)/Documents/veri.sqlite", 3 * mb, dolgu: 24)
        dosya("\(ev)/Projeler/site/package.json", 1 * kb, dolgu: 25)
        dosya("\(ev)/Projeler/site/package-lock.json", 1 * kb, dolgu: 26)
        dosya("\(ev)/Projeler/site/node_modules/paket-a/index.js", 2 * mb, dolgu: 27)
        dosya("\(ev)/Projeler/site/node_modules/paket-b/index.js", 1500 * kb, dolgu: 28)
        tarihAyarla("\(ev)/Projeler/site/package.json", simdi.addingTimeInterval(-240 * gun))
        tarihAyarla("\(ev)/Projeler/site/package-lock.json", simdi.addingTimeInterval(-240 * gun))
        dosya("\(ev)/Pictures/Photos Library.photoslibrary/originals/IMG_0001.heic", 3 * mb, dolgu: 29)
        dosya("\(lib)/Mail/V10/posta.emlx", 1 * mb, dolgu: 30)
        dosya("\(ev)/Movies/klon-ozgun.mov", 5 * mb, dolgu: 31)
        _ = clonefile("\(ev)/Movies/klon-ozgun.mov", "\(ev)/Movies/klon-kopya.mov", 0)

        // Adım 3: sahte uygulamalar ve artıkları
        let apps = Yol.ekle(ev, "Applications")
        uygulama("\(apps)/Ornek.app", kimlik: "com.deneme.ornek", surum: "2.1", appStore: true, boyut: 2 * mb)
        uygulama("\(apps)/Utilities/Arac.app", kimlik: "com.deneme.arac", surum: "0.9")
        uygulama("\(apps)/Calisan.app", kimlik: calisanKimlik)
        uygulama("\(apps)/Safari Taklit.app", kimlik: "com.apple.Safari")
        uygulama("\(apps)/Ferah.app", kimlik: "network.akca.ferah")
        uygulama("\(apps)/Kaldiricili/Kaldiricili.app", kimlik: "com.deneme.kaldiricili")
        uygulama("\(apps)/Kaldiricili/Uninstall Kaldiricili.app", kimlik: "com.deneme.kaldiricili.uninstaller", boyut: 200 * kb)
        uygulama("\(apps)/YeniEklenen.app", kimlik: "com.deneme.yeni")
        _ = symlink("\(apps)/Ornek.app", "\(apps)/Kisayol.app")
        // Contents'i başka yeri gösteren paket (Multipass benzeri)
        dosya("\(disari)/BagliIcerik/Contents/MacOS/Bagli", 1 * mb, dolgu: 40)
        dizin("\(apps)/Bagli.app")
        _ = symlink("\(disari)/BagliIcerik/Contents", "\(apps)/Bagli.app/Contents")
        for (p, gunOnce) in [("Ornek.app", 400.0), ("Utilities/Arac.app", 900), ("Calisan.app", 300), ("Safari Taklit.app", 500),
                             ("Kaldiricili/Kaldiricili.app", 250), ("Ferah.app", 400), ("Bagli.app", 400), ("YeniEklenen.app", 5)] {
            tarihAyarla("\(apps)/\(p)", simdi.addingTimeInterval(-gunOnce * gun))
        }
        dosya("\(lib)/Application Support/com.deneme.ornek/veri.db", 1 * mb, dolgu: 41)
        dosya("\(lib)/Application Support/com.deneme.ornekler/veri.db", 300 * kb, dolgu: 42)
        dosya("\(lib)/Application Support/Ornek/ayarlar.json", 100 * kb, dolgu: 43)
        dosya("\(lib)/Application Support/Ornekler/ayarlar.json", 100 * kb, dolgu: 44)
        dosya("\(lib)/Caches/com.deneme.ornek/onbellek.bin", 200 * kb, dolgu: 45)
        dosya("\(lib)/Saved Application State/com.deneme.ornek.savedState/pencere.plist", 5 * kb, dolgu: 46)
        dosya("\(lib)/Preferences/com.deneme.ornek.plist", 2 * kb, dolgu: 47)
        dosya("\(lib)/Application Support/com.deneme.arac/veri.bin", 500 * kb, dolgu: 48)
        dosya("\(lib)/Preferences/com.deneme.arac.plist", 2 * kb, dolgu: 49)

        // Adım 4: sistem verileri
        dosya("\(lib)/Application Support/Claude/vm_bundles/imaj.img", 3 * mb, dolgu: 50)
        dosya("\(lib)/Application Support/com.eskisirket.silinmis/veri.bin", 2 * mb, dolgu: 51)
        dosya("\(lib)/Containers/com.eskisirket.kapsayici/Data/veri.bin", 1 * mb, dolgu: 52)
        dosya("\(ev)/.claude/projects/proje/oturum.jsonl", 1500 * kb, dolgu: 53)

        // Tuzaklar: dışarıyı gösteren sembolik bağlar (hedef deneme evinin dışında, yine geçici dizinde)
        dosya("\(disari)/degerli.txt", 10 * kb, dolgu: 60)
        dosya("\(disari)/klasor/icerik.txt", 10 * kb, dolgu: 61)
        _ = symlink("\(disari)/degerli.txt", "\(lib)/Caches/com.deneme.uygulama/tuzak-dosya")
        _ = symlink("\(disari)/klasor", "\(lib)/Caches/com.deneme.uygulama/tuzak-klasor")
        _ = symlink(disari, "\(ev)/Desktop/disari-bag")
        return .success(ev)
    }
}
