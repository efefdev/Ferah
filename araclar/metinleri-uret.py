#!/usr/bin/env python3
"""araclar/metinler.tsv -> Sources/FerahCore/Metinler.swift

Metin tablosunun tek kaynağı metinler.tsv dosyasıdır. Her satır: anahtar <TAB> Türkçe <TAB> English.
- Yer tutucular: {0}, {1} ... (her dilde aynı küme olmalı).
- Çoğul: İngilizce sütunda "tekil||çoğul" (ilk sayısal argümana göre seçilir). Türkçede kullanılmaz.
- Satır sonu: \n (iki karakter).
- '#' ile başlayan satırlar ve boş satırlar yok sayılır.
Üretilen Swift dosyasında her anahtar için tüm dillerin yazılması zorunludur (switch), eksik dil derlemeyi bozar.

Kullanım: python3 araclar/metinleri-uret.py
"""
import os
import re
import sys

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GIRDI = os.path.join(KOK, "araclar", "metinler.tsv")
CIKTI = os.path.join(KOK, "Sources", "FerahCore", "Metinler.swift")


def kacis(s):
    # TSV'de satır sonu "\n" kaçış dizisiyle yazılır; Swift'te de satır sonu olarak kalır.
    return s.replace("\\", "\\\\").replace("\\\\n", "\\n").replace('"', '\\"')


def main():
    satirlar = []
    goruldu = set()
    with open(GIRDI, encoding="utf-8") as f:
        for no, satir in enumerate(f, 1):
            satir = satir.rstrip("\n")
            if not satir.strip() or satir.startswith("#"):
                continue
            parca = satir.split("\t")
            if len(parca) != 3:
                sys.exit(f"{GIRDI}:{no}: 3 sütun bekleniyor, {len(parca)} bulundu")
            anahtar, tr, en = parca
            if not re.fullmatch(r"[a-z][A-Za-z0-9]*", anahtar):
                sys.exit(f"{GIRDI}:{no}: geçersiz anahtar {anahtar!r}")
            if anahtar in goruldu:
                sys.exit(f"{GIRDI}:{no}: yinelenen anahtar {anahtar}")
            goruldu.add(anahtar)
            satirlar.append((anahtar, tr, en))

    o = []
    o.append("// BU DOSYA ÜRETİLDİ — elle düzenleme. Kaynak: araclar/metinler.tsv")
    o.append("// Yeniden üretmek için: python3 araclar/metinleri-uret.py")
    o.append("")
    o.append("/// Metin anahtarları. Her anahtarın tüm dillerde karşılığı vardır (bkz. `cift`).")
    o.append("public enum M: String, CaseIterable, Codable, Sendable {")
    for a, _, _ in satirlar:
        o.append(f"    case {a}")
    o.append("}")
    o.append("")
    o.append("extension M {")
    o.append("    /// (Türkçe, English)")
    o.append("    public var cift: (String, String) {")
    o.append("        switch self {")
    for a, tr, en in satirlar:
        o.append(f'        case .{a}: return ("{kacis(tr)}", "{kacis(en)}")')
    o.append("        }")
    o.append("    }")
    o.append("}")
    o.append("")
    with open(CIKTI, "w", encoding="utf-8") as f:
        f.write("\n".join(o))
    print(f"{len(satirlar)} anahtar -> {os.path.relpath(CIKTI, KOK)}")


if __name__ == "__main__":
    main()
