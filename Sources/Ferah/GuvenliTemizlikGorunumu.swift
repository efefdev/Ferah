import SwiftUI
import FerahCore

struct GuvenliTemizlikGorunumu: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(spacing: 0) {
            baslik
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
            Divider()
            icerik
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            altCubuk
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
        }
        .alert(T(.g1OnayBaslik), isPresented: $d.adim1Onay) {
            Button(T(.g1KaliciSil), role: .destructive) { d.temizle1() }
            Button(T(.gVazgec), role: .cancel) {}
        } message: {
            Text(T(.g1OnayMesaj, .sayi(d.seciliSayi), .bayt(d.seciliBoyut)))
        }
    }

    var baslik: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(T(.adimGuvenli)).font(.title2.weight(.semibold))
                Text(T(.g1Alt))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if d.tarama1 {
                ProgressView().controlSize(.small)
                Text(T(.g1KategoriIlerleme, .sayi(d.bitenKategori), .sayi(KategoriKimlik.allCases.count)))
                    .foregroundStyle(.secondary).monospacedDigit()
                Button(T(.gIptal)) { d.iptal1Et() }
            } else {
                Button {
                    d.tara1()
                } label: {
                    Label(d.tarama1Yapildi ? T(.gYenidenTara) : T(.gTara), systemImage: "magnifyingglass")
                }
                .controlSize(.large)
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }

    @ViewBuilder
    var icerik: some View {
        if !d.tarama1Yapildi {
            ContentUnavailableView {
                Label(T(.g1HenuzTaranmadi), systemImage: "sparkles")
            } description: {
                Text(T(.g1BosAciklama))
            } actions: {
                Button(T(.gTara)) { d.tara1() }.buttonStyle(.borderedProminent).controlSize(.large)
            }
        } else if d.gorunenKategoriler.isEmpty && !d.tarama1 {
            ContentUnavailableView(T(.g1Temiz), systemImage: "checkmark.circle",
                                   description: Text(T(.g1TemizAciklama)))
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    if let r = d.sonRapor { RaporSeridi(rapor: r) }
                    ForEach(d.gorunenKategoriler) { k in
                        KategoriKarti(k: k)
                    }
                    if d.tarama1 {
                        HStack { ProgressView().controlSize(.small); Text(T(.gTaraniyor)).foregroundStyle(.secondary) }
                            .padding()
                    }
                }
                .padding(18)
            }
        }
    }

    var altCubuk: some View {
        HStack {
            if d.temizleniyor {
                ProgressView(value: Double(d.temizlikIlerleme.0), total: Double(max(d.temizlikIlerleme.1, 1)))
                    .frame(width: 180)
                Text(T(.g1Temizleniyor, .sayi(d.temizlikIlerleme.0), .sayi(d.temizlikIlerleme.1))).foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    Text(T(.g1SeciliBoyut, .bayt(d.seciliBoyut))).font(.headline).monospacedDigit()
                    Text(T(.g1SeciliAlt, .sayi(d.seciliSayi))).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(T(.g1BuyugeGec)) { d.adim = .buyuk }
            Button {
                d.adim1Onay = true
            } label: {
                Label(T(.g1Temizle), systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!d.temizlenebilir)
        }
    }
}

struct RaporSeridi: View {
    @EnvironmentObject var d: Durum
    let rapor: TemizlikRaporu

    var parcalar: [String] {
        var p = [T(.g1DosyaSilindi, .sayi(rapor.silinenDosya))]
        if rapor.atlanan > 0 { p.append(T(.g1Atlandi, .sayi(rapor.atlanan))) }
        if !rapor.reddedilen.isEmpty { p.append(T(.g1Reddedildi, .sayi(rapor.reddedilen.count))) }
        return p
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").font(.title2).foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(T(.g1YerAcildi, .bayt(rapor.serbestBayt))).font(.headline)
                Text(parcalar.joined(separator: " · ")).font(.callout).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                d.sonRapor = nil
            } label: { Image(systemName: "xmark") }
                .accessibilityLabel(T(.g1RaporKapat))
                .buttonStyle(.plain).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct KategoriKarti: View {
    @EnvironmentObject var d: Durum
    let k: KategoriSonuc

    var acik: Bool { d.acik.contains(k.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                OnayKutusu(hal: kutuHali, etkin: !k.ogeler.isEmpty, etiket: k.kimlik.ad(EtkinDil.deger)) { d.kategoriyiDegistir(k) }
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(k.kimlik.ad(EtkinDil.deger)).font(.headline)
                        RiskRozeti(risk: k.risk)
                        Spacer()
                        Text(B(k.boyut)).font(.headline).monospacedDigit()
                    }
                    Text(k.kimlik.aciklama(EtkinDil.deger)).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 10) {
                        if !k.ogeler.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if acik { d.acik.remove(k.id) } else { d.acik.insert(k.id) }
                                }
                            } label: {
                                Label(T(.g1OgeSayisi, .sayi(k.ogeler.count)), systemImage: acik ? "chevron.down" : "chevron.right")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.accentColor)
                        }
                        if k.durum == .erisimYok || k.erisilemeyen > 0 {
                            Label(k.durum == .erisimYok ? T(.gErisimYok) : T(.g1Erisilemedi, .sayi(k.erisilemeyen)),
                                  systemImage: "lock.fill")
                                .font(.caption).foregroundStyle(.orange)
                            Button(T(.gTdeVer)) { d.tamDiskErisimiAc() }
                                .font(.caption).buttonStyle(.link)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(14)

            if acik {
                Divider().padding(.leading, 40)
                VStack(spacing: 0) {
                    ForEach(k.ogeler) { o in
                        OgeSatiri(o: o)
                        if o.id != k.ogeler.last?.id { Divider().padding(.leading, 40) }
                    }
                }
                .padding(.bottom, 6)
            }
        }
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary.opacity(0.07)))
    }

    var kutuHali: OnayKutusu.Hal {
        switch d.kategoriKutusu(k) {
        case .hepsi: return .acik
        case .biraz: return .karisik
        case .hic: return .kapali
        }
    }
}

struct OgeSatiri: View {
    @EnvironmentObject var d: Durum
    let o: TemizlikOgesi

    var body: some View {
        HStack(spacing: 10) {
            OnayKutusu(hal: d.secili.contains(o.yol) ? .acik : .kapali, etiket: d.gorunenAd(o)) {
                if d.secili.contains(o.yol) { d.secili.remove(o.yol) } else { d.secili.insert(o.yol) }
            }
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(d.gorunenAd(o)).lineLimit(1)
                    if o.calisiyor { Etiket(metin: T(.gCalisiyorEtiket), renk: .orange) }
                }
                if let n = o.not {
                    Text(n.s).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                } else if d.uygulamaAdlari[o.ad] != nil {
                    Text(o.ad).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            Text(T(.g1DosyaSayisi, .sayi(o.dosyaSayisi))).font(.caption).foregroundStyle(.secondary).monospacedDigit()
            Text(B(o.boyut)).monospacedDigit().frame(width: 80, alignment: .trailing)
            Button {
                finderdaGoster(o.yol)
            } label: { Image(systemName: "magnifyingglass.circle") }
                .accessibilityLabel(T(.gFinderdaGosterErisim, .yazi(d.gorunenAd(o))))
                .buttonStyle(.plain).foregroundStyle(.secondary)
                .help(T(.gFinderdaGoster))
        }
        .padding(.horizontal, 14)
        .padding(.leading, 26)
        .padding(.vertical, 6)
    }
}
