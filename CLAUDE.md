# CLAUDE.md — Fattoria Nucleare

Memoria del progetto. **Leggila tutta a inizio sessione**, poi fai i passi di "Primo avvio su un computer nuovo".
Aggiornala (soprattutto "Stato" e "Prossimi passi") prima di ogni commit importante: chi riprende il lavoro deve sapere
da qui cosa stiamo facendo, cosa è fatto e come continuare. Ultimo aggiornamento: **2026-11-20** (taratura 1).

---

## 1. Il progetto in breve
**Fattoria Nucleare** è un gioco di carte a corsie per telefono, **solo in orizzontale**, prima **iPhone** e poi **Android**.
Due sopravvissuti schierano animali e ortaggi mutanti in 4 recinti a testa, spendono **Caos** per giocare carte e
**Scuotere** le creature, attaccano con un **mirino Geiger** a tempo e si tolgono **Pazienza**. Tono demenziale post-nucleare cartoon.
- Engine: **Godot 4.7, GDScript** (cartella `game/`).
- Backend previsto: **Supabase** (non ancora collegato).
- Repo GitHub: `storrisauce/videogame`, ramo principale **`main`** (sempre aggiornato).

## 2. L'utente
- Parla italiano: **rispondi sempre in italiano semplice**, frasi brevi, niente gergo non spiegato.
- Ha un **Mac**: le build iOS si fanno lì con Xcode.
- Vuole salvataggi frequenti: **committa e pusha su `main` spesso**, non solo alla fine.
- Prima di decidere al posto suo su gusti, contenuti o regole, **chiedi**. Sui dettagli tecnici scegli tu e spiega in una riga.

## 3. Regole che non si discutono
1. **Contenuti originali (D-001, D-007 nel GDD).** Regole del gioco e *famiglie* di abilità del genere a corsie restano identiche
   a quelle studiate in `docs/analisi-meccaniche-card-wars.md` e `docs/catalogo-abilita-card-wars.md`.
   Ogni **carta, numero, eroe, nome, immagine** è invece originale: **mai** una mappatura carta-per-carta del gioco originale,
   anche se l'utente la chiede o la lascia intendere. Si spiega con gentilezza e si prosegue con contenuti originali.
2. **Nessun nome, termine o personaggio** dell'opera originale dentro il gioco (testi, codice visibile, asset). Nei documenti di studio sì.
3. **Nessuna novità di regole (D-005):** le debolezze dell'originale (difesa scenica, IA a una mossa, primo turno senza attacco,
   mazzo finito diverso fra umano e IA) restano finché l'utente non decide altrimenti. I **numeri** sono nostri e si possono tarare.
4. **Il tema segue il DNA tematico** (`docs/dna-tematico.md`): nome = battuta che spiega l'effetto, battuta di una riga, test finale per ogni carta.
5. **Non committare l'APK** né asset estratti dall'originale. Non mettere mai chiavi segrete nel repo.

---

## 4. Primo avvio su un computer nuovo (es. il Mac dell'utente)
Fai questi controlli **appena apri la cartella**, poi riassumi all'utente cosa manca e **chiedi il permesso prima di installare app**.

