#!/usr/bin/env bash
# Consolidated CPU + RAM status for the tmux status bar.
# Replaces the 24 individual #(...) script calls that the
# tmux-cpu plugin injects, cutting process spawns from 24/s to 1/s.
# Darwin-only copy for the nix-darwin flake. The Linux iostat and
# /proc/stat branches carried by the NixOS copy are dropped here.

set -u

# --- CPU percentage ----------------------------------------------------------
get_cpu_pct() {
  local pct=""
  if command -v iostat &>/dev/null; then
    # macOS iostat prints CPU (us sy id) and load-average columns by
    # default. The last field of the last line is the 15 m load
    # average, not idle. Locate the "id" column in the header row and
    # take it from the second sample, the current one.
    pct=$(iostat -c 2 2>/dev/null | awk '
      NR == 2 { for (i = 1; i <= NF; i++) if ($i == "id") c = i }
      c && NR > 2 { v = $c }
      END { if (c) printf "%.1f", 100 - v }')
  fi
  if [[ -z "$pct" ]]; then
    # Final fallback: ps snapshot (inaccurate but always available).
    local load cpus
    load=$(ps -aux 2>/dev/null | awk 'NR>1 {s+=$3} END {print s+0}')
    cpus=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
    pct=$(awk -v l="${load:-0}" -v c="$cpus" 'BEGIN {printf "%.1f", l/c}')
  fi
  echo "${pct:-0.0}"
}

# --- RAM percentage ----------------------------------------------------------
# Used = active + wired + compressed. File cache (free, inactive,
# speculative, purgeable pages) does not count as used. The active
# list still holds some hot file pages, so the number reads slightly
# high against the OS estimate (memory_pressure).
get_ram_pct() {
  local mem
  mem=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  vm_stat 2>/dev/null | awk -v mem="$mem" '
    NR == 1 {
      # Page size from the header, e.g. "page size of 16384 bytes".
      if (match($0, /page size of [0-9]+ bytes/))
        ps = substr($0, RSTART + 13, RLENGTH - 19) + 0
      if (ps == 0) ps = 4096
    }
    /Pages active/                 { a = $NF * ps }
    /Pages wired down/             { w = $NF * ps }
    /Pages occupied by compressor/ { c = $NF * ps }
    END {
      if (mem > 0) {
        used = a + w + c
        if (used > mem) used = mem
        printf "%.1f", 100 * used / mem
      }
    }'
}

# --- colour helpers (catppuccin-friendly) ------------------------------------
# Catppuccin Macchiato palette
color_for_pct() {
  local pct="$1"
  if   awk -v p="$pct" 'BEGIN {exit !(p >= 80)}'; then echo "#f38ba8"   # red
  elif awk -v p="$pct" 'BEGIN {exit !(p >= 30)}'; then echo "#f9e2af"   # yellow
  else echo "#a6e3a1"                                                   # green
  fi
}

cpu_icon_for() {
  local pct="$1"
  if   awk -v p="$pct" 'BEGIN {exit !(p >= 80)}'; then printf "≣"
  elif awk -v p="$pct" 'BEGIN {exit !(p >= 30)}'; then printf "≡"
  else printf "="
  fi
}

# --- main --------------------------------------------------------------------
CPU_PCT=$(get_cpu_pct)
RAM_PCT=$(get_ram_pct)
[[ -z "$RAM_PCT" ]] && RAM_PCT="0.0"

CPU_ICON=$(cpu_icon_for "$CPU_PCT")
CPU_COL=$(color_for_pct "$CPU_PCT")
RAM_COL=$(color_for_pct "$RAM_PCT")

# Single tmux-styled string, e.g.  ≡ 45.2%  🧠 67.8%
printf ' %s #[fg=%s]%s%%  #[fg=%s]%s%%' \
  "$CPU_ICON" "$CPU_COL" "$CPU_PCT" "$RAM_COL" "$RAM_PCT"
