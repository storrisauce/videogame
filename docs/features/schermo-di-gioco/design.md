# Schermo di gioco

**Status:** implemented · **Updated:** 2026-11-20 · [GDD](../../GDD.md) · [Implementation](implementation.md) · [Testing](testing.md)

La partita si gioca **solo in orizzontale**, con due pollici, prima su iPhone e poi su Android (D-006). Tutto il tavolo sta in uno schermo senza scorrere: l'avversario in alto, tu in basso, i sopravvissuti ai lati, la mano che spunta dal bordo inferiore. Serve il pilastro 2: una partita in una pausa caffè.

## Rules
1. **Layout.**
   - Colonna sinistra: i ritratti dei due sopravvissuti, l'avversario in alto e tu in basso, ciascuno con la Pazienza; il tuo ritratto è anche il pulsante dell'abilità.
   - Centro: la fila dei 4 recinti avversari in alto e la fila dei tuoi 4 in basso. In ogni recinto la creatura sta verso il centro del tavolo e la struttura, più piccola, dietro di lei.
   - Colonna destra: il contatore del Caos, il pulsante "Fine turno", il mazzo e il Letamaio (con il numero di carte).
   - Bordo inferiore: la mano a ventaglio, che spunta per metà. Toccandola sale tutta.
2. **Giocare una carta:** trascina dalla mano a un recinto. I recinti validi si illuminano del colore della banda; quelli non validi si scuriscono. Se lasci la carta fuori da un recinto valido, torna in mano.
3. **Scuotere:** tocca una tua creatura. Compare il pulsante "Scuoti (costo)". Se l'effetto chiede un bersaglio, i bersagli validi pulsano.
4. **Vedere una carta:** tieni premuto su qualsiasi carta, in mano o in campo, per vederla ingrandita con il testo intero. Rilasci per chiudere.
5. **Mirino Geiger:** il quadrante appare grande al centro, sopra il tavolo. Si tocca in un punto qualsiasi dello schermo.
6. **Pausa:** pulsante in alto a destra. Su Android anche il tasto indietro.
7. **Feedback:** vibrazione leggera quando posi una carta, forte con la Botta Atomica. Numeri di danno che saltano fuori. Versi esagerati. Scuotimento dello schermo con la Botta Atomica.

## Numbers
| Name | Value | Unit | What to watch in playtests |
|---|---|---|---|
| Orientamento | solo orizzontale, entrambi i versi | | |
| Schermo di riferimento | 852 × 393 (iPhone 15/16) | pt | |
| Schermo minimo | 667 × 375 (iPhone SE) | pt | testi tagliati, carte sovrapposte |
| Colonne laterali | circa 90 ciascuna [ASSUMPTION] | pt | |
| Larghezza di un recinto | circa 135 [ASSUMPTION] | pt | creatura e struttura leggibili insieme? |
| Creatura in campo | circa 80 × 108 [ASSUMPTION] | pt | si legge ATK/DEF a colpo d'occhio? |
| Struttura in campo | circa 48 × 64 [ASSUMPTION] | pt | |
| Mano a riposo | sporge per 56 [ASSUMPTION] | pt | copre i tuoi recinti? |
| Area minima di tocco | 44 × 44 | pt | tocchi sbagliati |
| Testo minimo | 13 [ASSUMPTION] | pt | |

## Edge cases
- Margini sicuri: in orizzontale la Dynamic Island sta su un lato e l'indicatore Home in basso. Niente comandi sotto la Dynamic Island, e la mano resta sopra l'indicatore Home.
- Telefono girato dall'altro verso: lo schermo si capovolge, il layout resta uguale.
- Notifica o chiamata durante il mirino: la partita va in pausa e il mirino riparte da capo.
- Su Android con schermi più larghi (fino a 21:9) lo spazio in più va ai recinti, non alle colonne laterali.
- iPad: non previsto al lancio [ASSUMPTION].

## Open questions
- [ASSUMPTION] Misure di colonne, recinti, carte e testo; da provare su iPhone SE in M2.
- Serve un tutorial guidato alla prima partita, o bastano suggerimenti in sovrimpressione?

## History
- 2026-11-20: designed in verticale.
- 2026-11-20: passato a solo orizzontale (D-006).
- 2026-11-20: implemented con grafica provvisoria; carte giocate a tocco invece che a trascinamento (D-010).
