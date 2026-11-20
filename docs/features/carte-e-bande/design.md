# Carte e bande

**Status:** designed · **Updated:** 2026-11-20 · [GDD](../../GDD.md)

Le carte sono il cuore comico e strategico del gioco. Ogni banda ha una zona della fattoria, un colore, uno stile di gioco e un umorismo suo. Ogni carta nasce dal suo effetto: si sceglie l'effetto, poi un nome, un'immagine e una battuta che lo "spieghino" (pilastro 1). Carte, numeri ed eroi sono originali (D-001). Gli effetti si scelgono dalle famiglie del genere elencate nel [catalogo](../../catalogo-abilita-card-wars.md), con le stesse regole, tradotte nel tema (D-007).

## Rules
1. **Formato di una carta:** nome (max 4 parole, italiano), banda, tipo (creatura / struttura / evento), rarità (comune, rara, epica, leggendaria), costo in Caos, ATK e DEF (solo creature), effetto, costo di Scuotere (solo creature), battuta di una riga, illustrazione.
2. **Livello:** ogni copia ha un livello. ATK, DEF e valori dell'effetto = base × livello, come nel genere (D-005). Il livello si decide quando trovi la carta.
3. **Mazzo:** da 30 a 40 carte più 4 zone; massimo 3 copie di una carta [ASSUMPTION]. Il massimo sale col livello del sopravvissuto: 30 al livello 1, +2 ogni 2 livelli [ASSUMPTION].
4. **Dati sul server:** tutte le statistiche stanno in una tabella Supabase, scaricata all'avvio e salvata sul telefono (D-004). Il bilanciamento si cambia senza aggiornare l'app.
5. **Test finale di ogni carta:** effetto di una famiglia valida, il nome fa sorridere da solo, nome e immagine spiegano l'effetto, qualcuno al tavolo la citerebbe. Se una risposta è no, si riscrive.

## Le bande

| Zona | Banda | Stile di gioco | Famiglie di effetti principali |
|---|---|---|---|
| Porcile Radioattivo | Maiali Corazzati | Lenti e duri: tanta DEF, assorbono danni | +DEF, riduzione danni, cure a sé |
| Pollaio Bombardato | Galline del Fronte | Aggressive e paranoiche: colpiscono la Pazienza | +ATK, danno diretto alla Pazienza, danno a tutti |
| Stagno delle Anatre Predone | Anatre Predone | Rubano e disturbano | −ATK all'avversario, rimanda in mano, scarta, blocca Scuotere |
| Campo delle Patate Urlanti | Patate Urlanti | Radicate: crescono e si curano a vicenda | cure alle adiacenti, +DEF in base alle zone, strutture curative |
| Discarica dei Recuperatori | Recuperatori | Economia: pescano, recuperano, costruiscono | pesca, Caos bonus, recupero dal Letamaio, strutture |
| Cratere della Centrale | (nessuna) | Carte jolly, giocabili in ogni zona | effetti strani e trasformazioni |

## I sopravvissuti (rosa di lancio)

| Sopravvissuto | Abilità | Ricarica [ASSUMPTION] |
|---|---|---|
| La Nonna col Fucile | **"Fuori dal mio orto!"**: 3 danni a una creatura avversaria | 3 turni |
| Contadino Gianni in Mutande | **"Oggi è lunedì?"**: +2 Caos questo turno | 3 turni |
| Il Trattore Senziente | **"Ordinanza del sindaco"**: +2 DEF a tutte le tue creature | 4 turni |
| Il Veterinario Terrorizzato | **"Stai fermo, ti prego"**: cura 6 a tutte le tue creature | 2 turni |
| Il Cane da Pastore che Ha Visto Troppo | **"Raduno."**: le creature di una banda costano 2 in meno questo turno | 2 turni |
| Lo Speaker della Radio | **"Notizia dell'ultima ora"**: peschi 2 carte | 3 turni |

## Esempi di carte (calibro)

