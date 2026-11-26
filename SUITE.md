# The mõd apps

| App | What it's for | Web | Source |
|---|---|---|---|
| mõd*Rïff* | play it: groovebox, every part in key | `/play/` (+ iPhone, iPad, Mac) | `modriff` repo |
| mõd*Score* | write it down: notation | `/score/` | `Mobile-Notation` repo |
| Music Playground | teach it: games for music class | `/playground/` | `General-Music` repo |

## What makes them one suite today

- **One home.** All three web apps are served from modriff.com, so they share one browser
  origin. dutdutrecords.com/apps/ links here.
- **One look.** Names are mõd + an italic word. The icon is the mõdRïff tile: dark rounded
  square (`#0b0d18`), the rainbow tilde, one white glyph (ring, whole note, tone bars). The
  rainbow is the seven part colours, `#ff5a5f #ff9a3c #ffd23f #5fdc6a #2ad4c8 #3a9bff #b46bff`.
- **Links both ways.** Each app points at the other two.
- **Same promise.** No accounts, no analytics, nothing loaded from other companies, work
  kept on the device (privacy.html says so for all three).

## Integration: the plan

Being on one origin means the apps can pass work to each other with no server.

1. **Handoff, the first step.** A shared `mod-suite` IndexedDB database with one store,
   `handoff`: `{ id, from, to, kind, title, payload, created }`, where `kind` is one of
   `musicxml`, `midi` (bytes) or `chords` (mõdRïff's chord timeline as JSON). The sending
   app writes a record and opens `/<app>/?handoff=<id>`; the receiving app imports it, then
   deletes it. mõdScore already imports MIDI and MusicXML and exports both; mõdRïff already
   writes a `.mid` with every Bounce. What's new is mõdRïff reading MIDI in, and about 40
   lines of shared handoff code.
2. **First flows to build:**
   - mõdRïff song → mõdScore: the parts as MIDI (it already writes one), later a lead
     sheet with chord symbols once mõdRïff writes MusicXML.
   - mõdScore melody → mõdRïff: the melody part as MIDI on the melody track.
   - Music Playground Song Maker → mõdScore: the kids' tune as notation.
3. **The iPhone app.** The native mõdRïff can't read the browser's storage. It uses the
   same files through the share sheet (`.mid` today) and could open
   `https://modriff.com/score/?import=<url>` once mõdScore accepts an import URL.
4. **Later:** one "Library" listing songs from all three apps (the same IndexedDB), and
   shared settings such as theme and tuning in `mod-suite` too.

Storage keys must not collide: mõdRïff uses `modo-*` (and never renames them), mõdScore
`mn_*` and the `modscore` database, Music Playground `mp_*`; new shared data goes under `mod-suite` only.
