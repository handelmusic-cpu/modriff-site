#!/usr/bin/env bash
# Copies the other mõd web apps into this site from their own repositories, checked out
# next to this one:
#   score/       mõdScore         (Mobile-Notation)
#   playground/  Music Playground (General-Music)
# play/ (mõdRïff) is made by `npm run publish:web` in the modriff repo, not here.
#
# All three share this origin on purpose: that is what lets them hand songs to each other
# in the browser later (same localStorage / IndexedDB / BroadcastChannel). Their storage
# keys don't collide: mõdRïff uses modo-*, mõdScore mn_* and the "modscore" database,
# Music Playground mp_*.
#
# Only runtime files are copied, and the copies are adjusted for this site:
#   - Music Playground's PostHog snippet is removed. modriff.com promises no analytics and
#     nothing loaded from other companies (privacy.html); the General-Music repo keeps it.
#   - Music Playground's links to its own bundled copies of mõdScore and mõdRïff point at
#     the real ones next door instead.
# Run: build/sync-apps.sh [score|playground], then commit. Never edit score/ or playground/.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
src_root="${APPS_SRC:-$(dirname "$here")}"

sync_app() {
  local dir="$1" repo="$2"; shift 2
  local src="$src_root/$repo" dst="$here/$dir"
  [ -d "$src" ] || { echo "missing $src (clone $repo next to this repo, or set APPS_SRC)" >&2; exit 1; }
  rm -rf "$dst"; mkdir -p "$dst"
  (cd "$src" && cp -R --parents "$@" "$dst/")
  local rev; rev="$(git -C "$src" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  printf '%s %s\n' "$repo" "$rev" > "$dst/.source"
  echo "$dir/ <- $repo@$rev ($(find "$dst" -type f | wc -l | tr -d ' ') files)"
}

want="${1:-all}"
if [ "$want" = all ] || [ "$want" = score ]; then
  sync_app score Mobile-Notation \
    index.html sw.js manifest.webmanifest icon-180.png icon-192.png icon-512.png \
    js/core.js js/panels.js js/editing.js js/render.js js/audio.js js/io.js js/boot.js \
    lib/vexflow.js lib/Tone.js samples
fi
if [ "$want" = all ] || [ "$want" = playground ]; then
  sync_app playground General-Music \
    index.html manifest.json sw.js css js icons audio dist THIRD-PARTY-NOTICES.md
  python3 - "$here/playground" <<'PY'
import sys, re, pathlib
d = pathlib.Path(sys.argv[1])
idx = d / 'index.html'
s = idx.read_text(encoding='utf-8')
s2 = re.sub(r'\s*<!-- Usage analytics \(PostHog\).*?</script>', '', s, count=1, flags=re.S)
if s2 == s or 'posthog' in s2.lower():
    sys.exit('PostHog block not removed: check General-Music/index.html')
idx.write_text(s2, encoding='utf-8')
ext = d / 'js' / 'externalapps.js'
e = ext.read_text(encoding='utf-8')
e2 = e.replace('external: "apps/modscore/index.html"', 'external: "../score/"') \
      .replace('external: "apps/modriff/index.html"', 'external: "../play/"')
if '"../score/"' not in e2 or '"../play/"' not in e2:
    sys.exit('companion links not rewritten: check General-Music/js/externalapps.js')
ext.write_text(e2, encoding='utf-8')
PY
  # The single-file offline copy carries the same snippet; strip it there too.
  python3 - "$here/playground/dist/music-playground.html" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1]); s = p.read_text(encoding='utf-8')
s2 = re.sub(r'\s*<!-- Usage analytics \(PostHog\).*?</script>', '', s, count=1, flags=re.S)
if 'posthog.init' in s2: sys.exit('PostHog still in dist/music-playground.html')
p.write_text(s2, encoding='utf-8')
PY
fi
