# Schermo di gioco: testing

**Updated:** 2026-11-20 · [Design](design.md) · [Implementation](implementation.md)

Comando: `godot --headless --path game --script res://tests/test_ui.gd` (esce con 1 se un controllo fallisce).

## Acceptance criteria
- [x] Dal menu si apre una partita che arriva alla fine con un vincitore e il pannello di fine partita; la rivincita apre una nuova partita (3 partite, giocate dall'IA per entrambi). *(`game/tests/test_ui.gd` › _test_full_game_through_ui)*
- [x] A 852×393, 667×375 e 932×430 nessun elemento esce dallo schermo, i recinti sono almeno 100×90 e "Fine turno" è alto almeno 44. *(› _test_layout)*
- [ ] Margini sicuri reali su iPhone (Dynamic Island, indicatore Home) — da provare sul telefono.
- [ ] Un tester finisce una partita senza spiegazioni — playtest in M2.
