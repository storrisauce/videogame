# CLAUDE.md — Fattoria Nucleare

Questo file è la memoria del progetto: leggilo per intero a inizio sessione e **aggiornalo prima di ogni commit importante**
(sezioni "Stato" e "Prossimi passi"). Chi riprende il lavoro deve sapere da qui cosa stiamo facendo, cosa è fatto e come continuare.

## Il progetto in breve
**Fattoria Nucleare** è un gioco di carte a corsie per telefono, **solo in orizzontale**, prima **iPhone** e poi **Android**.
Due sopravvissuti schierano animali e ortaggi mutanti in 4 recinti a testa e si tolgono "Pazienza" a turni.
Tono demenziale post-nucleare cartoon. Engine: **Godot 4.7, GDScript**. Backend: **Supabase** (account, salvataggi, dati delle carte).

## L'utente
- Parla italiano: **rispondi sempre in italiano semplice**, frasi brevi, niente gergo non spiegato.
- Ha un **Mac** (le build iOS si fanno lì con Xcode, o su GitHub Actions macOS).
- Vuole salvataggi frequenti: **pusha sul ramo di lavoro e ogni tanto anche su `main`** (permesso esplicito dato il 2026-11-20).

## Regole che non si discutono
1. **Contenuti originali (D-001, D-007 nel GDD).** Le regole del gioco e le *famiglie* di abilità del genere a corsie restano identiche
   a quelle studiate in `docs/analisi-meccaniche-card-wars.md` e `docs/catalogo-abilita-card-wars.md`.
   Ogni **carta, numero, eroe, nome, immagine** è invece originale: **mai** una mappatura carta-per-carta del gioco originale,
   anche se l'utente la chiede o la lascia intendere. Si spiega con gentilezza e si prosegue con contenuti originali.
2. **Nessun nome, termine o personaggio** dell'opera originale nel gioco (testi, codice visibile, asset). Nei documenti di studio sì.
3. **Nessuna novità di regole (D-005):** le debolezze dell'originale (difesa scenica, IA a una mossa, primo turno senza attacco,
   mazzo finito diverso fra umano e IA) restano finché l'utente non decide altrimenti. Sono elencate come proposte aperte.
4. **Il tema segue il DNA tematico** (`docs/dna-tematico.md`): nome = battuta che spiega l'effetto, flavor di una riga, test finale per ogni carta.
5. **Non committare l'APK** né asset estratti dall'originale.

