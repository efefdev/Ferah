import SwiftUI
import AppKit
import FerahCore

final class UygulamaTemsilcisi: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        if let i = CommandLine.arguments.firstIndex(of: "--tema"), i + 1 < CommandLine.arguments.count {
            NSApp.appearance = NSAppearance(named: CommandLine.arguments[i + 1] == "koyu" ? .darkAqua : .aqua)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func applicationWillTerminate(_ notification: Notification) {
        OnIzleme.kapat()
    }
}

struct FerahApp: App {
    @NSApplicationDelegateAdaptor(UygulamaTemsilcisi.self) var temsilci
    @StateObject private var durum = Durum()

    var body: some Scene {
        Window("Ferah", id: "ana") {
            AnaGorunum()
                .environmentObject(durum)
                .frame(minWidth: 900, minHeight: 620)
        }
        .defaultSize(width: 1060, height: 740)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

struct AnaGorunum: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(spacing: 0) {
            // --vitrin: yalnız deneme kipinde, README ekran görüntüleri için şeridi gizler.
            if d.ortam.deneme, !CommandLine.arguments.contains("--vitrin") {
                HStack(spacing: 8) {
                    Image(systemName: "testtube.2")
                    Text(T(.dBanner)).fontWeight(.semibold)
                    Text(d.ev).font(.caption).lineLimit(1).truncationMode(.middle).opacity(0.85)
                    Spacer()
                }
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.yellow)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(T(.dBannerErisim, .yazi(d.ev)))
            }
            DiskCubugu(disk: d.disk, kazanilan: d.kazanilan,
                       secili: d.adim == .guvenli ? d.seciliBoyut : 0)
                .id(d.dil)   // dil değişince disk çubuğunun yazıları da yenilensin
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 12)
            Divider()
            HStack(spacing: 0) {
                AdimGostergesi()
                    .frame(width: 210)
                    .layoutPriority(1)   // içerik sütunları dar pencerede kenar çubuğunu sıkıştırmasın
                Divider()
                Group {
                    switch d.adim {
                    case .guvenli: GuvenliTemizlikGorunumu()
                    case .buyuk: BuyukDosyalarGorunumu()
                    case .uygulamalar: UygulamalarGorunumu()
                    case .sistem: SistemVerileriGorunumu()
                    case .ozet: OzetGorunumu()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // Dil değişince bütün görünüm ağacı yeni dille yeniden kurulur (durum Durum'da korunur).
            .id(d.dil)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            // Doğrulama kolaylığı: açılışta salt okunur tarama başlatır (silme yapmaz).
            let a = CommandLine.arguments
            if a.contains("--ac-ve-tara") { d.tara1() }
            if a.contains("--ac-buyuk") { d.adim = .buyuk; d.tara2() }
            if a.contains("--ac-uygulamalar") { d.adim = .uygulamalar; d.tara3() }
            if a.contains("--ac-sistem") { d.adim = .sistem; d.tara4() }
            if let i = a.firstIndex(of: "--adim"), i + 1 < a.count, let n = Int(a[i + 1]), let adim = Adim(rawValue: n) {
                d.adim = adim
            }
            if d.ortam.deneme, a.contains("--deneme-onay") {
                d.adim = .guvenli
                d.tara1()
                d.taramaBitinceOnayGoster()
            }
            // Yalnız deneme kipi: pencere her masaüstünde görünür, böylece erişilebilirlik üzerinden
            // sürülürken kullanıcı başka masaüstüne geçince kaybolmaz. Pencere öne alınmaz (odak çalmaz).
            if d.ortam.deneme, a.contains("--her-masaustu") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    for w in NSApp.windows where w.isVisible && w.contentView != nil {
                        w.collectionBehavior.insert(.canJoinAllSpaces)
                    }
                }
            }
            if let i = a.firstIndex(of: "--pencere"), i + 1 < a.count {
                let p = a[i + 1].split(separator: "x").compactMap { Double($0) }
                if p.count == 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let w = NSApp.windows.first(where: { $0.isVisible && $0.contentView != nil }) {
                            w.setContentSize(NSSize(width: max(p[0], 900), height: max(p[1], 620)))
                        }
                    }
                }
            }
        }
    }
}

struct AdimGostergesi: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "wind")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                Text("Ferah").font(.title2.weight(.semibold))
            }
            .padding(.bottom, 14)
            ForEach(Adim.allCases) { a in
                Button {
                    d.adim = a
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(d.adim == a ? Color.accentColor : Color.secondary.opacity(0.15))
                                .frame(width: 26, height: 26)
                            Text("\(a.rawValue)")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(d.adim == a ? Color.white : Color.primary)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(a.baslik).font(.callout.weight(d.adim == a ? .semibold : .regular))
                            Text(a.altBaslik).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                    .background(d.adim == a ? Color.accentColor.opacity(0.10) : .clear,
                                in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(T(.gAdimErisim, .sayi(a.rawValue), .yazi(a.baslik)))
                .accessibilityAddTraits(d.adim == a ? .isSelected : [])
            }
            Spacer()
            if d.kazanilan > 0 || d.copBayt > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(T(.gBuOturumda)).font(.caption).foregroundStyle(.secondary)
                    Text(B(d.kazanilan)).font(.title3.weight(.semibold)).foregroundStyle(.green)
                    if d.copBayt > 0 && !d.copBosaltildi {
                        Text(T(.gCopte, .bayt(d.copBayt))).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 8)
            }
            DilSecici()
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .underPageBackgroundColor).opacity(0.5))
    }
}

/// Kenar çubuğunun altında küçük dil seçici: Sistem / Türkçe / English.
struct DilSecici: View {
    @EnvironmentObject var d: Durum

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let zorla = DilSecimi.zorla {
                // --dil ile zorlanmışsa seçici yerine etkin dil gösterilir (seçim kaydedilmez).
                Label(zorla == .tr ? "Türkçe" : "English", systemImage: "globe")
                    .font(.callout).foregroundStyle(.secondary)
                    .accessibilityLabel(T(.gDil))
            } else {
                Picker(selection: $d.dilTercihi) {
                    ForEach(DilTercihi.allCases) { Text($0.etiket).tag($0) }
                } label: {
                    Image(systemName: "globe")
                }
                .pickerStyle(.menu)
                .fixedSize()
                .accessibilityLabel(T(.gDil))
                .help(T(.gDil))
            }
            if d.dil != DilSecimi.acilisDili {
                Text(T(.gDilNot)).font(.caption2).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
