# Schermo di gioco: implementation

**Updated:** 2026-11-20 · [Design](design.md) · [Testing](testing.md)

## Approach
Interfaccia costruita interamente da codice, senza scene `.tscn` (tranne `main.tscn` che carica `ui/main.gd`), e grafica provvisoria disegnata con `_draw()`: carte, recinti e ritratti sono rettangoli colorati per banda con testo. Quando arriverà l'arte, `CardView` e `LaneView` mostreranno le immagini al posto dei rettangoli. La logica resta tutta in `Match`: la schermata chiama `can_play`, `play_card`, `scuoti`, `use_hero`, `attack_lane`, `end_turn`.

## Code map
| File / module | Role in this feature |
|---|---|
| `game/ui/main.gd` | radice: tema, margini sicuri dello schermo, passaggio menu ⇄ partita |
| `game/ui/menu_screen.gd` | scelta del sopravvissuto e delle 2 bande, mirino automatico, statistiche |
| `game/ui/match_screen.gd` | tavolo orizzontale, input, turni dell'IA animati, mirino, fine partita, rialzarsi |
| `game/ui/card_view.gd`, `lane_view.gd`, `hero_view.gd` | carta, recinto, ritratto (provvisori) |
| `game/ui/geiger_dial.gd` | il mirino Geiger |
| `game/ui/pal.gd` | colori e nomi delle bande |
| `game/core/profile.gd` | profilo salvato in `user://profilo.json` (scatolette, statistiche, scelte) |
| `game/tools/screenshot.gd` | screenshot di menu, partita e mirino (serve uno schermo) |

## Data and config
- **Config constants:** `data/rules.json` → `ring_green`, `ring_red`, `ring_spin_min`, `ring_spin_max`, `ring_turns`, `reward_win_fagioli`, `reward_loss_fagioli`.
- **Persistence:** `user://profilo.json`, senza versione (da aggiungere prima della sincronizzazione con Supabase).

## Deviations from design
- Le carte si giocano **toccando** la carta e poi il recinto, non trascinando (D-010).
- Nessuna vibrazione, nessuno scuotimento dello schermo, nessun verso: arrivano con l'arte e l'audio.
- La difesa mostra il quadrante con "Tocca per parare" ma il risultato non conta (D-005).
- Il rialzarsi compare nel pannello di fine partita, se hai almeno una scatoletta di tonno (3 all'inizio [ASSUMPTION]).

## History
- 2026-11-20: implemented con grafica provvisoria.
