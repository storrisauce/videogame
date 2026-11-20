# Partita: testing

**Updated:** 2026-11-20 · [Design](design.md) · [Implementation](implementation.md)

Comando: `godot --headless --path game --script res://tests/test_runner.gd` (esce con 1 se un controllo fallisce; verificato rompendo un test apposta).

## Acceptance criteria
- [x] Vantaggio fra bande: +0,25 contro la seguente nel ciclo, −0,25 contro la precedente, 0 altrimenti. *(`game/tests/test_runner.gd` › test_advantage_cycle)*
- [x] Caos parte da 2 per entrambi, sale di 1 a giro allo stesso ritmo, si ferma a 8. *(› test_caos_growth)*
- [x] Una carta si gioca solo con Caos sufficiente, nella zona della sua banda (Cratere ovunque), non in recinti disabilitati. *(› test_play_rules)*
- [x] La sostituzione manda la vecchia carta nel Letamaio; l'IA non sostituisce. *(› test_replace)*
- [x] Danno = ATK ± vantaggio, troncato; Botta Atomica × 1,5. *(› test_combat_advantage, test_botta_atomica)*
- [x] Recinto vuoto o creatura inerme: il danno va alla Pazienza, meno la penalità ATK. *(› test_hero_damage)*
- [x] Il primo giocatore non attacca al suo primo turno. *(› test_first_turn_no_combat)*
- [x] Morte nel Letamaio ed effetto "alla morte" della struttura. *(› test_death_and_on_death)*
- [x] Scuotere una volta per turno, a pagamento; i bonus restano. *(› test_scuoti)*
- [x] Aura della struttura su ATK. *(› test_structure_aura)*
- [x] Mazzo finito: l'umano perde Pazienza pari al livello a ogni turno; l'IA rimescola. *(› test_empty_deck)*
- [x] Il livello moltiplica ATK, DEF e valori d'effetto. *(› test_level_scaling)*
- [x] Mano massima 7: la pescata in più va persa. *(› test_hand_limit)*
- [x] Abilità del sopravvissuto con ricarica. *(› test_hero_cooldown)*
- [x] Una partita IA contro IA finisce con un vincitore prima del limite di turni. *(› test_full_game)*
- [x] Rialzarsi una volta per partita: Pazienza al massimo, mano e Letamaio nel mazzo, ripesca 5, le carte in campo restano. *(› test_resurrect)*
