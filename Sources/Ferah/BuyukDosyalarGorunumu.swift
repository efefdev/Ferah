import SwiftUI
import AppKit
import FerahCore

struct BuyukDosyalarGorunumu: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(spacing: 0) {
            baslik
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
            Divider()
            icerik
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var baslik: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(T(.adimBuyuk)).font(.title2.weight(.semibold)).lineLimit(1)
                    Text(T(.g2Alt))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                if d.tarama2 {
                    Button(T(.gIptal)) { d.iptal2Et() }
                } else {
                    Button {
                        d.tara2()
                    } label: {
                        Label(d.tarama2Yapildi ? T(.gYenidenTara) : T(.gTara), systemImage: "magnifyingglass")
                    }
                    .controlSize(.large)
                }
            }
            HStack(spacing: 12) {
                Text(T(.g2Esik)).foregroundStyle(.secondary)
                Picker(T(.g2Esik), selection: $d.esikMB) {
                    ForEach(d.ortam.esikSecenekleriMB, id: \.self) { mb in
                        Text(B(Int64(mb) * 1_000_000)).tag(mb)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                .help(T(.g2EsikYardim))
                .disabled(d.tarama2)
                Spacer()
                if d.tarama2Yapildi && !d.tarama2 {
                    Picker(T(.g2Gorunum), selection: $d.listeGorunumu) {
                        Image(systemName: "rectangle.portrait").tag(false).help(T(.g2KartGorunumu)).accessibilityLabel(T(.g2KartGorunumu))
                        Image(systemName: "list.bullet").tag(true).help(T(.g2ListeGorunumu)).accessibilityLabel(T(.g2ListeGorunumu))
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize()
                }
            }
        }
    }

    @ViewBuilder
    var icerik: some View {
        if !d.tarama2Yapildi {
            ContentUnavailableView {
                Label(T(.g2BosBaslik), systemImage: "doc.viewfinder")
            } description: {
                Text(T(.g2BosAciklama))
            } actions: {
                Button(T(.gTara)) { d.tara2() }.buttonStyle(.borderedProminent).controlSize(.large)
            }
        } else if d.tarama2 {
            TaramaSuruyor()
        } else if d.adaylar.isEmpty {
            ContentUnavailableView(T(.g2Yok), systemImage: "checkmark.circle",
                                   description: Text(T(.g2YokAciklama, .bayt(Int64(d.esikMB) * 1_000_000))))
        } else if d.listeGorunumu {
            AdayListesi()
        } else {
            KartAkisi()
        }
    }
}

struct TaramaSuruyor: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ProgressView().controlSize(.small)
                Text(T(.g2Incelendi, .sayi(d.incelenen), .sayi(d.adaylar.count)))
                    .monospacedDigit()
                Spacer()
            }
            Text(Yol.kisa(d.tarananYol, ev: d.ev))
                .font(.caption).foregroundStyle(.secondary)
                .lineLimit(1).truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
            List(d.adaylar.sorted { $0.boyut > $1.boyut }.prefix(200)) { c in
                HStack {
                    RiskRozeti(risk: c.aciklama.risk)
                    Text(c.ad).lineLimit(1)
                    Spacer()
                    Text(B(c.boyut)).monospacedDigit()
                }
            }
            .listStyle(.inset)
        }
        .padding(18)
    }
}

// MARK: - Kart akışı

struct KartAkisi: View {
    @EnvironmentObject var d: Durum
    @State private var klavye: Any?
    @State private var onayAday: BuyukAday?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(T(.g2Sira, .sayi(min(d.konum + 1, d.adaylar.count)), .sayi(d.adaylar.count)))
                    .font(.headline).monospacedDigit()
                ProgressView(value: Double(d.konum), total: Double(max(d.adaylar.count, 1)))
                    .frame(maxWidth: 260)
                Spacer()
                Text(T(.g2CopeTasinan, .bayt(d.copeTasinanBu)))
                    .foregroundStyle(.secondary).monospacedDigit()
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            Divider()
            if let c = d.siradaki {
                ScrollView {
                    AdayKarti(c: c)
                        .padding(22)
                        .id(c.id)
                }
            } else {
                KuyrukBitti()
            }
        }
        .onAppear { klavyeyiBagla() }
        .onDisappear { klavyeyiCoz() }
        .alert(
            T(.g2TekOnayBaslik, .yazi(onayAday?.ad ?? "")),
            isPresented: Binding(get: { onayAday != nil }, set: { if !$0 { onayAday = nil } }),
            presenting: onayAday
        ) { c in
            Button(T(.gVazgec), role: .cancel) {}
                .keyboardShortcut(.defaultAction)
            Button(T(.gCopeTasi), role: .destructive) { d.copeTasi([c]) }
        } message: { c in
            Text(T(.g2TekOnayMesaj, .yazi(c.aciklama.risk.etiket(EtkinDil.deger)), .bayt(c.boyut)) + "\n" + c.aciklama.neOlur.s)
        }
    }

    func klavyeyiBagla() {
        klavyeyiCoz()
        klavye = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { e in
            // Metin alanı odaktayken ya da kısayol tuşuyla birlikte basılmışsa karışma.
            if e.modifierFlags.intersection([.command, .control, .option]).isEmpty == false { return e }
            if NSApp.keyWindow?.firstResponder is NSTextView { return e }
            if NSApp.keyWindow?.attachedSheet != nil || NSApp.modalWindow != nil { return e }
            guard let c = d.siradaki, !d.tasiniyor else { return e }
            switch e.keyCode {
            case 123: // ←
                if e.isARepeat { return nil }
                d.sakla(c)
                return nil
            case 124: // →
                // Tek tuşla yalnız "Güvenli" öğeler taşınır; diğerleri onay ister.
                // Basılı tutulan tuş (tekrar) hiçbir zaman taşıma yapmaz.
                guard c.silinebilir, !e.isARepeat else { return nil }
                if c.aciklama.risk == .guvenli { d.copeTasi([c]) } else { onayAday = c }
                return nil
            case 49: // boşluk
                OnIzleme.degistir(c.yol)
                return nil
            default:
                return e
            }
        }
    }

    func klavyeyiCoz() {
        if let k = klavye { NSEvent.removeMonitor(k) }
        klavye = nil
    }
}

