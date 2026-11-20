# Fattoria Nucleare — Game Design Document

**Version:** 0.2 · **Updated:** 2026-11-20 · [Features](#feature-index) · [Decisions](#decisions) · [Change log](#change-log)

## Summary
Gioco di carte a turni per telefono. Ogni giocatore schiera animali e ortaggi mutanti in **4 recinti** davanti a quelli avversari.
Le carte costano **Caos**, che cresce di turno in turno. Le creature si potenziano con le **strutture**, gli **eventi** cambiano la situazione, e ogni attacco si gioca con un **mirino Geiger** a tempo.
Vince chi azzera la **Pazienza** del sopravvissuto avversario. Una partita dura 4–6 minuti.
Ambientazione: una fattoria dopo una bomba immaginaria, demenziale e cartoon.

| | |
|---|---|
| Genere e camera | Gioco di carte a corsie, 2D, vista dall'alto del tavolo, solo schermo orizzontale |
| Pubblico | 12+, casual-midcore, chi ama giochi di carte rapidi e humor nero cartoon |
| Piattaforme e input | **iPhone** (prima uscita), poi **Android**; due pollici: trascina, tocca, tieni premuto |
| Sessione | Partita 4–6 min; sessione tipica 3–4 partite |
| Engine | Godot 4 (GDScript), un solo progetto per iOS e Android — vedi D-002 |
| Backend | Supabase: account, salvataggi, dati delle carte modificabili senza aggiornare l'app — vedi D-004 |
| Scope | Small release: vertical slice su TestFlight, poi lancio iOS, poi Android |
| Riferimenti | Regole del genere studiate in [analisi meccaniche](analisi-meccaniche-card-wars.md); tono da *Exploding Kittens* e *60 Seconds!* |

## Pillars
1. **Il nome è la battuta e spiega l'effetto.** Ogni carta nasce dal suo effetto: chi legge nome ed effetto pensa "ha senso" e ride. Esclude nomi random e lore lunga.
2. **Una partita in una pausa caffè.** 4–6 minuti, in orizzontale con due pollici. Esclude menu profondi durante la partita e regole che servono spiegazioni.
3. **Tattica a recinti, abilità nel mirino.** Le scelte (dove giocare, cosa scuotere) contano più della fortuna; il mirino premia la mano ferma ma non ribalta da solo una partita persa.
4. **Regole del genere, contenuti nostri.** Regole e famiglie di abilità del genere a corsie, identiche; carte, numeri, eroi e mondo inventati da noi (D-001, D-007).

## Core loop
```
pesca → spendi Caos (gioca carte, scuoti creature) → attacca col mirino → togli Pazienza
  → vinci scatolette e carte → migliora il mazzo → affronta bande più toste → di nuovo
```
- **Secondi:** giocare carte nei recinti, scuotere, mirino Geiger ([partita](features/partita/design.md), [schermo di gioco](features/schermo-di-gioco/design.md))
- **Minuti:** una partita contro una banda della campagna ([partita](features/partita/design.md))
- **Tra le sessioni:** nuove carte dalle casse, costruzione del mazzo, avanzamento sulla mappa ([carte e bande](features/carte-e-bande/design.md))

## Feature index

| Feature | Status | Scope | Summary | Docs |
|---|---|---|---|---|
| Partita | designed | MVP | Regole del turno, Caos, recinti, Scuotere, combattimento col mirino Geiger, vittoria | [design](features/partita/design.md) |
| Carte e bande | designed | MVP | 5 bande + Cratere, sopravvissuti, formato delle carte, bilanciamento, set di lancio | [design](features/carte-e-bande/design.md) |
| Schermo di gioco | designed | MVP | Layout orizzontale per iPhone, gesti, feedback, accessibilità | [design](features/schermo-di-gioco/design.md) |
| IA avversaria | idea | MVP | Valuta ogni mossa col punteggio del tavolo e sceglie la migliore | — |
| Costruzione mazzo | idea | MVP | Mazzo di carte + 4 zone, limiti di copie e dimensione | — |
| Campagna | idea | MVP | Mappa della fattoria, una banda per zona, stelle con condizioni | — |
| Collezione e casse | idea | later | Casse del rifornimento a pesi, livelli delle carte, scatolette come valuta | — |
| Profilo e salvataggi | idea | MVP | Account anonimo Supabase, salvataggio cloud, dati delle carte scaricati | — |
| Versione Android | idea | later | Stesso progetto Godot, adattamento a schermi e tasto indietro | — |
| Sfide asincrone | idea | later | Combatti il mazzo salvato di un altro giocatore guidato dall'IA, trofei | — |
| Eventi a tempo | idea | later | Zone aperte certi giorni, sfidante casuale, regali giornalieri | — |

## Milestones
1. **M1, regole senza grafica:** partita · done when: una partita IA contro IA arriva alla fine con test automatici che verificano Caos, costi, danni e vittoria.
2. **M2, vertical slice su iPhone:** schermo di gioco, IA avversaria, 2 bande, 2 sopravvissuti, 30 carte · done when: su TestFlight un tester finisce una partita senza spiegazioni.
3. **M3, contenuti di lancio:** carte e bande complete, arte, audio · done when: tutte le bande e i sopravvissuti giocabili, ogni carta passa il test finale del DNA tematico.
4. **M4, meta e backend:** campagna, costruzione mazzo, profilo e salvataggi · done when: progressi salvati su Supabase e ripresi su un altro iPhone.
5. **M5, Android:** versione Android · done when: stessa build su Play Console (test interno) senza differenze di gioco.

## Direction
**Tono.** Demenziale, cinico, cartoon. Il mondo segue regole assurde ma coerenti (radiazioni, scarsità, vita di fattoria). Humor nero leggero, volgarità solo da cortile (letame, mutande, scoregge). Niente guerre, paesi, marchi o persone reali.

**Lessico in gioco.** Punti azione → **Caos** · PV dell'eroe → **Pazienza** · corsie → **Recinti** · terreni → **Zone** · fazioni → **Bande** · abilità attivabile → **Scuotere** · edifici → **Strutture** · incantesimi → **Eventi** · eroe → **Sopravvissuto** · scarti → **Letamaio** · critico → **Botta Atomica** · monete → **scatolette di fagioli** · gemme → **scatolette di tonno** (valgono doppio) · stamina → **Razioni**.

**Arte.** Campagna bruciacchiata, cieli giallo-verdi, lamiere e filo spinato. Mutazioni cartoon (occhi in più, bagliori verdi). Palette: verde radioattivo, ruggine, marrone fango, giallo allarme. Ogni banda ha un colore dominante leggibile anche in miniatura.

**Audio.** La radio della fattoria passa sempre lo stesso liscio, che cambia arrangiamento in battaglia. Versi animali esagerati per attacchi e morti.

**Accessibilità e lingua.** Italiano al lancio, testi pronti per la traduzione. Le bande si distinguono anche per icona, non solo per colore. Il mirino ha un'opzione "automatico".

## Decisions

| ID | Date | Decision | Alternatives considered | Why | Affects |
|---|---|---|---|---|---|
| D-001 | 2026-11-20 | Regole del genere a corsie mantenute; carte, numeri, eroi e mondo originali, senza mappatura 1:1 su un gioco esistente | Ricopiare carta per carta l'originale con nomi nuovi | Una copia rinominata resta una riproduzione dell'opera originale; e statistiche e costi originali non sono nemmeno nell'APK | carte-e-bande, partita |
| D-002 | 2026-11-20 | Godot 4 con GDScript, un progetto per iOS e Android | Unity; app web con Capacitor; Swift nativo + Kotlin | Gratuito, ottimo per 2D, un solo codice, test automatici in Linux; iOS richiede comunque un Mac o un runner macOS per firmare | tutto |
| D-003 | 2026-11-20 | Schermo verticale, una mano → superseded by D-006 | Orizzontale come i giochi da tavolo digitali | Pilastro 2; 4 recinti in colonna stanno in 393 pt di larghezza | schermo-di-gioco |
| D-004 | 2026-11-20 | Supabase per account, salvataggi e dati delle carte; partite contro l'IA giocabili offline | Tutto in locale; Firebase | Già scelto dall'utente; i dati delle carte si bilanciano senza aggiornare l'app | profilo, carte-e-bande |
| D-005 | 2026-11-20 | Regole del genere tenute così come le abbiamo studiate, comprese le debolezze (difesa scenica, IA a una mossa) | Correggerle subito | Richiesta dell'utente: nessuna novità di gameplay; le correzioni restano proposte aperte | partita |
| D-006 | 2026-11-20 | Solo schermo orizzontale, due pollici | Verticale con una mano (D-003) | Richiesta dell'utente; il tavolo a 4 recinti per lato respira meglio in larghezza | schermo-di-gioco |
| D-007 | 2026-11-20 | Le abilità delle carte usano le famiglie di effetti del genere (catalogo delle 239), tradotte nel tema; ogni carta resta originale | Inventare effetti nuovi; copiare le carte una per una | Richiesta dell'utente: stesse regole e stesse abilità; i mattoni del genere si usano, le carte specifiche no (D-001) | carte-e-bande |
| D-008 | 2026-11-20 | Build iOS sul Mac dell'utente con Xcode; GitHub Actions macOS come alternativa | Solo CI | L'utente ha un Mac | M2, M5 |
| D-009 | 2026-11-20 | 6 sopravvissuti al lancio, espandibili | Copiare la rosa dell'originale | La rosa originale non è nell'APK (sta sul server) e resta comunque fuori da D-001 | carte-e-bande |

## Open questions
- **Assumptions to confirm:** tutti i numeri segnati `[ASSUMPTION]` nelle note delle feature; l'abbinamento banda→stile di gioco; i 6 sopravvissuti come rosa di lancio.
- **Apple Developer Program:** serve l'iscrizione (99 $/anno) prima di TestFlight in M2.
- **Rischi:** il mirino può stancare dopo 20 partite (si verifica in M2 col playtest); bilanciare 5 bande con numeri nuovi (simulazioni IA contro IA da M1); volume di arte per ~90 carte (stile semplice e riutilizzabile, deciso in M3).

## Change log
**0.1 (2026-11-20):** prima stesura; partita, carte e bande, schermo di gioco progettati; D-001…D-005.
**0.2 (2026-11-20):** schermo solo orizzontale ([schermo di gioco](features/schermo-di-gioco/design.md)); D-006…D-009.
