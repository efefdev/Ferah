import Foundation
import FerahCore

/// Arayüzün o anki dili. Yalnız ana iş parçacığında, `Durum.dil` değişince güncellenir.
/// (Çekirdek bu değeri okumaz; dil çekirdeğe her zaman parametre olarak geçer.)
enum EtkinDil {
    nonisolated(unsafe) static var deger: Dil = .tr
}

/// Arayüz metni: anahtar + argümanlar, etkin dilde.
func T(_ a: M, _ args: MetinArg...) -> String { Metin(a, dizi: args)(EtkinDil.deger) }

extension Metin {
    /// Etkin dilde metin.
    var s: String { self(EtkinDil.deger) }
}

/// Etkin dilde boyut, sayı, göreli tarih.
func B(_ b: Int64) -> String { Bicim.bayt(b, EtkinDil.deger) }
func N(_ n: Int) -> String { Bicim.sayi(n, EtkinDil.deger) }
func G(_ d: Date) -> String { Bicim.goreli(d, EtkinDil.deger) }

/// Kullanıcının uygulama içi dil seçimi.
enum DilTercihi: String, CaseIterable, Identifiable {
    case sistem, tr, en
    var id: String { rawValue }

    var dil: Dil? {
        switch self {
        case .sistem: return nil
        case .tr: return .tr
        case .en: return .en
        }
    }

    /// Dil adları her dilde kendi adıyla gösterilir.
    var etiket: String {
        switch self {
        case .sistem: return T(.gDilSistem)
        case .tr: return "Türkçe"
        case .en: return "English"
        }
    }
}

enum DilSecimi {
    static let anahtar = "FerahDil"
    /// `--dil` ile zorlanan dil (kalıcı tercihi ezer, kaydedilmez).
    nonisolated(unsafe) static var zorla: Dil?
    /// Deneme kipinde tercih kaydedilmez (gerçek uygulamayla aynı ayar alanını paylaşır).
    nonisolated(unsafe) static var kaydetmeIzni = true
    /// Uygulama açılırken okunan sistem dil tercihleri (AppleLanguages değiştirilmeden önce).
    nonisolated(unsafe) static var sistemTercihleri: [String] = Locale.preferredLanguages
    /// Uygulama açılırken seçilen dil (menüler bu dilde kalır; değişince yeniden başlatma notu gösterilir).
    nonisolated(unsafe) static var acilisDili: Dil = .tr

    static func kayitliTercih() -> DilTercihi {
        DilTercihi(rawValue: UserDefaults.standard.string(forKey: anahtar) ?? "") ?? .sistem
    }

    static func kaydet(_ t: DilTercihi) {
        guard kaydetmeIzni, zorla == nil else { return }
        if t == .sistem { UserDefaults.standard.removeObject(forKey: anahtar) }
        else { UserDefaults.standard.set(t.rawValue, forKey: anahtar) }
    }

    static func hesapla(_ t: DilTercihi) -> Dil {
        Dil.sec(zorla: zorla, elle: t.dil, sistem: sistemTercihleri)
    }

    /// macOS'un kendi metinleri (menüler, sistem pencereleri) için uygulama dilini ayarlar.
    /// Yalnız bu süreçte geçerlidir (geçici argüman alanı); kullanıcının ayarlarına yazılmaz.
    static func sistemMetinleriniAyarla(_ dil: Dil) {
        var alan = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        alan["AppleLanguages"] = [dil.rawValue]
        UserDefaults.standard.setVolatileDomain(alan, forName: UserDefaults.argumentDomain)
    }
}
