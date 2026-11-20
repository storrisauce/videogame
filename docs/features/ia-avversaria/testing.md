# IA avversaria: testing

**Updated:** 2026-11-20 · [Design](design.md) · [Implementation](implementation.md)

## Acceptance criteria
- [x] Una partita IA contro IA finisce con un vincitore. *(`game/tests/test_runner.gd` › test_full_game)*
- [x] Dall'interfaccia, 3 partite giocate dall'IA per entrambi arrivano alla fine. *(`game/tests/test_ui.gd` › _test_full_game_through_ui)*
- [ ] Il punteggio del tavolo (regole 1–3) — nessun test diretto delle formule.
- [x] Non sostituisce le creature. *(`game/tests/test_runner.gd` › test_replace, per la regola di `Match`)*
