import Foundation
import Darwin

/// macOS'un "veri bulutta, yerelde yok" bayrağı (SF_DATALESS).
public let dosyaVerisizBayragi: UInt32 = 0x4000_0000

struct InodeAnahtar: Hashable {
    let dev: Int32
    let ino: UInt64
}

/// Hard link'leri bir kez saymak için iş parçacığı güvenli inode kümesi.
public final class InodeKumesi: @unchecked Sendable {
    private var kume = Set<InodeAnahtar>()
    private let kilit = NSLock()
    public init() {}

    /// İlk kez görüldüyse true.
    public func ekle(dev: Int32, ino: UInt64) -> Bool {
        kilit.lock()
        defer { kilit.unlock() }
        return kume.insert(InodeAnahtar(dev: dev, ino: ino)).inserted
    }
}

public enum GezKarar { case devam, atla, dur }

public struct GezOgesi {
    public enum Tur { case dizin, dizinSonu, dosya, bag, okunamadi(Int32), diger }
    public let tur: Tur
    public let seviye: Int
    let ent: UnsafeMutablePointer<FTSENT>

    public var yol: String { String(cString: ent.pointee.fts_path) }
    var yolC: UnsafeMutablePointer<CChar> { ent.pointee.fts_path }

    public var st: stat? {
        switch tur {
        case .okunamadi, .dizinSonu: return nil
        default:
            guard let p = ent.pointee.fts_statp else { return nil }
            return p.pointee
        }
    }
}

/// fts(3) tabanlı, sembolik bağları izlemeyen (FTS_PHYSICAL), birim sınırını aşmayan (FTS_XDEV) gezgin.
public enum Gezgin {
    @discardableResult
    public static func gez(_ kok: String, _ ziyaret: (GezOgesi) -> GezKarar) -> Bool {
        guard let c = strdup(kok) else { return false }
        defer { free(c) }
        var argv: [UnsafeMutablePointer<CChar>?] = [c, nil]
        guard let fts = fts_open(&argv, FTS_PHYSICAL | FTS_NOCHDIR | FTS_XDEV, nil) else { return false }
        defer { fts_close(fts) }
        while let ent = fts_read(fts) {
            let info = Int32(ent.pointee.fts_info)
            let tur: GezOgesi.Tur
            switch info {
            case FTS_D: tur = .dizin
            case FTS_DP: tur = .dizinSonu
            case FTS_F: tur = .dosya
            case FTS_SL, FTS_SLNONE: tur = .bag
            case FTS_DNR, FTS_ERR, FTS_NS: tur = .okunamadi(ent.pointee.fts_errno)
            default: tur = .diger
            }
            let o = GezOgesi(tur: tur, seviye: Int(ent.pointee.fts_level), ent: ent)
            switch ziyaret(o) {
            case .devam: break
            case .atla: if info == FTS_D { fts_set(fts, ent, FTS_SKIP) }
            case .dur: return true
            }
        }
        return true
    }
}

public struct Olcum: Codable, Sendable {
    /// Silinince gerçekten açılacak yer: ayrılmış boyut; APFS klonlarında yalnız dosyanın kendine ait blokları
    /// (klon ailesinin tüm üyeleri bu ölçümdeyse paylaşılan kısım bir kez eklenir).
    public var bayt: Int64 = 0
    /// Klonlarla paylaşılan ve bu ölçümün dışındaki dosyalar yüzünden boşalmayacak bayt (bilgi).
    public var paylasilan: Int64 = 0
    public var dosya: Int = 0
    public var okunamayan: Int = 0
    public var kokErisimYok = false
    public var yok = false
    public init() {}
}

/// APFS klon bilgisi (getattrlist + FSOPT_ATTR_CMN_EXTENDED; bkz. man getattrlist).
public struct KlonBilgisi: Sendable {
    /// ATTR_CMNEXT_PRIVATESIZE: silinirse hemen boşalacak, klon ya da anlık görüntüde tutulmayan bayt.
    public let ozel: Int64
    /// ATTR_CMNEXT_CLONEID: saf klonlarda ortak.
    public let klonKimligi: UInt64
    /// ATTR_CMNEXT_CLONE_REFCNT: aynı veri akışını paylaşan saf klon sayısı (kendisi dahil).
    public let refSayisi: UInt32
    /// EF_MAY_SHARE_BLOCKS
    public let paylasabilir: Bool
    /// EF_SHARES_ALL_BLOCKS
    public let tamKlon: Bool
}

public enum Klon {
    static let efMayShareBlocks: UInt64 = 0x1
    static let efSharesAllBlocks: UInt64 = 0x40

