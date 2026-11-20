# Schermo di gioco

**Status:** designed · **Updated:** 2026-11-20 · [GDD](../../GDD.md)

La partita si gioca in verticale con una mano, su iPhone (D-003). Tutto il tavolo sta in uno schermo senza scorrere: in alto l'avversario, in basso tu, la mano sotto il pollice. Serve il pilastro 2: una partita in una pausa caffè.

## Rules
1. **Layout dall'alto in basso:** barra avversario (ritratto, Pazienza, Caos, carte in mano) → 4 recinti avversari (struttura dietro, creatura verso il centro) → linea centrale (contatore Caos, pulsante "Fine turno", ricarica del sopravvissuto) → i tuoi 4 recinti (creatura verso il centro, struttura dietro) → la tua barra (ritratto con abilità, Pazienza) → la mano a ventaglio.
2. **Giocare una carta:** trascina dalla mano a un recinto. I recinti validi si illuminano del colore della banda; quelli non validi si scuriscono. Se lasci la carta fuori da un recinto valido, torna in mano.
3. **Scuotere:** tocca una tua creatura. Compare il pulsante "Scuoti (costo)". Se l'effetto chiede un bersaglio, i bersagli validi pulsano.
4. **Vedere una carta:** tieni premuto su qualsiasi carta, in mano o in campo, per vederla ingrandita con il testo intero. Rilasci per chiudere.
5. **Mirino Geiger:** il quadrante appare grande al centro, sopra il tavolo. Si tocca in un punto qualsiasi dello schermo.
6. **Abilità del sopravvissuto:** tocca il tuo ritratto quando la ricarica è a zero.
7. **Pausa:** pulsante in alto a destra. Su Android anche il tasto indietro.
8. **Feedback:** vibrazione leggera quando posi una carta, forte con la Botta Atomica. Numeri di danno che saltano fuori. Versi esagerati. Scuotimento dello schermo con la Botta Atomica.

## Numbers
| Name | Value | Unit | What to watch in playtests |
|---|---|---|---|
| Schermo di riferimento | 393 × 852 (iPhone 15/16) | pt | |
| Schermo minimo | 375 × 667 (iPhone SE) | pt | testi tagliati, carte sovrapposte |
| Carta in campo | circa 84 × 112 [ASSUMPTION] | pt | si legge ATK/DEF a colpo d'occhio? |
| Area minima di tocco | 44 × 44 | pt | tocchi sbagliati |
| Testo minimo | 13 [ASSUMPTION] | pt | |
| Carte in mano visibili senza sovrapposizione | 5, oltre si sovrappongono a ventaglio [ASSUMPTION] | carte | |

## Edge cases
- Margini sicuri: niente comandi sotto la Dynamic Island in alto né sopra l'indicatore Home in basso.
- Notifica o chiamata durante il mirino: la partita va in pausa e il mirino riparte da capo.
- Telefono girato in orizzontale: lo schermo resta verticale.
- Su Android con schermi più lunghi (fino a 21:9) lo spazio in più va al tavolo, non ai comandi.

## Open questions
- [ASSUMPTION] Misure delle carte e del testo; da provare su iPhone SE in M2.
- Serve un tutorial guidato alla prima partita, o bastano suggerimenti in sovrimpressione?

## History
- 2026-11-20: designed.
