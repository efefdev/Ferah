#!/bin/bash
# Ferah'ı derler ve build/Ferah.app paketini kurar (Xcode gerekmez; yalnız Command Line Tools).
set -euo pipefail

cd "$(dirname "$0")"
KOK="$(pwd)"
APP="$KOK/build/Ferah.app"

echo "→ Derleniyor (release)…"
swift build -c release
IKILI="$(swift build -c release --show-bin-path)/Ferah"

echo "→ Paket kuruluyor: $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$IKILI" "$APP/Contents/MacOS/Ferah"

SIMGE_ANAHTARI=""
if command -v iconutil >/dev/null 2>&1; then
    echo "→ Simge çiziliyor…"
    GECICI="$(mktemp -d)"
    if swiftc -O -o "$GECICI/simge" "$KOK/araclar/simge.swift" 2>/dev/null \
        && "$GECICI/simge" "$GECICI/Ferah.iconset" >/dev/null \
        && iconutil -c icns "$GECICI/Ferah.iconset" -o "$APP/Contents/Resources/Ferah.icns"; then
        SIMGE_ANAHTARI="<key>CFBundleIconFile</key><string>Ferah</string>"
    else
        echo "  (simge üretilemedi, simgesiz devam ediliyor)"
    fi
    rm -rf "$GECICI"
fi

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>network.akca.ferah</string>
    <key>CFBundleName</key><string>Ferah</string>
    <key>CFBundleDisplayName</key><string>Ferah</string>
    <key>CFBundleExecutable</key><string>Ferah</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleDevelopmentRegion</key><string>tr</string>
    <key>CFBundleLocalizations</key><array><string>tr</string><string>en</string></array>
    <key>CFBundleAllowMixedLocalizations</key><true/>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSSupportsAutomaticTermination</key><false/>
    $SIMGE_ANAHTARI
</dict>
</plist>
PLIST

# Arayüz metinleri ikiliye gömülüdür (Sources/FerahCore/Metinler.swift). Bu klasörler yalnız macOS'a uygulamanın
# Türkçe ve İngilizce desteklediğini bildirir; böylece menüler ve sistem pencereleri de seçili dilde gösterilir.
for d in tr en; do
    mkdir -p "$APP/Contents/Resources/$d.lproj"
    printf '"CFBundleDisplayName" = "Ferah";\n"CFBundleName" = "Ferah";\n' > "$APP/Contents/Resources/$d.lproj/InfoPlist.strings"
done

echo "→ Ad-hoc imzalanıyor…"
codesign --force --sign - "$APP"
codesign --verify "$APP" && echo "✓ Hazır: $APP"