    /// Dosyanın klon bilgisini okur; birim desteklemiyorsa ya da okunamazsa nil.
    public static func oku(_ yolC: UnsafePointer<CChar>) -> KlonBilgisi? {
        var al = attrlist()
        al.bitmapcount = u_short(ATTR_BIT_MAP_COUNT)
        al.commonattr = attrgroup_t(ATTR_CMN_RETURNED_ATTRS)
        al.forkattr = attrgroup_t(ATTR_CMNEXT_PRIVATESIZE | ATTR_CMNEXT_CLONEID | ATTR_CMNEXT_EXT_FLAGS | ATTR_CMNEXT_CLONE_REFCNT)
        var tampon = [UInt8](repeating: 0, count: 128)
        let r = tampon.withUnsafeMutableBytes { b in
            getattrlist(yolC, &al, b.baseAddress, b.count, UInt32(FSOPT_ATTR_CMN_EXTENDED | FSOPT_NOFOLLOW))
        }
        guard r == 0 else { return nil }
        return tampon.withUnsafeBytes { b -> KlonBilgisi? in
            var o = MemoryLayout<UInt32>.size
            let donen = b.loadUnaligned(fromByteOffset: o, as: attribute_set_t.self)
            o += MemoryLayout<attribute_set_t>.size
            var ozel: Int64? = nil, kimlik: UInt64 = 0, bayrak: UInt64 = 0, ref: UInt32 = 1
            if donen.forkattr & attrgroup_t(ATTR_CMNEXT_PRIVATESIZE) != 0 { ozel = b.loadUnaligned(fromByteOffset: o, as: Int64.self); o += 8 }
            if donen.forkattr & attrgroup_t(ATTR_CMNEXT_CLONEID) != 0 { kimlik = b.loadUnaligned(fromByteOffset: o, as: UInt64.self); o += 8 }
            if donen.forkattr & attrgroup_t(ATTR_CMNEXT_EXT_FLAGS) != 0 { bayrak = b.loadUnaligned(fromByteOffset: o, as: UInt64.self); o += 8 }
            if donen.forkattr & attrgroup_t(ATTR_CMNEXT_CLONE_REFCNT) != 0 { ref = b.loadUnaligned(fromByteOffset: o, as: UInt32.self); o += 4 }
            guard let ozel else { return nil }
            return KlonBilgisi(ozel: ozel, klonKimligi: kimlik, refSayisi: ref,
                               paylasabilir: bayrak & efMayShareBlocks != 0, tamKlon: bayrak & efSharesAllBlocks != 0)
        }
    }
}

/// Bir ölçüm boyunca inode ve klon ailesi muhasebesi.
final class OlcumHesabi {
    let inodlar: InodeKumesi
    var aileler: [UInt64: (ref: UInt32, gorulen: UInt32, paylasilan: Int64)] = [:]
    init(_ inodlar: InodeKumesi) { self.inodlar = inodlar }

    /// Dosyanın bu ölçüme katkısı. Klon değilse ayrılmış boyut.
    func katki(_ st: stat, _ yolC: UnsafePointer<CChar>?, _ o: inout Olcum) -> Int64 {
        let b = Olcer.ayrilmis(st, inodlar)
        guard b >= Olcer.klonEsigi, b > 0, (st.st_mode & S_IFMT) == S_IFREG, let yolC,
              let k = Klon.oku(yolC), k.paylasabilir else { return b }
        let ozel = max(0, min(k.ozel, b))
        let pay = b - ozel
        if k.tamKlon && k.refSayisi > 1 {
            var a = aileler[k.klonKimligi] ?? (k.refSayisi, 0, 0)
            a.gorulen += 1
            a.paylasilan = max(a.paylasilan, pay)
            aileler[k.klonKimligi] = a
        } else {
            o.paylasilan += pay
        }
        return ozel
    }

    /// Ölçüm sonunda: ailenin tüm üyeleri görüldüyse paylaşılan kısım bir kez eklenir.
    func bitir(_ o: inout Olcum) {
        for (_, a) in aileler {
            if a.gorulen >= a.ref { o.bayt += a.paylasilan } else { o.paylasilan += a.paylasilan }
        }
    }
}

public enum Olcer {
    /// Bu boyuttan küçük dosyalarda klon bilgisi okunmaz (hız). Sınamalar 0 yapabilir.
    nonisolated(unsafe) public static var klonEsigi: Int64 = 1_000_000

    /// Diskte ayrılmış gerçek boyut (st_blocks × 512 = fileAllocatedSize). Seyrek dosyalar şişirilmez,
    /// birden çok bağlantılı dosyalar inode kümesiyle bir kez sayılır.
    static func ayrilmis(_ st: stat, _ inodlar: InodeKumesi) -> Int64 {
        let b = Int64(st.st_blocks) * 512
        if st.st_nlink > 1, (st.st_mode & S_IFMT) == S_IFREG {
            if !inodlar.ekle(dev: st.st_dev, ino: st.st_ino) { return 0 }
        }
        return b
    }

    /// Tek bir dosyanın silinince açılacak boyutu (klon farkında).
    public static func dosyaKazanci(_ yol: String) -> Int64 {
        var st = stat()
        guard lstat(yol, &st) == 0 else { return 0 }
        var o = Olcum()
        let h = OlcumHesabi(InodeKumesi())
        return yol.withCString { h.katki(st, $0, &o) }
    }

    public static func olc(_ yol: String, inodlar: InodeKumesi? = nil, iptal: (() -> Bool)? = nil) -> Olcum {
        let hesap = OlcumHesabi(inodlar ?? InodeKumesi())
        var o = Olcum()
        var sayac = 0
        let acildi = Gezgin.gez(yol) { g in
            sayac += 1
            if sayac & 1023 == 0, let iptal, iptal() { return .dur }
            switch g.tur {
            case .okunamadi(let e):
                if g.seviye == 0 {
                    if e == ENOENT || e == ENOTDIR { o.yok = true } else { o.kokErisimYok = true }
                } else {
                    o.okunamayan += 1
                }
            case .dizinSonu:
                break
            case .dosya:
                if let st = g.st { o.bayt += hesap.katki(st, g.yolC, &o); o.dosya += 1 }
            case .dizin, .bag, .diger:
                if let st = g.st { o.bayt += ayrilmis(st, hesap.inodlar) }
            }
            return .devam
        }
        hesap.bitir(&o)
        if !acildi { o.yok = true }
        return o
    }
}
