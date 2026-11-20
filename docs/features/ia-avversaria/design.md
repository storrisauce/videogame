# IA avversaria

**Status:** implemented · **Updated:** 2026-11-20 · [GDD](../../GDD.md)

L'avversario è l'IA del genere, studiata nell'[analisi](../../analisi-meccaniche-card-wars.md) (§11): a ogni azione prova tutte le mosse legali su una copia della partita, dà un punteggio al tavolo e gioca la migliore; passa quando nessuna mossa è almeno pari. Serve il pilastro 2: partite veloci, avversario leggibile. Codice: `game/core/greedy_ai.gd`.

## Rules
1. Punteggio di un lato = somma dei 4 recinti + Pazienza al sicuro + Caos × 1 + carte in mano × 3. Valore = punteggio IA − punteggio avversario.
2. Recinto con una sua creatura: ATK + Vita se nessuno davanti, altrimenti ATK + max(0, Vita − ATK del nemico). Recinto vuoto con un nemico davanti: −ATK del nemico.
3. Pazienza al sicuro = max(0, Pazienza − ATK delle creature nemiche senza nessuno davanti).
4. Gioca solo in recinti vuoti, non sostituisce mai (D-005). Non fa il mirino: i suoi attacchi sono sempre "colpo".
5. A mazzo finito rimescola mano e Letamaio e ripesca 5 (D-005).

## Numbers
| Name | Value | Unit | What to watch in playtests |
|---|---|---|---|
| Peso del Caos | 1 | punti | |
| Peso di una carta in mano | 3 | punti | l'IA tiene troppe carte? |
| Azioni massime per turno | 30 | azioni | |

## Open questions
- Proposte escluse per ora (D-005): previsione a due mosse, sostituzione delle creature, livelli di difficoltà.

## History
- 2026-11-20: implemented (M1).
