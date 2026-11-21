import SwiftUI
import AppKit
import FerahCore

struct SistemVerileriGorunumu: View {
    @EnvironmentObject var d: Durum
    @State private var secim: String?
    @State private var onay: SistemKalemi?
    @State private var olculemeyenAcik = false

    var body: some View {
        VStack(spacing: 0) {
            baslik
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
            Divider()
            icerik
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(T(.g2TekOnayBaslik, .yazi(onay?.ad ?? "")),
               isPresented: Binding(get: { onay != nil }, set: { if !$0 { onay = nil } }), presenting: onay) { k in
            Button(T(.gVazgec), role: .cancel) {}
                .keyboardShortcut(.defaultAction)
            Button(T(.gCopeTasi), role: .destructive) { d.sistemKaleminiCopeTasi(k) }
        } message: { k in
            Text(T(.g4OnayMesaj, .yazi(Yol.kisa(k.yol, ev: d.ev)), .bayt(k.boyut)) + "\n" + k.aciklama.neOlur.s)
        }
    }

    var baslik: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(T(.adimSistem)).font(.title2.weight(.semibold))
                Text(T(.g4Alt))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if d.tarama4 {
                ProgressView().controlSize(.small)
                Text(T(.g2Sira, .sayi(d.tarama4Ilerleme.0), .sayi(d.tarama4Ilerleme.1))).foregroundStyle(.secondary).monospacedDigit()
            } else {
                Button { d.tara4() } label: {
                    Label(d.dokum == nil ? T(.gTara) : T(.gYenidenTara), systemImage: "magnifyingglass")
                }
                .controlSize(.large)
            }
        }
    }

    @ViewBuilder
    var icerik: some View {
        if let dk = d.dokum {
            let olculen = dk.kalemler.filter { $0.olculemedi == nil }
            let olculemeyen = dk.kalemler.filter { $0.olculemedi != nil }
            let enBuyuk = max(olculen.first?.boyut ?? 1, 1)
            HStack(spacing: 0) {
                List(selection: $secim) {
                    Section {
                        ozet(dk)
                    }
                    Section(T(.g4Olculenler, .bayt(dk.esik))) {
                        ForEach(olculen) { k in
                            SistemSatiri(k: k, oran: Double(k.boyut) / Double(enBuyuk)).tag(k.id)
                        }
                        HStack {
                            Text(T(.g4Diger, .sayi(dk.digerSayi))).foregroundStyle(.secondary)
                            Spacer()
                            Text(B(dk.digerBayt)).monospacedDigit().foregroundStyle(.secondary)
                        }
                    }
                    if !olculemeyen.isEmpty {
                        Section {
                            DisclosureGroup(T(.g4Olculemeyenler, .sayi(olculemeyen.count)), isExpanded: $olculemeyenAcik) {
                                ForEach(olculemeyen) { k in
                                    SistemSatiri(k: k, oran: 0).tag(k.id)
                                }
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .frame(minWidth: 360, idealWidth: 520)
                Divider()
                Group {
                    if let s = secim, let k = dk.kalemler.first(where: { $0.id == s }) {
                        ScrollView { SistemKarti(k: k, onayIste: { onay = $0 }).padding(18) }
                    } else {
                        BolmeYerTutucu(T(.g4BirKalemSec), systemImage: "hand.point.left",
                                               description: Text(T(.g4BirKalemAciklama)))
                    }
                }
                .frame(minWidth: 260, maxWidth: .infinity, maxHeight: .infinity)
            }
        } else if d.tarama4 {
            ProgressView(T(.g4Olculuyor))
        } else {
            ContentUnavailableView {
                Label(T(.g4BosBaslik), systemImage: "chart.bar.doc.horizontal")
            } description: {
                Text(T(.g4BosAciklama))
            } actions: {
                Button(T(.gTara)) { d.tara4() }.buttonStyle(.borderedProminent).controlSize(.large)
            }
        }
    }

    func ozet(_ dk: SistemDokumu) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 18) {
                VStack(alignment: .leading) {
                    Text(T(.g4Olculen)).font(.caption).foregroundStyle(.secondary)
                    Text(B(dk.olculen)).font(.title3.weight(.semibold)).monospacedDigit()
                }
                if let y = dk.tahminiOlculemeyen, !d.ortam.deneme {
                    VStack(alignment: .leading) {
                        Text(T(.g4Tahmini)).font(.caption).foregroundStyle(.secondary)
                        Text(T(.g4TahminDegeri, .bayt(y))).font(.title3.weight(.semibold)).monospacedDigit()
                    }
                }
                VStack(alignment: .leading) {
                    Text(T(.g4AnlikGoruntu)).font(.caption).foregroundStyle(.secondary)
                    Text(N(dk.anlikGoruntuler.count)).font(.title3.weight(.semibold))
                }
            }
            if d.ortam.deneme {
                Text(T(.g4DenemeNotu))
                    .font(.caption).foregroundStyle(.secondary)
            } else {
            Text(T(.g4TahminNotu))
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            if !dk.tamDiskErisimi && !d.ortam.deneme {
                HStack {
                    Label(T(.g4TdeYok),
                          systemImage: "lock.fill")
                        .font(.caption).foregroundStyle(.orange)
                    Button(T(.gTdeVer)) { d.tamDiskErisimiAc() }.font(.caption).buttonStyle(.link)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

extension SistemEylemi {
    /// Rozet için kısa ad (tam ad yardım balonunda ve erişilebilirlikte).
    var kisaEtiket: String {
        switch self {
        case .ferahTemizler: return T(.g4KisaFerah)
        case .adim1: return T(.g4KisaAdim1)
        case .uygulamaIcinden: return T(.g4KisaUyg)
        case .yenidenBaslat: return T(.g4KisaYeniden)
        case .dokunma: return T(.g4KisaDokunma)
        case .bilgi: return T(.g4KisaBilgi)
        }
    }

    var renk: Color {
        switch self {
        case .ferahTemizler: return .green
        case .adim1: return .teal
        case .uygulamaIcinden: return .blue
        case .yenidenBaslat: return .indigo
        case .dokunma: return .purple
        case .bilgi: return .secondary
        }
    }
}

struct SistemSatiri: View {
    @EnvironmentObject var d: Durum
    let k: SistemKalemi
    let oran: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if k.ust != nil { Image(systemName: "arrow.turn.down.right").font(.caption).foregroundStyle(.tertiary) }
                VStack(alignment: .leading, spacing: 1) {
                    Text(k.sahip.map { T(.ikili, .yazi(k.ad), .yazi($0)) } ?? k.ad).lineLimit(1)
                    Text(Yol.kisa(Yol.ebeveyn(k.yol), ev: d.ev)).font(.caption2).foregroundStyle(.tertiary)
                        .lineLimit(1).truncationMode(.middle)
                }
                Spacer()
                if k.sahipsiz { Etiket(metin: T(.g4Sahipsiz), renk: .orange) }
                Etiket(metin: k.eylem.kisaEtiket, renk: k.eylem.renk)
                    .fixedSize()
                    .help(k.eylem.etiket(EtkinDil.deger))
                if let n = k.olculemedi {
                    Text(n.a == .svOlcGuvenilmez ? T(.g4Guvenilmez) : T(.g4OlculemediKisa)).font(.caption).foregroundStyle(.orange)
                } else {
                    Text(B(k.boyut)).monospacedDigit().frame(width: 72, alignment: .trailing)
                }
                if d.sistemKararlari[k.yol] == .cop { Etiket(metin: T(.g2Copte), renk: .green) }
            }
            if oran > 0 {
                GeometryReader { g in
                    Capsule().fill(k.eylem.renk.opacity(0.55))
                        .frame(width: max(2, g.size.width * oran))
                }
                .frame(height: 4)
                .padding(.leading, k.ust != nil ? 22 : 0)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(T(.g3SatirErisim, .yazi(k.ad), .yazi(k.olculemedi == nil ? B(k.boyut) : T(.g4OlculemediKisa)), .yazi(k.eylem.etiket(EtkinDil.deger))))
    }
}

struct SistemKarti: View {
    @EnvironmentObject var d: Durum
    let k: SistemKalemi
    let onayIste: (SistemKalemi) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(k.ad).font(.title2.weight(.semibold))
                Text(Yol.kisa(k.yol, ev: d.ev)).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                HStack(spacing: 6) {
                    Text(k.olculemedi == nil ? B(k.boyut) : T(.g4OlculemediBuyuk)).font(.title3.weight(.semibold)).monospacedDigit()
                    Etiket(metin: k.aciklama.tur.s)
                    RiskRozeti(risk: k.aciklama.risk)
                    Etiket(metin: k.eylem.etiket(EtkinDil.deger), renk: k.eylem.renk)
                }
                if let s = k.sahip { Text(T(.g4AitOlduguUyg, .yazi(s))).font(.callout) }
                if k.sahipsiz {
                    Label(T(.g4SahipsizUyari), systemImage: "questionmark.folder")
                        .font(.callout).foregroundStyle(.orange)
                }
                if let n = k.olculemedi { Text(n.s).font(.callout).foregroundStyle(.orange) }
                if k.kismen { Text(T(.g4Kismen)).font(.caption).foregroundStyle(.secondary) }
            }
            NeOlurKutusu(a: k.aciklama)
            if case .hata(let m) = d.sistemKararlari[k.yol] {
                Label(m.s, systemImage: "exclamationmark.triangle.fill").font(.callout).foregroundStyle(.orange)
            }
            HStack {
                Button { finderdaGoster(k.yol) } label: { Label(T(.gFinderdaGoster), systemImage: "folder") }
                Spacer()
                if k.tasinabilir {
                    Button { onayIste(k) } label: { Label(T(.gCopeTasi), systemImage: "trash") }
                        .buttonStyle(.borderedProminent)
                        .disabled(d.tasiniyor || d.sistemKararlari[k.yol] == .cop)
                } else if k.eylem == .adim1 {
                    Button(T(.g4Adim1eGit)) { d.adim = .guvenli }
                } else if !k.evIcinde {
                    Text(T(.g4EvDisi)).font(.caption).foregroundStyle(.secondary)
                }
            }
            .controlSize(.large)
        }
        .padding(18)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.primary.opacity(0.07)))
    }
}
