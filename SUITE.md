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

## Integration

### How a handoff works (built)

One app opens another with the work in the link's fragment:

    https://modriff.com/score/#mod=1&kind=midi&from=playground&title=My%20tune&data=<base64url>

- `kind` is `midi` (data: the `.mid` bytes) or `musicxml` (data: the UTF-8 text).
- The fragment never reaches a server, so a song stays on the device. The same link works
  from the iPhone app, which can't see the browser's storage: it just opens Safari.
- The receiving app imports it as a new song, says where it came from, and clears the
  fragment so a reload doesn't import it twice.
- Sending is synchronous, straight from the click: Safari blocks a tab opened after an await.

The code is `suite/mod-suite.js` (`ModSuite.url / send / receive`, plus a small MIDI writer
and `noteNumber`). mõdScore and Music Playground carry identical copies as `js/suite.js`;
mõdRïff inlines the send half (`_modSuiteUrl`). Change the canonical copy, then copy it.

### Flows

| From | To | What | Status |
|---|---|---|---|
| mõdRïff (Song > File > Open in mõdScore) | mõdScore | the chart's chords, in the song's key | built (v2.0g) |
| Music Playground (Song Maker > Open in mõdScore) | mõdScore | the tune, each square an eighth note | built |
| mõdScore | mõdRïff | the melody part onto the melody track | next: mõdRïff needs a MIDI reader |
| mõdRïff Bounce `.mid` | mõdScore | every part played, one staff each | next: offer it when a Bounce ends |

The chart `.mid` (download and handoff alike) carries a key signature: the major scale that
holds the most of the mode's notes, marked minor for a minor key. mõdScore's MIDI import
reads it and spells notes in that key; a file without one opens in C as before.

### Later

- A shared `mod-suite` IndexedDB store for work too big for a link (a whole Bounce), and
  one "Library" listing songs from all three apps; shared settings such as theme in it too.
- mõdScore → mõdRïff needs mõdRïff to read MIDI (melody and chords in, quantised to its grid).

Storage keys must not collide: mõdRïff uses `modo-*` (and never renames them), mõdScore
`mn_*` and the `modscore` database, Music Playground `mp_*`; new shared data goes under `mod-suite` only.
