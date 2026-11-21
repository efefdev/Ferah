// BU DOSYA ÜRETİLDİ — elle düzenleme. Kaynak: araclar/metinler.tsv
// Yeniden üretmek için: python3 araclar/metinleri-uret.py

/// Metin anahtarları. Her anahtarın tüm dillerde karşılığı vardır (bkz. `cift`).
public enum M: String, CaseIterable, Codable, Sendable {
    case birlesim
    case ham
    case parantez
    case ikili
    case uclu
    case riskGuvenli
    case riskDikkat
    case riskRiskli
    case riskDokunma
    case sureGun
    case sureHafta
    case sureAy
    case sureYil
    case oneriSilinebilir
    case oneriBakVeKararVer
    case oneriSakla
    case oneriDokunma
    case bulutDepolama
    case aEditorTur
    case aEditorNe
    case aEditorGeri
    case aEditorOneri
    case aSifreliImajTur
    case aDiskImajiTur
    case aSifreliImajNe
    case aGizliDmgNe
    case aYedekYoksaGelmez
    case aXipTur
    case aKurulumTur
    case aKurulumKuruluNe
    case aKurulumKuruluGeri
    case aKurulumNe
    case aKurulumGeri
    case aIpswTur
    case aIpswNe
    case aIpswGeri
    case aIsoTur
    case aIsoNe
    case aIsoGeri
    case aVmTur
    case aVmNe
    case aVmOneri
    case aSparseNe
    case aSparseOneri
    case aFcpTur
    case aFcpNe
    case aFcpOneri
    case aLogicTur
    case aBandTur
    case aMuzikProjeNe
    case aImovieTur
    case aImovieNe
    case aBlendYedekTur
    case aBlendYedekVarNe
    case aBlendYedekYokNe
    case aSilinirseGelmez
    case aBlendTur
    case aBlendNe
    case aDbTur
    case aDbNe
    case aModelTur
    case aModelNe
    case aModelGeri
    case aEkranKaydiTur
    case aEkranKaydiNe
    case aBaskaKopyaYoksa
    case aVideoTur
    case aVideoNe
    case aYalnizKopyaVarsa
    case aVideoOneri
    case aPsdTur
    case aGorselTur
    case aGorselNe
    case aSesTur
    case aSesNe
    case aArsivTur
    case aArsivAcilmisNe
    case aArsivAcilmisGeri
    case aArsivAcilmisOneri
    case aArsivNe
    case aArsivGeri
    case aArsivOneri
    case aAppTur
    case aAppNe
    case aAppGeri
    case aXcarchiveTur
    case aXcarchiveNe
    case aXcarchiveGeri
    case aLogTur
    case aLogNe
    case aKutuphaneTur
    case aKutuphaneNe
    case aKutuphaneGeri
    case aKutuphaneOneri
    case aBelgeTur
    case aBelgeNe
    case aPaketTur
    case aKlasorTur
    case aUzantisizTur
    case aBilinmeyenTur
    case aBilinmeyenNe
    case aBilinmeyenOneri
    case aKorunanTur
    case aFerahSilmez
    case aFotoKitTur
    case aFotoKitNe
    case aFotoKitOneri
    case aMuzikKitTur
    case aMuzikKitNe
    case aMuzikKitOneri
    case aTvKitTur
    case aTvKitNe
    case aTvKitOneri
    case aUygTur
    case aUygKorunanNe
    case aUygKorunanOneri
    case aNodeTur
    case aNodeNe
    case aNodeGeri
    case aVenvTur
    case aVenvNe
    case aVenvGeri
    case aPodsTur
    case aPodsNe
    case aPodsGeri
    case aDerlemeTur
    case aDerlemeNe
    case aDerlemeGeri
    case aIosYedekTur
    case aIosYedekCihazNe
    case aIosYedekNe
    case aIosYedekGeri
    case aIosYedekOneri
    case aDockerTur
    case aDockerNe
    case aDockerGeri
    case aDockerOneri
    case aHfTur
    case aHfNe
    case aHfGeri
    case aOllamaTur
    case aOllamaNe
    case aOllamaGeri
    case aOllamaOneri
    case aSteamTur
    case aSteamNe
    case aSteamGeri
    case aSteamOneri
    case aBglOnbellek
    case aBglKlon
    case aBglKopya
    case aBglBulut
    case aBglGit
    case aBglProje
    case aBglSonYedek
    case aBglAcilmamis
    case aBglDegismemis
    case bEvKendisi
    case bEvUstu
    case bStandart
    case bKokKlasor
    case bKorunanVeri
    case bIcindeKorunan
    case bFotoKit
    case bMuzikKit
    case bTvKit
    case bAnahtarZinciri
    case bAppKlasoru
    case bYolYok
    case bSembolikApp
    case bAppDegil
    case bAppKoku
    case bAppKokDisi
    case bInfoPlistYok
    case bApple
    case bCalisiyor
    case bKendisi
    case bBosYol
    case bNul
    case bGoreli
    case bKokDizin
    case bSonBilesen
    case bUstYok
    case bEvDisi
    case bKokYok
    case bKategoriDisi
    case sYalnizIcerik
    case sArtikYok
    case sKlasorDegil
    case sKlasorOkunamadi
    case sTasimaIzniYok
    case sKullanimda
    case dMutlak
    case dKlasorYok
    case dYasak
    case dGecici
    case dKurulamadi
    case katUygulamaOnbellek
    case katGunlukler
    case katTarayici
    case katGelistirici
    case katCop
    case katEskiKurulum
    case katXcodeArsiv
    case katSimulator
    case katUygulamaOnbellekAc
    case katGunluklerAc
    case katTarayiciAc
    case katGelistiriciAc
    case katCopAc
    case katEskiKurulumAc
    case katXcodeArsivAc
    case katSimulatorAc
    case katOnbellegi
    case katSimOnbellek
    case katDeposu
    case katIndirmeleri
    case katCargo
    case katGoDerleme
    case katTarayiciOnbellek
    case katNotCalisiyor
    case katNotMacos
    case katNotTarayiciAcik
    case katNotPnpm
    case katNotIndirildi
    case katNotSimulator
    case uKaynakAppStore
    case uKaynakGelistirici
    case uKaynakApple
    case uSilApple
    case uSilKisayol
    case uSilCalisiyor
    case uArtikVeri
    case uArtikOnbellek
    case uArtikKapsayici
    case uArtikPencere
    case uArtikAg
    case uArtikWeb
    case uArtikGunluk
    case uBoyutKisayol
    case uBoyutBaskaYer
    case uBilinmiyor
    case uTur
    case uNeTasinir
    case uNeVeriGider
    case uNeVeriKalir
    case uGeriAppStore
    case uGeriGelistirici
    case uNedenSistem
    case uNedenGuvenlik
    case uNedenAdobe
    case uNedenOffice
    case uOneriKaldirici
    case uOneriKaldiriciAdi
    case uBglIntel
    case uBglDocker
    case uBglOyun
    case uBglCC
    case uBglVm
    case uBglAndroid
    case uBglSonKullanim
    case uBglHicEklendi
    case uOneriYeni
    case uBglDegisme
    case uBglBilinmiyor
    case uBglErisilemedi
    case svEylemFerah
    case svEylemAdim1
    case svEylemUyg
    case svEylemYeniden
    case svEylemDokunma
    case svEylemBilgi
    case svOlcTde
    case svOlcIzin
    case svOlcGuvenilmez
    case svKisiselTur
    case svKisiselNe
    case svKisiselMetin
    case svClaudeVmTur
    case svClaudeVmNe
    case svClaudeVmGeri
    case svClaudeVmMetin
    case svClaudeTur
    case svClaudeNe
    case svClaudeMetin
    case svClaudeCodeProjeTur
    case svClaudeCodeProjeNe
    case svGeriGelmez
    case svClaudeCodeProjeMetin
    case svClaudeCodeTur
    case svClaudeCodeNe
    case svClaudeCodeMetin
    case svWhatsappTur
    case svWhatsappNe
    case svWhatsappMetin
    case svTelegramTur
    case svTelegramNe
    case svTelegramMetin
    case svSignalTur
    case svSignalNe
    case svSignalMetin
    case svDockerTur
    case svDockerNe
    case svDockerMetin
    case svDriveTur
    case svDriveNe
    case svDriveMetin
    case svProfilTur
    case svProfilNe
    case svProfilMetin
    case svGoogleTur
    case svGoogleNe
    case svGoogleMetin
    case svXcodeTur
    case svXcodeNe
    case svXcodeMetin
    case svSimTur
    case svSimNe
    case svSimMetin
    case svGelistiriciTur
    case svGelistiriciNe
    case svIosYedekTur
    case svIosYedekNe
    case svIosYedekMetin
    case svMailTur
    case svMailNe
    case svMailMetin
    case svMesajTur
    case svMesajNe
    case svMesajMetin
    case svFotoTur
    case svFotoNe
    case svOnbellekTur
    case svOnbellekNe
    case svGunlukTur
    case svGunlukNe
    case svOyunTur
    case svOyunNe
    case svOyunMetin
    case svCrossoverTur
    case svCrossoverNe
    case svCrossoverMetin
    case svAracTur
    case svAracNe
    case svAracGeri
    case svAracMetin
    case svPaketYonTur
    case svPaketYonNe
    case svCacheTur
    case svCacheNe
    case svCacheGeri
    case svOllamaTur
    case svOllamaNe
    case svOllamaMetin
    case svKapsayiciTur
    case svKapsayiciNe
    case svSahipliTur
    case svSahipliNe
    case svSahipliMetin
    case svSahipsizTur
    case svSahipsizNe
    case svSahipsizMetin
    case svKorunanTur
    case svLibKokTur
    case svLibKokNe
    case svLibKokMetin
    case svBilinmeyenTur
    case svBilinmeyenMetin
    case svGuncellemeTur
    case svGuncellemeNe
    case svGuncellemeMetin
    case svTakasTur
    case svTakasNe
    case svTakasMetin
    case svFoldersTur
    case svFoldersNe
    case svFoldersMetin
    case svTmpTur
    case svTmpNe
    case svTmpMetin
    case svCltTur
    case svCltNe
    case svCltMetin
    case svDbTur
    case svDbNe
    case svDbMetin
    case svLibTur
    case svLibNe
    case svLibMetin
    case svAppsTur
    case svAppsNe
    case svAppsMetin
    case svSistemTur
    case svSistemNe
    case gSec
    case gSecErisim
    case gSecili
    case gKismenSecili
    case gSeciliDegil
    case gKullanilan
    case gSeciliBaslik
    case gKazanilan
    case gBos
    case gToplam
    case gDilSistem
    case gDil
    case gDilNot
    case dBanner
    case dBannerErisim
    case gAdimErisim
    case gBuOturumda
    case gCopte
    case adimGuvenli
    case adimBuyuk
    case adimUyg
    case adimSistem
    case adimOzet
    case adimGuvenliAlt
    case adimBuyukAlt
    case adimUygAlt
    case adimSistemAlt
    case adimOzetAlt
    case suzAltiAy
    case suzUcAy
    case suzBirYil
    case suzKayitYok
    case suzTumu
    case uOzetAlti
    case uOzetUc
    case uOzetYil
    case uOzetKayitsiz
    case uOzetTumu
    case sirEskiKullanim
    case sirBoyut
    case sirAd
    case gTasinamadi
    case g1OnayBaslik
    case g1KaliciSil
    case gVazgec
    case g1OnayMesaj
    case g1Alt
    case g1KategoriIlerleme
    case gIptal
    case gYenidenTara
    case gTara
    case g1HenuzTaranmadi
    case g1BosAciklama
    case g1Temiz
    case g1TemizAciklama
    case gTaraniyor
    case g1Temizleniyor
    case g1SeciliBoyut
    case g1SeciliAlt
    case g1BuyugeGec
    case g1Temizle
    case g1DosyaSilindi
    case g1Atlandi
    case g1Reddedildi
    case g1YerAcildi
    case g1RaporKapat
    case g1OgeSayisi
    case gErisimYok
    case g1Erisilemedi
    case gTdeVer
    case gCalisiyorEtiket
    case g1DosyaSayisi
    case gFinderdaGosterErisim
    case gFinderdaGoster
    case g2Alt
    case g2Esik
    case g2EsikYardim
    case g2Gorunum
    case g2KartGorunumu
    case g2ListeGorunumu
    case g2BosBaslik
    case g2BosAciklama
    case g2Yok
    case g2YokAciklama
    case g2Incelendi
    case g2Sira
    case g2CopeTasinan
    case g2TekOnayBaslik
    case gCopeTasi
    case g2TekOnayMesaj
    case g2Bitti
    case g2BittiAciklama
    case g2BasaDon
    case g2UygulamalaraGec
    case g2DahaOnceSakladin
    case g2SonAcilma
    case g2Degisme
    case g2KopyaTasindi
    case gSakla
    case g2SaklaYardim
    case gGozAt
    case g2GozAtYardim
    case g2Onceki
    case g2CopeTasiYardim
    case g2SilmezYardim
    case g2Korunuyor
    case g2Klavye
    case g2CopeTasindi
    case g2Saklandi
    case g2Tasinamadi
    case gSilersenNeOlur
    case gGeriNasilGelir
    case gOneriAyrac
    case g2SutunAd
    case g2SutunBoyut
    case g2SutunTur
    case g2SutunRisk
    case g2SutunDurum
    case g2Copte
    case g2SaklandiBuyuk
    case g2OncedenSaklandi
    case g2SeciliOzet
    case g2SecilenleriCopeTasi
    case g2TopluOnayBaslik
    case g2TopluOnayMesaj
    case g2KorunanAtlanacak
    case g3TekOnayBaslik
    case g3CokOnayBaslik
    case g3Verileriyle
    case g3VeDahasi
    case g3OnayMesaj
    case g3Atlanacak
    case g3Alt
    case g3Suzgec
    case g3Ara
    case g3AraErisim
    case g3AppleGoster
    case g3AppleYardim
    case g3Sirala
    case g3Siralama
    case g3BosBaslik
    case g3BosAciklama
    case g3Inceleniyor
    case g3CokSecili
    case g3CokSeciliAciklama
    case g3BirSec
    case g3BirSecAciklama
    case g3CokluSecim
    case g3SeciliSayisi
    case g3CopeTasiKisa
    case g3CopeTasiYardim
    case g3SistemeGec
    case g3Apple
    case g3Intel
    case g3CalisiyorEtiket
    case g3Olculemedi
    case g3ArtikVeri
    case g3BoyutOlculemediErisim
    case g3SatirErisim
    case g3SonKullanim
    case g3HicEklendi
    case g3KayitYokDegisti
    case g3TarihBilinmiyor
    case g3Surum
    case g3BoyutOlculemedi
    case g3IntelRosetta
    case g3GerideKalan
    case g3Erisilemedi
    case g3Ac
    case g3VerileriKaldir
    case g4Alt
    case g4OnayMesaj
    case g4Olculenler
    case g4Diger
    case g4Olculemeyenler
    case g4BirKalemSec
    case g4BirKalemAciklama
    case g4Olculuyor
    case g4BosBaslik
    case g4BosAciklama
    case g4Olculen
    case g4Tahmini
    case g4TahminDegeri
    case g4AnlikGoruntu
    case g4DenemeNotu
    case g4TahminNotu
    case g4TdeYok
    case g4KisaFerah
    case g4KisaAdim1
    case g4KisaUyg
    case g4KisaYeniden
    case g4KisaDokunma
    case g4KisaBilgi
    case g4Sahipsiz
    case g4Guvenilmez
    case g4OlculemediKisa
    case g4OlculemediBuyuk
    case g4AitOlduguUyg
    case g4SahipsizUyari
    case g4Kismen
    case g4Adim1eGit
    case g4EvDisi
    case g5Alt
    case g5YerAcildi
    case g5Kalici
    case g5OgeSayisi
    case g5CopBosaltildi
    case g5CopBosalinca
    case g5Adim2
    case g5OgeVeNot
    case g5Uyg
    case g5UygSayisi
    case g5UygVeri
    case g5Sistem
    case g5CopBosaltilincaAcilan
    case g5Saklanan
    case g5SaklananNot
    case g5Atlanan
    case g5AtlananNot
    case g5Reddedilen
    case g5Disk
    case g5Once
    case g5Simdi
    case g5BosDeger
    case g5GecikmeNotu
    case g5Reddedilenler
    case g5CopuBosalt
    case g5Gecmis
    case g5BastanTara
    case g5BosaltBaslik
    case g5KaliciBosalt
    case g5Bosaltildi
    case g5ErisimYok
    case g5BosaltMesaj
    case g5BosaltMesajGenel
    case g5IslemSayisi
    case g5HenuzIslemYok
    case g5Tarih
    case g5Yol
    case g5Yontem
    case g5KaliciSilindi
    case g5CopeTasindi
    case g5Kayit
    case g5Kapat
    case cMimariIntel
    case cMimariEvrensel
    case cDiger
    case cEsikHata
    case cYardim
    case cDenemeKuruldu
    case cReddedildi
    case cKurKlasorBekler
    case cDegerBekler
    case cBilinmeyenBayrak
    case cTemaHata
    case cDilHata
    case cDenemeReddedildi
    case cDenemeOnayHata
}

