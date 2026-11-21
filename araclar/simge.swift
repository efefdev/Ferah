// Ferah uygulama simgesini çizer: verilen .iconset klasörüne tüm boyutları PNG olarak yazar.
// Kullanım: simge <cikti.iconset>
import AppKit

let cikti = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Ferah.iconset"
try? FileManager.default.createDirectory(atPath: cikti, withIntermediateDirectories: true)

func ciz(_ px: Int) -> Data? {
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                                     samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                     colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px)
    // macOS simge ızgarası: 1024'te 824'lük yuvarlatılmış kare
    let kenar = s * 0.1
    let kare = NSRect(x: kenar, y: kenar, width: s - 2 * kenar, height: s - 2 * kenar)
    let yol = NSBezierPath(roundedRect: kare, xRadius: kare.width * 0.225, yRadius: kare.width * 0.225)
    NSGradient(colors: [NSColor(calibratedRed: 0.20, green: 0.78, blue: 0.74, alpha: 1),
                        NSColor(calibratedRed: 0.13, green: 0.45, blue: 0.86, alpha: 1)])?
        .draw(in: yol, angle: -60)

    // Üç rüzgâr çizgisi
    NSColor.white.setStroke()
    let w = kare.width
    let x0 = kare.minX + w * 0.18
    let cizgiler: [(CGFloat, CGFloat, CGFloat)] = [(0.66, 0.62, 0.11), (0.48, 0.74, 0.14), (0.30, 0.50, 0.09)]
    for (yOran, uzunluk, kivrim) in cizgiler {
        let y = kare.minY + w * yOran
        let p = NSBezierPath()
        p.lineWidth = w * 0.065
        p.lineCapStyle = .round
        p.move(to: NSPoint(x: x0, y: y))
        let bitis = x0 + w * uzunluk
        p.line(to: NSPoint(x: bitis - w * kivrim, y: y))
        p.appendArc(withCenter: NSPoint(x: bitis - w * kivrim, y: y + w * kivrim / 1.4),
                    radius: w * kivrim / 1.4, startAngle: -90, endAngle: 150)
        p.stroke()
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

for taban in [16, 32, 128, 256, 512] {
    for olcek in [1, 2] {
        let px = taban * olcek
        let ad = olcek == 1 ? "icon_\(taban)x\(taban).png" : "icon_\(taban)x\(taban)@2x.png"
        if let d = ciz(px) {
            try? d.write(to: URL(fileURLWithPath: "\(cikti)/\(ad)"))
        }
    }
}
print("simge yazıldı: \(cikti)")
