#!/usr/bin/env bash
# =============================================================================
# optimize_placeholders.sh
# Resize & optimize PNG placeholder images for iOS/macOS apps.
#
# Strategy: fill + center-crop → exact canvas → max PNG compression
#
# Requires: ImageMagick 7.1+ (brew install imagemagick)
#
# Usage examples:
#   ./optimize_placeholders.sh book_dark.png book_light.png movie_dark.png movie_light.png
#   ./optimize_placeholders.sh *.png --out ./Assets --size 80x108 --scales 1,2,3
# =============================================================================

set -euo pipefail

# ─── Defaults ────────────────────────────────────────────────────────────────
W=80
H=108
SCALES=(1 2 3)
OUT_DIR="./placeholder_assets"
FILTER="Lanczos"      # best quality for downscaling (alt: Mitchell, Triangle)

# ─── ANSI colors ─────────────────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
C='\033[0;36m'; B='\033[1m';    NC='\033[0m'

hr() { printf '%s' "$(printf '─%.0s' {1..60})"; echo; }

# ─── human-readable bytes (macOS: no numfmt) ─────────────────────────────────
hr_bytes() {
  local b=$1
  if   (( b >= 1048576 )); then awk "BEGIN{printf \"%.1f MB\", $b/1048576}"
  elif (( b >= 1024    )); then awk "BEGIN{printf \"%.1f KB\", $b/1024}"
  else echo "${b} B"
  fi
}

# ─── Parse arguments ─────────────────────────────────────────────────────────
INPUTS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)    OUT_DIR="$2";  shift 2 ;;
    --size)
      W="${2%%x*}"; H="${2##*x}"; shift 2 ;;
    --scales)
      IFS=',' read -ra SCALES <<< "$2"; shift 2 ;;
    --filter) FILTER="$2"; shift 2 ;;
    --help|-h)
      sed -n '4,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    -*)
      echo -e "${R}Unknown option: $1${NC}"; exit 1 ;;
    *)
      INPUTS+=("$1"); shift ;;
  esac
done

[[ ${#INPUTS[@]} -eq 0 ]] && {
  echo -e "${R}✗ No input files. Usage: $0 *.png [--out dir] [--size WxH]"
  exit 1
}

# ─── Dependency check ────────────────────────────────────────────────────────
if ! command -v magick &>/dev/null; then
  echo -e "${R}✗ ImageMagick 7 not found.${NC}"
  echo -e "  Install: ${C}brew install imagemagick${NC}"
  exit 1
fi

IM_VER=$(magick -version | awk 'NR==1{print $3}')

# ─── Banner ──────────────────────────────────────────────────────────────────
hr
echo -e "${B}optimize_placeholders${NC}  ImageMagick ${C}${IM_VER}${NC}"
echo -e "Target: ${B}${W}×${H}pt${NC}  Scales: ${B}[$(IFS='×'; echo "${SCALES[*]@Q}" | tr -d "'" )]${NC}  Filter: ${FILTER}"
hr

mkdir -p "${OUT_DIR}"

# ─── Core: resize one image to one scale ─────────────────────────────────────
#   Strategy: fill (^) → center-crop → strip metadata → max compression
#   Result is always exactly W*scale × H*scale pixels.
process_one() {
  local src="$1"
  local dst="$2"
  local scale="$3"
  local pw=$(( W * scale ))
  local ph=$(( H * scale ))

  magick "${src}" \
    -filter "${FILTER}" \
    -resize "${pw}x${ph}^" \
    -gravity Center \
    -extent "${pw}x${ph}" \
    -strip \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${dst}"
}

# ─── Process every input file ─────────────────────────────────────────────────
declare -A TOTAL_IN_BY_BASE   # bytes of source per base name
TOTAL_IN_BYTES=0
TOTAL_OUT_BYTES=0
PROCESSED=()

for src in "${INPUTS[@]}"; do
  [[ -f "${src}" ]] || { echo -e "${R}✗ Not found: ${src}${NC}"; continue; }

  fname=$(basename "${src}" .png)
  src_bytes=$(stat -f%z "${src}")
  TOTAL_IN_BYTES=$(( TOTAL_IN_BYTES + src_bytes ))

  echo -e "${B}▸ ${fname}.png${NC}  source: $(hr_bytes ${src_bytes})"

  file_out_bytes=0
  for scale in "${SCALES[@]}"; do
    pw=$(( W * scale )); ph=$(( H * scale ))
    dst="${OUT_DIR}/${fname}@${scale}x.png"

    process_one "${src}" "${dst}" "${scale}"

    dst_bytes=$(stat -f%z "${dst}")
    file_out_bytes=$(( file_out_bytes + dst_bytes ))
    TOTAL_OUT_BYTES=$(( TOTAL_OUT_BYTES + dst_bytes ))

    pct=$(awk "BEGIN{printf \"%d\", 100 - (${dst_bytes}*100/${src_bytes})}")
    echo -e "  ${G}✓${NC} @${scale}x  ${pw}×${ph}px  $(hr_bytes ${dst_bytes})  ${Y}−${pct}%${NC}"
  done

  PROCESSED+=("${fname}")
  echo ""
done


# ─── Summary ─────────────────────────────────────────────────────────────────
hr
echo -e "${B}Summary${NC}"
echo -e "  Sources:     $(hr_bytes ${TOTAL_IN_BYTES})  (${#INPUTS[@]} file(s))"
echo -e "  All outputs: $(hr_bytes ${TOTAL_OUT_BYTES})  (${#SCALES[@]} scale(s) × ${#INPUTS[@]} variant(s))"

if (( TOTAL_IN_BYTES > 0 )); then
  overall=$(awk "BEGIN{printf \"%.0f\", 100 - (${TOTAL_OUT_BYTES}*100/${TOTAL_IN_BYTES})}")
  echo -e "  Savings:     ${G}−${overall}% vs. using originals at all resolutions${NC}"
fi

hr
echo -e "${G}Done.${NC} Assets in: ${C}${OUT_DIR}${NC}"
