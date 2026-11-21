import SwiftUI
import AppKit
import FerahCore

extension Risk {
    var renk: Color {
        switch self {
        case .guvenli: return .green
        case .dikkat: return .orange
        case .riskli: return .red
        case .dokunma: return .purple
        }
    }

    var simge: String {
        switch self {
        case .guvenli: return "checkmark.shield"
        case .dikkat: return "exclamationmark.triangle"
        case .riskli: return "exclamationmark.octagon"
        case .dokunma: return "lock"
        }
    }
}

struct RiskRozeti: View {
    let risk: Risk
    var body: some View {
        Label(risk.etiket(EtkinDil.deger), systemImage: risk.simge)
            .font(.caption.weight(.semibold))
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(risk.renk.opacity(0.15), in: Capsule())
            .foregroundStyle(risk.renk)
    }
}

struct Etiket: View {
    let metin: String
    var renk: Color = .secondary
    var body: some View {
        Text(metin)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(renk.opacity(0.12), in: Capsule())
            .foregroundStyle(renk)
    }
}

/// Üç durumlu onay kutusu.
struct OnayKutusu: View {
    enum Hal { case acik, kapali, karisik }
    let hal: Hal
    var etkin = true
    /// Ekran okuyucu ve UI otomasyonu için ad (ör. kategori ya da öğe adı).
    var etiket: String = T(.gSec)
    let degistir: () -> Void

    var body: some View {
        Button(action: degistir) {
            Image(systemName: hal == .acik ? "checkmark.square.fill" : hal == .karisik ? "minus.square.fill" : "square")
                .font(.system(size: 15))
                .foregroundStyle(hal == .kapali ? Color.secondary : Color.accentColor)
        }
        .buttonStyle(.plain)
        .disabled(!etkin)
        .opacity(etkin ? 1 : 0.4)
        .accessibilityLabel(T(.gSecErisim, .yazi(etiket)))
        .accessibilityValue(hal == .acik ? T(.gSecili) : hal == .karisik ? T(.gKismenSecili) : T(.gSeciliDegil))
    }
}

/// Disk doluluk çubuğu: kullanılan / seçili (silinecek) / kazanılan / boş.
struct DiskCubugu: View {
    let disk: DiskBilgisi?
    var kazanilan: Int64 = 0
    var secili: Int64 = 0
    var yukseklik: CGFloat = 14
    var aciklamaGoster = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { g in
                let w = g.size.width
                let t = max(Double(disk?.toplam ?? 1), 1)
                let kullanilan = Double(disk?.kullanilan ?? 0)
                let sec = min(Double(secili), kullanilan)
                let kaz = min(Double(kazanilan), Double(disk?.bos ?? 0))
                HStack(spacing: 0) {
                    Rectangle().fill(Color.accentColor.gradient)
                        .frame(width: w * (kullanilan - sec) / t)
                    Rectangle().fill(Color.orange.opacity(0.85))
                        .frame(width: w * sec / t)
                    Rectangle().fill(Color.green.gradient)
                        .frame(width: w * kaz / t)
                    Rectangle().fill(Color.secondary.opacity(0.18))
                }
                .clipShape(RoundedRectangle(cornerRadius: yukseklik / 2.5))
                .animation(.easeInOut(duration: 0.4), value: secili)
                .animation(.easeInOut(duration: 0.4), value: kazanilan)
            }
            .frame(height: yukseklik)
            if aciklamaGoster, let d = disk {
                HStack(spacing: 14) {
                    gosterge(.accentColor, T(.gKullanilan), d.kullanilan)
                    if secili > 0 { gosterge(.orange, T(.gSeciliBaslik), secili) }
                    if kazanilan > 0 { gosterge(.green, T(.gKazanilan), kazanilan) }
                    gosterge(Color.secondary.opacity(0.4), T(.gBos), d.bos)
                    Spacer()
                    Text(T(.gToplam, .bayt(d.toplam))).foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
    }

    func gosterge(_ r: Color, _ ad: String, _ b: Int64) -> some View {
        HStack(spacing: 5) {
            Circle().fill(r).frame(width: 8, height: 8)
            Text(ad).foregroundStyle(.secondary)
            Text(B(b)).monospacedDigit()
        }
    }
}

/// Quick Look (qlmanage -p) ile önizleme.
enum OnIzleme {
    private static var surec: Process?
    private static var sonYol: String?

    static func degistir(_ yol: String) {
        if let p = surec, p.isRunning {
            p.terminate()
            surec = nil
            if sonYol == yol { return }
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
        p.arguments = ["-p", yol]
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        do {
            try p.run()
            surec = p
            sonYol = yol
        } catch {
            surec = nil
        }
    }

    static func kapat() {
        if let p = surec, p.isRunning { p.terminate() }
        surec = nil
    }
}

func finderdaGoster(_ yol: String) {
    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: yol)])
}

/// Dar ayrıntı bölmeleri için yer tutucu. ContentUnavailableView'un büyük başlığı ve iç boşluğu
/// 900 pt'lik pencerede bölmeyi genişletip tüm içeriği taşırıyordu.
struct BolmeYerTutucu: View {
    let baslik: String
    let simge: String
    let aciklama: Text

    init(_ baslik: String, systemImage: String, description: Text) {
        self.baslik = baslik
        self.simge = systemImage
        self.aciklama = description
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: simge).font(.system(size: 30)).foregroundStyle(.tertiary)
            Text(baslik).font(.title3.weight(.semibold)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            aciklama.font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