extension M {
    /// (Türkçe, English)
    public var cift: (String, String) {
        switch self {
        case .birlesim: return ("", "")
        case .ham: return ("{0}", "{0}")
        case .parantez: return ("{0} ({1})", "{0} ({1})")
        case .ikili: return ("{0} — {1}", "{0} — {1}")
        case .uclu: return ("{0} — {1} — {2}", "{0} — {1} — {2}")
        case .riskGuvenli: return ("Güvenli", "Safe")
        case .riskDikkat: return ("Dikkat", "Caution")
        case .riskRiskli: return ("Riskli", "Risky")
        case .riskDokunma: return ("Dokunma", "Don't touch")
        case .sureGun: return ("{0} gündür", "{0} day||{0} days")
        case .sureHafta: return ("{0} haftadır", "{0} week||{0} weeks")
        case .sureAy: return ("{0} aydır", "{0} month||{0} months")
        case .sureYil: return ("{0} yıldır", "{0} year||{0} years")
        case .oneriSilinebilir: return ("Silinebilir", "Safe to delete")
        case .oneriBakVeKararVer: return ("Bakıp karar ver", "Look first, then decide")
        case .oneriSakla: return ("Saklaman önerilir", "Better to keep")
        case .oneriDokunma: return ("Ferah bunu silmez", "Ferah won't delete this")
        case .bulutDepolama: return ("Bulut depolama", "Cloud storage")
        case .aEditorTur: return ("Editör eklentisinin parçası", "Part of an editor extension")
        case .aEditorNe: return ("Kurulu bir editör eklentisinin ({0}) dosyası. Silersen eklenti bozulur.", "A file from an installed editor extension ({0}). Deleting it breaks the extension.")
        case .aEditorGeri: return ("Eklentiyi editörden kaldırıp yeniden kurarak.", "Remove and reinstall the extension in the editor.")
        case .aEditorOneri: return ("Yer açmak istiyorsan eklentiyi editörün Eklentiler bölümünden kaldır.", "To free up space, uninstall the extension from the editor's Extensions panel.")
        case .aSifreliImajTur: return ("Şifreli disk imajı (.{0})", "Encrypted disk image (.{0})")
        case .aDiskImajiTur: return ("Disk imajı (.{0})", "Disk image (.{0})")
        case .aSifreliImajNe: return ("Parolayla korunan bir disk imajı; büyük olasılıkla bir kasa ya da şifreli yedek. Silersen içindeki her şey gider.", "A password-protected disk image, most likely a vault or an encrypted backup. Deleting it loses everything inside.")
        case .aGizliDmgNe: return ("Gizli bir klasörde duruyor; bir uygulamanın veri kabı olarak kullandığı imaj olabilir, kurulum dosyası değil.", "It sits in a hidden folder, so it may be a data container an app uses rather than an installer.")
        case .aYedekYoksaGelmez: return ("Yedeği yoksa geri gelmez.", "Gone for good unless you have a backup.")
        case .aXipTur: return ("İmzalı arşiv (.xip, çoğunlukla Xcode)", "Signed archive (.xip, usually Xcode)")
        case .aKurulumTur: return ("Kurulum dosyası (.{0})", "Installer (.{0})")
        case .aKurulumKuruluNe: return ("Bir uygulamanın kurulum dosyası. {0} zaten Uygulamalar klasöründe kurulu görünüyor; kurulum dosyasına artık gerek kalmaz.", "An app installer. {0} already appears to be installed in Applications, so you no longer need the installer.")
        case .aKurulumKuruluGeri: return ("Gerekirse üreticinin sitesinden yeniden indirilir.", "You can download it again from the developer's website if needed.")
        case .aKurulumNe: return ("Bir uygulamanın kurulum dosyası. Kurulu bir uygulamayla eşleştiremedim; henüz kurmadıysan ya da artık bulunmayan bir sürümse lazım olabilir.", "An app installer. I couldn't match it to an installed app; you may still need it if you haven't installed it yet or it's a version you can't get anymore.")
        case .aKurulumGeri: return ("Çoğu kurulum dosyası üreticinin sitesinden yeniden indirilebilir.", "Most installers can be downloaded again from the developer's website.")
        case .aIpswTur: return ("iPhone/iPad yazılım imajı (.ipsw)", "iPhone/iPad software image (.ipsw)")
        case .aIpswNe: return ("Finder ya da Apple Configurator'ın bir cihazı geri yüklemek için indirdiği iOS imajı. Geri yükleme bittiyse işe yaramaz.", "An iOS image that Finder or Apple Configurator downloaded to restore a device. Once the restore is done, it's no longer useful.")
        case .aIpswGeri: return ("Gerektiğinde Apple'dan yeniden indirilir.", "It's downloaded again from Apple when needed.")
        case .aIsoTur: return ("Disk imajı (.iso)", "Disk image (.iso)")
        case .aIsoNe: return ("Genellikle bir işletim sistemi ya da yazılım kurulum imajı. Sanal makine kurduysan büyük olasılıkla artık gerekmez.", "Usually an operating system or software install image. If you've already set up the virtual machine, you probably don't need it anymore.")
        case .aIsoGeri: return ("Çoğunlukla yayıncısından yeniden indirilir.", "Usually available again from the publisher.")
        case .aVmTur: return ("Sanal makine diski (.{0})", "Virtual machine disk (.{0})")
        case .aVmNe: return ("Bir sanal makinenin diski. Silersen içindeki işletim sistemi, uygulamalar ve tüm dosyalar gider.", "A virtual machine's disk. Deleting it loses the operating system, apps and every file inside.")
        case .aVmOneri: return ("Sanal makine uygulamasının içinden sil; içinde gereken dosya varsa önce dışarı al.", "Delete it from within the virtualization app, and copy out any files you need first.")
        case .aSparseNe: return ("Bir disk gibi kullanılan imaj; şifreli bir kap ya da Time Machine ağ yedeği olabilir. Silersen içindeki her şey gider.", "An image used like a disk; it may be an encrypted container or a Time Machine network backup. Deleting it loses everything inside.")
        case .aSparseOneri: return ("Önce çift tıklayıp bağla ve içine bak.", "Double-click to mount it and look inside first.")
        case .aFcpTur: return ("Final Cut Pro kitaplığı", "Final Cut Pro library")
        case .aFcpNe: return ("Final Cut projeleri ve içe aktarılmış medya bu kitaplıkta. Silersen kurgular ve (kopyalanmışsa) çekimler gider.", "Final Cut projects and imported media live in this library. Deleting it loses your edits and, if media was copied in, your footage.")
        case .aFcpOneri: return ("Yer açmak için Final Cut'ta Dosya > Oluşturulmuş Kitaplık Dosyalarını Sil'i kullan; render ve proxy'ler gider, proje kalır.", "To free up space, use File > Delete Generated Library Files in Final Cut; renders and proxies go, the project stays.")
        case .aLogicTur: return ("Logic Pro projesi", "Logic Pro project")
        case .aBandTur: return ("GarageBand projesi", "GarageBand project")
        case .aMuzikProjeNe: return ("Bir müzik projesi; kayıtlar ve miks ayarları içinde. Silersen proje gider.", "A music project with its recordings and mix settings inside. Deleting it loses the project.")
        case .aImovieTur: return ("iMovie kitaplığı", "iMovie library")
        case .aImovieNe: return ("iMovie projeleri ve içe aktarılmış videolar burada. Silersen projeler gider.", "iMovie projects and imported videos live here. Deleting it loses the projects.")
        case .aBlendYedekTur: return ("Blender otomatik yedeği (.{0})", "Blender auto-backup (.{0})")
        case .aBlendYedekVarNe: return ("Blender'ın her kayıtta tuttuğu bir önceki sürüm. Asıl .blend dosyan yanında duruyor; bu yedek ancak son kaydı geri almak istersen işe yarar.", "The previous version Blender keeps on every save. Your main .blend file is right next to it; this backup only helps if you want to undo the last save.")
        case .aBlendYedekYokNe: return ("Blender'ın tuttuğu bir önceki sürüm. Asıl .blend dosyası yanında yok; bu yedek tek kopya olabilir.", "A previous version that Blender kept. The main .blend file isn't next to it, so this backup may be the only copy.")
        case .aSilinirseGelmez: return ("Silinirse geri gelmez.", "Gone for good once deleted.")
        case .aBlendTur: return ("Blender projesi", "Blender project")
        case .aBlendNe: return ("Bir Blender sahnesi. Silersen model, malzeme ve animasyonlar gider.", "A Blender scene. Deleting it loses the models, materials and animations.")
        case .aDbTur: return ("Veritabanı dosyası (.{0})", "Database file (.{0})")
        case .aDbNe: return ("Bir uygulamanın ya da projenin verisini tutan veritabanı. Silersen o uygulama bu verileri kaybeder.", "A database holding an app's or project's data. Deleting it means that app loses this data.")
        case .aModelTur: return ("Yapay zekâ model dosyası (.{0})", "AI model file (.{0})")
        case .aModelNe: return ("Bir yapay zekâ modelinin ağırlıkları. Silersen bu modeli kullanan uygulama onu yeniden indirmek ister.", "The weights of an AI model. If you delete it, the app that uses the model will want to download it again.")
        case .aModelGeri: return ("Çoğunlukla yeniden indirilebilir ama büyük bir indirmedir. Kendin eğittiysen geri gelmez.", "Usually downloadable again, but it's a large download. If you trained it yourself, it's gone for good.")
        case .aEkranKaydiTur: return ("Ekran kaydı", "Screen recording")
        case .aEkranKaydiNe: return ("macOS ya da bir kayıt aracıyla alınmış ekran videosu. Çoğu bir kez izlenip unutulur; içindekine hâlâ ihtiyacın yoksa silinebilir.", "A screen video made with macOS or a recording tool. Most are watched once and forgotten; if you no longer need what's in it, it can go.")
        case .aBaskaKopyaYoksa: return ("Başka yerde kopyası yoksa geri gelmez.", "Gone for good unless there's a copy elsewhere.")
        case .aVideoTur: return ("Video (.{0})", "Video (.{0})")
        case .aVideoNe: return ("Kişisel bir çekim ya da kurgu olabilir. Başka yerde (Fotoğraflar, harici disk, bulut) kopyası yoksa silindiğinde geri gelmez.", "It may be personal footage or an edit. Unless there's a copy elsewhere (Photos, an external drive, the cloud), it's gone for good once deleted.")
        case .aYalnizKopyaVarsa: return ("Yalnız başka bir kopyası varsa.", "Only if there's another copy.")
        case .aVideoOneri: return ("Göz at ile izle; kopyası olduğundan eminsen sil.", "Watch it with Quick Look, and delete it only if you're sure there's a copy.")
        case .aPsdTur: return ("Photoshop belgesi", "Photoshop document")
        case .aGorselTur: return ("Görsel (.{0})", "Image (.{0})")
        case .aGorselNe: return ("Kişisel bir fotoğraf ya da tasarım dosyası olabilir. Başka kopyası yoksa silindiğinde geri gelmez.", "It may be a personal photo or design file. Unless there's another copy, it's gone for good once deleted.")
        case .aSesTur: return ("Ses dosyası (.{0})", "Audio file (.{0})")
        case .aSesNe: return ("Kendi kaydın ya da bir projenin parçası olabilir. Başka kopyası yoksa silindiğinde geri gelmez.", "It may be your own recording or part of a project. Unless there's another copy, it's gone for good once deleted.")
        case .aArsivTur: return ("Arşiv (.{0})", "Archive (.{0})")
        case .aArsivAcilmisNe: return ("Sıkıştırılmış arşiv. Açılmış hali aynı adla yanında duruyor; arşiv büyük olasılıkla fazlalık.", "A compressed archive. Its extracted copy sits right next to it under the same name, so the archive is most likely redundant.")
        case .aArsivAcilmisGeri: return ("Gerekirse açılmış klasör yeniden sıkıştırılabilir.", "If needed, the extracted folder can be compressed again.")
        case .aArsivAcilmisOneri: return ("Açılmış klasörün tam olduğuna bir bak, sonra sil.", "Check that the extracted folder is complete, then delete.")
        case .aArsivNe: return ("Sıkıştırılmış arşiv; içinde ne olduğu adından anlaşılmıyor. Tek kopyaysa silindiğinde içindekiler de gider.", "A compressed archive whose name doesn't say what's inside. If it's the only copy, its contents go with it.")
        case .aArsivGeri: return ("İndirilmiş bir dosyaysa kaynağından yeniden indirilebilir.", "If it was downloaded, you can get it again from the source.")
        case .aArsivOneri: return ("Göz at ile içine bak.", "Look inside with Quick Look.")
        case .aAppTur: return ("Uygulama paketi", "App bundle")
        case .aAppNe: return ("Uygulamalar klasörünün dışında duran bir uygulama; büyük olasılıkla indirilmiş ya da kopyalanmış bir sürüm.", "An app sitting outside the Applications folder, most likely a downloaded or copied version.")
        case .aAppGeri: return ("Üreticinin sitesinden yeniden indirilebilir; ayarları ayrı tutulduğu için kaybolmaz.", "You can download it again from the developer; its settings are stored separately, so they aren't lost.")
        case .aXcarchiveTur: return ("Xcode arşivi", "Xcode archive")
        case .aXcarchiveNe: return ("Yayımlanmış bir uygulama sürümünün arşivi ve hata ayıklama sembolleri. Silersen o sürümün çökme raporlarını çözmek zorlaşır.", "The archive and debug symbols of a released app version. Deleting it makes that version's crash reports harder to symbolicate.")
        case .aXcarchiveGeri: return ("Aynı kaynak koddan yeniden arşivlenebilir ama sembolleri birebir aynı olmaz.", "You can archive the same source code again, but the symbols won't match exactly.")
        case .aLogTur: return ("Günlük dosyası (.{0})", "Log file (.{0})")
        case .aLogNe: return ("Bir programın kayıt dosyası. Yalnız bir sorunun izini sürerken işe yarar.", "A program's log file. Only useful when tracking down a problem.")
        case .aKutuphaneTur: return ("Program kütüphanesi (.{0})", "Program library (.{0})")
        case .aKutuphaneNe: return ("Bir programın, eklentinin ya da Python paketinin parçası. Silersen onu kullanan program çalışmaz.", "Part of a program, plug-in or Python package. Deleting it breaks whatever uses it.")
        case .aKutuphaneGeri: return ("Ait olduğu programı yeniden kurarak.", "Reinstall the program it belongs to.")
        case .aKutuphaneOneri: return ("Yer açmak istiyorsan ait olduğu programı ya da ortamı bütün olarak kaldır.", "To free up space, remove the program or environment it belongs to as a whole.")
        case .aBelgeTur: return ("Belge (.{0})", "Document (.{0})")
        case .aBelgeNe: return ("Kendi çalışman olabilir. Başka kopyası yoksa silindiğinde geri gelmez.", "It may be your own work. Unless there's another copy, it's gone for good once deleted.")
        case .aPaketTur: return ("Paket (.{0})", "Package (.{0})")
        case .aKlasorTur: return ("Klasör", "Folder")
        case .aUzantisizTur: return ("Uzantısız dosya", "File without an extension")
        case .aBilinmeyenTur: return ("Bilinmeyen dosya (.{0})", "Unknown file (.{0})")
        case .aBilinmeyenNe: return ("Bunun ne olduğunu bilmiyorum, bu yüzden silinince ne olacağını kestiremiyorum.", "I don't know what this is, so I can't tell what happens if you delete it.")
        case .aBilinmeyenOneri: return ("Emin değilsen sakla; Göz at ile içine bakabilirsin.", "If you're not sure, keep it; you can look inside with Quick Look.")
        case .aKorunanTur: return ("Korunan öğe", "Protected item")
        case .aFerahSilmez: return ("Ferah bunu silmez.", "Ferah won't delete this.")
        case .aFotoKitTur: return ("Fotoğraflar kitaplığı", "Photos library")
        case .aFotoKitNe: return ("Tüm fotoğrafların, videoların, albümlerin ve düzenlemelerin bu kitaplıkta. Ferah bunu silmez.", "All your photos, videos, albums and edits are in this library. Ferah won't delete it.")
        case .aFotoKitOneri: return ("Yer açmak için Fotoğraflar > Ayarlar > iCloud'da \"Mac Depolama Alanını Optimize Et\"i aç.", "To free up space, turn on \"Optimize Mac Storage\" in Photos > Settings > iCloud.")
        case .aMuzikKitTur: return ("Müzik kitaplığı", "Music library")
        case .aMuzikKitNe: return ("Müzik uygulamasının kitaplığı; çalma listelerin ve şarkı bilgilerin burada. Ferah bunu silmez.", "The Music app's library, with your playlists and song info. Ferah won't delete it.")
        case .aMuzikKitOneri: return ("Şarkıları Müzik uygulamasının içinden kaldır.", "Remove songs from within the Music app.")
        case .aTvKitTur: return ("TV kitaplığı", "TV library")
        case .aTvKitNe: return ("TV uygulamasının kitaplığı. Ferah bunu silmez.", "The TV app's library. Ferah won't delete it.")
        case .aTvKitOneri: return ("İndirilmiş filmleri TV uygulamasının içinden kaldır.", "Remove downloaded movies from within the TV app.")
        case .aUygTur: return ("Uygulama", "App")
        case .aUygKorunanNe: return ("Uygulamalar klasöründeki bir uygulama. Ferah uygulama kaldırmaz.", "An app in the Applications folder. Ferah doesn't remove apps from this step.")
        case .aUygKorunanOneri: return ("Kaldırmak istersen Finder'dan ya da uygulamanın kendi kaldırıcısıyla yap.", "To remove it, use Finder or the app's own uninstaller.")
        case .aNodeTur: return ("Node.js bağımlılıkları (node_modules)", "Node.js dependencies (node_modules)")
        case .aNodeNe: return ("Projenin indirilmiş npm paketleri silinir. Projenin kendi kodu bozulmaz ama yeniden kurulana kadar çalışmaz.", "Deletes the project's downloaded npm packages. Your code isn't touched, but the project won't run until they're reinstalled.")
        case .aNodeGeri: return ("Proje klasöründe npm install (ya da yarn / pnpm install) ile geri gelir; ilk çalıştırma uzar.", "Run npm install (or yarn / pnpm install) in the project folder to bring them back; the first run takes longer.")
        case .aVenvTur: return ("Python sanal ortamı", "Python virtual environment")
        case .aVenvNe: return ("Projeye kurulmuş Python paketleri silinir. Projenin kodu bozulmaz.", "Deletes the Python packages installed for the project. Your code isn't touched.")
        case .aVenvGeri: return ("python -m venv ile yeniden oluşturup pip install -r requirements.txt ile kurulur.", "Recreate it with python -m venv and reinstall with pip install -r requirements.txt.")
        case .aPodsTur: return ("CocoaPods bağımlılıkları (Pods)", "CocoaPods dependencies (Pods)")
        case .aPodsNe: return ("iOS/macOS projesinin indirilmiş kütüphaneleri silinir. Proje bozulmaz ama yeniden kurulana kadar derlenmez.", "Deletes the iOS/macOS project's downloaded libraries. The project isn't damaged, but it won't build until they're reinstalled.")
        case .aPodsGeri: return ("Proje klasöründe pod install ile geri gelir.", "Run pod install in the project folder to bring them back.")
        case .aDerlemeTur: return ("Derleme çıktısı ({0})", "Build output ({0})")
        case .aDerlemeNe: return ("Projenin derlenmiş hali. Kaynak kod bozulmaz.", "The project's compiled output. Your source code isn't touched.")
        case .aDerlemeGeri: return ("Projeyi yeniden derleyince oluşur; ilk derleme uzun sürer.", "It's regenerated when you build again; the first build takes longer.")
        case .aIosYedekTur: return ("iPhone/iPad yedeği", "iPhone/iPad backup")
        case .aIosYedekCihazNe: return ("\"{0}\" cihazının bu Mac'teki yerel yedeği silinir.", "Deletes the local backup of \"{0}\" on this Mac.")
        case .aIosYedekNe: return ("Bir iPhone/iPad'in bu Mac'teki yerel yedeği silinir.", "Deletes an iPhone or iPad's local backup on this Mac.")
        case .aIosYedekGeri: return ("iCloud yedeğin varsa cihaz ondan geri yüklenebilir; yoksa bu yedekteki veriler geri gelmez.", "If you have an iCloud backup, the device can be restored from it; otherwise the data in this backup is gone for good.")
        case .aIosYedekOneri: return ("Cihazı bağlayıp Finder'dan yedekleri yönet; emin değilsen sakla.", "Connect the device and manage its backups in Finder; if you're not sure, keep it.")
        case .aDockerTur: return ("Docker disk imajı (Docker.raw)", "Docker disk image (Docker.raw)")
        case .aDockerNe: return ("Docker'ın tüm imajları, konteynerleri ve volume'ları bu tek dosyada. Silersen hepsi gider; volume'lardaki veritabanları dahil.", "All of Docker's images, containers and volumes live in this one file. Deleting it loses all of them, including any databases in volumes.")
        case .aDockerGeri: return ("İmajlar yeniden çekilebilir ama volume verisi geri gelmez.", "Images can be pulled again, but volume data is gone for good.")
        case .aDockerOneri: return ("Docker'ın kendi temizliğini kullan: docker system prune -a ya da Docker Desktop > Troubleshoot > Clean / Purge data.", "Use Docker's own cleanup instead: docker system prune -a, or Docker Desktop > Troubleshoot > Clean / Purge data.")
        case .aHfTur: return ("Hugging Face model önbelleği", "Hugging Face model cache")
        case .aHfNe: return ("Hugging Face kütüphanelerinin indirdiği bir model ya da veri kümesi. Kullanan kod bir sonraki çalıştırmada yeniden indirir.", "A model or dataset downloaded by the Hugging Face libraries. Code that uses it downloads it again on the next run.")
        case .aHfGeri: return ("Yeniden indirilebilir ama büyük bir indirmedir.", "It can be downloaded again, but it's a large download.")
        case .aOllamaTur: return ("Ollama modelleri", "Ollama models")
        case .aOllamaNe: return ("Ollama'ya indirdiğin tüm yerel modeller silinir. Kendi Modelfile'ınla oluşturduğun modeller de gider.", "Deletes every local model you've downloaded to Ollama, including models you built from your own Modelfile.")
        case .aOllamaGeri: return ("ollama pull <model> ile yeniden indirilebilir ama GB'larca indirmedir.", "They can be downloaded again with ollama pull <model>, but that's gigabytes of downloads.")
        case .aOllamaOneri: return ("Yalnız bir modeli silmek için ollama rm <model> kullan.", "To delete a single model, use ollama rm <model>.")
        case .aSteamTur: return ("Steam oyunu", "Steam game")
        case .aSteamNe: return ("Kurulu bir oyunun dosyaları silinir. Kayıtlar çoğunlukla Steam Cloud'da durur ama her oyunda değil.", "Deletes an installed game's files. Saves are usually in Steam Cloud, but not for every game.")
        case .aSteamGeri: return ("Steam'den yeniden indirilir.", "It can be downloaded again from Steam.")
        case .aSteamOneri: return ("Steam'in içinden Yönet > Kaldır ile sil; Steam kendi kaydını da günceller.", "Uninstall it in Steam with Manage > Uninstall so Steam updates its own records too.")
        case .aBglOnbellek: return ("Bir uygulamanın önbellek klasöründe duruyor; çoğunlukla uygulamanın ürettiği geçici bir kopyadır.", "It sits in an app's cache folder, so it's usually a temporary copy the app made.")
        case .aBglKlon: return ("{0} başka dosyalarla paylaşılıyor (APFS klonu); bu dosya tek başına silinirse o kısım boşalmaz. Gösterilen boyut gerçekten açılacak yer.", "{0} is shared with other files (APFS clone), so deleting this file alone won't free that part. The size shown is the space you'll actually get back.")
        case .aBglKopya: return ("Aynı dosyanın bir kopyası daha var: {0}. Birini silmek veri kaybettirmez.", "There's another copy of this file: {0}. Deleting one won't lose any data.")
        case .aBglBulut: return ("{0} ile eşitleniyor: silersen tüm cihazlarından ve buluttan da silinir.", "Synced with {0}: deleting it also removes it from all your devices and the cloud.")
        case .aBglGit: return ("Bir Git deposunda izleniyor: silersen depo değişmiş görünür; son commit'teki hali git restore ile geri getirilebilir.", "Tracked in a Git repository: deleting it shows up as a change, and git restore brings back the last committed version.")
        case .aBglProje: return ("Bu projeye {0} dokunulmamış.", "This project hasn't been touched in {0}.")
        case .aBglSonYedek: return ("Son yedek: {0}.", "Last backup: {0}.")
        case .aBglAcilmamis: return ("1 yılı aşkın süredir açılmamış (son açılma {0}).", "Not opened in over a year (last opened {0}).")
        case .aBglDegismemis: return ("1 yılı aşkın süredir değiştirilmemiş ({0}).", "Not modified in over a year ({0}).")
        case .bEvKendisi: return ("Ev klasörünün kendisi.", "Your home folder itself.")
        case .bEvUstu: return ("Ev klasörünü içeren bir üst klasör.", "A folder that contains your home folder.")
        case .bStandart: return ("macOS'un standart klasörü ({0}); klasörün kendisi silinmez.", "A standard macOS folder ({0}); the folder itself is never deleted.")
        case .bKokKlasor: return ("Sistemin kullandığı bir kök klasör (~/{0}).", "A root folder the system uses (~/{0}).")
        case .bKorunanVeri: return ("Korunan kişisel veri (~/{0}).", "Protected personal data (~/{0}).")
        case .bIcindeKorunan: return ("İçinde korunan bir klasör var (~/{0}).", "It contains a protected folder (~/{0}).")
        case .bFotoKit: return ("Fotoğraflar kitaplığı; tüm fotoğraf ve videoların burada.", "The Photos library, with all your photos and videos.")
        case .bMuzikKit: return ("Müzik kitaplığı.", "The Music library.")
        case .bTvKit: return ("TV kitaplığı.", "The TV library.")
        case .bAnahtarZinciri: return ("Anahtar zinciri; parolaların burada.", "A keychain, where your passwords are stored.")
        case .bAppKlasoru: return ("Uygulamalar klasöründeki bir uygulama.", "An app in the Applications folder.")
        case .bYolYok: return ("Yol yok.", "The path doesn't exist.")
        case .bSembolikApp: return ("Sembolik bağ; uygulamanın kendisi değil.", "A symbolic link, not the app itself.")
        case .bAppDegil: return ("Bir uygulama paketi (.app) değil.", "Not an app bundle (.app).")
        case .bAppKoku: return ("Uygulama klasörünün kendisi.", "The Applications folder itself.")
        case .bAppKokDisi: return ("İzinli uygulama klasörlerinin dışında.", "Outside the allowed application folders.")
        case .bInfoPlistYok: return ("Geçerli bir uygulama paketi değil (Info.plist yok).", "Not a valid app bundle (no Info.plist).")
        case .bApple: return ("Apple uygulaması; macOS'un parçası.", "An Apple app; part of macOS.")
        case .bCalisiyor: return ("Uygulama şu an çalışıyor; önce kapat.", "The app is running; quit it first.")
        case .bKendisi: return ("Ferah'ın kendisi.", "Ferah itself.")
        case .bBosYol: return ("Boş yol.", "Empty path.")
        case .bNul: return ("Yolda NUL karakteri var.", "The path contains a NUL character.")
        case .bGoreli: return ("Göreli yol kabul edilmez.", "Relative paths aren't accepted.")
        case .bKokDizin: return ("Kök dizin.", "The root directory.")
        case .bSonBilesen: return ("Geçersiz son bileşen.", "Invalid last path component.")
        case .bUstYok: return ("Üst klasör bulunamadı.", "The parent folder wasn't found.")
        case .bEvDisi: return ("Ev klasörünün dışında.", "Outside your home folder.")
        case .bKokYok: return ("Bu kategori için izinli kök yok.", "No allowed root folder for this category.")
        case .bKategoriDisi: return ("Kategorinin izinli köklerinin dışında.", "Outside this category's allowed folders.")
        case .sYalnizIcerik: return ("Yalnız içerik silme yalnız kalıcı temizlikte kullanılır.", "Contents-only deletion is only used for permanent cleanup.")
        case .sArtikYok: return ("Artık yok (tarama ile temizlik arasında kaldırılmış).", "No longer there (removed between the scan and the cleanup).")
        case .sKlasorDegil: return ("Klasör değil (sembolik bağ ya da dosya).", "Not a folder (a symbolic link or a file).")
        case .sKlasorOkunamadi: return ("Klasör okunamadı (erişim izni yok).", "Couldn't read the folder (no permission).")
        case .sTasimaIzniYok: return ("Taşıma izni yok (dosya yönetici ya da sistem tarafından sahiplenilmiş olabilir). Finder'da göster ile bulup Çöp'e kendin sürükleyebilirsin; Finder parolanı sorar.", "No permission to move it (it may be owned by an administrator or the system). Use Show in Finder and drag it to the Trash yourself; Finder will ask for your password.")
        case .sKullanimda: return ("Dosyalar kullanımda ya da kilitli.", "The files are in use or locked.")
        case .dMutlak: return ("Mutlak bir yol ver.", "Give an absolute path.")
        case .dKlasorYok: return ("Klasör bulunamadı.", "Folder not found.")
        case .dYasak: return ("{0} ya da onu içeren bir klasör deneme evi olamaz.", "{0}, or a folder containing it, can't be a demo home.")
        case .dGecici: return ("Deneme evi geçici dizin ({0}) altında olmalı.", "The demo home must be inside the temporary directory ({0}).")
        case .dKurulamadi: return ("Kurulamadı.", "Couldn't set it up.")
        case .katUygulamaOnbellek: return ("Uygulama önbellekleri", "App caches")
        case .katGunlukler: return ("Günlükler ve çökme raporları", "Logs and crash reports")
        case .katTarayici: return ("Tarayıcı önbellekleri", "Browser caches")
        case .katGelistirici: return ("Geliştirici önbellekleri", "Developer caches")
        case .katCop: return ("Çöp Kutusu", "Trash")
        case .katEskiKurulum: return ("Eski kurulum dosyaları", "Old installers")
        case .katXcodeArsiv: return ("Xcode arşivleri", "Xcode archives")
        case .katSimulator: return ("Kullanılamayan simülatörler", "Unavailable simulators")
        case .katUygulamaOnbellekAc: return ("Uygulamaların hızlanmak için tuttuğu geçici dosyalar. Silinince uygulama gerekenleri yeniden oluşturur; ilk açılış biraz yavaş olabilir.", "Temporary files apps keep to run faster. Once deleted, apps rebuild what they need; the first launch may be a little slower.")
        case .katGunluklerAc: return ("Uygulamaların tuttuğu kayıtlar ve çökme raporları. Yalnız bir sorunun izini sürerken işe yarar; silinince hiçbir uygulama etkilenmez.", "Logs and crash reports that apps keep. Only useful when tracking down a problem; deleting them doesn't affect any app.")
        case .katTarayiciAc: return ("Tarayıcıların sakladığı sayfa, resim ve betik kopyaları. Geçmiş, parolalar, çerezler ve yer imlerine dokunulmaz; siteler ilk açılışta biraz yavaş yüklenir.", "Copies of pages, images and scripts that browsers keep. History, passwords, cookies and bookmarks aren't touched; sites load a little slower the first time.")
        case .katGelistiriciAc: return ("Derleme araçlarının ve paket yöneticilerinin önbellekleri. Silinince sonraki derleme/kurulum biraz uzun sürer, gerekenler yeniden indirilir.", "Caches from build tools and package managers. Once deleted, the next build or install takes a bit longer while what's needed is downloaded again.")
        case .katCopAc: return ("Çöp Kutusu'ndaki öğeler. Buradan temizlenenler kalıcı olarak silinir, geri alınamaz.", "Items in the Trash. Anything cleaned here is deleted permanently and can't be undone.")
        case .katEskiKurulumAc: return ("İndirilenler'deki 30 günden eski .dmg, .pkg, .ipsw ve .xip dosyaları. Uygulama kurulduysa genellikle gereksizdir; kalıcı olarak silinir.", ".dmg, .pkg, .ipsw and .xip files in Downloads older than 30 days. Usually unnecessary once the app is installed; they're deleted permanently.")
        case .katXcodeArsivAc: return ("Xcode'da Archive ile üretilmiş arşivler. Yayımlanmış bir sürümün hata ayıklama sembolleri bunlarda olabilir; silinirse o sürümün çökme raporlarını çözmek zorlaşır.", "Archives made with Archive in Xcode. They may hold the debug symbols of a released version; without them, that version's crash reports are harder to symbolicate.")
        case .katSimulatorAc: return ("Çalışma ortamı (iOS sürümü) artık yüklü olmayan simülatör cihazları; açılamazlar. İçlerindeki uygulama verileri de silinir.", "Simulator devices whose runtime (iOS version) is no longer installed, so they can't be opened. The app data inside them is deleted too.")
        case .katOnbellegi: return ("{0} önbelleği", "{0} cache")
        case .katSimOnbellek: return ("Simülatör önbellekleri", "Simulator caches")
        case .katDeposu: return ("{0} deposu", "{0} store")
        case .katIndirmeleri: return ("{0} indirmeleri", "{0} downloads")
        case .katCargo: return ("Cargo paket önbelleği", "Cargo package cache")
        case .katGoDerleme: return ("Go derleme önbelleği", "Go build cache")
        case .katTarayiciOnbellek: return ("{0} — önbellek", "{0} — cache")
        case .katNotCalisiyor: return ("Uygulama şu an çalışıyor.", "The app is running right now.")
        case .katNotMacos: return ("macOS bileşeni; arka planda çalışıyor olabilir.", "A macOS component; it may be running in the background.")
        case .katNotTarayiciAcik: return ("Tarayıcı şu an açık.", "The browser is open right now.")
        case .katNotPnpm: return ("pnpm dosyaları projelerdeki node_modules ile paylaşılır; gerçek kazanç daha az olabilir.", "pnpm shares files with node_modules in your projects, so the actual space saved may be smaller.")
        case .katNotIndirildi: return ("İndirildi: {0}", "Downloaded {0}")
        case .katNotSimulator: return ("Çalışma ortamı yüklü değil. Xcode listesinde kalırsa: xcrun simctl delete unavailable", "Its runtime isn't installed. If it stays in Xcode's list, run: xcrun simctl delete unavailable")
        case .uKaynakAppStore: return ("App Store", "App Store")
        case .uKaynakGelistirici: return ("Geliştiriciden", "From the developer")
        case .uKaynakApple: return ("Apple", "Apple")
        case .uSilApple: return ("Apple uygulaması; macOS'un parçası, Ferah kaldırmaz.", "An Apple app; part of macOS. Ferah won't remove it.")
        case .uSilKisayol: return ("Bu bir kısayol (sembolik bağ); asıl uygulama başka yerde.", "This is a shortcut (symbolic link); the actual app is elsewhere.")
        case .uSilCalisiyor: return ("Şu an çalışıyor; önce uygulamayı kapat.", "It's running right now; quit the app first.")
        case .uArtikVeri: return ("Uygulama verisi", "App data")
        case .uArtikOnbellek: return ("Önbellek", "Cache")
        case .uArtikKapsayici: return ("Uygulama kapsayıcısı", "App container")
        case .uArtikPencere: return ("Pencere durumu", "Window state")
        case .uArtikAg: return ("Ağ depolaması", "Network storage")
        case .uArtikWeb: return ("Web verisi", "Web data")
        case .uArtikGunluk: return ("Günlükler", "Logs")
        case .uBoyutKisayol: return ("Kısayol; asıl uygulama başka yerde.", "Shortcut; the actual app is elsewhere.")
        case .uBoyutBaskaYer: return ("Ölçülemedi: uygulamanın içeriği başka bir klasörde ({0}).", "Couldn't measure: the app's contents are in another folder ({0}).")
        case .uBilinmiyor: return ("bilinmiyor", "unknown")
        case .uTur: return ("Uygulama ({0})", "App ({0})")
        case .uNeTasinir: return ("Uygulama Çöp Kutusu'na taşınır; Çöp'ü boşaltana kadar geri alabilirsin.", "The app is moved to the Trash; you can put it back until you empty the Trash.")
        case .uNeVeriGider: return ("Ayarların ve uygulama içi verilerin de gider ({0}).", "Your settings and in-app data go too ({0}).")
        case .uNeVeriKalir: return ("Ayarların ve verilerin yerinde kalır; yeniden kurarsan kaldığın yerden devam edersin.", "Your settings and data stay put; if you reinstall, you pick up where you left off.")
        case .uGeriAppStore: return ("App Store > Satın Alınanlar'dan ücretsiz yeniden indirilir.", "You can download it again for free from App Store > Purchased.")
        case .uGeriGelistirici: return ("Geliştiricinin sitesinden yeniden indirmen gerekir; lisans anahtarı gerekiyorsa elinde olduğundan emin ol.", "You'll need to download it again from the developer's website; if it needs a license key, make sure you have it.")
        case .uNedenSistem: return ("Bu uygulama sisteme ek bileşenler kuruyor", "This app installs extra system components")
        case .uNedenGuvenlik: return ("VPN/güvenlik yazılımları ağ ve sistem uzantıları kurar", "VPN and security software install network and system extensions")
        case .uNedenAdobe: return ("Adobe uygulamaları Creative Cloud ile ortak bileşenler kurar", "Adobe apps install components shared with Creative Cloud")
        case .uNedenOffice: return ("Office uygulamaları ortak bileşenleri paylaşır", "Office apps share common components")
        case .uOneriKaldirici: return ("{0}; kendi kaldırıcısını kullanmak daha temiz.", "{0}, so using its own uninstaller is cleaner.")
        case .uOneriKaldiriciAdi: return ("Kaldırıcı: {0}.", "Uninstaller: {0}.")
        case .uBglIntel: return ("Yalnız Intel için derlenmiş; Apple Silicon'da Rosetta ile çalışıyor. Güncel bir sürümü olabilir.", "Built for Intel only; it runs through Rosetta on Apple silicon. A newer version may be available.")
        case .uBglDocker: return ("Docker'ın imaj ve konteynerleri ayrı bir disk imajında (Docker.raw) durur; uygulamayı silmek onları kendiliğinden silmez.", "Docker's images and containers live in a separate disk image (Docker.raw); deleting the app doesn't remove them.")
        case .uBglOyun: return ("Kurulu oyunlar ayrı klasörlerde durur ve çok yer tutabilir; önce başlatıcının içinden oyunları kaldır.", "Installed games live in separate folders and can take a lot of space; uninstall them from the launcher first.")
        case .uBglCC: return ("Creative Cloud kaldırılırsa diğer Adobe uygulamaları güncellenemez ya da açılmaz.", "Without Creative Cloud, other Adobe apps can't update or won't open.")
        case .uBglVm: return ("Sanal makineler ayrı dosyalarda durur; uygulamayı silmek onları silmez, ama onlar da büyük yer tutar.", "Virtual machines live in separate files; deleting the app doesn't remove them, and they take a lot of space too.")
        case .uBglAndroid: return ("Android SDK ve emülatörler ~/Library/Android içinde ayrıca GB'larca yer tutar.", "The Android SDK and emulators take up gigabytes more in ~/Library/Android.")
        case .uBglSonKullanim: return ("Son kullanım: {0}.", "Last used {0}.")
        case .uBglHicEklendi: return ("Hiç açılmamış ya da kullanım kaydı yok; {0} eklendi.", "Never opened, or no usage record; added {0}.")
        case .uOneriYeni: return ("Yakın zamanda eklenmiş; henüz kullanmaya başlamamış olabilirsin.", "Added recently; you may not have started using it yet.")
        case .uBglDegisme: return ("Kullanım kaydı yok ve eklenme tarihi bilinmiyor; paket {0} değiştirilmiş.", "No usage record and the date added is unknown; the app bundle was modified {0}.")
        case .uBglBilinmiyor: return ("Kullanım kaydı ve eklenme tarihi bilinmiyor.", "Usage record and date added are unknown.")
        case .uBglErisilemedi: return ("Bazı verilerine izin olmadan bakılamadı; boyutları hesaba katılmadı.", "Some of its data couldn't be checked without permission, so its size isn't counted.")
        case .svEylemFerah: return ("Ferah temizleyebilir", "Ferah can clean")
        case .svEylemAdim1: return ("Adım 1'de temizlenir", "Cleaned in Step 1")
        case .svEylemUyg: return ("Uygulamanın kendi içinden", "From within the app")
        case .svEylemYeniden: return ("Yeniden başlatınca boşalır", "Freed on restart")
        case .svEylemDokunma: return ("Dokunma", "Don't touch")
        case .svEylemBilgi: return ("Bilgi", "Info")
        case .svOlcTde: return ("Ölçülmedi: başka uygulamanın korumalı verisi; Tam Disk Erişimi verilirse ölçülür.", "Not measured: another app's protected data. It can be measured once you grant Full Disk Access.")
        case .svOlcIzin: return ("Ölçülemedi (izin gerekir).", "Couldn't measure (permission needed).")
        case .svOlcGuvenilmez: return ("Güvenilir ölçülemedi: ölçülen boyut disk kapasitesini aşıyor (klon/seyrek dosyalar).", "Couldn't measure reliably: the measured size exceeds the disk's capacity (clones or sparse files).")
        case .svKisiselTur: return ("Kişisel dosyalar", "Personal files")
        case .svKisiselNe: return ("Belgelerin, projelerin ve indirdiklerin. Sistem verisi değil; burada yalnız toplamı göstermek için ölçüldü.", "Your documents, projects and downloads. Not system data; it's measured here only to show the total.")
        case .svKisiselMetin: return ("Büyük dosyalar adımında tek tek incele.", "Review it item by item in the Large Files step.")
        case .svClaudeVmTur: return ("Claude sanal makine imajı", "Claude virtual machine image")
        case .svClaudeVmNe: return ("Claude masaüstü uygulamasının kod çalıştırmak için indirdiği sanal makine imajı. Uygulama kapalıyken silinirse gerektiğinde yeniden indirilir.", "A virtual machine image the Claude desktop app downloads to run code. If deleted while the app is closed, it's downloaded again when needed.")
        case .svClaudeVmGeri: return ("Claude gerektiğinde kendisi yeniden indirir (büyük indirme).", "Claude downloads it again itself when needed (a large download).")
        case .svClaudeVmMetin: return ("Önce Claude'u kapat, sonra Çöp'e taşı.", "Quit Claude first, then move it to the Trash.")
        case .svClaudeTur: return ("Claude masaüstü verileri", "Claude desktop data")
        case .svClaudeNe: return ("Claude uygulamasının ayarları, oturumu ve sanal makine imajı. En büyük parçası vm_bundles; ayrı satırda.", "The Claude app's settings, session and virtual machine image. The largest part is vm_bundles, listed separately.")
        case .svClaudeMetin: return ("Yalnız vm_bundles alt kalemini temizlemek yeterli.", "Cleaning just the vm_bundles item is enough.")
        case .svClaudeCodeProjeTur: return ("Claude Code oturum kayıtları", "Claude Code session history")
        case .svClaudeCodeProjeNe: return ("Claude Code'un proje başına tuttuğu konuşma kayıtları. Silinirse eski konuşmalara dönülemez (claude --resume çalışmaz).", "The conversation history Claude Code keeps per project. Once deleted, you can't go back to old conversations (claude --resume won't work).")
        case .svGeriGelmez: return ("Geri gelmez.", "It can't be recovered.")
        case .svClaudeCodeProjeMetin: return ("Yalnız eski projelerin klasörlerini taşımayı düşün.", "Consider moving only the folders of old projects.")
        case .svClaudeCodeTur: return ("Claude Code verileri", "Claude Code data")
        case .svClaudeCodeNe: return ("Claude Code'un ayarları, belleği ve oturum kayıtları. Ayarların ve hafızan da burada.", "Claude Code's settings, memory and session history. Your settings and memory live here too.")
        case .svClaudeCodeMetin: return ("Büyük kısmı projects alt klasörü; ayrı satırda.", "Most of it is the projects subfolder, listed separately.")
        case .svWhatsappTur: return ("WhatsApp verileri", "WhatsApp data")
        case .svWhatsappNe: return ("Sohbetlerin ve indirilen fotoğraf/videolar. Klasörü elle silmek sohbet geçmişini bozar.", "Your chats and downloaded photos and videos. Deleting the folder by hand breaks your chat history.")
        case .svWhatsappMetin: return ("WhatsApp > Ayarlar > Depolama ve Veri > Depolamayı Yönet'ten büyük medyayı sil.", "Delete large media from WhatsApp > Settings > Storage and Data > Manage Storage.")
        case .svTelegramTur: return ("Telegram verileri", "Telegram data")
        case .svTelegramNe: return ("Telegram'ın indirdiği medya ve önbellek. Mesajlar bulutta durur.", "Media and cache that Telegram downloaded. Messages stay in the cloud.")
        case .svTelegramMetin: return ("Telegram > Ayarlar > Veri ve Depolama > Depolama Kullanımı > Önbelleği Temizle.", "Telegram > Settings > Data and Storage > Storage Usage > Clear Cache.")
        case .svSignalTur: return ("Signal verileri", "Signal data")
        case .svSignalNe: return ("Signal mesajları yalnız bu cihazda durur; klasör silinirse geri gelmez.", "Signal messages are stored only on this device; if the folder is deleted, they're gone for good.")
        case .svSignalMetin: return ("Signal > Ayarlar > Sohbetler'den eski ekleri sil.", "Delete old attachments from Signal > Settings > Chats.")
        case .svDockerTur: return ("Docker verileri", "Docker data")
        case .svDockerNe: return ("Docker imajları, konteynerleri ve volume'ları. Klasörü elle silmek Docker'ı bozar.", "Docker images, containers and volumes. Deleting the folder by hand breaks Docker.")
        case .svDockerMetin: return ("Docker Desktop > Troubleshoot > Clean / Purge data ya da docker system prune -a.", "Docker Desktop > Troubleshoot > Clean / Purge data, or docker system prune -a.")
        case .svDriveTur: return ("Google Drive önbelleği", "Google Drive cache")
        case .svDriveNe: return ("Google Drive'ın yerelde tuttuğu dosya kopyaları. Henüz yüklenmemiş değişiklikler de burada olabilir.", "Local copies of files that Google Drive keeps. Changes that haven't been uploaded yet may be here too.")
        case .svDriveMetin: return ("Google Drive > Ayarlar > Tercihler'de akış (stream) moduna geç ya da önbelleği küçült.", "In Google Drive > Settings > Preferences, switch to streaming or reduce the cache.")
        case .svProfilTur: return ("Tarayıcı profili", "Browser profile")
        case .svProfilNe: return ("Geçmiş, yer imleri, parolalar, çerezler ve eklentiler. Önbellek kısmı Adım 1'de temizlenir.", "History, bookmarks, passwords, cookies and extensions. The cache part is cleaned in Step 1.")
        case .svProfilMetin: return ("Önbellekler için Adım 1'i kullan.", "Use Step 1 for the caches.")
        case .svGoogleTur: return ("Google uygulamalarının verileri", "Google apps data")
        case .svGoogleNe: return ("Chrome profili ve diğer Google uygulamalarının verileri bir arada.", "The Chrome profile and other Google apps' data, all together.")
        case .svGoogleMetin: return ("Alt kalemlere bak; Chrome profili silinmemeli.", "Look at the items inside; the Chrome profile shouldn't be deleted.")
        case .svXcodeTur: return ("Xcode verileri", "Xcode data")
        case .svXcodeNe: return ("Platform destek dosyaları, arşivler ve DerivedData. DerivedData ve DeviceSupport Adım 1'de temizlenir.", "Platform support files, archives and DerivedData. DerivedData and DeviceSupport are cleaned in Step 1.")
        case .svXcodeMetin: return ("Xcode > Settings > Platforms'tan kullanmadığın platformları kaldır.", "Remove platforms you don't use in Xcode > Settings > Platforms.")
        case .svSimTur: return ("Simülatör cihazları", "Simulator devices")
        case .svSimNe: return ("iOS simülatörlerinin cihazları ve içlerindeki uygulama verileri.", "iOS simulator devices and the app data inside them.")
        case .svSimMetin: return ("Terminalde xcrun simctl delete unavailable; kullanılamayanlar Adım 1'de de listelenir.", "Run xcrun simctl delete unavailable in Terminal; unavailable ones are also listed in Step 1.")
        case .svGelistiriciTur: return ("Geliştirici verileri", "Developer data")
        case .svGelistiriciNe: return ("Xcode ve simülatör verileri. Önbellek kısımları Adım 1'de temizlenir.", "Xcode and simulator data. The cache parts are cleaned in Step 1.")
        case .svIosYedekTur: return ("iPhone/iPad yedekleri", "iPhone/iPad backups")
        case .svIosYedekNe: return ("Cihazlarının bu Mac'teki yerel yedekleri. iCloud yedeğin yoksa silinince geri gelmez.", "Local backups of your devices on this Mac. Without an iCloud backup, they're gone for good once deleted.")
        case .svIosYedekMetin: return ("Cihazı bağla, Finder'da seç > Yedekleri Yönet.", "Connect the device, select it in Finder > Manage Backups.")
        case .svMailTur: return ("Mail verileri", "Mail data")
        case .svMailNe: return ("E-postaların ve ekleri. Ferah dokunmaz.", "Your email and attachments. Ferah doesn't touch them.")
        case .svMailMetin: return ("Mail > Ayarlar > Hesaplar'da büyük posta kutularını arşivle; ekleri indirmeyi sınırla.", "Archive large mailboxes in Mail > Settings > Accounts, and limit attachment downloads.")
        case .svMesajTur: return ("Mesajlar ve ekleri", "Messages and attachments")
        case .svMesajNe: return ("iMessage sohbetlerin ve ekleri. Klasörü elle silmek sohbetleri bozar.", "Your iMessage conversations and attachments. Deleting the folder by hand breaks your conversations.")
        case .svMesajMetin: return ("Sistem Ayarları > Genel > Depolama > Mesajlar'dan büyük ekleri sil ya da 'Mesajları sakla' süresini kısalt.", "Delete large attachments in System Settings > General > Storage > Messages, or shorten \"Keep Messages\".")
        case .svFotoTur: return ("Fotoğraflar önbellekleri", "Photos caches")
        case .svFotoNe: return ("Fotoğraflar uygulamasının analiz ve küçük resim önbellekleri; macOS yönetir.", "The Photos app's analysis and thumbnail caches; macOS manages them.")
        case .svOnbellekTur: return ("Önbellekler", "Caches")
        case .svOnbellekNe: return ("Uygulama önbellekleri.", "App caches.")
        case .svGunlukTur: return ("Günlükler", "Logs")
        case .svGunlukNe: return ("Uygulama günlükleri ve çökme raporları.", "App logs and crash reports.")
        case .svOyunTur: return ("Oyun ve başlatıcı verileri", "Games and launcher data")
        case .svOyunNe: return ("Kurulu oyunlar ve başlatıcı verileri. Dünyalar/kayıtlar da burada olabilir.", "Installed games and launcher data. Worlds and saves may be here too.")
        case .svOyunMetin: return ("Oyunları başlatıcının içinden kaldır; kayıtları önce yedekle.", "Uninstall games from within the launcher, and back up your saves first.")
        case .svCrossoverTur: return ("CrossOver şişeleri", "CrossOver bottles")
        case .svCrossoverNe: return ("Windows uygulamalarının kurulu olduğu şişeler. Silinen şişedeki uygulamalar ve verileri gider.", "Bottles with Windows apps installed. Deleting a bottle loses its apps and their data.")
        case .svCrossoverMetin: return ("CrossOver'da kullanmadığın şişeyi seçip sil.", "Select a bottle you don't use in CrossOver and delete it there.")
        case .svAracTur: return ("Geliştirici araç zinciri", "Developer toolchain")
        case .svAracNe: return ("Kurulu dil sürümleri ve araçlar ({0}). Silinirse bu araçlar çalışmaz.", "Installed language versions and tools ({0}). If deleted, these tools stop working.")
        case .svAracGeri: return ("Aracın kendi kurulum betiğiyle yeniden kurulabilir.", "It can be reinstalled with the tool's own installer.")
        case .svAracMetin: return ("Tümünü silmek yerine kullanmadığın sürümleri aracın kendisiyle kaldır.", "Rather than deleting it all, remove versions you don't use with the tool itself.")
        case .svPaketYonTur: return ("Paket yöneticisi verileri", "Package manager data")
        case .svPaketYonNe: return ("Önbellek kısmı Adım 1'de temizlenir; geri kalanı kurulu araçlar.", "The cache part is cleaned in Step 1; the rest is installed tools.")
        case .svCacheTur: return ("Araç önbellekleri (~/.cache)", "Tool caches (~/.cache)")
        case .svCacheNe: return ("Komut satırı araçlarının önbellekleri (model indirmeleri dahil). Silinince gerekenler yeniden indirilir.", "Caches from command-line tools (including model downloads). Once deleted, what's needed is downloaded again.")
        case .svCacheGeri: return ("Kullanan araç yeniden indirir.", "The tool that uses it downloads it again.")
        case .svOllamaTur: return ("Ollama modelleri", "Ollama models")
        case .svOllamaNe: return ("İndirilmiş yerel yapay zekâ modelleri.", "Downloaded local AI models.")
        case .svOllamaMetin: return ("ollama rm <model> ile tek tek kaldır.", "Remove them one by one with ollama rm <model>.")
        case .svKapsayiciTur: return ("Uygulama kapsayıcıları", "App containers")
        case .svKapsayiciNe: return ("Uygulamaların korumalı veri alanları; alt kalemlere bak.", "Apps' protected data areas; look at the items inside.")
        case .svSahipliTur: return ("{0} verisi", "{0} data")
        case .svSahipliNe: return ("{0} uygulamasının verisi. Silersen ayarları ve uygulama içi verileri gider.", "Data for {0}. Deleting it loses its settings and in-app data.")
        case .svSahipliMetin: return ("Gerekirse Uygulamalar adımında uygulamayla birlikte kaldır.", "If needed, remove it together with the app in the Apps step.")
        case .svSahipsizTur: return ("Sahipsiz artık olabilir", "Possibly leftover data")
        case .svSahipsizNe: return ("Kurulu bir uygulamayla eşleşmedi; kaldırılmış bir uygulamanın artığı olabilir. Komut satırı aracına aitse silinince o aracın verisi gider.", "It didn't match any installed app, so it may be left over from an app you removed. If it belongs to a command-line tool, deleting it loses that tool's data.")
        case .svSahipsizMetin: return ("Adından ne olduğunu kontrol et; emin değilsen sakla.", "Check its name to see what it is; if you're not sure, keep it.")
        case .svKorunanTur: return ("Korunan veri", "Protected data")
        case .svLibKokTur: return ("Sistem klasörü (~/Library)", "System folder (~/Library)")
        case .svLibKokNe: return ("macOS'un ya da uygulamaların kullandığı bir kök klasör. Bütün olarak silinmesi bir şeyleri bozabilir.", "A top-level folder that macOS or apps use. Deleting it as a whole could break things.")
        case .svLibKokMetin: return ("Büyükse alt kalemlerine bak.", "If it's large, look at the items inside.")
        case .svBilinmeyenTur: return ("Bilinmeyen klasör", "Unknown folder")
        case .svBilinmeyenMetin: return ("Emin değilsen sakla; Finder'da göster ile içine bakabilirsin.", "If you're not sure, keep it; you can look inside with Show in Finder.")
        case .svGuncellemeTur: return ("Bekleyen macOS güncellemesi", "Pending macOS update")
        case .svGuncellemeNe: return ("İndirilmiş ama kurulmamış sistem güncellemesi. Kurunca kendiliğinden silinir.", "A system update that's downloaded but not installed. It's removed automatically once installed.")
        case .svGuncellemeMetin: return ("Sistem Ayarları > Genel > Yazılım Güncelleme'den güncellemeyi kur.", "Install the update from System Settings > General > Software Update.")
        case .svTakasTur: return ("Takas ve uyku imajı", "Swap and sleep image")
        case .svTakasNe: return ("Bellek takas dosyaları ve uyku için bellek görüntüsü (sleepimage). macOS yönetir.", "Memory swap files and the memory image used for sleep (sleepimage). macOS manages them.")
        case .svTakasMetin: return ("Yeniden başlatınca takas dosyaları küçülür.", "Swap files shrink after a restart.")
        case .svFoldersTur: return ("Kullanıcı geçici dosyaları ve önbellekleri", "User temporary files and caches")
        case .svFoldersNe: return ("macOS ve uygulamaların geçici dosyaları (C: önbellek, T: geçici, X: kod imzası önbellekleri). Elle silmek açık uygulamaları bozabilir.", "Temporary files from macOS and apps (C: caches, T: temporary, X: code-signing caches). Deleting them by hand can break open apps.")
        case .svFoldersMetin: return ("Yeniden başlatınca geçici kısım temizlenir.", "The temporary part is cleared after a restart.")
        case .svTmpTur: return ("Geçici dosyalar (/tmp)", "Temporary files (/tmp)")
        case .svTmpNe: return ("Programların geçici dosyaları.", "Programs' temporary files.")
        case .svTmpMetin: return ("Yeniden başlatınca temizlenir.", "Cleared after a restart.")
        case .svCltTur: return ("Komut satırı araçları / simülatör ortamları", "Command Line Tools / simulator runtimes")
        case .svCltNe: return ("Xcode Komut Satırı Araçları ve simülatör çalışma ortamları.", "Xcode Command Line Tools and simulator runtimes.")
        case .svCltMetin: return ("Simülatör ortamları için Xcode > Settings > Platforms; araçlar gerekli.", "For simulator runtimes, use Xcode > Settings > Platforms; the tools themselves are needed.")
        case .svDbTur: return ("Sistem veritabanları ve günlükleri", "System databases and logs")
        case .svDbNe: return ("macOS'un kendi kayıtları ve veritabanları.", "macOS's own logs and databases.")
        case .svDbMetin: return ("macOS yönetir.", "macOS manages these.")
        case .svLibTur: return ("Sistem genelinde uygulama verisi", "System-wide app data")
        case .svLibNe: return ("Tüm kullanıcılar için kurulmuş uygulama bileşenleri ve verileri.", "App components and data installed for all users.")
        case .svLibMetin: return ("Ait olduğu uygulamayı kaldırınca çoğu gider.", "Most of it goes away when you remove the app it belongs to.")
        case .svAppsTur: return ("Uygulamalar", "Applications")
        case .svAppsNe: return ("Kurulu uygulamalar.", "Installed apps.")
        case .svAppsMetin: return ("Uygulamalar adımında incele.", "Review them in the Apps step.")
        case .svSistemTur: return ("Sistem verisi", "System data")
        case .svSistemNe: return ("macOS'un yönettiği alan.", "Space managed by macOS.")
        case .gSec: return ("Seç", "Select")
        case .gSecErisim: return ("{0} seç", "Select {0}")
        case .gSecili: return ("seçili", "selected")
        case .gKismenSecili: return ("kısmen seçili", "partially selected")
        case .gSeciliDegil: return ("seçili değil", "not selected")
        case .gKullanilan: return ("Kullanılan", "Used")
        case .gSeciliBaslik: return ("Seçili", "Selected")
        case .gKazanilan: return ("Kazanılan", "Recovered")
        case .gBos: return ("Boş", "Free")
        case .gToplam: return ("Toplam {0}", "Total {0}")
        case .gDilSistem: return ("Sistem", "System")
        case .gDil: return ("Dil", "Language")
        case .gDilNot: return ("Menüler ve sistem pencereleri yeniden başlatınca bu dile geçer.", "Menus and system dialogs switch to this language after a restart.")
        case .dBanner: return ("DENEME KİPİ — sahte klasör üzerinde çalışıyor", "DEMO MODE — working on a fake folder")
        case .dBannerErisim: return ("Deneme kipi: sahte klasör üzerinde çalışıyor, {0}", "Demo mode: working on a fake folder, {0}")
        case .gAdimErisim: return ("Adım {0}: {1}", "Step {0}: {1}")
        case .gBuOturumda: return ("Bu oturumda", "This session")
        case .gCopte: return ("+ {0} Çöp'te", "+ {0} in the Trash")
        case .adimGuvenli: return ("Güvenli temizlik", "Safe Cleanup")
        case .adimBuyuk: return ("Büyük dosyalar", "Large Files")
        case .adimUyg: return ("Uygulamalar", "Apps")
        case .adimSistem: return ("Sistem verileri", "System Data")
        case .adimOzet: return ("Özet", "Summary")
        case .adimGuvenliAlt: return ("Bilinen gereksizler", "Known clutter")
        case .adimBuyukAlt: return ("Tek tek sorar", "One item at a time")
        case .adimUygAlt: return ("Kullanmadıkların", "Apps you don't use")
        case .adimSistemAlt: return ("Yer nereye gidiyor", "Where space goes")
        case .adimOzetAlt: return ("Ne kazandın", "What you got back")
        case .suzAltiAy: return ("6 aydan uzun", "Over 6 months")
        case .suzUcAy: return ("3 ay", "3 months")
        case .suzBirYil: return ("1 yıl", "1 year")
        case .suzKayitYok: return ("Kayıt yok", "No record")
        case .suzTumu: return ("Tümü", "All")
        case .uOzetAlti: return ("6 aydır açılmayan {0} uygulama · {1}", "{0} app not opened in 6 months · {1}||{0} apps not opened in 6 months · {1}")
        case .uOzetUc: return ("3 aydır açılmayan {0} uygulama · {1}", "{0} app not opened in 3 months · {1}||{0} apps not opened in 3 months · {1}")
        case .uOzetYil: return ("1 yıldır açılmayan {0} uygulama · {1}", "{0} app not opened in a year · {1}||{0} apps not opened in a year · {1}")
        case .uOzetKayitsiz: return ("Kullanım kaydı olmayan {0} uygulama · {1}", "{0} app with no usage record · {1}||{0} apps with no usage record · {1}")
        case .uOzetTumu: return ("Toplam {0} uygulama · {1}", "{0} app in total · {1}||{0} apps in total · {1}")
        case .sirEskiKullanim: return ("En eski kullanım", "Oldest use")
        case .sirBoyut: return ("Boyut", "Size")
        case .sirAd: return ("Ad", "Name")
        case .gTasinamadi: return ("Taşınamadı", "Couldn't move")
        case .g1OnayBaslik: return ("Seçilenler kalıcı olarak silinsin mi?", "Permanently delete the selected items?")
        case .g1KaliciSil: return ("Kalıcı olarak sil", "Delete Permanently")
        case .gVazgec: return ("Vazgeç", "Cancel")
        case .g1OnayMesaj: return ("{0} öğe, toplam {1} silinecek. Bu adımdakiler Çöp Kutusu'na gitmez, geri alınamaz. Kullanımda olan dosyalar atlanır.", "{0} item, {1} in total, will be deleted. Items in this step don't go to the Trash and can't be recovered. Files in use are skipped.||{0} items, {1} in total, will be deleted. Items in this step don't go to the Trash and can't be recovered. Files in use are skipped.")
        case .g1Alt: return ("Bilinen gereksiz dosyalar: önbellekler, günlükler, eski kurulum dosyaları.", "Known clutter: caches, logs and old installers.")
        case .g1KategoriIlerleme: return ("{0} / {1} kategori", "{0} / {1} categories")
        case .gIptal: return ("İptal", "Cancel")
        case .gYenidenTara: return ("Yeniden tara", "Scan Again")
        case .gTara: return ("Tara", "Scan")
        case .g1HenuzTaranmadi: return ("Henüz taranmadı", "Not scanned yet")
        case .g1BosAciklama: return ("Tara'ya bas; Ferah önbellekleri, günlükleri ve bilinen gereksizleri paralel olarak ölçer. Tarama hiçbir şeyi silmez.", "Click Scan and Ferah measures caches, logs and other known clutter in parallel. Scanning never deletes anything.")
        case .g1Temiz: return ("Temizlenecek bir şey bulunamadı", "Nothing to clean up")
        case .g1TemizAciklama: return ("Bilinen gereksiz dosya kategorilerinin hepsi boş görünüyor.", "All the known clutter categories look empty.")
        case .gTaraniyor: return ("Taranıyor…", "Scanning…")
        case .g1Temizleniyor: return ("Temizleniyor… {0} / {1}", "Cleaning… {0} / {1}")
        case .g1SeciliBoyut: return ("Seçili: {0}", "Selected: {0}")
        case .g1SeciliAlt: return ("{0} öğe · kalıcı olarak silinir", "{0} item · deleted permanently||{0} items · deleted permanently")
        case .g1BuyugeGec: return ("Büyük dosyalara geç", "Go to Large Files")
        case .g1Temizle: return ("Seçilenleri temizle", "Clean Selected")
        case .g1DosyaSilindi: return ("{0} dosya silindi", "{0} file deleted||{0} files deleted")
        case .g1Atlandi: return ("{0} dosya kullanımda olduğu için atlandı", "{0} file skipped because it was in use||{0} files skipped because they were in use")
        case .g1Reddedildi: return ("{0} öğe güvenlik bekçisince reddedildi", "{0} item refused by the safety guard||{0} items refused by the safety guard")
        case .g1YerAcildi: return ("{0} yer açıldı", "{0} freed")
        case .g1RaporKapat: return ("Raporu kapat", "Close Report")
        case .g1OgeSayisi: return ("{0} öğe", "{0} item||{0} items")
        case .gErisimYok: return ("Erişim izni yok", "No access permission")
        case .g1Erisilemedi: return ("{0} klasöre erişilemedi", "{0} folder couldn't be accessed||{0} folders couldn't be accessed")
        case .gTdeVer: return ("Tam Disk Erişimi ver…", "Grant Full Disk Access…")
        case .gCalisiyorEtiket: return ("çalışıyor", "running")
        case .g1DosyaSayisi: return ("{0} dosya", "{0} file||{0} files")
        case .gFinderdaGosterErisim: return ("{0} Finder'da göster", "Show {0} in Finder")
        case .gFinderdaGoster: return ("Finder'da göster", "Show in Finder")
        case .g2Alt: return ("Tek tek sorar; Çöp'e taşınır, geri alınabilir.", "One item at a time; moved to the Trash, so you can put it back.")
        case .g2Esik: return ("Eşik", "Threshold")
        case .g2EsikYardim: return ("Bu boyutun üstündeki dosyalar listelenir", "Files larger than this are listed")
        case .g2Gorunum: return ("Görünüm", "View")
        case .g2KartGorunumu: return ("Kart görünümü", "Card view")
        case .g2ListeGorunumu: return ("Liste görünümü", "List view")
        case .g2BosBaslik: return ("Ev klasöründeki büyük dosyalar", "Large files in your home folder")
        case .g2BosAciklama: return ("Eşiği seç ve tara. Ferah her dosya için ne olduğunu ve silersen ne olacağını açıklar; kararı sen verirsin.", "Pick a threshold and scan. For each file, Ferah explains what it is and what happens if you delete it; you make the call.")
        case .g2Yok: return ("Eşiği aşan dosya yok", "No files above the threshold")
        case .g2YokAciklama: return ("{0} üstünde aday bulunamadı. Daha düşük bir eşik deneyebilirsin.", "Nothing found above {0}. You can try a lower threshold.")
        case .g2Incelendi: return ("{0} öğe incelendi · {1} aday", "Checked {0} · {1} found")
        case .g2Sira: return ("{0} / {1}", "{0} / {1}")
        case .g2CopeTasinan: return ("Çöp'e taşınan: {0}", "Moved to Trash: {0}")
        case .g2TekOnayBaslik: return ("“{0}” Çöp Kutusu'na taşınsın mı?", "Move “{0}” to the Trash?")
        case .gCopeTasi: return ("Çöpe taşı", "Move to Trash")
        case .g2TekOnayMesaj: return ("{0} · {1}", "{0} · {1}")
        case .g2Bitti: return ("Hepsi bu kadar", "That's everything")
        case .g2BittiAciklama: return ("{0} öğe Çöp Kutusu'na taşındı ({1}), {2} öğe saklandı.", "{0} item moved to the Trash ({1}), {2} kept.||{0} items moved to the Trash ({1}), {2} kept.")
        case .g2BasaDon: return ("Başa dön", "Back to Start")
        case .g2UygulamalaraGec: return ("Uygulamalara geç", "Go to Apps")
        case .g2DahaOnceSakladin: return ("daha önce sakladın", "kept before")
        case .g2SonAcilma: return ("Son açılma {0}", "Last opened {0}")
        case .g2Degisme: return ("Değişme {0}", "Modified {0}")
        case .g2KopyaTasindi: return ("Bu dosyanın diğer kopyasını az önce Çöp'e taşıdın; bu artık tek kopya olabilir.", "You just moved this file's other copy to the Trash; this may now be the only copy.")
        case .gSakla: return ("Sakla", "Keep")
        case .g2SaklaYardim: return ("Sakla (←)", "Keep (←)")
        case .gGozAt: return ("Göz at", "Quick Look")
        case .g2GozAtYardim: return ("Quick Look (boşluk)", "Quick Look (Space)")
        case .g2Onceki: return ("Önceki", "Previous")
        case .g2CopeTasiYardim: return ("Çöp Kutusu'na taşı (→)", "Move to Trash (→)")
        case .g2SilmezYardim: return ("Ferah bu öğeyi silmez", "Ferah won't delete this item")
        case .g2Korunuyor: return ("Bu öğe korunuyor; Çöpe taşı düğmesi kapalı.", "This item is protected, so Move to Trash is turned off.")
        case .g2Klavye: return ("Klavye: ← sakla · → çöpe taşı (Güvenli olmayanlarda onay sorar) · boşluk göz at", "Keyboard: ← keep · → move to Trash (asks first unless Safe) · Space Quick Look")
        case .g2CopeTasindi: return ("Çöp'e taşındı", "Moved to Trash")
        case .g2Saklandi: return ("saklandı", "kept")
        case .g2Tasinamadi: return ("taşınamadı: {0}", "couldn't move: {0}")
        case .gSilersenNeOlur: return ("Silersen ne olur?", "What happens if you delete it?")
        case .gGeriNasilGelir: return ("Geri nasıl gelir:", "How to get it back:")
        case .gOneriAyrac: return ("— {0}", "— {0}")
        case .g2SutunAd: return ("Ad", "Name")
        case .g2SutunBoyut: return ("Boyut", "Size")
        case .g2SutunTur: return ("Tür", "Kind")
        case .g2SutunRisk: return ("Risk", "Risk")
        case .g2SutunDurum: return ("Durum", "Status")
        case .g2Copte: return ("Çöp'te", "In Trash")
        case .g2SaklandiBuyuk: return ("Saklandı", "Kept")
        case .g2OncedenSaklandi: return ("Önceden saklandı", "Kept before")
        case .g2SeciliOzet: return ("{0} seçili · {1}", "{0} selected · {1}")
        case .g2SecilenleriCopeTasi: return ("Seçilenleri Çöpe taşı", "Move Selected to Trash")
        case .g2TopluOnayBaslik: return ("Seçilenler Çöp Kutusu'na taşınsın mı?", "Move the selected items to the Trash?")
        case .g2TopluOnayMesaj: return ("{0} öğe ({1}) Çöp Kutusu'na taşınacak; boşaltana kadar geri alabilirsin.", "{0} item ({1}) will be moved to the Trash; you can put it back until you empty the Trash.||{0} items ({1}) will be moved to the Trash; you can put them back until you empty the Trash.")
        case .g2KorunanAtlanacak: return ("{0} korunan öğe atlanacak.", "{0} protected item will be skipped.||{0} protected items will be skipped.")
        case .g3TekOnayBaslik: return ("“{0}” Çöp Kutusu'na taşınsın mı?", "Move “{0}” to the Trash?")
        case .g3CokOnayBaslik: return ("{0} uygulama Çöp Kutusu'na taşınsın mı?", "Move {0} app to the Trash?||Move {0} apps to the Trash?")
        case .g3Verileriyle: return ("{0} (verileriyle)", "{0} (with its data)")
        case .g3VeDahasi: return ("{0} ve {1} tane daha", "{0} and {1} more")
        case .g3OnayMesaj: return ("{0}\nToplam {1}. Çöp Kutusu'nu boşaltana kadar geri alabilirsin.", "{0}\nTotal {1}. You can put them back until you empty the Trash.")
        case .g3Atlanacak: return ("{0} uygulama taşınamaz, atlanacak.", "{0} app can't be moved and will be skipped.||{0} apps can't be moved and will be skipped.")
        case .g3Alt: return ("Uzun süredir açmadığın uygulamalar. Çöp Kutusu'na taşınır, geri alınabilir.", "Apps you haven't opened in a long time. They're moved to the Trash, so you can put them back.")
        case .g3Suzgec: return ("Süzgeç", "Filter")
        case .g3Ara: return ("Ara", "Search")
        case .g3AraErisim: return ("Uygulama ara", "Search apps")
        case .g3AppleGoster: return ("Apple'ı göster", "Show Apple")
        case .g3AppleYardim: return ("Apple uygulamalarını da listele (silinemezler)", "Also list Apple apps (they can't be removed)")
        case .g3Sirala: return ("Sırala", "Sort")
        case .g3Siralama: return ("Sıralama", "Sort order")
        case .g3BosBaslik: return ("Kurulu uygulamalar", "Installed apps")
        case .g3BosAciklama: return ("Ferah /Applications ve ~/Applications'ı tarar; her uygulamanın en son ne zaman açıldığını, boyutunu ve geride bıraktığı verileri gösterir. Tarama hiçbir şeyi silmez.", "Ferah scans /Applications and ~/Applications and shows when each app was last opened, its size and the data it leaves behind. Scanning never deletes anything.")
        case .g3Inceleniyor: return ("Uygulamalar inceleniyor…", "Checking apps…")
        case .g3CokSecili: return ("{0} uygulama seçili", "{0} app selected||{0} apps selected")
        case .g3CokSeciliAciklama: return ("Toplam {0}. Ayrıntı için tek birini seç.", "Total {0}. Select a single app for details.")
        case .g3BirSec: return ("Bir uygulama seç", "Select an app")
        case .g3BirSecAciklama: return ("Silersen ne olacağını burada görürsün.", "You'll see here what happens if you delete it.")
        case .g3CokluSecim: return ("⌘ ile çoklu seçim", "⌘-click to select several")
        case .g3SeciliSayisi: return ("{0} seçili", "{0} selected")
        case .g3CopeTasiKisa: return ("Çöp'e taşı", "Move to Trash")
        case .g3CopeTasiYardim: return ("Seçilen uygulamaları Çöp Kutusu'na taşı", "Move the selected apps to the Trash")
        case .g3SistemeGec: return ("Sistem verilerine geç", "Go to System Data")
        case .g3Apple: return ("Apple", "Apple")
        case .g3Intel: return ("Intel", "Intel")
        case .g3CalisiyorEtiket: return ("Çalışıyor", "Running")
        case .g3Olculemedi: return ("ölçülemedi", "not measured")
        case .g3ArtikVeri: return ("+ {0} veri", "+ {0} data")
        case .g3BoyutOlculemediErisim: return ("boyut ölçülemedi", "size not measured")
        case .g3SatirErisim: return ("{0}, {1}, {2}", "{0}, {1}, {2}")
        case .g3SonKullanim: return ("Son kullanım: {0}", "Last used {0}")
        case .g3HicEklendi: return ("Hiç açılmamış ya da kayıt yok · eklendi {0}", "Never opened or no record · added {0}")
        case .g3KayitYokDegisti: return ("Kullanım kaydı yok · paket {0} değişti", "No usage record · bundle modified {0}")
        case .g3TarihBilinmiyor: return ("Kullanım kaydı ve eklenme tarihi bilinmiyor", "Usage record and date added unknown")
        case .g3Surum: return ("Sürüm {0}", "Version {0}")
        case .g3BoyutOlculemedi: return ("Boyut ölçülemedi", "Size not measured")
        case .g3IntelRosetta: return ("Intel · Rosetta ile çalışır", "Intel · runs with Rosetta")
        case .g3GerideKalan: return ("Geride kalan veriler", "Leftover data")
        case .g3Erisilemedi: return ("erişilemedi", "no access")
        case .g3Ac: return ("Aç", "Open")
        case .g3VerileriKaldir: return ("Verilerini de kaldır ({0})", "Also remove its data ({0})")
        case .g4Alt: return ("Depolama ekranındaki \"Sistem Verileri\" nereye gidiyor? Yalnız ölçer; ev dışındaki hiçbir şeye dokunmaz.", "Where does the \"System Data\" in Storage settings go? This only measures; nothing outside your home folder is touched.")
        case .g4OnayMesaj: return ("{0} · {1}", "{0} · {1}")
        case .g4Olculenler: return ("Ölçülenler ({0} üstü)", "Measured (over {0})")
        case .g4Diger: return ("Diğer: {0} küçük kalem", "Other: {0} small item||Other: {0} small items")
        case .g4Olculemeyenler: return ("Ölçülemeyenler ({0})", "Not measured ({0})")
        case .g4BirKalemSec: return ("Bir kalem seç", "Select an item")
        case .g4BirKalemAciklama: return ("Ne olduğunu ve ne yapılabileceğini burada görürsün.", "You'll see here what it is and what you can do about it.")
        case .g4Olculuyor: return ("Ölçülüyor… (ev klasörü, ~/Library, /Library ve geçici dizinler)", "Measuring… (home folder, ~/Library, /Library and temporary folders)")
        case .g4BosBaslik: return ("Yer nereye gidiyor?", "Where does your space go?")
        case .g4BosAciklama: return ("Ferah ~/Library, gizli klasörler, /Library ve macOS'un geçici dizinlerini ölçer ve her kalem için ne yapılabileceğini söyler. Tarama hiçbir şeyi silmez.", "Ferah measures ~/Library, hidden folders, /Library and macOS's temporary folders, and tells you what you can do about each item. Scanning never deletes anything.")
        case .g4Olculen: return ("Ölçülen", "Measured")
        case .g4Tahmini: return ("Tahmini ölçülemeyen", "Estimated unmeasured")
        case .g4TahminDegeri: return ("~{0}", "~{0}")
        case .g4AnlikGoruntu: return ("Anlık görüntü (Time Machine)", "Snapshots (Time Machine)")
        case .g4DenemeNotu: return ("Deneme kipi: yalnız sahte klasör ölçülür; ev dışı sistem yolları ve tahmin gösterilmez.", "Demo mode: only the fake folder is measured; system paths outside it and the estimate aren't shown.")
        case .g4TahminNotu: return ("Tahmin = diskte kullanılan alan − Ferah'ın ölçtüğü her şey. İçinde macOS sistem birimi, anlık görüntüler, izin verilmeyen klasörler ve ölçülemeyen kalemler var; kesin değil. macOS Depolama ekranı farklı hesapladığı için sayılar birebir tutmaz.", "Estimate = used disk space − everything Ferah measured. It includes the macOS system volume, snapshots, folders without permission and unmeasured items, so it isn't exact. macOS Storage settings calculate differently, so the numbers won't match exactly.")
        case .g4TdeYok: return ("Tam Disk Erişimi yok: diğer uygulamaların kapsayıcıları (ör. WhatsApp) izin penceresi açmamak için ölçülmedi.", "No Full Disk Access: other apps' containers (such as WhatsApp) weren't measured, to avoid permission prompts.")
        case .g4KisaFerah: return ("Ferah temizler", "Ferah cleans")
        case .g4KisaAdim1: return ("Adım 1'de", "In Step 1")
        case .g4KisaUyg: return ("Uygulamadan", "In the app")
        case .g4KisaYeniden: return ("Yeniden başlat", "Restart")
        case .g4KisaDokunma: return ("Dokunma", "Don't touch")
        case .g4KisaBilgi: return ("Bilgi", "Info")
        case .g4Sahipsiz: return ("sahipsiz?", "leftover?")
        case .g4Guvenilmez: return ("güvenilmez", "unreliable")
        case .g4OlculemediKisa: return ("ölçülemedi", "not measured")
        case .g4OlculemediBuyuk: return ("Ölçülemedi", "Not measured")
        case .g4AitOlduguUyg: return ("Ait olduğu uygulama: {0}", "Belongs to: {0}")
        case .g4SahipsizUyari: return ("Kurulu bir uygulamayla eşleşmedi; kurulu olmayan bir uygulamanın artığı olabilir.", "It didn't match any installed app, so it may be left over from an app that's no longer installed.")
        case .g4Kismen: return ("Bazı alt klasörler okunamadı; gerçek boyut daha büyük olabilir.", "Some subfolders couldn't be read, so the real size may be larger.")
        case .g4Adim1eGit: return ("Adım 1'e git", "Go to Step 1")
        case .g4EvDisi: return ("Ev klasörü dışında; Ferah yalnız bilgi verir.", "Outside your home folder; Ferah only shows information.")
        case .g5Alt: return ("Bu oturumda yaptıkların.", "What you did this session.")
        case .g5YerAcildi: return ("yer açıldı", "freed")
        case .g5Kalici: return ("Kalıcı silinen (Adım 1)", "Deleted permanently (Step 1)")
        case .g5OgeSayisi: return ("{0} öğe", "{0} item||{0} items")
        case .g5CopBosaltildi: return ("Çöp boşaltıldı", "Trash emptied")
        case .g5CopBosalinca: return ("Çöp boşalınca yer açılır", "Space is freed when the Trash is emptied")
        case .g5Adim2: return ("Çöp'e taşınan (Adım 2)", "Moved to Trash (Step 2)")
        case .g5OgeVeNot: return ("{0} öğe · {1}", "{0} item · {1}||{0} items · {1}")
        case .g5Uyg: return ("Kaldırılan uygulamalar (Adım 3)", "Removed apps (Step 3)")
        case .g5UygSayisi: return ("{0} uygulama", "{0} app||{0} apps")
        case .g5UygVeri: return ("{0} uygulama + {1} verileri", "{0} app + {1} of data||{0} apps + {1} of data")
        case .g5Sistem: return ("Sistem verilerinden (Adım 4)", "From System Data (Step 4)")
        case .g5CopBosaltilincaAcilan: return ("Çöp boşaltılınca açılan", "Freed by emptying the Trash")
        case .g5Saklanan: return ("Saklanan", "Kept")
        case .g5SaklananNot: return ("Sonraki taramada sona alınır", "Moved to the end in the next scan")
        case .g5Atlanan: return ("Atlanan", "Skipped")
        case .g5AtlananNot: return ("Kullanımda ya da kilitli olduğu için", "Because they were in use or locked")
        case .g5Reddedilen: return ("Güvenlik bekçisinin reddettiği", "Refused by the safety guard")
        case .g5Disk: return ("Disk", "Disk")
        case .g5Once: return ("Önce", "Before")
        case .g5Simdi: return ("Şimdi", "Now")
        case .g5BosDeger: return ("{0} boş", "{0} free")
        case .g5GecikmeNotu: return ("macOS boş alanı bazen gecikmeli günceller (yerel Time Machine anlık görüntüleri, temizlenebilir alan).", "macOS sometimes updates free space with a delay (local Time Machine snapshots, purgeable space).")
        case .g5Reddedilenler: return ("Reddedilenler ({0})", "Refused ({0})")
        case .g5CopuBosalt: return ("Çöp Kutusu'nu boşalt…", "Empty Trash…")
        case .g5Gecmis: return ("Geçmiş", "History")
        case .g5BastanTara: return ("Baştan tara", "Scan Again from Start")
        case .g5BosaltBaslik: return ("Çöp Kutusu boşaltılsın mı?", "Empty the Trash?")
        case .g5KaliciBosalt: return ("Kalıcı olarak boşalt", "Empty Permanently")
        case .g5Bosaltildi: return ("Çöp Kutusu boşaltıldı.", "The Trash has been emptied.")
        case .g5ErisimYok: return ("Ferah'ın Çöp Kutusu'na erişim izni yok; Finder'da açtım. Oradan Boşalt'a basabilir ya da Tam Disk Erişimi verebilirsin.", "Ferah doesn't have permission to access the Trash, so I opened it in Finder. You can click Empty there, or grant Full Disk Access.")
        case .g5BosaltMesaj: return ("Çöp Kutusu'ndaki {0} öğe ({1}) kalıcı olarak silinecek; yalnız bu oturumda taşıdıkların değil, hepsi. Geri alınamaz.", "{0} item in the Trash ({1}) will be deleted permanently — everything, not just what you moved this session. This can't be undone.||{0} items in the Trash ({1}) will be deleted permanently — everything, not just what you moved this session. This can't be undone.")
        case .g5BosaltMesajGenel: return ("Çöp Kutusu'ndaki her şey kalıcı olarak silinecek; yalnız bu oturumda taşıdıkların değil. Geri alınamaz.", "Everything in the Trash will be deleted permanently, not just what you moved this session. This can't be undone.")
        case .g5IslemSayisi: return ("{0} işlem", "{0} action||{0} actions")
        case .g5HenuzIslemYok: return ("Henüz işlem yok", "No actions yet")
        case .g5Tarih: return ("Tarih", "Date")
        case .g5Yol: return ("Yol", "Path")
        case .g5Yontem: return ("Yöntem", "Method")
        case .g5KaliciSilindi: return ("Kalıcı silindi", "Deleted permanently")
        case .g5CopeTasindi: return ("Çöp'e taşındı", "Moved to Trash")
        case .g5Kayit: return ("Kayıt: {0}", "Log file: {0}")
        case .g5Kapat: return ("Kapat", "Close")
        case .cMimariIntel: return ("Yalnız Intel", "Intel only")
        case .cMimariEvrensel: return ("Apple Silicon / Evrensel", "Apple silicon / Universal")
        case .cDiger: return ("{0} küçük kalem, {1}", "{0} small item, {1}||{0} small items, {1}")
        case .cEsikHata: return ("--esik pozitif bir MB değeri bekler", "--esik expects a positive value in MB")
        case .cYardim: return ("Ferah — macOS temizlik uygulaması\n  Ferah                        arayüzü açar\n  Ferah --tara-json            Adım 1 kategori taramasını JSON basar (salt okunur)\n  Ferah --buyuk-json [--esik MB]\n                               büyük dosya adaylarını açıklamalarıyla JSON basar (salt okunur)\n  Ferah --uygulamalar-json     kurulu uygulamaları kullanım ve artık verileriyle JSON basar (salt okunur)\n  Ferah --sistem-json          \"Sistem verileri\" dökümünü JSON basar (salt okunur)\n  Ferah --oz-sinama            geçici dizinde güvenlik ve silme sınamalarını çalıştırır\n  Ferah --akis-sinama          geçici dizinde deneme evi kurar, arayüzün görünüm modelini uçtan uca sürer\n  Ferah --deneme-evi-kur KLASÖR\n                               geçici dizin altındaki KLASÖR'e gerçekçi sahte bir ev kurar\n  Ferah --deneme-evi KLASÖR    arayüzü yalnız bu sahte ev üzerinde açar (gerçek dosyalara dokunmaz)\nHer kipte:\n  --dil tr|en                  dili zorlar (varsayılan: uygulama içi seçim, yoksa sistem dili)\nArayüz bayrakları:\n  --tema acik|koyu             görünümü zorlar\n  --ac-ve-tara, --ac-buyuk, --ac-uygulamalar, --ac-sistem\n                               açılışta salt okunur tarama başlatır\n  --adim N                     açılışta N. adıma geçer (1–5)\n  --pencere GENxYÜK            pencere boyutu (ör. 900x620)\n  --deneme-onay                (yalnız deneme kipinde) açılışta bir onay penceresi gösterir\n  --her-masaustu               (yalnız deneme kipinde) pencere her masaüstünde görünür; erişilebilirlikle sürmek için", "Ferah — a disk cleaner for macOS\n  Ferah                        opens the app\n  Ferah --tara-json            prints the Step 1 category scan as JSON (read-only)\n  Ferah --buyuk-json [--esik MB]\n                               prints large-file candidates with explanations as JSON (read-only)\n  Ferah --uygulamalar-json     prints installed apps with usage and leftover data as JSON (read-only)\n  Ferah --sistem-json          prints the \"System Data\" breakdown as JSON (read-only)\n  Ferah --oz-sinama            runs the safety and deletion tests in a temporary folder\n  Ferah --akis-sinama          sets up a demo home in a temporary folder and drives the app's view model end to end\n  Ferah --deneme-evi-kur FOLDER\n                               builds a realistic fake home in FOLDER inside the temporary directory\n  Ferah --deneme-evi FOLDER    opens the app on that fake home only (your real files are never touched)\nIn every mode:\n  --dil tr|en                  forces the language (default: in-app choice, otherwise the system language)\nApp flags:\n  --tema acik|koyu             forces light or dark appearance\n  --ac-ve-tara, --ac-buyuk, --ac-uygulamalar, --ac-sistem\n                               starts a read-only scan at launch\n  --adim N                     opens step N (1–5) at launch\n  --pencere WxH                window size (e.g. 900x620)\n  --deneme-onay                (demo mode only) shows a confirmation dialog at launch\n  --her-masaustu               (demo mode only) the window shows on every Space; for driving it through Accessibility")
        case .cDenemeKuruldu: return ("Deneme evi kuruldu: {0}", "Demo home created: {0}")
        case .cReddedildi: return ("Reddedildi: {0}", "Refused: {0}")
        case .cKurKlasorBekler: return ("--deneme-evi-kur bir klasör yolu bekler", "--deneme-evi-kur expects a folder path")
        case .cDegerBekler: return ("{0} bir değer bekler", "{0} expects a value")
        case .cBilinmeyenBayrak: return ("Bilinmeyen bayrak: {0}", "Unknown flag: {0}")
        case .cTemaHata: return ("--tema yalnız acik ya da koyu olabilir", "--tema must be acik or koyu")
        case .cDilHata: return ("--dil yalnız tr ya da en olabilir", "--dil must be tr or en")
        case .cDenemeReddedildi: return ("Deneme evi reddedildi: {0}", "Demo home refused: {0}")
        case .cDenemeOnayHata: return ("--deneme-onay yalnız --deneme-evi ile kullanılabilir", "--deneme-onay can only be used with --deneme-evi")
        }
    }
}