### 4.1 Strumenti
| Strumento | Serve per | Controllo | Installazione su Mac |
|---|---|---|---|
| Homebrew | installare il resto | `brew --version` | https://brew.sh |
| **Godot 4.7.x** (standard, non .NET) | il gioco | `godot --version` | `brew install --cask godot` oppure https://godotengine.org/download/macos/ — releases: https://github.com/godotengine/godot/releases (serve la **4.7**; se brew installa una versione diversa, scarica la 4.7.x dal link) |
| Comando `godot` nel terminale | test e simulazioni | `which godot` | `sudo ln -sf /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot` |
| Export templates Godot 4.7 | build iPhone/Android | Godot → Editor → Manage Export Templates | pulsante *Download and Install* (stessa versione dell'editor) |
| **Xcode** | build e firma iOS | `xcodebuild -version` | App Store, poi `xcode-select --install` |
| Apple Developer Program | TestFlight e App Store | — | https://developer.apple.com/programs/ (99 $/anno) |
| **Node.js ≥ 22.20** | installare le skill | `node -v` | `brew install node` |
| Python 3 | controllo dei documenti | `python3 --version` | già presente su macOS |
| **Blender** (≥ 4.x, testato 5.3) | arte 3D → immagini delle carte | `/Applications/Blender.app/Contents/MacOS/Blender --version` | `brew install --cask blender` oppure https://www.blender.org/download/ (sorgente: https://github.com/blender/blender, non serve compilarlo) |
| Android Studio + JDK 17 | build Android (più avanti) | — | https://developer.android.com/studio ; poi in Godot: Editor Settings → Export → Android, percorsi SDK e JDK |
| Supabase CLI | database (più avanti) | `supabase --version` | `brew install supabase/tap/supabase` |

### 4.2 Skill di Claude Code
Installate globalmente (`-g`) per Claude Code. Controllo: `ls ~/.claude/skills | wc -l` (atteso circa 148).
Se mancano, installale (servono Node.js; alla fine, se non compaiono, riavvia Claude Code):
```bash
npx -y skills add gamedev-skills/awesome-gamedev-agent-skills -a claude-code -g -y
npx -y skills add https://github.com/cloudai-x/threejs-skills -a claude-code -g -y
npx -y skills add scottstts/Threejs-Awesome-Graphics-Agent-Skills -a claude-code -g -y
npx -y skills add RobLe3/cc-blender-skill -a claude-code -g -y
```
| Pacchetto | Link | Quante | Uso nel progetto |
|---|---|---|---|
| Awesome Gamedev Agent Skills | https://github.com/gamedev-skills/awesome-gamedev-agent-skills | 80 | **le principali**: Godot, design, UI, carte, export |
| Three.js skills | https://github.com/cloudai-x/threejs-skills | 13 | solo per prototipi web o materiale promozionale (il gioco è Godot) |
| Three.js Awesome Graphics | https://github.com/scottstts/Threejs-Awesome-Graphics-Agent-Skills | 24 | come sopra (bloom, particelle, effetti radioattivi nel web) |
| **Blender pilotato da Claude** | https://github.com/RobLe3/cc-blender-skill | 30 | **arte 3D**: modellazione, materiali, texture/UV, luci, camere, render, animazione, export; richiede il collegamento Blender ↔ Claude (§4.2.2) |

**Skill usate finora:** `game-docs` (GDD e note di design, con il controllo `scripts/check_docs.py`), `godot-gdscript-headless-testing`
(test senza grafica), `godot-ui-control` (schermate), `godot-export` (preset iOS/Android). **Da usare nei prossimi passi:** `router`,
`card-game`, `game-ui-ux`, `game-feel` (vibrazioni, scuotimenti, mirino), `create-game-assets` (stile e immagini delle carte),
`audio-design` / `godot-audio`, `save-systems` (profilo), `godot-animation`, `performance-optimization`, `level-design` (campagna).
Per Blender c'è il pacchetto RobLe3/cc-blender-skill (§4.2.2); senza il collegamento MCP si usano script Python (vedi §6.4).

### 4.2.1 Skill per grafica, texture e 3D (trovate il 2026-11-20)
Cercate nel catalogo https://skills.sh/ (`npx skills find …`) e verificate per installazioni e stelle GitHub.
Installale quando si lavora sull'arte (§9, punto 4). Chiedi all'utente prima di quelle a pagamento.
| Skill | Link | Cosa fa | Costo | Comando |
|---|---|---|---|---|
| **Blender pilotato da Claude** — ✅ **installata** | https://github.com/RobLe3/cc-blender-skill (178★, ~4K installazioni) | 10 skill per Blender 5.x: modellazione, materiali e texture, luci, telecamere, rendering, animazione, esportazione, da schizzo a 3D, flusso da professionista | gratis (usa il Blender del computer) | `npx -y skills add RobLe3/cc-blender-skill -a claude-code -g -y` |
| **Scenario** (arte AI delle creature) | https://github.com/scenario-labs/skills (3.926★) | immagini, texture, modelli 3D e animazioni con l'AI, **personaggi coerenti** tra le carte; skill per Godot (shader), Blender (animazione 2D), asset di gioco | **a pagamento**: account Scenario + chiave API | `npx -y skills add scenario-labs/skills -a claude-code -g -y` |
| **Meshy** (modelli 3D da testo/immagine) | https://github.com/meshy-dev/meshy-3d-agent (120★, ~3,4K installazioni) | "maiale con armatura di lamiera" → modello 3D con texture, da rifinire in Blender | **a pagamento**: account Meshy | `npx -y skills add meshy-dev/meshy-3d-agent -a claude-code -g -y` |

Già installate e utili per la grafica: `create-game-assets` (stile, sprite, texture, controllo qualità e licenze),
`godot-shaders` e `shader-programming` (bagliori radioattivi, contorni, dissolvenze), `godot-3d-essentials`, `game-feel` (animazioni
dei colpi). Le Three.js valgono solo per il 3D nel browser.
Scartate: skill "ai-image-generation" di fonti sconosciute con numeri di installazioni non credibili; "game-art" e "3d-modeling" con poche
decine di installazioni. Chiavi API (Scenario, Meshy): mai nel repo; sul Mac in variabili d'ambiente o nel portachiavi.

### 4.2.2 Collegare Blender a Claude (serve alle skill di Blender, solo sul Mac)
Le 30 skill di RobLe3 comandano un **Blender aperto** tramite un server **MCP** (un ponte tra Claude Code e Blender).
Ingresso principale: `/text-to-blender` oppure una richiesta normale ("modella un silos arrugginito"); per scene complete
`blender-pro-workflow`. Istruzioni originali: `~/.claude/skills/text-to-blender/references/mcp-backends.md` e `agent-hosts.md`.
Due possibilità (chiedi all'utente prima di cambiare la configurazione di Claude Code):
- **MCP ufficiale di Blender** (preferito, serve Blender ≥ 5.1): in Blender → *Preferenze → Get Extensions → Repositories*
  aggiungi `https://lab.blender.org/`, installa e attiva l'estensione **MCP**, poi avvia il suo server nelle preferenze
  dell'estensione; quindi registra in Claude Code il client MCP indicato dall'estensione, con nome `blender`.
- **blender-mcp di ahujasid** (Blender ≥ 4.0, documentazione: https://github.com/ahujasid/blender-mcp): installa `uv`
  (`brew install uv`), in Blender installa l'add-on `addon.py` del repository e premi *Connect* nel pannello laterale
  (porta 9876), poi: `claude mcp add blender -- uvx blender-mcp`
Verifica: chiedi a Claude un'interrogazione di sola lettura della scena prima di qualsiasi modifica. Alcune skill di
ricostruzione da riferimenti vogliono anche Python con `pillow opencv-python numpy scipy` (`pip3 install pillow opencv-python numpy scipy`).
**Nel cloud** non c'è un Blender aperto né l'MCP: lì le skill servono come guida e si lavora con script `bpy` in background (§10).

Elenco completo dei nomi:
- Gamedev (80): ai-behavior-trees-utility-ai, audio-design, bevy-ecs, camera-systems, card-game, create-game-assets, defold-core, dialogue-systems, ebitengine-game, fps-shooter, game-ai, game-docs, game-feel, game-jam, game-ui-ux, godot-2d-movement, godot-3d-essentials, godot-animation, godot-audio, godot-csharp, godot-export, godot-gdscript, godot-gdscript-headless-testing, godot-multiplayer, godot-nodes-scenes, godot-physics, godot-resources, godot-shaders, godot-signals-groups, godot-tilemap, godot-ui-control, input-systems, itch-publish, level-design, love2d-core, performance-optimization, phaser-arcade-physics, phaser-core, physics-tuning, pixijs-rendering, platformer, procedural-gen, prototype-fast, puzzle, pygame-core, roblox-* (8), roguelike, router, rpg, save-systems, shader-programming, steam-publish, survival-crafting, threejs-gltf-loading, threejs-materials-lighting, threejs-scene-setup, tower-defense, unity-* (8), unreal-* (6), visual-novel.
- Three.js (13): threejs-animation, -asset-pipeline, -fundamentals, -geometry, -interaction, -lighting, -loaders, -materials, -performance, -postprocessing, -react-three-fiber, -shaders, -textures.
- Blender di RobLe3 (30): text-to-blender, blender-pro-workflow, blender-modeling, blender-materials, blender-uv-texturing, blender-lighting, blender-cameras, blender-rendering, blender-animation, blender-export, blender-skill-harmonizer, animation-quality-gate, atlas-uv-fitting, closed-surface-uv-coverage, contour-to-mesh, fit-repair-optimizer, landmark-fit-repair, mascot-logo-reconstruction, multiview-constraint-solver, multiview-fit-loop, orbital-hud-motion, orthographic-registration, quality-refinement-autoloop, reference-analysis-validator, reference-look-calibration, reference-to-3d, source-part-segmentation, texture-driven-mesh-fitting, texture-state-animation, wireframe-to-3d.
- Three.js Graphics (24): threejs-atmosphere-aerial-perspective, -bloom, -camera-direction, -exposure-color-grading, -image-pipeline, -parallax-occlusion-mapping, -precipitation-surfaces, -procedural-animation, -procedural-architecture, -procedural-fields, -procedural-geometry, -procedural-materials, -procedural-planets, -procedural-vegetation, -procedural-vfx, -raymarched-space-effects, -screen-space-ambient-occlusion, -shadow-systems, -skill-router, -spectral-ocean, -temporal-surfaces, -visual-validation, -volumetric-clouds, -water-optics.

### 4.3 Verifica che tutto funzioni
```bash
godot --headless --path game --import                                  # prima volta dopo il clone
godot --headless --path game --script res://tests/test_runner.gd       # regole: atteso "74 ok, 0 falliti", uscita 0
godot --headless --path game --script res://tests/test_ui.gd           # interfaccia: atteso "47 ok, 0 falliti" (la fila lontana in prospettiva deve restare toccabile, ≥ 44 pt), uscita 0
python3 ~/.claude/skills/game-docs/scripts/check_docs.py docs          # documenti: 0 errori
```
I test escono con codice 1 se qualcosa fallisce. Gli errori di script **non** cambiano il codice d'uscita: cerca anche
`SCRIPT ERROR` nell'output.

### 4.4 Poi chiedi all'utente come continuare
Riassumi lo stato in 3 righe e proponi le opzioni di §9 ("Prossimi passi"), con la tua raccomandazione per prima.

---

## 5. Mappa dei file
| Percorso | Cosa contiene |
|---|---|
| `CLAUDE.md` | questa memoria |
| `docs/GDD.md` | il gioco in una pagina: pilastri, ciclo, **indice delle funzionalità con stati**, tappe M1–M5, **decisioni D-001…D-019**, domande aperte, storico |
| `docs/features/partita/` | regole e numeri della partita (`design.md`), codice (`implementation.md`), test (`testing.md`) |
| `docs/features/carte-e-bande/design.md` | bande, sopravvissuti, formato delle carte, budget statistiche, carte d'esempio |
| `docs/features/schermo-di-gioco/` | layout orizzontale iPhone, gesti, misure; implementazione e test |
| `docs/features/ia-avversaria/` | l'IA del genere: formula del punteggio del tavolo |
| `docs/dna-tematico.md` | mondo, tono, lessico, formule dei nomi (testo dell'utente) |
| `docs/analisi-meccaniche-card-wars.md` | studio delle regole del gioco originale, dal codice dell'APK |
| `docs/catalogo-abilita-card-wars.md` | le 239 famiglie di abilità con quando scattano ed effetti |
| `game/project.godot` | progetto Godot 4.7: 852×393, orientamento orizzontale (sensor landscape), renderer mobile |
| `game/main.tscn`, `game/ui/main.gd` | scena principale: tema, margini sicuri, menu ⇄ partita |
| `game/ui/` | `menu_screen.gd`, `match_screen.gd` (tavolo, input, turni IA, mirino, fine partita), `card_view.gd`, `lane_view.gd`, `hero_view.gd`, `geiger_dial.gd`, `pal.gd` (colori/nomi) |
| `game/core/` | **motore delle regole senza grafica**: `match.gd` (stato e regole), `abilities.gd` (famiglie + testi in italiano), `card_db.gd`, `card_inst.gd`, `lane.gd`, `player_state.gd`, `greedy_ai.gd`, `game_runner.gd`, `deck_factory.gd`, `profile.gd` |
| `game/data/cards.json` | 31 carte di prova (6 per banda + 4 del Cratere) e 6 sopravvissuti; ogni carta = famiglia + valori |
| `game/data/rules.json` | tutti i numeri (Caos, Pazienza, mirino, vantaggi fra bande, ricompense) |
| `game/tests/` | `test_runner.gd` (regole), `test_ui.gd` (partite intere dall'interfaccia + layout a 3 misure) |
| `art/audio/gen_audio.py`, `game/assets/audio/`, `game/ui/sfx.gd` | generatore dei suoni e delle musiche (originali); file audio; suoni, musica e vibrazioni nel gioco |
| `game/tools/` | `simulate.gd` (partite IA contro IA con statistiche), `screenshot.gd` (immagini di menu, partita, mirino) |
| `game/export_presets.cfg` | preset **iOS** e **Android** minimi (includono `data/*.json`); Godot li completa all'apertura |
| `docs/art/design-system.md` | **regole grafiche**: palette, scala, contorni, luce, ombre, animazione, bande, tavolo, interfaccia |
| `art/palette/`, `art/sprites/`, `art/tools/pixel.py` | palette (.json/.gpl/.hex), sprite in testo (.pxl), strumento render/controllo |
| `game/assets/cards/`, `game/assets/heroes/`, `game/assets/board/` | sprite delle carte e dei sopravvissuti, terreni (PNG generati da `art/gen/`) |
| `game/ui/art.gd` | colori della palette per nome, illustrazioni 3D delle carte (`draw_art`), vecchie figure pixel di riserva |
| `game/ui/menu_stage.gd`, `bunker_set.gd` | scena 3D della home; scenografia del bunker (luci, tavolo, oggetti) |
| `game/models/` (`kit.gd`, `models.gd`, `recipes_*.gd`), `game/shaders/` | modelli 3D cartoon delle carte e degli eroi; shader toon e contorno |
| `game/ui/ui_kit.gd`, `stat_chip.gd` | linguaggio dell'interfaccia cartoon; contatori con icona |
| `game/assets/models/` (Kenney CC0), `game/assets/fonts/` (OFL), `game/assets/art3d/` | oggetti di scena e ortaggi, font con licenze, foto dei modelli per le carte |
| `game/ui/board_3d.gd`, `fx_layer.gd`, `juice.gd` | tavolo 3D con animazioni, effetti 2D (numeri, carte che volano), risposte al tocco |
| `art/reference/` | pacchetto di riferimento, **solo in locale** (licenza: niente ridistribuzione) |
| `art/blender/nano_da_giardino_sacro.py` | vecchia prova con Blender (non più la strada principale) |

## 6. Come si lavora

### 6.1 Giocare e provare
- **Nell'editor:** apri Godot → *Import* → scegli `game/project.godot` → **F5** per giocare (col mouse al posto del dito).
- **Simulazioni di bilanciamento:** `godot --headless --path game --script res://tools/simulate.gd -- 2000 7 0.25`
  (partite, seme, probabilità di Botta Atomica). Circa 4 minuti per 2000 partite.
- **Screenshot** (sul Mac basta la finestra; nel cloud serve `xvfb-run`):
  `godot --path game --resolution 852x393 --script res://tools/screenshot.gd -- /percorso/cartella`

### 6.2 Documenti di design (skill `game-docs`)
Ogni funzionalità ha uno stato (`idea` → `designed` → `in progress` → `implemented`, più `changed — code pending` e `cut`),
uguale nel GDD e nel suo `design.md`. Ogni numero ha una sola casa: il `design.md` della funzionalità; il codice lo legge da
`game/data/*.json`. Dopo ogni modifica lancia il controllo (§4.3) e registra le decisioni nella tabella del GDD.

### 6.3 Esportare per iPhone (sul Mac)
**Via rapida da terminale (provata il 2026-11-20, iPhone 16e, Personal Team gratuito: l'app scade dopo 7 giorni):**
template 4.7.2 già in `~/Library/Application Support/Godot/export_templates/4.7.2.stable`; il Team ID **non** va nel repo
(si mette nel preset solo per l'esportazione e poi si toglie). Bundle ID: `it.storri.fattorianucleare`.
```bash
cd game && sed -i '' 's/app_store_team_id=""/app_store_team_id="<TEAM_ID>"/' export_presets.cfg
godot --headless --export-debug "iOS" ../build/ios/FattoriaNucleare.xcodeproj
sed -i '' 's/app_store_team_id="<TEAM_ID>"/app_store_team_id=""/' export_presets.cfg
cd ../build/ios && xcodebuild -project FattoriaNucleare.xcodeproj -scheme FattoriaNucleare -configuration Debug -destination "id=<UDID>" -derivedDataPath dd -allowProvisioningUpdates -allowProvisioningDeviceRegistration DEVELOPMENT_TEAM=<TEAM_ID> CODE_SIGN_STYLE=Automatic build
xcrun devicectl device install app --device <UDID> dd/Build/Products/Debug-iphoneos/FattoriaNucleare.app
xcrun devicectl device process launch --device <UDID> it.storri.fattorianucleare
```
Team ID: `security find-certificate -c "Apple Development" -p | openssl x509 -noout -subject` (campo OU). UDID: `xcrun devicectl list devices`.
Icona provvisoria: `godot --headless --path game --script res://tools/make_icon.gd -- <id_creatura>` → `game/assets/icon.png`.

1. Godot → *Editor → Manage Export Templates* → scarica i template della **stessa versione** (4.7.x).
2. *Project → Export* → preset **iOS**: imposta **App Store Team ID** (dal tuo account Apple Developer) e cambia il
   **Bundle Identifier** provvisorio `it.fattorianucleare.gioco` (D-011) con uno tuo.
3. *Export Project* → crea un progetto Xcode in `build/ios/` → aprilo in Xcode → collega l'iPhone → *Run*.
   Per TestFlight: in Xcode *Product → Archive → Distribute App*.
4. Prima di esportare puoi verificare i dati con: `godot --headless --path game --export-pack "iOS" ../build/test.pck`
   e `godot --headless --main-pack build/test.pck --quit-after 200` (nessun `ERROR` atteso).
Android (più avanti): preset **Android** già presente; servono Android Studio, JDK 17, una keystore di rilascio
(mai nel repo: Godot la tiene in `.godot/export_credentials.cfg`, che è ignorato da git).

### 6.4 Arte, pixel art e Blender
- **Cosa sono le texture:** semplicemente **immagini** (PNG) usate dal gioco: illustrazioni delle carte, sfondi, icone.
  In Godot basta metterle nella cartella del progetto: Godot le importa da solo. Oggi il gioco **non ne usa**: carte e tavolo
  sono disegnati con rettangoli e testo (grafica provvisoria).
- **Design system grafico: `docs/art/design-system.md` — leggilo prima di disegnare qualunque cosa.** Stile ispirato a
  Sunnyside World (solo riferimento, in `art/reference/`, ignorato da git: non si usano i suoi elementi, si disegna tutto da
  zero alla stessa scala del mondo). Palette unica di 63 colori in `art/palette/`. Sprite come testo in `art/sprites/*.pxl`,
  strumento `art/tools/pixel.py` (solo Python standard): `render`, `render-all`, `check` (colori fuori palette), `preview`.
  Godot usa il filtro *Nearest* per tutto il progetto.
- **Piano per l'arte (D-013): pixel art 2D, motore sempre Godot** (Phaser e PixiJS scartati: andrebbe riscritto tutto).
  Sprite delle creature in `game/assets/cards/<id-carta>.png`, sfondi in `game/assets/board/`; `CardView` li mostra quando
  esistono, altrimenti resta il rettangolo. In Godot la pixel art vuole il filtro *Nearest* e scale intere. Stile da decidere con
  l'utente (dimensione degli sprite, palette) e da scrivere con la skill `create-game-assets`.
- **Strumenti per la pixel art (verificati il 2026-11-20):** serve **Aseprite** (a pagamento, ~20 $, https://www.aseprite.org/;
  non ancora installato). Poi **Pixel Plugin** (https://github.com/willibrandon/pixel-plugin, MIT, include il suo server MCP):
  `claude plugin marketplace add willibrandon/pixel-plugin` e `claude plugin install pixel-plugin`, poi `/pixel-setup`.
  Alternativa più attiva: **Aseprite MCP** (https://github.com/diivi/aseprite-mcp, MIT). **SpriteCook** è un servizio AI a pagamento.
- **Tileset di Cainos** (https://cainos.itch.io/pixel-art-top-down-basic, tile 32×32): uso commerciale permesso, modifiche
  permesse, **ridistribuzione vietata**. Il repo GitHub è **pubblico**: i file originali non vanno committati così come sono
  (o il repo diventa privato, o restano fuori da git). Decisione dell'utente.
- **Blender sul Mac** (non più la strada principale, D-013): gli script in `art/blender/` si lanciano così:
  `/Applications/Blender.app/Contents/MacOS/Blender --background --python art/blender/nano_da_giardino_sacro.py -- /percorso/out.png`
  (lo script usa Cycles su CPU e contorni a "guscio invertito"; sul Mac con GPU si può passare a EEVEE e provare Freestyle).
  Blender va bene per oggetti, strutture e ambienti in stile uniforme; per creature espressive serve un artista o un generatore
  di immagini, con Blender per uniformare.

### 6.5 Git
- Ramo principale: `main`. Committa e pusha spesso. Messaggi di commit in inglese.
- `build/` e `game/.godot/` sono ignorati. Non committare APK, keystore, chiavi.

### 6.6 Supabase (non ancora collegato)
Su GitHub (repo → Settings → Secrets and variables → Actions) l'utente sta inserendo: secret `SUPABASE_ACCESS_TOKEN`,
`SUPABASE_DB_PASSWORD`; variabili `SUPABASE_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Il gioco userà solo URL e chiave
*anon/publishable*; **mai** la chiave `service_role` nel gioco. In locale, URL e chiave anon si possono tenere in un file non
committato (es. `game/data/supabase.local.json`, da aggiungere a `.gitignore`).

---

## 7. Stato (2026-11-20)
- ✅ **Analisi** del gioco originale dall'APK: regole, formule, IA, meta, 239 famiglie di abilità.
- ✅ **GDD 0.4** + note: `partita` (implemented), `schermo-di-gioco` (implemented, grafica provvisoria), `ia-avversaria`
  (implemented), `carte-e-bande` (designed). Decisioni D-001…D-019.
- ✅ **Gioco giocabile** su computer (e pronto per l'esportazione):
  - menu: sopravvissuto, 2 bande per il mazzo, mirino automatico, statistiche e scatolette;
  - partita contro l'IA in orizzontale: tocca una carta e poi un recinto per giocarla; tocca una tua creatura per **Scuoterla**;
    tocca il tuo ritratto per l'abilità; **Fine turno** → mirino Geiger per ogni tuo attacco → turno dell'IA animato;
  - fine partita con ricompense in scatolette di fagioli, **rialzarsi** con 1 scatoletta di tonno (una volta), rivincita;
  - profilo salvato in `user://profilo.json`.
- ✅ **Test:** 74 controlli delle regole + 45 dell'interfaccia (3 partite intere dalle schermate, layout a 852×393, 667×375,
  932×430), tutti verdi e senza errori di script. Screenshot controllati a occhio.
- ✅ **Preset di esportazione** iOS e Android; pacchetto esportato provato: parte e carica i dati.
- ✅ **Blender** testato (prova "Nano da Giardino Sacro").
- ✅ **Taratura 1** (D-012, accettata dall'utente): +1 Caos al secondo giocatore nel primo turno, sopravvissuti e
  carte ritoccati. 2000 partite: chi inizia **61%** (prima 65%); sopravvissuti 45–56%; bande 46–53% (Patate la più debole).
  Il simulatore accetta varianti senza toccare i JSON, es. `-- 1000 7 0.25 "caos_bonus_secondo=2;hero.nonna.v1=3;card.ratto_accumulatore.atk=2"`.
- ✅ **Grafica pixel art in tutto il gioco** (D-013, D-014): 31 carte e 6 sopravvissuti animati (4 fotogrammi), terreni delle
  bande, tavolo-altopiano con disposizione "da console" (consolle laterali, vassoio della mano, Fine turno grande), menu con
  ritratto, mirino a contatore Geiger, tema dei bottoni in legno.
- ✅ **Strada A, cartoon 3D** (D-016, proposta approvata https://claude.ai/artifact/XEnCiiNFvFC85sW1pHutUc): interfaccia
  cartoon (`ui/ui_kit.gd`: Lilita One/Nunito con contorno, pannelli con bulloni, gemme, icone), carte nuove (costo, tipo,
  illustrazione, nome mai tagliato, abilità quando ingrandita, attacco/vita nelle icone, cornice del terreno), eroi negli angoli,
  contatori con icona, "Fine turno" che pulsa, mano a ventaglio, registro come banner; tabellone toon (vassoio di legno sul
  tavolo di lamiera di un bunker, terreni low-poly per banda, oggetti di scena Kenney CC0, bagliore solo radioattivo);
  creature e sopravvissuti 3D da `game/models/` (kit + ricette per gruppo: **tutti i 37 modelli fatti**); illustrazioni delle carte = foto dei modelli
  (`godot --path game --script res://tools/render_models.gd -- <cartella> --bake` → `assets/art3d/`); **effetti delle
  abilità**: confronto del tavolo prima/dopo ogni Scuotere/eroe/evento/struttura → raggio verde dalla fonte ai bersagli e
  numeri (danno, cura, ±DEF, ±ATK, Caos, carte).
- ✅ **D-020, contorni uniformi** (`shaders/outline.gdshader`): spessore fisso sullo schermo (`Kit.outline_thickness`, 0,0058
  dell'altezza; 0,009 nelle foto delle carte), spinta dal centro (`radial = 1`) per le forme del kit, normale (`radial = 0`)
  per modelli importati e ciambelle. Niente più contorni staccati agli spigoli.
- ✅ **D-019, revisione completa:** home come scena 3D del bunker (`ui/menu_stage.gd`: sopravvissuto su un piedistallo sotto
  la lampada; sopra solo logo, nome/soprannome/abilità, frecce tonde, bande come gettoni, "Gioca", scatolette, rotellina con
  le impostazioni); interfaccia di gioco minimal (niente etichette sotto le icone, scheda solo per le azioni, tondo
  dell'abilità sull'angolo del ritratto, gettoni attacco/vita sopra le creature), mirino Geiger tondo, fine partita con
  titolo colorato e bottone principale, animazioni 3D con preparazione, salto ad arco, onde d'urto, rinculo, pausa
  d'impatto e colpo di telecamera sulla Botta Atomica, morte con capriola e scintille; mano che non copre mai i nomi;
  rimossi `board_view.gd`, `terrain_bg.gd`, `sprite_view.gd` (non più usati).
- ✅ **D-018, atmosfera del bunker** (`game/ui/bunker_set.gd`): lampada calda sopra il tabellone (bordi in ombra), luce verde
  attorno a barile e uranio, ombre e cadute di luce "a gradini" nello shader, tavolo di lamiera con giunture, bulloni, graffi,
  cavi e mappa; oggetti raggruppati con contorni spessi (barile con melma, scatoletta rovesciata, maschera antigas, santuario
  del nano con candele, radio, contatore Geiger, cassa di uranio, torre di raffreddamento, funghi mutanti), polvere nell'aria.
  Attenzione: `Kit.blob` mette la misura nella scala, quindi le animazioni di scala vanno fatte relative alla scala di partenza.
- ✅ **D-017:** carte in stile C "targa di lamiera" (illustrazione ~2/3, nome su targhetta del colore della banda, gettoni
  di attacco e vita, testo dell'abilità che si adatta quando la carta è scelta), sopravvissuti con nome e soprannome
  (Gertrude, Gianni, Ermenegildo, Dottor Tremolo, Brigadiere, Ruggero: in `data/cards.json`, campi `name` ed `epithet`),
  oggetti nucleari sul tavolo (barile col trifoglio, torre di raffreddamento, contatore Geiger, barre di uranio, fungo
  mutante, cartello), 3D disegnato direttamente nella finestra a piena risoluzione con MSAA 4x + FXAA.
- ✅ **Tavolo 3D e animazioni** (D-015): `game/ui/board_3d.gd` (altopiano 3D, Sprite3D pixel art, telecamera che si adatta,
  arrivi/attacchi/colpi/morti, scossa a trauma), `fx_layer.gd` (numeri di danno, carta che vola), `juice.gd` (pressione dei
  pulsanti, entrate sfalsate), menu rifatto, scheda carta compatta, opzione "Meno movimento". Controllo animazioni:
  `godot --path game --resolution 852x393 --script res://tools/anim_check.gd -- <cartella> 20` (foto ogni secondo).
- ✅ **D-022, rifiniture 3D e glitch:** contorni con normali medie nel colore dei vertici (`Kit.prepare_outlines`, da chiamare
  dopo aver costruito modelli o scene; un test controlla che nessuna mesh resti senza), gettoni ATK/vita ai piedi delle creature
  (`Board3D.head_point`), figure limitate al recinto (`MAX_H/MAX_W/MAX_D`), telecamera 45° fov 36, luce di contorno da dietro
  (`toon.gdshader`: le luci "da dietro" disegnano solo il bordo), vignettatura e colori (`ui/ui3d.gd`), terreni 3D per banda
  e acqua animata (`shaders/water.gdshader`), occhi con riflesso e `Kit.idle_life` (palpebre, sguardo), scelta del bersaglio
  sopra la mano, avversario mai con il tuo stesso sopravvissuto, Pazienza mai negativa sullo schermo.
- ✅ **D-021, suoni e vibrazioni:** 32 effetti e 2 musiche originali sintetizzati da `art/audio/gen_audio.py`
  (in `game/assets/audio/`), suonati da `ui/sfx.gd` (`Sfx.play`, `Sfx.music`, `Sfx.buzz`, bus Musica/Effetti con limitatore);
  impostazioni Musica, Effetti sonori, Vibrazione nella rotellina della home (salvate nel profilo). Mancano i versi degli animali.
- ✅ **Prima prova su iPhone reale** (2026-11-20): esportata, compilata e installata da terminale (§6.3).
  Correzioni dopo la prova: vignettatura su tutto lo schermo (non solo nei margini sicuri), rotellina disegnata (⚙ manca
  nei font iOS: niente simboli speciali nei testi), ritmo più lento (`MatchScreen.PACE`), carta dell'avversario mostrata
  prima di ogni sua mossa (`_reveal_ai_action`), recinto che si illumina prima di ogni attacco, opzione "Animazioni rapide".
- ✅ **D-024, coda di presentazione** (`match_screen.gd`: `_on_event` → `_steps` → `_present()`): il Match calcola subito,
  lo schermo racconta un evento alla volta con la foto dello stato di quel momento (`_view_snapshot`, `_disp`); tavolo
  (`Board3D.refresh_view`), gettoni (`LaneView.show_lane`), Pazienza (`HeroView.disp_hp`) e contatori cambiano solo al
  loro turno; chi muore resta a vita 0 finché non tocca alla sua morte. Nel Match Scuotere, abilità ed eventi si
  annunciano prima dei loro effetti. Ogni mutazione del Match va seguita da `await _present()` prima di `_check_over()`.
- ❌ Non ancora fatto: trascinamento delle carte (D-010), tutorial, set di lancio (~90 carte),
  costruzione libera del mazzo, campagna, casse/collezione, Supabase, build su iPhone reale, Android.

## 8. Tappe (dal GDD)
M1 regole senza grafica ✅ → **M2 vertical slice su iPhone** (gioco fatto; manca la prova su TestFlight) → M3 contenuti di lancio
(carte, arte, audio) → M4 meta e backend (campagna, mazzo, Supabase) → M5 Android.

## 9. Prossimi passi — da proporre all'utente
1. **Provarlo sul tuo iPhone** (consigliato per primo): template 4.7, Team ID e Bundle ID, export Xcode, run sul telefono/TestFlight.
   Serve l'Apple Developer Program per TestFlight.
2. **Bilanciamento (taratura 2):** chi inizia è ancora al 61%; si può provare `caos_bonus_secondo=2` (chiedere all'utente).
   Rinforzare un po' Patate e Cane. Rifare la taratura quando arriva il set di lancio.
3. **Contenuti:** scrivere il set di lancio (~15 carte per banda + 15 Cratere) seguendo il DNA tematico e il catalogo delle famiglie;
   implementare in `abilities.gd` le famiglie nuove che servono (con test).
4. **Rifiniture dello stile A:** tabellone un po' più grande sullo schermo; dubbi aperti sui modelli (il tacchino con la
   forchetta, le pile di copertoni della baracca, la fascia tricolore del Trattore da confermare con l'utente); i raggi della
   Mucca Laser rimpiccioliscono la sua foto; suoni e vibrazioni.
5. **Arte e vita, rifiniture:** effetti delle abilità (Scuotere mostra cosa succede), carattere pixel con accenti, suoni
   (`godot-audio`), vibrazioni, schermata di fine partita illustrata, tutorial. Poi: carattere pixel con accenti (serve scaricarne uno libero, chiedere), animazioni di attacco,
   colpito e morte, numeri di danno, effetti (fumo, scintille), schermata di fine partita illustrata. Poi, se l'utente vuole,
   la prospettiva (`BoardView.PERSPECTIVE = true`, sprite ×3 vicino e ×2 lontano) o un vero 2.5D.
   Per disegnare: `art/gen/*.py` con `art/tools/shapes.py` (ellipse, blob, polygon, grid, tidy, outline), poi
   `python3 art/tools/pixel.py check`, `stats`, `compare`.
5. **Rifiniture dello schermo:** trascinamento delle carte, vibrazioni e scuotimento con la Botta Atomica (`game-feel`), suoni
   (`godot-audio`), tutorial alla prima partita.
6. **Meta e Supabase (M4):** costruzione del mazzo, campagna, profilo sul server, dati delle carte scaricati.
7. **Android (M5).**

---

## 11. Risorse esterne: pacchetti, skill, asset (cosa, perché, licenza, stato)
Aggiornala ogni volta che si installa, si scarica o si scarta qualcosa. "Usata" = applicata davvero nel progetto.

### 11.1 Programmi sul Mac
| Programma | Perché | Stato |
|---|---|---|
| Godot 4.7.2 (Homebrew) | motore del gioco (D-002) | installato, comando `godot` |
| Blender 5.3 (Homebrew) | modelli 3D e ritocchi degli asset (togliere/aggiungere mutazioni, convertire FBX → GLB) | installato, non ancora collegato a Claude (§4.2.2) |
| Xcode 27.2 | build iOS | presente |
| Node 24, Python 3.14, uv | installare skill; strumenti dell'arte; MCP di Blender | presenti |
| numpy, ffmpeg (con libvorbis) | generare suoni e musiche (`art/audio/gen_audio.py`) | presenti |
| GitHub Desktop | push su GitHub (il terminale non ha il login: `gh auth login` mai completato) | in uso per i push |

### 11.2 Skill di Claude Code (in `~/.claude/skills`)
| Pacchetto | Skill usate e perché | Non usate e perché |
|---|---|---|
| gamedev-skills/awesome-gamedev-agent-skills | `game-docs` (GDD), `godot-gdscript-headless-testing` (test), `godot-ui-control` + `game-ui-ux` (gerarchia dell'HUD, tocchi ≥ 44 pt, contrasto, safe area), `game-feel` (tre livelli di impatto, scossa a trauma, numeri, schiacciamento), `card-game` (zone e invarianti), `godot-animation` (Tween), `godot-3d-essentials` (tavolo 3D), `godot-export`, `create-game-assets`, `godot-audio` + `audio-design` (bus Musica/Effetti, limitatore, livelli, musica abbassata sotto i colpi, variazione di tono) | quelle di altri motori (Unity, Unreal, Roblox, Phaser...) |
| RobLe3/cc-blender-skill (30) | pronte per quando Blender sarà collegato via MCP | non ancora usate: manca il collegamento |
| greensock/gsap-skills (8) | `gsap-core`, `gsap-timeline`: principi di sequenze, easing, sfalsamenti, riduzione del movimento, tradotti in Tween di Godot | GSAP è una libreria JavaScript: nel gioco Godot non si usa il codice |
| majidmanzarpour/threejs-game-skills (9) | `threejs-game-ui-designer`: gerarchia (sopravvivenza → obiettivo → feedback → contorno), niente "cartelle di statistiche" | il resto è per giochi Three.js nel browser |
| cloudai-x/threejs-skills (13), scottstts Three.js Graphics (24) | solo principi di luci, materiali, bloom | il gioco non è Three.js |
| animate, emil-design-eng | regole di movimento: ease-out in entrata, mai da scala 0, 150–300 ms, pressione 0,97, sfalsamento 30–80 ms | — |
| frontend-design | un solo elemento memorabile per schermata, testi semplici e attivi, niente maiuscole decorative | — |
| vercel-react-view-transitions | idea di "elemento condiviso": la carta vola dalla mano al recinto | il codice è React |
| vercel-react-native-skills, vercel-react-best-practices, vercel-composition-patterns, web-design-guidelines | solo il principio "anima solo posizione/scala/trasparenza" | regole per codice React o pagine web: nel progetto Godot non c'è niente a cui applicarle |

### 11.3 Asset e riferimenti
| Risorsa | Licenza | Uso | Stato |
|---|---|---|---|
| Sunnyside World (danieldiggle.itch.io/sunnyside) | uso commerciale e modifiche sì; **niente ridistribuzione, niente addestramento AI** | solo riferimento di stile per la pixel art (D-013) | in `art/reference/`, ignorato da git |
| ENDESGA 32 | palette pubblica | base della palette di 63 colori | usata |
| Cainos Pixel Art Top Down | commerciale sì, ridistribuzione no | valutato | non usato |
| Kenney UI Pack (opengameart.org/content/ui-pack) | CC0 | scaricato; le cornici sono disegnate in codice nella palette (il pacchetto non ha contorni) | in `art/vendor/`, non usato nel gioco |
| Kenney Survival Kit, Food Kit, Nature Kit (glTF; mirror opengameart.org) | CC0 | scatolette, barile, cassa (tavolo del bunker); carota, barbabietola, zucca... (`Kit.food`) | **usati**: copie in `game/assets/models/` con licenza; archivi in `art/vendor/` (ignorati da git) |
| Quaternius Farm Animals (opengameart.org; FBX/OBJ/Blend) | CC0 | scaricato come riserva; le creature sono procedurali per coerenza di stile | non usato |
| Vertexcat Farm Animals Set | CC0 | solo su itch.io (download non automatizzabile) | non scaricato |
| Lilita One, Nunito (github.com/google/fonts) | SIL OFL 1.1 | titoli/numeri/bottoni; testi delle abilità | **usati**: `game/assets/fonts/` con i file OFL |

### 11.4 Strumenti nostri
`art/tools/pixel.py` (render .pxl → PNG, `check` palette, `stats`, `compare`, `preview`), `art/tools/shapes.py` (forme per gli sprite),
`art/gen/*.py` (generatori di sprite e terreni), `game/tools/simulate.gd` (bilanciamento, con varianti), `game/tools/screenshot.gd`
(menu, tavolo, partita, mirino), `game/tools/anim_check.gd` (partita animata, una foto al secondo).

## 10. Note solo per la sessione cloud (container Linux)
Valide solo quando si lavora nel cloud di Claude Code, non sul Mac.
- La rete passa da un proxy: `download.blender.org` è bloccato; GitHub releases e PyPI funzionano.
- Godot: `mkdir -p /opt/godot && cd /opt/godot && curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip && unzip -o -q g.zip && ln -sf /opt/godot/Godot_v4.7-stable_linux.x86_64 /usr/local/bin/godot`
- Blender come modulo Python: `apt-get install -y libegl1 libgl1 libxkbcommon0 libsm6 libxi6 libxxf86vm1 libxfixes3 libxrender1 && python3 -m venv /opt/blender-venv && /opt/blender-venv/bin/pip install bpy`
  poi `/opt/blender-venv/bin/python -I art/blender/<script>.py <out.png>` (solo Cycles su CPU; Freestyle non funziona).
- Screenshot: `apt-get install -y xvfb libgl1-mesa-dri` e `xvfb-run -s "-screen 0 1704x786x24" godot --path game --rendering-driver opengl3 --resolution 852x393 --script res://tools/screenshot.gd -- <cartella>`
- Le skill gamedev si reinstallano da sole con lo script di setup dell'ambiente cloud "Default"; le altre con i comandi di §4.2.
