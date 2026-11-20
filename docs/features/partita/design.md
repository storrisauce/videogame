# Partita

**Status:** in progress · **Updated:** 2026-11-20 · [GDD](../../GDD.md) · [Implementation](implementation.md) · [Testing](testing.md)

Due sopravvissuti si sfidano con le loro bande su 4 recinti a testa, uno di fronte all'altro. A ogni turno spendi il Caos per giocare carte e scuotere creature, poi le tue creature attaccano il recinto di fronte con il mirino Geiger. Le regole sono quelle del genere a corsie, come le abbiamo studiate ([analisi](../../analisi-meccaniche-card-wars.md)); i numeri sono nostri (D-001, D-005). Serve il pilastro 3: tattica nei recinti, abilità nel mirino.

## Rules
1. **Preparazione.** Una moneta lanciata dal Trattore decide chi inizia. Ogni giocatore mette le 4 zone del suo mazzo sui suoi 4 recinti, nell'ordine che vuole, e pesca 5 carte.
2. **Inizio turno.** Si azzerano gli stati del turno (*protetta*, *inerme*, *già scossa*, *appena giocata*). Scattano gli effetti di inizio turno. Peschi 1 carta: con 7 in mano la pescata va persa.
3. **Caos.** Il Caos del giro parte da `CAOS_INIZIALE` e sale di 1 alla fine di ogni giro, fino a `CAOS_MAX`. A ogni turno hai Caos del giro + Caos bonus dal turno prima. Quello che non spendi si perde.
4. **Giocare una carta.** Una creatura o una struttura va in un recinto se: il recinto non è disabilitato; la banda della carta è quella della zona del recinto (le carte del **Cratere** vanno ovunque); hai Caos ≥ costo − sconti (minimo 0). Un recinto contiene una creatura davanti e una struttura dietro. Se è già occupato, la nuova carta sostituisce la vecchia, che va nel Letamaio.
5. **Eventi.** Effetto immediato, poi la carta va nel Letamaio.
6. **Scuotere.** Una creatura in campo può usare la sua abilità **una volta per turno**, pagando il suo costo in Caos, se non è bloccata e se l'effetto ha un bersaglio valido. Le modifiche di ATK e DEF restano finché la creatura è in campo.
7. **Abilità del sopravvissuto.** Gratuita. Dopo l'uso ha una ricarica di N turni, che scende di 1 a ogni fine turno.
8. **Combattimento.** Dopo la preparazione, le tue creature attaccano una alla volta, dal recinto 1 al 4. Il primo giocatore salta il combattimento del suo primo turno.
9. **Mirino Geiger.** Per ogni tuo attacco, la lancetta gira su un quadrante con una zona **verde** (colpo) e una **rossa** (Botta Atomica), subito dopo la verde, in posizione casuale. Tocchi per fermarla. Fuori dalle zone, o allo scadere del tempo, è un "colpo normale". Contro un recinto vuoto tutto il quadrante tranne il rosso è verde. Nel turno dell'avversario il quadrante compare ("tocca per parare") ma il risultato non cambia il danno (D-005).
10. **Danno a una creatura.** `danno = ATK + ATK × vantaggio[banda attaccante][banda difensore]`, minimo 0; × `MOLT_BOTTA` con Botta Atomica nel tuo turno; poi − riduzione danni del difensore × suo fattore danni. La creatura muore quando i danni arrivano alla sua DEF. Chi attacca non subisce danni.
11. **Danno alla Pazienza.** Se di fronte non c'è una creatura, o è *inerme*, il danno va al sopravvissuto: ATK − penalità ATK, × `MOLT_BOTTA` con Botta Atomica.
12. **Mazzo finito.** Se a inizio turno il tuo mazzo è vuoto, perdi Pazienza pari al livello del tuo sopravvissuto, a ogni turno.
13. **Fine.** Perde chi arriva a 0 Pazienza. Una volta per partita puoi rialzarti pagando 1 scatoletta di tonno: Pazienza al massimo, la mano e il Letamaio tornano nel mazzo, peschi 5 carte.

## Numbers
| Name | Value | Unit | What to watch in playtests |
|---|---|---|---|
| Recinti per giocatore | 4 | | |
| Carte iniziali / mano massima | 5 / 7 | carte | |
| `CAOS_INIZIALE` | 2 [ASSUMPTION] | Caos | primo turno troppo vuoto? |
| `CAOS_MAX` | 8 [ASSUMPTION] | Caos | partite che si trascinano dopo il turno 8 |
| Pazienza del sopravvissuto | 25 + 5 × livello [ASSUMPTION] | | durata media della partita (obiettivo 4–6 min) |
| Ampiezza verde / rossa | 0,25 / 0,08 [ASSUMPTION] | frazione di giro | % di Botte Atomiche (obiettivo 20–30%) |
| Tempo per un giro di lancetta | 1,2–1,6 [ASSUMPTION] | s | |
| Giri prima che scada | 3 [ASSUMPTION] | giri | |
| `MOLT_BOTTA` | 1,5 [ASSUMPTION] | × | |
| Vantaggio fra bande | +0,25 contro la banda seguente nel ciclo, −0,25 contro la precedente, 0 con le altre [ASSUMPTION] | | una banda dominante |
| Ciclo dei vantaggi | Porcile → Patate → Stagno → Pollaio → Discarica → Porcile [ASSUMPTION] | | |

## Edge cases
- App chiusa a metà partita: la partita contro l'IA si riprende dall'inizio del turno in corso.
- Mirino in "automatico": dà sempre colpo verde, mai Botta Atomica.
- Due effetti di inizio turno insieme: si risolvono dal recinto 1 al 4, prima i tuoi.
- Un attaccante con ATK 0 non attacca e il mirino non compare.
- Nessuna mossa legale: il turno passa da solo alla fase di combattimento.

## Open questions
- [ASSUMPTION] Tutti i numeri sopra; da tarare con simulazioni IA contro IA in M1.
- Proposte di miglioramento escluse per ora (D-005): dare effetto alla parata, togliere la regola del primo turno senza attacco, rendere uguale per l'IA la regola del mazzo finito.

- **Prime simulazioni (2000 partite IA contro IA, set di prova):** circa 16 turni totali (8 a testa); chi inizia vince il **64%**; la Nonna vince il 65%, Veterinario e Cane il 41%; Discarica la banda più debole (44%). La Botta Atomica al 25% accorcia di poco le partite. Da tarare: vantaggio di chi inizia, abilità dei sopravvissuti, carte della Discarica.

## History
- 2026-11-20: designed.
- 2026-11-20: in progress, motore M1 in `game/core/`.
