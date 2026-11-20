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
| `game/` | Progetto Godot (in costruzione, vedi "Stato") |

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
- **Supabase:** l'utente sta mettendo nei secret/variabili di GitHub Actions `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`
  (secret) e `SUPABASE_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` (variabili). Da questa sessione non sono leggibili:
  per lavorare sul database da qui serve una credenziale chiesta con il modulo sicuro dell'ambiente. Mai chiedere chiavi in chat;
  mai mettere la chiave `service_role` nel gioco.

## Stato (aggiornato 2026-11-20)
- ✅ Analisi del gioco originale dall'APK (regole, formule, IA, meta, catalogo abilità).
- ✅ GDD 0.2 + note di design di `partita`, `carte-e-bande`, `schermo-di-gioco` (stato `designed`). Decisioni D-001…D-009.
- ✅ Ramo `main` creato e allineato.
- 🔧 **In corso: M1 "regole senza grafica"** — progetto Godot in `game/` con il motore delle regole in GDScript puro,
  test automatici senza grafica e partite IA contro IA.

## Prossimi passi (M1)
1. Creare `game/project.godot` (Godot 4.7, orientamento orizzontale `landscape`, finestra 852×393 di riferimento).
2. Motore delle regole in `game/core/` come classi GDScript **senza nodi** (testabili da terminale):
   dati delle carte (da `game/data/cards.json`), stato della partita, regole del turno, Caos, giocata, Scuotere,
   combattimento con risultato del mirino passato come parametro (`colpo` / `botta` / `normale`), danni, vittoria, mazzo finito.
3. Abilità come piccole classi o funzioni registrate per nome di famiglia (come nel catalogo), così le carte nel JSON
   dicono solo "famiglia + valori".
4. IA greedy a una mossa come nell'analisi (§11): punteggio del tavolo e scelta della mossa migliore.
5. `game/tests/test_runner.gd` (vedi skill `godot-gdscript-headless-testing`): test di Caos, costi, danni, vantaggi fra bande,
   Botta Atomica, danno alla Pazienza, mazzo finito, vittoria. Uscita 1 se un test fallisce.
6. `game/tools/simulate.gd`: N partite IA contro IA con statistiche (durata in turni, vincitore per banda) per tarare i numeri.
7. Comandi:
   ```bash
   godot --headless --path game --import
   godot --headless --path game --script res://tests/test_runner.gd
   godot --headless --path game --script res://tools/simulate.gd
   ```
8. Fine M1: aggiornare stati nel GDD (`partita` → `in progress`/`implemented`), scrivere `implementation.md` e `testing.md`,
   aggiornare questo file, commit e push anche su `main`.

## Dopo M1
M2 vertical slice su iPhone (schermo orizzontale, 2 bande, 2 sopravvissuti, 30 carte, TestFlight) → M3 contenuti → M4 campagna e Supabase → M5 Android.
Prima di M2 serve l'iscrizione dell'utente all'Apple Developer Program.
