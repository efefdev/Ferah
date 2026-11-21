import SwiftUI
import AppKit
import FerahCore

struct UygulamalarGorunumu: View {
    @EnvironmentObject var d: Durum
    @State private var onay: [UygulamaBilgisi] = []

    var liste: [UygulamaBilgisi] { d.gorunenUygulamalar }
    var secilenler: [UygulamaBilgisi] { d.uygulamalar.filter { d.uygulamaSecimi.contains($0.id) } }

    var body: some View {
        VStack(spacing: 0) {
            baslik
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 10)
            Divider()
            icerik
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(onay.count == 1 ? T(.g3TekOnayBaslik, .yazi(onay.first?.ad ?? "")) : T(.g3CokOnayBaslik, .sayi(onay.count)),
               isPresented: Binding(get: { !onay.isEmpty }, set: { if !$0 { onay = [] } })) {
            Button(T(.gVazgec), role: .cancel) {}
                .keyboardShortcut(.defaultAction)
            Button(T(.gCopeTasi), role: .destructive) { d.uygulamalariCopeTasi(onay) }
        } message: {
            let tasinabilir = onay.filter(\.silinebilir)
            let adlar = tasinabilir.prefix(8).map { u in
                d.verileriDahil(u) && !u.girdi.artiklar.isEmpty ? T(.g3Verileriyle, .yazi(u.ad)) : u.ad
            }.joined(separator: ", ")
            let toplam = tasinabilir.reduce(Int64(0)) { $0 + d.tasinacakBoyut($1) }
            let liste = tasinabilir.count > 8 ? T(.g3VeDahasi, .yazi(adlar), .sayi(tasinabilir.count - 8)) : adlar
            let atlanan = onay.count - tasinabilir.count
            Text(T(.g3OnayMesaj, .yazi(liste), .bayt(toplam))
                 + (atlanan > 0 ? " " + T(.g3Atlanacak, .sayi(atlanan)) : ""))
        }
    }

