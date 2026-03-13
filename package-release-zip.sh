#!/bin/bash

Arch="$1"
OutputPath="$2"

OutputArch="v2rayN-${Arch}"
FileName="v2rayN-${Arch}.zip"

# 1. Скачиваем оригинальный бандл
wget -nv -O $FileName "https://github.com/2dust/v2rayN-core-bin/raw/refs/heads/master/$FileName"

ZipPath64="./$OutputArch"
mkdir -p "$ZipPath64"

# 2. Распаковываем
unzip -q $FileName -d "$ZipPath64"

# 3. Копируем твой скомпилированный GUI
cp -rf $OutputPath/* "$ZipPath64/$OutputArch/"

# 4. ПЕРЕХОДИМ К ЗАМЕНЕ ФАЙЛОВ
cd "$ZipPath64/$OutputArch"

echo "[+] Overwriting Geo assets with nnymph versions..."
# Скачиваем с принудительной перезаписью (-o)
curl -fsSL -o "geosite.dat" "https://github.com/nnymph/v2ray-rules-dat/releases/latest/download/geosite.dat"
curl -fsSL -o "geoip.dat" "https://github.com/nnymph/v2ray-rules-dat/releases/latest/download/geoip.dat"
curl -fsSL -o "Country.mmdb" "https://raw.githubusercontent.com/nnymph/v2ray-ru-blocked-geoip/release/Country.mmdb"
curl -fsSL -o "geoip.metadb" "https://github.com/MetaCubeX/meta-rules-dat/releases/latest/download/geoip.metadb"

# 5. РАБОТА С SRS ФАЙЛАМИ
echo "[+] Downloading .srs rule-sets..."
mkdir -p "srss"

# Список GEOIP SRS
for f in geoip-discord.srs geoip-nnymph-all-blocked.srs geoip-nnymph-block.srs \
         geoip-nnymph-direct.srs geoip-nnymph-proxy.srs geoip-private.srs geoip-ru-blocked.srs; do
    curl -fsSL -o "srss/$f" "https://raw.githubusercontent.com/nnymph/v2ray-rules-dat/release/sing-box/rule-set-geoip/$f"
done

# Список GEOSITE SRS
for f in geosite-category-ads-all.srs geosite-discord.srs geosite-google.srs \
         geoip-cloudflare.srs geoip-cloudfront.srs geoip-fastly.srs \
         geosite-nnymph-block.srs geosite-nnymph-direct.srs geosite-nnymph-proxy.srs \
         geosite-private.srs geosite-ru-available-only-inside.srs geosite-nnymph-ru-blocked-self.srs \
         geosite-twitch-blocked.srs geosite-ru-blocked-self.srs geosite-ru-blocked.srs geosite-youtube.srs; do
    curl -fsSL -o "srss/$f" "https://raw.githubusercontent.com/nnymph/v2ray-rules-dat/release/sing-box/rule-set-geosite/$f"
done

# Возвращаемся в корень для упаковки
cd ../../

# 6. Финальная упаковка
rm -f $FileName
7z a -tZip $FileName "$ZipPath64/$OutputArch" -mx1
