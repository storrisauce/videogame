# IA avversaria: implementation

**Updated:** 2026-11-20 · [Design](design.md) · [Testing](testing.md)

## Approach
Funzioni statiche senza stato. `choose()` clona la partita per ogni azione legale (`Match.legal_actions`), la applica e confronta `board_score()`. La schermata e il simulatore chiamano `choose()` in ciclo finché restituisce `{}`.

## Code map
| File / module | Role in this feature |
|---|---|
| `game/core/greedy_ai.gd` | `lane_score`, `health_score`, `side_score`, `board_score`, `choose` |
| `game/core/game_runner.gd` | partita completa IA contro IA |
| `game/ui/match_screen.gd` › `_ai_turn` | turno dell'IA animato nella schermata |

## Data and config
- **Config constants:** pesi 1 (Caos) e 3 (carta in mano) scritti in `greedy_ai.gd` come nel genere.
- **Persistence:** nessuna.

## Deviations from design
Nessuna.

## History
- 2026-11-20: implemented.