    var baslik: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(T(.adimUyg)).font(.title2.weight(.semibold))
                    Text(T(.g3Alt))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if d.tarama3 {
                    ProgressView().controlSize(.small)
                    Text(T(.g2Sira, .sayi(d.tarama3Ilerleme.0), .sayi(d.tarama3Ilerleme.1))).foregroundStyle(.secondary).monospacedDigit()
                } else {
                    Button {
                        d.tara3()
                    } label: {
                        Label(d.tarama3Yapildi ? T(.gYenidenTara) : T(.gTara), systemImage: "magnifyingglass")
                    }
                    .controlSize(.large)
                }
            }
            if d.tarama3Yapildi {
                // İki satır: dar pencerede (900 pt) de taşmasın.
                HStack(spacing: 10) {
                    Picker(T(.g3Suzgec), selection: $d.suzgec) {
                        ForEach(UygulamaSuzgeci.allCases) { Text($0.etiket).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .accessibilityLabel(T(.g3Suzgec))
                }
                HStack(spacing: 10) {
                    TextField(T(.g3Ara), text: $d.arama)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 260)
                        .accessibilityLabel(T(.g3AraErisim))
                        // macOS penceredeki ilk metin alanını kendiliğinden odaklar; sayfa açılınca
                        // klavye girdisi arama kutusuna kaymasın diye odağı bırak.
                        .onAppear {
                            DispatchQueue.main.async { NSApp.windows.forEach { $0.makeFirstResponder(nil) } }
                        }
                    Toggle(T(.g3AppleGoster), isOn: $d.appleGoster)
                        .toggleStyle(.checkbox)
                        .fixedSize()
                        .help(T(.g3AppleYardim))
                    Spacer(minLength: 8)
                    Picker(T(.g3Sirala), selection: $d.siralama) {
                        ForEach(UygulamaSiralama.allCases) { Text($0.etiket).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                    .accessibilityLabel(T(.g3Siralama))
                }
            }
        }
    }

    @ViewBuilder
    var icerik: some View {
        if !d.tarama3Yapildi {
            ContentUnavailableView {
                Label(T(.g3BosBaslik), systemImage: "square.grid.2x2")
            } description: {
                Text(T(.g3BosAciklama))
            } actions: {
                Button(T(.gTara)) { d.tara3() }.buttonStyle(.borderedProminent).controlSize(.large)
            }
        } else if d.tarama3 && d.uygulamalar.isEmpty {
            ProgressView(T(.g3Inceleniyor))
        } else {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ozetSatiri
                    Divider()
                    List(liste, selection: $d.uygulamaSecimi) { u in
                        UygulamaSatiri(u: u).tag(u.id)
                    }
                    .listStyle(.inset)
                    .frame(maxHeight: .infinity)
                    Divider()
                    altCubuk
                }
                // Sağdaki kart uzun olunca liste sütunu kısalmasın: sütun tüm yüksekliği kaplar.
                .frame(minWidth: 340, idealWidth: 430, maxHeight: .infinity)
                Divider()
                Group {
                    if secilenler.count == 1, let u = secilenler.first {
                        ScrollView { UygulamaKarti(u: u, onayIste: { onay = $0 }).padding(18) }
                    } else if secilenler.count > 1 {
                        BolmeYerTutucu(T(.g3CokSecili, .sayi(secilenler.count)), systemImage: "square.stack",
                                               description: Text(T(.g3CokSeciliAciklama, .bayt(secilenler.reduce(0) { $0 + d.tasinacakBoyut($1) }))))
                    } else {
                        BolmeYerTutucu(T(.g3BirSec), systemImage: "hand.point.left",
                                               description: Text(T(.g3BirSecAciklama)))
                    }
                }
                .frame(minWidth: 260, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    var ozetSatiri: some View {
        HStack {
            Text(d.suzgec.ozet(liste.count, liste.reduce(0) { $0 + $1.girdi.boyut }))
                .font(.callout.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    var altCubuk: some View {
        HStack {
            // Dar pencerede kesilmesin: sığmazsa ipucu gizlenir (düğmenin yardım balonunda da var).
            ViewThatFits(in: .horizontal) {
                Text(d.uygulamaSecimi.isEmpty ? T(.g3CokluSecim) : T(.g3SeciliSayisi, .sayi(d.uygulamaSecimi.count))).fixedSize()
                Text(d.uygulamaSecimi.isEmpty ? "" : T(.g3SeciliSayisi, .sayi(d.uygulamaSecimi.count))).fixedSize()
                Color.clear.frame(width: 0, height: 0)
            }
                .font(.caption).foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer(minLength: 8)
            Button {
                onay = secilenler
            } label: {
                Label(T(.g3CopeTasiKisa), systemImage: "trash")
            }
            .fixedSize()
            .help(T(.g3CopeTasiYardim) + " — " + T(.g3CokluSecim))
            .disabled(!secilenler.contains { $0.silinebilir && d.uygulamaKararlari[$0.yol] != .cop } || d.tasiniyor)
            Button(T(.g3SistemeGec)) { d.adim = .sistem }
                .fixedSize()
        }
        .padding(10)
    }
}

struct UygulamaSatiri: View {
    @EnvironmentObject var d: Durum
    let u: UygulamaBilgisi

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: u.yol)).resizable().frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(u.ad).lineLimit(1)
                    if let s = u.girdi.surum { Text(s).font(.caption).foregroundStyle(.tertiary).lineLimit(1) }
                }
                Text(kullanimMetni).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                HStack(spacing: 4) {
                    if u.girdi.kaynak == .appStore { Etiket(metin: T(.uKaynakAppStore), renk: .blue) }
                    if u.girdi.apple { Etiket(metin: T(.g3Apple)) }
                    if u.girdi.yalnizIntel { Etiket(metin: T(.g3Intel), renk: .orange) }
                    if u.girdi.calisiyor { Etiket(metin: T(.g3CalisiyorEtiket), renk: .green) }
                    if let k = d.uygulamaKararlari[u.yol] {
                        switch k {
                        case .cop: Etiket(metin: T(.g2Copte), renk: .green)
                        case .hata: Etiket(metin: T(.gTasinamadi), renk: .red)
                        case .sakla: EmptyView()
                        }
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(u.girdi.boyutNotu == nil ? B(u.girdi.boyut) : T(.g3Olculemedi))
                    .monospacedDigit()
                    .foregroundStyle(u.girdi.boyutNotu == nil ? Color.primary : Color.orange)
                if u.girdi.artikBoyutu > 0 {
                    Text(T(.g3ArtikVeri, .bayt(u.girdi.artikBoyutu))).font(.caption).foregroundStyle(.secondary).monospacedDigit()
                }
            }
        }
        .padding(.vertical, 3)
        .opacity(d.uygulamaKararlari[u.yol] == .cop ? 0.5 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(T(.g3SatirErisim, .yazi(u.ad), .yazi(u.girdi.boyutNotu == nil ? B(u.girdi.boyut) : T(.g3BoyutOlculemediErisim)), .yazi(kullanimMetni)))
    }

    var kullanimMetni: String {
        if let s = u.girdi.sonKullanilma { return T(.g3SonKullanim, .goreli(s, Date())) }
        if let e = u.girdi.eklenme { return T(.g3HicEklendi, .goreli(e, Date())) }
        if let m = u.girdi.degisme { return T(.g3KayitYokDegisti, .goreli(m, Date())) }
        return T(.g3TarihBilinmiyor)
    }
}

struct UygulamaKarti: View {
    @EnvironmentObject var d: Durum
    let u: UygulamaBilgisi
    let onayIste: ([UygulamaBilgisi]) -> Void

    var veriler: Binding<Bool> {
        Binding(get: { d.verilerDahil[u.yol] ?? false }, set: { d.verilerDahil[u.yol] = $0 })
    }

    var body: some View {
        let a = AciklamaMotoru.uygulamaAcikla(u.girdi, verilerDahil: d.verileriDahil(u))
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: u.yol)).resizable().frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(u.ad).font(.title2.weight(.semibold))
                    Text([u.girdi.surum.map { T(.g3Surum, .yazi($0)) }, u.girdi.kimlik].compactMap { $0 }.joined(separator: " · "))
                        .font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                    Text(Yol.kisa(u.yol, ev: d.ev)).font(.caption).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    // Dar bölmede rozetler alt satıra iner; rozet yazısı kırılmaz.
                    let boyut = Text(u.girdi.boyutNotu == nil ? B(u.girdi.boyut) : T(.g3BoyutOlculemedi))
                        .font(.title3.weight(.semibold)).monospacedDigit()
                    let rozetler = HStack(spacing: 6) {
                        Etiket(metin: u.girdi.kaynak.etiket(EtkinDil.deger), renk: u.girdi.kaynak == .appStore ? .blue : .secondary)
                            .fixedSize()
                        if u.girdi.yalnizIntel { Etiket(metin: T(.g3IntelRosetta), renk: .orange).fixedSize() }
                        RiskRozeti(risk: a.risk).fixedSize()
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 6) { boyut; rozetler }
                        VStack(alignment: .leading, spacing: 6) { boyut; rozetler }
                    }
                }
            }

            NeOlurKutusu(a: a)

            if !u.girdi.artiklar.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(T(.g3GerideKalan)).font(.headline)
                    ForEach(u.girdi.artiklar) { ar in
                        HStack {
                            Text(ar.tur.s).frame(width: 140, alignment: .leading)
                            Text(Yol.kisa(ar.yol, ev: d.ev)).lineLimit(1).truncationMode(.middle).foregroundStyle(.secondary)
                            Spacer()
                            Text(ar.erisilemedi ? T(.g3Erisilemedi) : B(ar.boyut)).monospacedDigit()
                        }
                        .font(.caption)
                    }
                }
            }

            if let neden = u.girdi.silinemezNedeni {
                Label(neden.s, systemImage: "lock").font(.callout).foregroundStyle(.secondary)
            }
            if case .hata(let m) = d.uygulamaKararlari[u.yol] {
                Label(m.s, systemImage: "exclamationmark.triangle.fill").font(.callout).foregroundStyle(.orange)
            }

            // İki satır: dar sağ bölmede düğme yazıları kesilmesin.
            if !u.girdi.artiklar.isEmpty {
                Toggle(T(.g3VerileriKaldir, .bayt(u.girdi.artikBoyutu)), isOn: veriler)
                    .toggleStyle(.checkbox)
                    .disabled(!u.silinebilir)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 10) {
                // Sığarsa yazılı, sığmazsa yalnız simgeli (yardım balonu ve erişilebilirlik adı aynı kalır).
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        Button { finderdaGoster(u.yol) } label: { Label(T(.gFinderdaGoster), systemImage: "folder") }
                            .fixedSize()
                        Button { NSWorkspace.shared.open(URL(fileURLWithPath: u.yol)) } label: { Label(T(.g3Ac), systemImage: "arrow.up.forward.app") }
                            .disabled(u.girdi.sembolikBag)
                            .fixedSize()
                    }
                    HStack(spacing: 10) {
                        Button { finderdaGoster(u.yol) } label: { Label(T(.gFinderdaGoster), systemImage: "folder").labelStyle(.iconOnly) }
                            .help(T(.gFinderdaGoster))
                            .accessibilityLabel(T(.gFinderdaGoster))
                        Button { NSWorkspace.shared.open(URL(fileURLWithPath: u.yol)) } label: { Label(T(.g3Ac), systemImage: "arrow.up.forward.app").labelStyle(.iconOnly) }
                            .disabled(u.girdi.sembolikBag)
                            .help(T(.g3Ac))
                            .accessibilityLabel(T(.g3Ac))
                    }
                }
                Spacer(minLength: 8)
                Button { onayIste([u]) } label: { Label(T(.gCopeTasi), systemImage: "trash") }
                    .buttonStyle(.borderedProminent)
                    .tint(a.risk >= .dikkat ? .orange : .accentColor)
                    .disabled(!u.silinebilir || d.tasiniyor || d.uygulamaKararlari[u.yol] == .cop)
                    .fixedSize()
            }
            .controlSize(.large)
        }
        .padding(18)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.primary.opacity(0.07)))
    }
}
