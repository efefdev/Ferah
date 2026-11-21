import Foundation
import CoreServices

/// Açıklama motoru için bağlam sinyallerini dosya sisteminden toplar (salt okunur).
public enum SinyalToplayici {
    /// /Applications, ~/Applications ve sistem uygulamalarının adları (".app" olmadan).
    public static func kuruluUygulamalar(ev: String = NSHomeDirectory()) -> [String] {
        var adlar: [String] = []
        for d in ["/Applications", "/Applications/Utilities", "/System/Applications", "/System/Applications/Utilities", Yol.ekle(ev, "Applications")] {
            guard let l = try? FileManager.default.contentsOfDirectory(atPath: d) else { continue }
            for x in l where x.hasSuffix(".app") { adlar.append(String(x.dropLast(4))) }
        }
        return adlar
    }

    static func harfAnahtari(_ s: String) -> String {
        String(Yol.katla(s).unicodeScalars.filter { CharacterSet.letters.contains($0) })
    }

    /// "Firefox 120.0.dmg" → "Firefox"; "googlechrome.dmg" → "Google Chrome".
    public static func eslesenUygulama(_ dosyaAdi: String, kurulu: [String]) -> String? {
        let govde = (dosyaAdi as NSString).deletingPathExtension
        // İlk rakama ya da ayraca kadar olan kısım.
        var on = ""
        for ch in govde {
            if ch.isNumber || ch == "-" || ch == "_" || ch == "(" { break }
            on.append(ch)
        }
        let anahtar = harfAnahtari(on.isEmpty ? govde : on)
        guard anahtar.count >= 3 else { return nil }
        for app in kurulu {
            let ak = harfAnahtari(app)
            guard ak.count >= 3 else { continue }
            if ak == anahtar { return app }
            if anahtar.count >= 4 && ak.hasPrefix(anahtar) { return app }
            if ak.count >= 4 && anahtar.hasPrefix(ak) { return app }
        }
        return nil
    }

    public static func bulutSaglayici(_ yol: String, ev: String) -> String? {
        if Yol.altinda(yol, Yol.ekle(ev, "Library/Mobile Documents")) { return "iCloud Drive" }
        let cs = Yol.ekle(ev, "Library/CloudStorage")
        if Yol.altinda(yol, cs) {
            let ilk = String(yol.dropFirst(cs.count + 1).split(separator: "/").first ?? "")
            if ilk.hasPrefix("Dropbox") { return "Dropbox" }
            if ilk.hasPrefix("GoogleDrive") { return "Google Drive" }
            if ilk.hasPrefix("OneDrive") { return "OneDrive" }
            if ilk.hasPrefix("Box") { return "Box" }
            return ilk.components(separatedBy: "-").first ?? "Bulut depolama"
        }
        if Yol.altinda(yol, Yol.ekle(ev, "Dropbox")) { return "Dropbox" }
        if Yol.altinda(yol, Yol.ekle(ev, "Google Drive")) { return "Google Drive" }
        if Yol.altinda(yol, Yol.ekle(ev, "OneDrive")) { return "OneDrive" }
        // Masaüstü ve Belgeler iCloud ile eşitleniyorsa
        if let v = try? URL(fileURLWithPath: yol).resourceValues(forKeys: [.isUbiquitousItemKey]), v.isUbiquitousItem == true {
            return "iCloud Drive"
        }
        return nil
    }

    static var gitYolu: String? {
        for p in ["/Library/Developer/CommandLineTools/usr/bin/git", "/Applications/Xcode.app/Contents/Developer/usr/bin/git",
                  "/opt/homebrew/bin/git", "/usr/local/bin/git"] where FileManager.default.isExecutableFile(atPath: p) {
            return p
        }
        return nil
    }

    /// Yolun içinde olduğu Git deposunun kökü (ev dizinine kadar çıkar).
    static func gitKoku(_ yol: String, ev: String) -> String? {
        var d = Yol.ebeveyn(yol)
        while Yol.esitVeyaAltinda(d, ev) && d != "/" {
            if Yol.varMi(Yol.ekle(d, ".git")) { return d }
            if Yol.katla(d) == Yol.katla(ev) { break }
            d = Yol.ebeveyn(d)
        }
        return nil
    }

