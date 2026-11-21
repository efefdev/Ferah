import Foundation
import Darwin

public enum Yontem: String, Codable, Sendable {
    case kalici
    case cop
}

public struct SilmeIstegi: Sendable {
    public let yol: String
    public let islem: Islem
    /// true: klasörün kendisi kalır, içindekiler silinir (önbellek klasörleri için).
    public let yalnizIcerik: Bool

    public init(yol: String, islem: Islem, yalnizIcerik: Bool = false) {
        self.yol = yol
        self.islem = islem
        self.yalnizIcerik = yalnizIcerik
    }
}

public struct IslemSonucu: Codable, Sendable {
    public enum Durum: String, Codable, Sendable { case tamam, kismen, kuru, reddedildi, hata }
    public let yol: String
    public var durum: Durum
    public var yontem: Yontem
    public var serbestBayt: Int64 = 0
    public var silinenDosya: Int = 0
    /// Kullanımda/kilitli olduğu için silinemeyen dosya sayısı.
    public var atlanan: Int = 0
    public var neden: Metin?
    public var copYolu: String?
    /// Kuru çalıştırmada silinecek olanlar.
    public var silinecekler: [String] = []
}

/// Silme ve taşımanın TEK yolu. Her çağrı önce Bekçi'den geçer.
public final class Silici: @unchecked Sendable {
    public let bekci: Bekci
    public var kuruCalistir: Bool
    public let depo: Depo?
    let copeTasiyici: (URL) throws -> URL?

    public init(bekci: Bekci, kuruCalistir: Bool = false, depo: Depo? = nil,
                copeTasiyici: ((URL) throws -> URL?)? = nil) {
        self.bekci = bekci
        self.kuruCalistir = kuruCalistir
        self.depo = depo
        self.copeTasiyici = copeTasiyici ?? { url in
            var sonuc: NSURL?
            try FileManager.default.trashItem(at: url, resultingItemURL: &sonuc)
            return sonuc as URL?
        }
    }

    public func uygula(_ istek: SilmeIstegi) -> IslemSonucu {
        let yontem: Yontem
        if case .kaliciSil = istek.islem { yontem = .kalici } else { yontem = .cop }
        var sonuc = IslemSonucu(yol: istek.yol, durum: .tamam, yontem: yontem)

        if istek.yalnizIcerik {
            // Klasörün kendisi silinmez; yalnız listelenir. Her çocuk ayrı ayrı denetlenir.
            guard case .kaliciSil = istek.islem else {
                sonuc.durum = .reddedildi
                sonuc.neden = Metin(.sYalnizIcerik)
                return sonuc
            }
            let ust: String
            switch bekci.kanonik(istek.yol) {
            case .failure(let h): sonuc.durum = .reddedildi; sonuc.neden = h.neden; return sonuc
            case .success(let k): ust = k
            }
            guard Yol.varMi(ust) else {
                sonuc.durum = .hata
                sonuc.neden = Metin(.sArtikYok)
                return sonuc
            }
            guard Yol.dizinMi(ust) else {
                sonuc.durum = .reddedildi
                sonuc.neden = Metin(.sKlasorDegil)
                return sonuc
            }
            guard let cocuklar = try? FileManager.default.contentsOfDirectory(atPath: ust) else {
                sonuc.durum = .hata
                sonuc.neden = Metin(.sKlasorOkunamadi)
                return sonuc
            }
            var reddedilen = 0
            for c in cocuklar {
                let alt = uygulaTek(Yol.ekle(ust, c), istek.islem, yontem: yontem)
                sonuc.serbestBayt += alt.serbestBayt
                sonuc.silinenDosya += alt.silinenDosya
                sonuc.atlanan += alt.atlanan
                sonuc.silinecekler += alt.silinecekler
                if alt.durum == .reddedildi { reddedilen += 1; sonuc.neden = alt.neden }
            }
            if kuruCalistir { sonuc.durum = .kuru }
            else if reddedilen > 0 && reddedilen == cocuklar.count && !cocuklar.isEmpty { sonuc.durum = .reddedildi }
            else if sonuc.atlanan > 0 || reddedilen > 0 { sonuc.durum = .kismen }
            if !kuruCalistir, sonuc.serbestBayt > 0 || sonuc.silinenDosya > 0 {
                depo?.gecmiseEkle([GecmisKaydi(tarih: Date(), yol: ust, boyut: sonuc.serbestBayt, yontem: yontem)])
            }
            return sonuc
        }

        sonuc = uygulaTek(istek.yol, istek.islem, yontem: yontem)
        // Geçmişe yalnız gerçekten bir şey silinen ya da taşınan işlemler yazılır.
        let gitti = sonuc.serbestBayt > 0 || sonuc.silinenDosya > 0 || !Yol.varMi(sonuc.yol)
        if !kuruCalistir, sonuc.durum == .tamam || sonuc.durum == .kismen, gitti {
            depo?.gecmiseEkle([GecmisKaydi(tarih: Date(), yol: sonuc.yol, boyut: sonuc.serbestBayt, yontem: yontem)])
        }
        return sonuc
    }