## Mappa dei file
| File | Cosa contiene |
|---|---|
| `docs/GDD.md` | Il gioco in una pagina: pilastri, ciclo, indice funzionalità con stati, tappe M1–M5, **decisioni D-001…**, domande aperte |
| `docs/features/partita/design.md` | Regole della partita e numeri (Caos, mirino Geiger, danni, vittoria) |
| `docs/features/carte-e-bande/design.md` | Bande, sopravvissuti, formato carte, bilanciamento, carte d'esempio |
| `docs/features/schermo-di-gioco/design.md` | Layout orizzontale iPhone, gesti, misure |
| `docs/dna-tematico.md` | Mondo, tono, lessico, formule dei nomi (testo dell'utente) |
| `docs/analisi-meccaniche-card-wars.md` | Studio delle regole del gioco originale, ricavato dal codice dell'APK |
| `docs/catalogo-abilita-card-wars.md` | Le 239 famiglie di abilità con trigger ed effetti |
| `game/` | Progetto Godot: `core/` regole e IA, `data/` carte e numeri, `tests/` test, `tools/` simulatore |

## Come si lavora
- **Documenti di design:** si usa la skill `game-docs`. Ogni feature ha uno stato (`idea` → `designed` → `in progress` → `implemented`)
  uguale nel GDD e nel suo `design.md`. Dopo ogni modifica: `python3 ~/.claude/skills/game-docs/scripts/check_docs.py docs` deve dare 0 errori.
  Quando una feature riceve codice, si aggiungono `implementation.md` e `testing.md` accanto al suo `design.md`.
- **Numeri:** ogni numero ha una sola casa (il `design.md` della feature). Il codice li legge da file dati, non li ricopia a mano.
- **Skill utili** (installate in `~/.claude/skills`): `router`, `godot-gdscript`, `godot-gdscript-headless-testing`, `card-game`,
  `game-ai`, `godot-ui-control`, `game-ui-ux`, `game-feel`, `godot-export`, `create-game-assets`, `game-docs`.
- **Git:** ramo di lavoro `claude/vibrant-turing-1ezyql`; pusha lì, e periodicamente `git push origin HEAD:main`.
  Messaggi di commit in inglese, chiusi dalle righe di attribuzione richieste dalla sessione.

## Ambiente (sessione cloud, container usa-e-getta)
Ogni nuova sessione parte da un container pulito: va reinstallato ciò che serve.
- **Skill gamedev:** si installano da sole con lo script di setup dell'ambiente cloud "Default"
  (`npx -y skills add gamedev-skills/awesome-gamedev-agent-skills -a claude-code -g -y`). Se mancano, lancia quel comando.
- **Godot 4.7 (Linux, senza grafica):**
  ```bash
  mkdir -p /opt/godot && cd /opt/godot && curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip && unzip -o -q g.zip && ln -sf /opt/godot/Godot_v4.7-stable_linux.x86_64 /usr/local/bin/godot && godot --headless --version
  ```
- **Blender 5.3 (per arte 3D / immagini delle carte):** il sito download.blender.org è bloccato dal proxy; si usa il pacchetto
  Python ufficiale `bpy` da PyPI, più alcune librerie di sistema per il rendering senza schermo:
  ```bash
  apt-get install -y libegl1 libgl1 libxkbcommon0 libsm6 libxi6 libxxf86vm1 libxfixes3 libxrender1
  python3 -m venv /opt/blender-venv && /opt/blender-venv/bin/pip install bpy
  /opt/blender-venv/bin/python -I script.py   # dentro: import bpy; motore CYCLES con device CPU (EEVEE/Workbench non vanno senza GPU)
  ```
- **Skill Three.js** (chieste dall'utente, utili solo per prototipi web o materiale promozionale, non per il gioco Godot):
  ```bash
  npx -y skills add https://github.com/cloudai-x/threejs-skills -a claude-code -g -y
  npx -y skills add scottstts/Threejs-Awesome-Graphics-Agent-Skills -a claude-code -g -y
  ```
- **Supabase:** l'utente sta mettendo nei secret/variabili di GitHub Actions `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`
  (secret) e `SUPABASE_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` (variabili). Da questa sessione non sono leggibili:
  per lavorare sul database da qui serve una credenziale chiesta con il modulo sicuro dell'ambiente. Mai chiedere chiavi in chat;
  mai mettere la chiave `service_role` nel gioco.

## Stato (aggiornato 2026-11-20)
- ✅ Analisi del gioco originale dall'APK (regole, formule, IA, meta, catalogo abilità).
- ✅ GDD 0.3 + note di design di `partita` (in progress), `carte-e-bande`, `schermo-di-gioco` (designed). Decisioni D-001…D-009.
- ✅ **M1 quasi finita:** progetto Godot in `game/` (orizzontale, 852×393):
  - `game/core/`: motore delle regole (`match.gd`), famiglie di abilità (`abilities.gd`), dati (`card_db.gd`), IA (`greedy_ai.gd`), partita IA contro IA (`game_runner.gd`).
  - `game/data/cards.json`: set di prova di 31 carte (6 per banda + 4 del Cratere) e 6 sopravvissuti; `game/data/rules.json`: numeri.
  - `game/tests/test_runner.gd`: 64 controlli, tutti verdi; il runner esce con 1 se un controllo fallisce (verificato).
  - `game/tools/simulate.gd`: 2000 partite in ~4 minuti. Risultati in `docs/features/partita/design.md` (Open questions):
    chi inizia vince il 64%, Nonna troppo forte (65%), Veterinario e Cane deboli (41%), Discarica debole (44%).
- ✅ Blender 5.3 (`bpy`) installato e testato: renderizza senza schermo con Cycles su CPU.
- ✅ Ramo `main` allineato.

## Prossimi passi
1. **Chiudere M1:** implementare la regola 13 della partita (rialzarsi con 1 scatoletta di tonno); proporre all'utente
   come tarare i numeri (vantaggio di chi inizia, sopravvissuti, Discarica) e rilanciare le simulazioni. Non cambiare
   regole del genere senza il suo via libera (D-005): si toccano solo i numeri nostri.
2. **M2 vertical slice su iPhone:** scena di gioco orizzontale in Godot secondo `docs/features/schermo-di-gioco/design.md`
   (skill `godot-ui-control`, `game-ui-ux`, `game-feel`), mirino Geiger interattivo, collegata a `Match`.
   Poi export iOS dal Mac dell'utente (skill `godot-export`) e TestFlight (serve l'Apple Developer Program).
3. Arte: definire lo stile con la skill `create-game-assets`; Blender può servire per modelli 3D trasformati in immagini 2D.

Comandi utili:
```bash
godot --headless --path game --import
godot --headless --path game --script res://tests/test_runner.gd
godot --headless --path game --script res://tools/simulate.gd -- 2000 7 0.25   # partite, seme, probabilità di Botta Atomica
python3 ~/.claude/skills/game-docs/scripts/check_docs.py docs
```

## Dopo M1
M2 vertical slice su iPhone (schermo orizzontale, 2 bande, 2 sopravvissuti, 30 carte, TestFlight) → M3 contenuti → M4 campagna e Supabase → M5 Android.
Prima di M2 serve l'iscrizione dell'utente all'Apple Developer Program.
