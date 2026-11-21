import SwiftUI
import FerahCore

struct OzetGorunumu: View {
    @EnvironmentObject var d: Durum
    @State private var bosaltOnayi = false
    @State private var gecmisAcik = false
    @State private var bilgi: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(T(.adimOzet)).font(.title2.weight(.semibold))
                    Text(T(.g5Alt)).foregroundStyle(.secondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(B(d.kazanilan))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .monospacedDigit()
                    Text(T(.g5YerAcildi)).font(.title3).foregroundStyle(.secondary)
                }

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                    satir("trash.slash", T(.g5Kalici), B(d.kaliciBayt), T(.g5OgeSayisi, .sayi(d.kaliciOge)))
                    let copNotu = d.copBosaltildi ? T(.g5CopBosaltildi) : T(.g5CopBosalinca)
                    satir("trash", T(.g5Adim2), B(d.adim2Bayt), T(.g5OgeVeNot, .sayi(d.adim2Oge), .yazi(copNotu)))
                    satir("square.grid.2x2", T(.g5Uyg), B(d.kaldirilanUygulamaBayt),
                          (d.kaldirilanArtikBayt > 0 ? T(.g5UygVeri, .sayi(d.kaldirilanUygulama), .bayt(d.kaldirilanArtikBayt))
                                                     : T(.g5UygSayisi, .sayi(d.kaldirilanUygulama))) + " · " + copNotu)
                    if d.sistemCopBayt > 0 {
                        satir("chart.bar.doc.horizontal", T(.g5Sistem), B(d.sistemCopBayt), copNotu)
                    }
                    if d.copBosaltmaBayt > 0 {
                        satir("sparkles", T(.g5CopBosaltilincaAcilan), B(d.copBosaltmaBayt), "")
                    }
                    satir("hand.raised", T(.g5Saklanan), T(.g5OgeSayisi, .sayi(d.saklananOge)), T(.g5SaklananNot))
                    satir("forward", T(.g5Atlanan), T(.g1DosyaSayisi, .sayi(d.atlananDosya)), T(.g5AtlananNot))
                    if !d.reddedilen.isEmpty {
                        satir("shield.lefthalf.filled", T(.g5Reddedilen), T(.g5OgeSayisi, .sayi(d.reddedilen.count)), "")
                    }
                }
                .padding(16)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 10) {
                    Text(T(.g5Disk)).font(.headline)
                    HStack(spacing: 10) {
                        Text(T(.g5Once)).frame(width: 56, alignment: .leading).foregroundStyle(.secondary)
                        DiskCubugu(disk: d.ilkDisk, aciklamaGoster: false)
                        Text(d.ilkDisk.map { T(.g5BosDeger, .bayt($0.bos)) } ?? "—")
                            .frame(width: 110, alignment: .trailing).monospacedDigit()
                    }
                    HStack(spacing: 10) {
                        Text(T(.g5Simdi)).frame(width: 56, alignment: .leading).foregroundStyle(.secondary)
                        DiskCubugu(disk: d.disk, kazanilan: d.kazanilan, aciklamaGoster: false)
                        Text(d.disk.map { T(.g5BosDeger, .bayt($0.bos)) } ?? "—")
                            .frame(width: 110, alignment: .trailing).monospacedDigit()
                    }
                    Text(T(.g5GecikmeNotu))
                        .font(.caption).foregroundStyle(.secondary)
                }

                if !d.reddedilen.isEmpty {
                    DisclosureGroup(T(.g5Reddedilenler, .sayi(d.reddedilen.count))) {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(d.reddedilen, id: \.self) { Text($0.metin(EtkinDil.deger)).font(.caption).textSelection(.enabled) }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        d.copuOku()
                        bosaltOnayi = true
                    } label: {
                        Label(T(.g5CopuBosalt), systemImage: "trash")
                    }
                    .controlSize(.large)
                    Button {
                        gecmisAcik = true
                    } label: {
                        Label(T(.g5Gecmis), systemImage: "clock.arrow.circlepath")
                    }
                    .controlSize(.large)
                    Button(T(.g5BastanTara)) {
                        d.adim = .guvenli
                        d.tara1()
                    }
                    .controlSize(.large)
                    Spacer()
                }
                if let b = bilgi {
                    Text(b).font(.callout).foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .onAppear { d.diskiYenile() }
        .alert(T(.g5BosaltBaslik), isPresented: $bosaltOnayi) {
            Button(T(.g5KaliciBosalt), role: .destructive) {
                d.copuBosalt { basarili in
                    if basarili {
                        bilgi = T(.g5Bosaltildi)
                    } else {
                        bilgi = T(.g5ErisimYok)
                        d.copuFinderdaAc()
                    }
                }
            }
            Button(T(.gVazgec), role: .cancel) {}
        } message: {
            if let k = d.copBilgisi, k.durum == .tamam {
                Text(T(.g5BosaltMesaj, .sayi(k.ogeler.count), .bayt(k.boyut)))
            } else {
                Text(T(.g5BosaltMesajGenel))
            }
        }
        .sheet(isPresented: $gecmisAcik) {
            GecmisGorunumu(kayitlar: d.depo.gecmis().reversed(), ev: d.ev, dosyaKlasoru: d.depo.klasor)
        }
    }

    @ViewBuilder
    func satir(_ simge: String, _ ad: String, _ deger: String, _ not: String) -> some View {
        GridRow {
            Image(systemName: simge).foregroundStyle(.secondary).frame(width: 20)
            Text(ad)
            Text(deger).fontWeight(.semibold).monospacedDigit()
            Text(not).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct GecmisGorunumu: View {
    let kayitlar: [GecmisKaydi]
    let ev: String
    var dosyaKlasoru: String = Depo.varsayilanKlasor
    @Environment(\.dismiss) var kapat

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(T(.g5Gecmis)).font(.title3.weight(.semibold))
                Spacer()
                Text(T(.g5IslemSayisi, .sayi(kayitlar.count))).foregroundStyle(.secondary)
            }
            .padding(16)
            Divider()
            if kayitlar.isEmpty {
                ContentUnavailableView(T(.g5HenuzIslemYok), systemImage: "clock")
                    .frame(maxHeight: .infinity)
            } else {
                Table(kayitlar) {
                    TableColumn(T(.g5Tarih)) { k in Text(Bicim.tarih(k.tarih, EtkinDil.deger)) }.width(min: 120, ideal: 150)
                    TableColumn(T(.g5Yol)) { k in
                        Text(Yol.kisa(k.yol, ev: ev)).lineLimit(1).truncationMode(.middle).help(k.yol)
                    }
                    .width(min: 200, ideal: 380)
                    TableColumn(T(.g2SutunBoyut)) { k in Text(B(k.boyut)).monospacedDigit() }.width(min: 70, ideal: 90)
                    TableColumn(T(.g5Yontem)) { k in
                        Text(k.yontem == .kalici ? T(.g5KaliciSilindi) : T(.g5CopeTasindi))
                    }
                    .width(min: 90, ideal: 110)
                }
            }
            Divider()
            HStack {
                Text(T(.g5Kayit, .yazi(Yol.kisa(Yol.ekle(dosyaKlasoru, "gecmis.json"), ev: ev)))).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button(T(.g5Kapat)) { kapat() }.keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
        .frame(width: 760, height: 480)
    }
}