    public static func gitIzliyor(_ yol: String, ev: String) -> Bool {
        guard let git = gitYolu, let kok = gitKoku(yol, ev: ev) else { return false }
        let goreli = String(yol.dropFirst(kok.count + 1))
        let p = Process()
        p.executableURL = URL(fileURLWithPath: git)
        p.arguments = ["-C", kok, "ls-files", "-z", "--", goreli]
        let boru = Pipe()
        p.standardOutput = boru
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return false }
        let veri = boru.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return p.terminationStatus == 0 && !veri.isEmpty
    }

    /// Şifreli disk imajları "encrcdsa" başlığıyla başlar (yalnız ilk 8 bayt okunur).
    public static func sifreliImajMi(_ yol: String) -> Bool {
        guard let h = FileHandle(forReadingAtPath: yol) else { return false }
        defer { try? h.close() }
        let v = (try? h.read(upToCount: 8)) ?? Data()
        return v == Data("encrcdsa".utf8)
    }

    /// İki dosyanın aynı içerikte olup olmadığını örnekleyerek tahmin eder:
    /// mantıksal boyut eşit ve baştan, ortadan, sondan 1 MB'lık parçalar aynıysa.
    public static func ayniIcerikMi(_ a: String, _ b: String) -> Bool {
        var sa = stat(), sb = stat()
        guard lstat(a, &sa) == 0, lstat(b, &sb) == 0, sa.st_size == sb.st_size, sa.st_size > 0 else { return false }
        if sa.st_dev == sb.st_dev && sa.st_ino == sb.st_ino { return false }
        guard let ha = FileHandle(forReadingAtPath: a), let hb = FileHandle(forReadingAtPath: b) else { return false }
        defer { try? ha.close(); try? hb.close() }
        let boyut = UInt64(sa.st_size)
        let parca: UInt64 = 1 << 20
        for ofset in [0, boyut / 2, boyut > parca ? boyut - parca : 0] {
            do {
                try ha.seek(toOffset: ofset)
                try hb.seek(toOffset: ofset)
                let x = try ha.read(upToCount: Int(parca)) ?? Data()
                let y = try hb.read(upToCount: Int(parca)) ?? Data()
                if x != y { return false }
            } catch {
                return false
            }
        }
        return true
    }

    /// Spotlight'ın "son kullanılma" tarihi.
    public static func sonKullanilma(_ yol: String) -> Date? {
        guard let item = MDItemCreate(kCFAllocatorDefault, yol as CFString),
              let d = MDItemCopyAttribute(item, kMDItemLastUsedDate) else { return nil }
        return d as? Date
    }

    static func sonDegisme(_ yol: String) -> Date? {
        var st = stat()
        guard lstat(yol, &st) == 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(st.st_mtimespec.tv_sec))
    }

    /// Proje klasöründeki (aday hariç) en son değişen öğenin tarihi.
    static func projeSonDegisme(_ aday: String) -> Date? {
        let proje = Yol.ebeveyn(aday)
        guard let l = try? FileManager.default.contentsOfDirectory(atPath: proje) else { return nil }
        var enSon: Date? = nil
        for x in l where Yol.ekle(proje, x) != aday && x != ".DS_Store" {
            if let d = sonDegisme(Yol.ekle(proje, x)), d > (enSon ?? .distantPast) { enSon = d }
        }
        return enSon
    }

    public static func topla(_ g: AdayGirdisi, ev: String, kurulu: [String]) -> Sinyaller {
        var s = Sinyaller()
        let u = Yol.uzanti(g.ad)
        let ebeveyn = Yol.ebeveyn(g.yol)
        if ["dmg", "pkg", "mpkg"].contains(u) {
            s.kuruluUygulama = eslesenUygulama(g.ad, kurulu: kurulu)
        }
        if u == "dmg" || u == "sparseimage" {
            s.sifreliImaj = sifreliImajMi(g.yol)
        }
        if AciklamaMotoru.arsivler.contains(u) {
            var govde = g.ad
            for son in [".tar.gz", ".tar.bz2", ".tar.xz", ".tar.zst", ".tgz", ".tbz", ".txz", ".\(u)"] where Yol.katla(govde).hasSuffix(son) {
                govde = String(govde.dropLast(son.count))
                break
            }
            s.acilmisHaliYaninda = !govde.isEmpty && Yol.dizinMi(Yol.ekle(ebeveyn, govde))
        }
        if u.hasPrefix("blend"), u != "blend" {
            let asil = (g.ad as NSString).deletingPathExtension + ".blend"
            s.asilDosyaYaninda = Yol.varMi(Yol.ekle(ebeveyn, asil))
        }
        s.bulut = bulutSaglayici(g.yol, ev: ev)
        if g.ozelTur == nil || g.ozelTur == .derlemeCiktisi {
            s.gitIzleniyor = gitIzliyor(g.yol, ev: ev)
        }
        switch g.ozelTur {
        case .nodeModules, .sanalOrtam, .pods, .derlemeCiktisi:
            s.projeSonDegisme = projeSonDegisme(g.yol)
        case .iosYedegi:
            if let pl = NSDictionary(contentsOfFile: Yol.ekle(g.yol, "Info.plist")) {
                s.cihazAdi = pl["Device Name"] as? String ?? pl["Display Name"] as? String
                s.sonYedek = pl["Last Backup Date"] as? Date
            }
        default:
            break
        }
        return s
    }
}
