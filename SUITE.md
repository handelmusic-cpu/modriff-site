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

| From | To | What | Where |
|---|---|---|---|
| mõdRïff | mõdScore | the chart's chords, in the song's key | Song > File > Open in mõdScore (v2.0g) |
| mõdRïff | mõdScore | a Bounce take, one staff a part, drums left out | the toast when a Bounce with MIDI ends (v2.0h) |
| mõdScore | mõdRïff | the part being edited, into the melody roll (16th steps, up to 64, Follow off) | Songs > More mõd apps > Open this part in mõdRïff |
| Music Playground | mõdScore | the Song Maker tune, each square an eighth note | Song Maker > Open in mõdScore |

Every MIDI mõdRïff writes (chart and Bounce) carries a key signature: the major scale that
holds the most of the mode's notes, marked minor for a minor key. mõdScore's MIDI import
reads it and spells notes in that key, names parts after their tracks, and leaves drum
tracks (channel 10) out with a message. mõdRïff reads MIDI with `_smfNotes` and takes a
handed-over part through the same path as a pasted tab (`tabToMelodyGrid`), with Undo.

The flows are tested in `modriff/tests/suite/handoff.test.js` and end to end by hand on a
local copy of this site (see the commits that added them).

### Later

- A shared `mod-suite` IndexedDB store for work too big for a link (a long Bounce says to
  save the .mid instead today), and one "Library" listing songs from all three apps.
- Drums both ways: mõdScore's drum set staff from a Bounce's channel 10, and mõdScore drum
  parts into mõdRïff's drum grid.
- Chords from mõdScore into mõdRïff's chart (chord symbols, not just the notes).

Storage keys must not collide: mõdRïff uses `modo-*` (and never renames them), mõdScore
`mn_*` and the `modscore` database, Music Playground `mp_*`; new shared data goes under `mod-suite` only.
