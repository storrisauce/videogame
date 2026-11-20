# Partita: implementation

**Updated:** 2026-11-20 · [Design](design.md) · [Testing](testing.md)

## Approach
Motore delle regole in GDScript puro, senza nodi, così gira da terminale, nei test e nell'IA. Tutta la partita è un oggetto `Match` clonabile: l'IA prova ogni mossa su un clone e tiene la migliore. Le carte nel JSON dicono solo "famiglia + valori"; cosa fa ogni famiglia sta in `Abilities`. Il risultato del mirino entra da fuori (`combat(p, crits)`), così regole e interfaccia restano separate.

## Code map
| File / module | Role in this feature |
|---|---|
| `game/core/match.gd` | stato e regole: turno, Caos, giocata, Scuotere, combattimento, danni, mazzo finito, vittoria, `legal_actions`/`apply`, `clone` |
| `game/core/abilities.gd` | famiglie di abilità di carte e sopravvissuti: bersagli validi e risoluzione |
| `game/core/card_db.gd` | carica `data/cards.json` e `data/rules.json`; vantaggio fra bande |
| `game/core/card_inst.gd`, `lane.gd`, `player_state.gd` | copia di carta, recinto, giocatore |
| `game/core/greedy_ai.gd` | IA a una mossa con il punteggio del tavolo del genere |
| `game/core/game_runner.gd` | partita completa IA contro IA |
| `game/tools/simulate.gd` | statistiche su molte partite |

## Data and config
- **Config constants:** `data/rules.json` → `caos_iniziale`, `caos_max`, `hero_hp_base`, `hero_hp_per_level`, `molt_botta`, `advantage`, `advantage_cycle`, `starting_hand`, `max_hand` (valori in [design](design.md#numbers)).
- **Persistence:** nessuna.

## Deviations from design
- Regola 13 (rialzarsi con 1 scatoletta di tonno) non ancora implementata.
- I recinti si fronteggiano con lo stesso indice (0 contro 0); l'ordine di attacco è sempre dal recinto 0 al 3.
- La ricarica del sopravvissuto parte da 0: l'abilità è pronta dal primo turno [ASSUMPTION].
- Famiglie implementate: solo quelle usate dal set di prova (14 di creature/eventi, 3 di strutture, 6 di sopravvissuti).

## History
- 2026-11-20: implemented in M1 (motore, IA, test, simulatore).
