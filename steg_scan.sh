#!/bin/bash
# steg_scan.sh - quick steganalysis suite for Kali
# Usage: ./steg_scan.sh <file>

FILE="$1"
OUTDIR="./steg_out_$(date +%s)"
mkdir -p "$OUTDIR"

echo "[*] File: $FILE" | tee "$OUTDIR/log.txt"

echo -e "\n[1] exiftool (metadata)"; exiftool "$FILE" | tee -a "$OUTDIR/log.txt"
echo -e "\n[2] strings (search common magic bytes)"; strings -a "$FILE" | head -n 200 > "$OUTDIR/strings_head.txt"

echo -e "\n[3] stegdetect (JPEG only) - may need to be installed separately"; 
if command -v stegdetect >/dev/null 2>&1; then
  stegdetect -v "$FILE" | tee -a "$OUTDIR/log.txt"
else
  echo "stegdetect not found" | tee -a "$OUTDIR/log.txt"
fi

echo -e "\n[4] zsteg (PNG/BMP) - check LSB/zlib/openstego"
if command -v zsteg >/dev/null 2>&1; then
  zsteg --all "$FILE" | tee "$OUTDIR/zsteg.txt"
else
  echo "zsteg not found (gem install zsteg)" | tee -a "$OUTDIR/log.txt"
fi

echo -e "\n[5] steghide info (detect steghide data)"
if command -v steghide >/dev/null 2>&1; then
  steghide info "$FILE" 2>&1 | tee "$OUTDIR/steghide_info.txt"
else
  echo "steghide not installed" | tee -a "$OUTDIR/log.txt"
fi

echo -e "\n[6] binwalk (carve embedded files)"
if command -v binwalk >/dev/null 2>&1; then
  binwalk -e "$FILE" | tee -a "$OUTDIR/binwalk.txt"
else
  echo "binwalk not found" | tee -a "$OUTDIR/log.txt"
fi

echo -e "\n[7] foremost (carve by headers)"
if command -v foremost >/dev/null 2>&1; then
  foremost -i "$FILE" -o "$OUTDIR/foremost_out" | tee -a "$OUTDIR/foremost.txt"
else
  echo "foremost not found" | tee -a "$OUTDIR/log.txt"
fi

echo -e "\n[8] check file type and appended data"
file "$FILE" | tee -a "$OUTDIR/log.txt"
hexdump -C "$FILE" | tail -n 200 > "$OUTDIR/hexdump_tail.txt"

echo -e "\n[+] Results saved to $OUTDIR"