| Carta | Banda · tipo | Costo | ATK/DEF | Effetto (Scuotere: costo) | Battuta |
|---|---|---|---|---|---|
| Scrofa Carrarmato | Porcile · creatura | 4 | 3/10 | Scuoti (1): +3 DEF a sé | "Ha mangiato un trattore. Il trattore era d'accordo." |
| Maiale in Lamiera | Porcile · creatura | 2 | 1/6 | Scuoti (1): +2 DEF alle creature adiacenti | "Rumoroso quando cammina. Anche da fermo." |
| Pulcino Mitragliere | Pollaio · creatura | 2 | 3/2 | Scuoti (1): 2 danni alla Pazienza avversaria | "Pio. Ratatatà. Pio." |
| Gallina Uova-Bomba | Pollaio · creatura | 3 | 2/4 | Scuoti (2): 2 danni a tutte le creature avversarie | "Non chiederle la frittata." |
| Anatra col Coltello | Stagno · creatura | 3 | 4/3 | Scuoti (1): −2 ATK alla creatura di fronte | "Qua. Dammi le scatolette. Qua." |
| Oca Esattrice | Stagno · creatura | 4 | 3/5 | Scuoti (2): rimanda in mano la creatura di fronte | "Le tasse si pagano anche dopo la fine del mondo." |
| Patata Depressa | Patate · creatura | 1 | 1/4 | Scuoti (1): cura 2 alle creature adiacenti | "Sta male lei, così stanno bene gli altri." |
| Carota Urlatrice | Patate · creatura | 3 | 2/6 | Scuoti (1): +1 DEF per ogni tua zona Patate | "Più ne pianti, più urlano." |
| Procione con lo Scolapasta | Discarica · creatura | 2 | 2/4 | Scuoti (1): peschi 1 carta | "Ha trovato un elmo. E una lasagna del '93." |
| Capra Baratto | Discarica · creatura | 3 | 2/5 | Scuoti (0): sacrifica una tua struttura, +3 Caos | "Ti do questa sedia per mezza scatoletta." |
| Rana a Due Teste | Cratere · creatura | 3 | 3/3 | Scuoti (2): scambia ATK e DEF di una creatura | "Le due teste non si parlano." |
| Nano da Giardino Sacro | Cratere · struttura | 2 | — | La creatura davanti ha +2 ATK | "Pregatelo. Lui vi guarda. Sempre." |
| Silos Instabile | Pollaio · struttura | 3 | — | Quando la creatura davanti muore, 3 danni alla Pazienza avversaria | "Vietato fumare. Vietato respirare forte." |
| Fienile Fumante | Patate · struttura | 2 | — | A inizio turno cura 2 alla creatura davanti | "Il fumo fa bene. Dice il fienile." |
| "Pioggia Acida" | Cratere · evento | 3 | — | 3 danni a tutte le creature | "Prendete l'ombrello. Anzi, no." |
| "Hai Preso Tu l'Apriscatole?" | Discarica · evento | 1 | — | Peschi 2 carte | "Giorno 112. Nessuno l'ha preso." |
| "Razionamento" | Stagno · evento | 2 | — | L'avversario ha −2 Caos nel prossimo turno | "Una fava a testa. Mezza per la capra." |

## Numbers
| Name | Value | Unit | What to watch in playtests |
|---|---|---|---|
| Carte al lancio | ~90: 15 per banda + 15 del Cratere [ASSUMPTION] | carte | varietà percepita |
| Composizione per banda | 10 creature, 3 strutture, 2 eventi [ASSUMPTION] | carte | |
| Budget statistiche | ATK + DEF ≈ 3 × costo + 1, meno 1–2 punti se l'effetto è forte [ASSUMPTION] | punti | carte sempre prese / mai prese |
| Rarità al lancio | 50% comuni, 30% rare, 15% epiche, 5% leggendarie [ASSUMPTION] | | |

## Open questions
- [ASSUMPTION] Abbinamento banda→stile, ciclo dei vantaggi (in [partita](../partita/design.md)), budget statistiche.
- [ASSUMPTION] Rosa dei 6 sopravvissuti e relative abilità.
- 6 sopravvissuti al lancio, espandibili (D-009); le abilità si scelgono tra le famiglie delle abilità degli eroi del genere.

## History
- 2026-11-20: designed.
- 2026-11-20: abilità legate al catalogo del genere (D-007); rosa di 6 confermata (D-009).