struct KuyrukBitti: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        let cop = d.adaylar.filter { d.kararlar[$0.yol] == .cop }.count
        let sakla = d.adaylar.filter { d.kararlar[$0.yol] == .sakla }.count
        ContentUnavailableView {
            Label(T(.g2Bitti), systemImage: "checkmark.seal")
        } description: {
            Text(T(.g2BittiAciklama, .sayi(cop), .bayt(d.copeTasinanBu), .sayi(sakla)))
        } actions: {
            HStack {
                Button(T(.g2BasaDon)) { d.konum = 0 }
                Button(T(.g2UygulamalaraGec)) { d.adim = .uygulamalar }.buttonStyle(.borderedProminent)
            }
        }
    }
}

struct AdayKarti: View {
    @EnvironmentObject var d: Durum
    let c: BuyukAday

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: c.yol))
                    .resizable()
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 5) {
                    Text(c.ad).font(.title2.weight(.semibold)).lineLimit(2)
                    Text(Yol.kisa(Yol.ebeveyn(c.yol), ev: d.ev))
                        .font(.callout).foregroundStyle(.secondary)
                        .lineLimit(1).truncationMode(.middle)
                        .textSelection(.enabled)
                    HStack(spacing: 8) {
                        Text(B(c.boyut)).font(.title3.weight(.semibold)).monospacedDigit()
                        Etiket(metin: c.aciklama.tur.s)
                        RiskRozeti(risk: c.aciklama.risk)
                        if c.saklandi { Etiket(metin: T(.g2DahaOnceSakladin), renk: .blue) }
                        if let k = d.kararlar[c.yol] { kararEtiketi(k) }
                    }
                    HStack(spacing: 14) {
                        if let a = c.girdi.sonAcilma {
                            Label(T(.g2SonAcilma, .goreli(a, Date())), systemImage: "eye")
                        }
                        if let m = c.girdi.sonDegisme {
                            Label(T(.g2Degisme, .goreli(m, Date())), systemImage: "pencil")
                        }
                    }
                    .font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            NeOlurKutusu(a: c.aciklama)

            if let k = c.sinyaller.kopyaYolu, d.kararlar[k] == .cop {
                Label(T(.g2KopyaTasindi),
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 10) {
                Button {
                    d.sakla(c)
                } label: {
                    Label(T(.gSakla), systemImage: "arrow.left")
                }
                .help(T(.g2SaklaYardim))
                Button {
                    OnIzleme.degistir(c.yol)
                } label: {
                    Label(T(.gGozAt), systemImage: "eye")
                }
                .help(T(.g2GozAtYardim))
                Button {
                    finderdaGoster(c.yol)
                } label: {
                    Label(T(.gFinderdaGoster), systemImage: "folder")
                }
                Spacer()
                if d.konum > 0 {
                    Button(T(.g2Onceki)) { d.oncekine() }
                }
                Button {
                    d.copeTasi([c])
                } label: {
                    Label(T(.gCopeTasi), systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(c.aciklama.risk >= .riskli ? .red : .accentColor)
                .disabled(!c.silinebilir || d.tasiniyor)
                .help(c.silinebilir ? T(.g2CopeTasiYardim) : T(.g2SilmezYardim))
            }
            .controlSize(.large)
            if !c.silinebilir {
                Label(T(.g2Korunuyor), systemImage: "lock")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Text(T(.g2Klavye))
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding(22)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.primary.opacity(0.07)))
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func kararEtiketi(_ k: Karar) -> some View {
        switch k {
        case .cop: Etiket(metin: T(.g2CopeTasindi), renk: .green)
        case .sakla: Etiket(metin: T(.g2Saklandi), renk: .blue)
        case .hata(let m): Etiket(metin: T(.g2Tasinamadi, .metin(m)), renk: .red)
        }
    }
}

struct NeOlurKutusu: View {
    let a: Aciklama

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(T(.gSilersenNeOlur), systemImage: "questionmark.circle.fill")
                .font(.headline)
                .foregroundStyle(a.risk.renk)
            Text(a.neOlur.s).fixedSize(horizontal: false, vertical: true)
            if let g = a.geriNasil {
                HStack(alignment: .top, spacing: 6) {
                    Text(T(.gGeriNasilGelir)).fontWeight(.semibold)
                    Text(g.s).fixedSize(horizontal: false, vertical: true)
                }
                .font(.callout)
            }
            ForEach(a.baglam, id: \.self) { b in
                Label(b.s, systemImage: "info.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "lightbulb")
                Text(a.oneri.etiket(EtkinDil.deger)).fontWeight(.semibold)
                if let m = a.oneriMetni { Text(T(.gOneriAyrac, .metin(m))).fixedSize(horizontal: false, vertical: true) }
            }
            .font(.callout)
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(a.risk.renk.opacity(0.09), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(a.risk.renk.opacity(0.35)))
    }
}

// MARK: - Liste görünümü

struct AdayListesi: View {
    @EnvironmentObject var d: Durum
    @State private var secim = Set<String>()
    @State private var onaySor = false

    var secilenler: [BuyukAday] { d.adaylar.filter { secim.contains($0.id) } }

    var body: some View {
        VStack(spacing: 0) {
            Table(d.adaylar, selection: $secim) {
                TableColumn(T(.g2SutunAd)) { c in
                    HStack(spacing: 6) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: c.yol)).resizable().frame(width: 16, height: 16)
                        Text(c.ad).lineLimit(1)
                    }
                    .help(c.yol)
                }
                .width(min: 180, ideal: 280)
                TableColumn(T(.g2SutunBoyut)) { c in Text(B(c.boyut)).monospacedDigit() }
                    .width(min: 70, ideal: 90)
                TableColumn(T(.g2SutunTur)) { c in Text(c.aciklama.tur.s).lineLimit(1) }
                    .width(min: 120, ideal: 200)
                TableColumn(T(.g2SutunRisk)) { c in RiskRozeti(risk: c.aciklama.risk) }
                    .width(min: 80, ideal: 90)
                TableColumn(T(.g2SutunDurum)) { c in
                    switch d.kararlar[c.yol] {
                    case .cop: Text(T(.g2Copte)).foregroundStyle(.green)
                    case .sakla: Text(T(.g2SaklandiBuyuk)).foregroundStyle(.blue)
                    case .hata: Text(T(.gTasinamadi)).foregroundStyle(.red)
                    case nil: Text(c.saklandi ? T(.g2OncedenSaklandi) : "—").foregroundStyle(.secondary)
                    }
                }
                .width(min: 80, ideal: 110)
            }
            Divider()
            HStack {
                if let tek = secilenler.first, secilenler.count == 1 {
                    Text(tek.aciklama.neOlur.s).font(.callout).foregroundStyle(.secondary).lineLimit(2)
                } else {
                    Text(T(.g2SeciliOzet, .sayi(secim.count), .bayt(secilenler.reduce(0) { $0 + $1.boyut })))
                        .foregroundStyle(.secondary).monospacedDigit()
                }
                Spacer()
                Button(T(.gSakla)) { for c in secilenler { d.sakla(c, ilerle: false) } }
                    .disabled(secim.isEmpty)
                Button(T(.gFinderdaGoster)) { if let c = secilenler.first { finderdaGoster(c.yol) } }
                    .disabled(secim.count != 1)
                Button {
                    onaySor = true
                } label: {
                    Label(T(.g2SecilenleriCopeTasi), systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!secilenler.contains { $0.silinebilir } || d.tasiniyor)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
        .alert(T(.g2TopluOnayBaslik), isPresented: $onaySor) {
            Button(T(.gCopeTasi)) { d.copeTasi(secilenler, ilerle: false) }
            Button(T(.gVazgec), role: .cancel) {}
        } message: {
            let tasinabilir = secilenler.filter(\.silinebilir)
            let korunan = secilenler.count - tasinabilir.count
            Text(T(.g2TopluOnayMesaj, .sayi(tasinabilir.count), .bayt(tasinabilir.reduce(0) { $0 + $1.boyut })) + (korunan > 0 ? " " + T(.g2KorunanAtlanacak, .sayi(korunan)) : ""))
        }
    }
}
