# Schermo di gioco

**Status:** implemented · **Updated:** 2026-11-20 · [GDD](../../GDD.md) · [Implementation](implementation.md) · [Testing](testing.md)

La partita si gioca **solo in orizzontale**, con due pollici, prima su iPhone e poi su Android (D-006). Tutto il tavolo sta in uno schermo senza scorrere: l'avversario in alto, tu in basso, i sopravvissuti ai lati, la mano che spunta dal bordo inferiore. Serve il pilastro 2: una partita in una pausa caffè.

## Rules
1. **Layout.**
   - Disposizione "da console" (D-014): a sinistra una consolle di legno con il **tuo** sopravvissuto (ritratto animato, Pazienza, abilità), mazzo e Letamaio, e in basso il contatore del **Caos** e il Menu; a destra la consolle dell'**avversario** (ritratto, Pazienza, mano, mazzo, Caos) e in basso il grande pulsante **Fine turno**.
   - Centro: il tavolo è un altopiano di fattoria visto dall'alto (siepe in fondo, scogliera davanti, steccati tra i recinti). In fondo la fila dei 4 recinti avversari, poi un sentiero di terra, poi la fila dei tuoi 4. Ogni recinto mostra il terreno della sua banda; la creatura sta in piedi con **ATK** (tondo rosso) e **Vita** (barra verde con i numeri) sopra la testa, e la struttura dietro di lei.
   - Bordo inferiore: la mano su un vassoio di legno, carte con lo sprite animato, costo, nome, ATK e Vita.
   - Grafica: pixel art secondo il [design system](../../art/design-system.md). Il tavolo è in **3D vero** (D-015): altopiano inclinato verso di te, figure pixel art in piedi rivolte alla telecamera, steccati, siepe e alberi in 3D; la telecamera si avvicina da sola finché il tavolo riempie lo spazio tra le consolle. Vita, attacco, evidenziazioni e tocchi sono un livello 2D sopra (il tocco vale dentro il trapezio del recinto).
   - Scheda della carta: una striscia compatta in alto (nome e numeri, abilità e battuta, azioni a destra), così i recinti restano visibili.
   - Movimento (skill game-feel, animate): la carta vola dalla mano al recinto e la creatura cade con un rimbalzo; all'attacco scatta in avanti, chi è colpito lampeggia e trema, il danno salta fuori come numero (più grande con la Botta Atomica, che fa tremare anche la telecamera); chi muore si schiaccia in una nuvoletta; l'avviso del turno entra con una leggera crescita; i pulsanti si abbassano al tocco. Entrate in ease-out, 150–400 ms. "Meno movimento" nel menu toglie scosse e salti.
   - Menu: titolo e un solo pulsante principale (Gioca) a sinistra, con i tuoi numeri e l'anteprima delle creature del mazzo; a destra il sopravvissuto grande e animato da scorrere con le frecce e le due bande da cambiare con un tocco.
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
| Colonne laterali | 100 ciascuna [ASSUMPTION] | pt | |
| Vassoio della mano | alto 112 [ASSUMPTION] | pt | carte leggibili? |
| Larghezza di un recinto | circa 155 (852) / 115 (667) | pt | creatura e struttura leggibili insieme? |
| Scala degli sprite | ×2 ovunque (1 px del mondo = 2 pt) | | creature piccole leggibili su iPhone SE? |
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
- 2026-11-20: grafica in pixel art (D-013) e disposizione da console con tavolo-altopiano (D-014).
- 2026-11-20: tavolo 3D, animazioni, scheda compatta, menu nuovo (D-015).
