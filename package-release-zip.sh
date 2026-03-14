#!/bin/bash

# Останавливаем скрипт при любой ошибке, необъявленной переменной или сбое в пайплайне
set -euo pipefail

Arch="$1"
OutputPath="$2"

OutputArch="v2rayN-${Arch}"
FileName="v2rayN-${Arch}.zip"
ZipPath64="./$OutputArch"
BinPath="$ZipPath64/$OutputArch/bin"

# Базовые ссылки (чтобы не дублировать их в коде)
ASSET_REPO_LATEST="https://github.com/nnymph/v2ray-rules-dat/releases/latest/download"
GEOIP_MMDB_URL="https://raw.githubusercontent.com/nnymph/v2ray-ru-blocked-geoip/release/Country.mmdb"
METADB_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/latest/download/geoip.metadb"
SRS_BASE_URL="https://raw.githubusercontent.com/nnymph/v2ray-rules-dat/release/sing-box"

echo "[*] Начинаем сборку для архитектуры: $Arch"

# 1. Скачиваем оригинальный бандл (используем curl вместо wget для единообразия)
echo "[+] Скачиваем оригинальное ядро v2rayN-core-bin..."
curl -fsSL -o "$FileName" "https://github.com/2dust/v2rayN-core-bin/raw/refs/heads/master/$FileName"

# 2. Распаковываем
mkdir -p "$ZipPath64"
unzip -q "$FileName" -d "$ZipPath64"

# 3. Копируем твой скомпилированный GUI
echo "[+] Копируем скомпилированные файлы GUI..."
cp -rf "$OutputPath"/* "$ZipPath64/$OutputArch/"

# 4. Создаем директории для гео-баз
mkdir -p "$BinPath/srss"

# 5. Скачиваем основные Geo-базы
echo "[+] Загружаем основные Geo-файлы в папку bin/..."
curl -fsSL -o "$BinPath/geosite.dat" "$ASSET_REPO_LATEST/geosite.dat"
curl -fsSL -o "$BinPath/geoip.dat" "$ASSET_REPO_LATEST/geoip.dat"
curl -fsSL -o "$BinPath/Country.mmdb" "$GEOIP_MMDB_URL"
curl -fsSL -o "$BinPath/geoip.metadb" "$METADB_URL"

# 6. Работа с SRS правилами
echo "[+] Загружаем .srs правила для sing-box..."

# Исправленный массив GEOIP (сюда переехали cloudflare, cloudfront, fastly)
GEOIP_RULES=(
    "geoip-discord.srs"
    "geoip-nnymph-all-blocked.srs"
    "geoip-nnymph-block.srs"
    "geoip-nnymph-direct.srs"
    "geoip-nnymph-proxy.srs"
    "geoip-private.srs"
    "geoip-ru-blocked.srs"
    "geoip-cloudflare.srs"
    "geoip-cloudfront.srs"
    "geoip-fastly.srs"
)

for f in "${GEOIP_RULES[@]}"; do
    curl -fsSL -o "$BinPath/srss/$f" "$SRS_BASE_URL/rule-set-geoip/$f"
done

# Массив GEOSITE
GEOSITE_RULES=(
    "geosite-category-ads-all.srs"
    "geosite-discord.srs"
    "geosite-google.srs"
    "geosite-nnymph-block.srs"
    "geosite-nnymph-direct.srs"
    "geosite-nnymph-proxy.srs"
    "geosite-private.srs"
    "geosite-ru-available-only-inside.srs"
    "geosite-nnymph-ru-blocked-self.srs"
    "geosite-twitch-blocked.srs"
    "geosite-ru-blocked-self.srs"
    "geosite-ru-blocked.srs"
    "geosite-youtube.srs"
)

for f in "${GEOSITE_RULES[@]}"; do
    curl -fsSL -o "$BinPath/srss/$f" "$SRS_BASE_URL/rule-set-geosite/$f"
done

# 7. Финальная упаковка
echo "[+] Создаем итоговый архив $FileName..."
rm -f "$FileName"
7z a -tZip "$FileName" "$ZipPath64/$OutputArch" -mx1

echo "[*] Сборка успешно завершена!"