    private func uygulaTek(_ yol: String, _ islem: Islem, yontem: Yontem) -> IslemSonucu {
        var sonuc = IslemSonucu(yol: yol, durum: .tamam, yontem: yontem)
        let k: String
        switch bekci.denetle(yol, islem) {
        case .failure(let h):
            sonuc.durum = .reddedildi
            sonuc.neden = h.neden
            return sonuc
        case .success(let s):
            k = s
        }
        sonuc = IslemSonucu(yol: k, durum: .tamam, yontem: yontem)

        switch islem {
        case .copeTasi, .uygulamaCopeTasi:
            let o = Olcer.olc(k)
            sonuc.serbestBayt = o.bayt
            sonuc.silinenDosya = max(1, o.dosya)
            if kuruCalistir {
                sonuc.durum = .kuru
                sonuc.silinecekler = [k]
                return sonuc
            }
            do {
                let hedef = try copeTasiyici(URL(fileURLWithPath: k))
                sonuc.copYolu = hedef?.path
            } catch {
                sonuc.durum = .hata
                let e = error as NSError
                let izin = [NSFileWriteNoPermissionError, NSFileReadNoPermissionError].contains(e.code)
                    || (e.userInfo[NSUnderlyingErrorKey] as? NSError).map { $0.domain == NSPOSIXErrorDomain && ($0.code == Int(EPERM) || $0.code == Int(EACCES)) } == true
                sonuc.neden = izin
                    ? Metin(.sTasimaIzniYok)
                    : Metin(.ham, .yazi(e.localizedDescription))   // macOS'un kendi hata metni (sistem dilinde)
                sonuc.serbestBayt = 0
                sonuc.silinenDosya = 0
            }
            return sonuc
        case .kaliciSil:
            let r = agacSil(k, kuru: kuruCalistir)
            sonuc.serbestBayt = r.bayt
            sonuc.silinenDosya = r.dosya
            sonuc.atlanan = r.atlanan
            if kuruCalistir {
                sonuc.durum = .kuru
                sonuc.silinecekler = [k]
            } else if r.atlanan > 0 {
                sonuc.durum = r.dosya > 0 ? .kismen : .hata
                if r.dosya == 0 { sonuc.neden = Metin(.sKullanimda) }
            }
            return sonuc
        }
    }

    /// Sembolik bağları izlemeden (FTS_PHYSICAL) ağacı aşağıdan yukarı siler.
    /// Silinemeyen dosyalar sessizce atlanır ve sayılır.
    private func agacSil(_ k: String, kuru: Bool) -> (bayt: Int64, dosya: Int, atlanan: Int) {
        if kuru {
            // Kuru çalıştırma: aynı ölçerle (hard link ve APFS klonu farkında) ne açılacağını raporla.
            let o = Olcer.olc(k)
            return (o.bayt, o.dosya, o.okunamayan)
        }
        var bayt: Int64 = 0
        var dosya = 0
        var atlanan = 0
        Gezgin.gez(k) { g in
            switch g.tur {
            case .dizin:
                break
            case .dizinSonu:
                _ = rmdir(g.yolC)
            case .dosya, .bag, .diger:
                guard let st = g.st else { return .devam }
                // Silmeden HEMEN önce bu dosyanın gerçekten boşaltacağı yeri oku: başka bağlantısı kalan dosya
                // yer açmaz; APFS klonunda yalnız kendine ait bloklar açılır. Aynı ailenin son üyesi silinirken
                // özel boyutu tam boyuta çıkmış olur, böylece toplam doğru kalır.
                var acilacak: Int64 = 0
                if st.st_nlink <= 1 || (st.st_mode & S_IFMT) != S_IFREG {
                    acilacak = Int64(st.st_blocks) * 512
                    if (st.st_mode & S_IFMT) == S_IFREG, acilacak >= Olcer.klonEsigi,
                       let kb = Klon.oku(g.yolC), kb.paylasabilir {
                        acilacak = max(0, min(kb.ozel, acilacak))
                    }
                }
                if unlink(g.yolC) == 0 {
                    bayt += acilacak
                    dosya += 1
                } else {
                    atlanan += 1
                }
            case .okunamadi:
                atlanan += 1
            }
            return .devam
        }
        return (bayt, dosya, atlanan)
    }
}
