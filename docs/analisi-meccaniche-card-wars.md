# Analisi delle meccaniche dell'APK "Card Wars"

Fonte: codice C# (Unity, compilazione Mono) estratto da `Assembly-CSharp.dll` nell'APK.
Le tabelle dei dati (statistiche delle carte, costi, matrice dei vantaggi, ricompense) **non sono nell'APK**:
il gioco le scarica dal server (`db_Creatures.json`, `db_Spells.json`, `db_RPS.json`, `db_Parameters.json`...).
Quindi qui ci sono le **regole** e le **formule**, non i numeri delle singole carte.

I termini originali sono tra parentesi solo come riferimento: per un gioco nostro vanno cambiati nomi, tema e grafica.

---

## 1. Il tavolo

| Elemento | Valore (dal codice) |
|---|---|
| Giocatori | 2 (tu contro IA o contro un altro giocatore) |
| Corsie per giocatore | **4**, una di fronte all'altra |
| Tipi di terreno | **5** (Corn, Plains, Swamp, Cotton, Sand) |
| Carte pescate all'inizio | **5** |
| Mano massima | **7** carte (oltre non peschi) |
| Oggetti per corsia | **2**: una creatura + un edificio |
| Mazzi salvabili | 5 |

Ogni corsia ha: un terreno, un indice, le corsie adiacenti, la corsia avversaria di fronte,
e degli stati speciali (disabilitata, abilità bloccate, costo delle abilità modificato, "cancello di rarità" che vieta carte troppo rare).

## 2. Tipi di carta

- **Creatura**: ha ATK (attacco) e DEF (difesa = punti vita), un costo, una fazione, una rarità e spesso un'**abilità attivabile** (Floop) con un suo costo.
- **Edificio**: si mette dietro la creatura nella corsia e dà effetti passivi o a evento (quando una creatura entra, muore, vince, viene attivata...).
- **Incantesimo**: effetto immediato, poi va negli scarti.
- **Leader / Eroe**: non è nel mazzo. Ha i punti vita del giocatore, un'abilità con tempo di ricarica e parametri propri per il minigioco di combattimento.
- (Esiste anche un tipo "Dweeb" usato per lo stato di sconfitta, con la proposta di resuscitare pagando gemme.)

**Fazioni** = i 5 terreni + "Universale".

## 3. Struttura della partita

1. **Chi inizia**: una freccia gira a caso (fasi `ArrowSpinStart/End`).
2. **Terreni**: ogni giocatore dispone i 4 terreni del proprio mazzo sulle 4 corsie (il mazzo contiene sia le carte che i terreni).
3. **Turni**, ognuno diviso in:
   - **Inizio turno**: si azzerano i contatori del turno; le carte in campo perdono gli stati temporanei (protetta, inerme, già attivata, appena evocata); si attivano gli effetti di inizio turno e quelli persistenti dell'avversario; **peschi 1 carta**.
   - **Preparazione** (Setup): giochi carte e usi abilità spendendo **punti azione**. Se non hai punti o mosse legali si passa oltre (con un avviso se ti restano mosse).
   - **Combattimento** (Battle): ogni tua creatura attacca la corsia di fronte, una corsia alla volta, con il minigioco a tempo.
   - **Il primo giocatore salta il combattimento nel suo primo turno.**
4. Si alternano finché un leader arriva a 0 punti vita.

## 4. Punti azione (Magic Points)

- Si parte da `Starting_Magic_Points` (valore dal server).
- Alla fine di ogni giro completo i punti azione **aumentano di 1**, fino a `Max_Magic_Points`.
- I punti del turno = valore del giro + punti bonus (dati da carte o abilità), poi i bonus si azzerano.
- Costanti del codice: valore di un punto azione = 1, valore di una carta = 3 (usato dall'IA per valutare le mosse).

## 5. Regole per giocare una carta

Una carta si può giocare in una corsia solo se:
1. in questo momento ti è permesso giocare quel tipo di carta (alcuni effetti bloccano creature, edifici o incantesimi);
2. per creature ed edifici: la corsia non è disabilitata e la rarità della carta non supera il "cancello di rarità" della corsia;
3. **la fazione della carta corrisponde al terreno della corsia** (le carte Universali vanno ovunque);
4. hai abbastanza punti azione: **costo = costo base − sconti attivi** (minimo 0).

Se la corsia ha già una creatura (o un edificio) puoi **sostituirla** con la nuova carta.

## 6. Abilità attivabili (Floop)

- **Costo** = costo base dell'abilità + modificatore del giocatore + modificatore della corsia. Alcuni effetti impongono un costo fisso. Minimo 0.
- Di solito una volta per turno (stato `Flooped`). Si azzera a inizio turno.
- Una creatura può essere "bloccata" e non poter usare l'abilità.
- Gli edifici possono reagire quando una creatura usa l'abilità (es. +ATK o +DEF a ogni attivazione).

## 7. Combattimento

### Il minigioco a tempo (anello)
- Un indicatore gira su un anello. Tocchi lo schermo per fermarlo.
- Sull'anello ci sono una **zona colpo** e una **zona critico**, posizionate a caso a ogni attacco.
- Risultato: **Critico** (dentro la zona critico), **Colpo** (dentro la zona colpo), **Mancato** (fuori, o se il tempo scade).
- La dimensione delle zone dipende da: leader (valori diversi per attacco e difesa), modificatori della missione e carte che allargano le zone.
- La velocità di rotazione è casuale fra un minimo e un massimo del leader, moltiplicata per un fattore della missione.
- Quando attacchi c'è scritto "tocca per attaccare", quando attacca l'avversario "tocca per bloccare": il minigioco serve anche in difesa, con zone di difesa proprie.
- Se la corsia avversaria è vuota, la zona colpo si allarga.

### Formula del danno a una creatura
```
danno = ATK + ATK × Fattore[fazione attaccante][fazione difensore]   (minimo 0)
se Critico e stai attaccando tu:  danno = danno × moltiplicatore critico del leader
danno ricevuto = (danno − riduzione danni) × fattore danni del difensore   (minimo 0)
```
- C'è quindi una **matrice di vantaggi fra fazioni** stile carta-forbice-sasso (tabella `db_RPS.json`, sul server).
- La creatura muore quando i danni accumulati raggiungono la DEF.
- Se l'attaccante vince e nella sua corsia c'è un edificio, scatta l'effetto "alla vittoria" dell'edificio.

### Danno diretto al leader
- Se di fronte **non c'è una creatura** (o è "inerme"), l'attaccante colpisce il leader avversario: **danno = ATK − penalità ATK attive**.
- Anche qui un Critico moltiplica il danno.
- Una creatura "protetta" non viene colpita, e una che "non può attaccare" salta il turno.

### Statistiche effettive di una creatura
```
ATK = (ATK base + modificatori) × fattore ATK      (minimo 0)
DEF = (DEF base + modificatori) × fattore DEF
Vita = DEF − danni subiti                          (minimo 0)
```

## 8. Leader

- **Punti vita = PV base + 5 × livello** (`HP_PER_LEVEL = 5`).
- Esperienza e livello. Il livello aumenta anche la **dimensione massima del mazzo**.
- Abilità speciale con **tempo di ricarica** in turni (es. ridurre costi, pescare, curare, bonus a una fazione).
- Parametri propri del minigioco: zone colpo/critico in attacco e difesa, velocità, moltiplicatore critico.

## 9. Fine del mazzo

Se il mazzo è vuoto a inizio turno appare un avviso e il leader **perde punti vita** (sembra pari al livello del leader), poi il mazzo viene **rimescolato**.

## 10. Vittoria e sconfitta

- Vince chi porta a 0 i punti vita del leader avversario.
- Se perdi puoi **resuscitare pagando gemme** e continuare.
- Ricompense: esperienza e monete (casuali fra un minimo e un massimo della missione), carte da forzieri con probabilità a pesi.

## 11. Catalogo delle abilità (239 tipi di effetto)

**Creature (140)**, le famiglie principali:
- Bonus ATK/DEF: a sé, alle adiacenti, a tutte, alla stessa fazione, in base a terreni, carte in mano, corsie vuote o numero di attivazioni.
- Malus all'avversario: −ATK o −DEF al bersaglio, a tutti, alla fazione; scambia o pareggia gli ATK.
- Danno: al bersaglio, all'avversario di fronte, alle adiacenti, a tutti, al leader; in base a scarti, terreni diversi, rarità.
- Cure: a sé, adiacenti, bersaglio, tutti, leader.
- Controllo: proteggi, rendi inerme, blocca abilità o evocazioni, rimanda in mano, resetta.
- Economia: pesca carte, guadagna punti azione, sacrifica per punti, riprendi dagli scarti, rimescola la mano.
- Modifica dell'anello: allarga zona colpo, critico o difesa.

**Edifici (26)**: bonus ATK/DEF continui, danno o cura quando una creatura entra o muore, cura a inizio turno, riduzione o moltiplicazione dei danni, abilità più economiche, cancello di rarità, rimanda in mano sacrificando.

**Incantesimi (73)**: attacca una creatura (anche solo di una certa fazione), distruggi edifici, distruggi in base alla rarità, disabilita una corsia, blocca un tipo di carta all'avversario, trasforma (Polymorph), danno doppio, ruba vita, scambia ATK/DEF, sposta edifici, riduci costi, rimanda in mano, scarta, pesca.

## 12. Intelligenza artificiale

L'IA valuta ogni carta in mano su ogni corsia e ogni abilità disponibile, dà un punteggio al tavolo risultante
(ATK, DEF e corsie vuote, con pesi `WEIGHT_SCALE` e `DEF_FACTOR`) e sceglie la mossa migliore.
Ha funzioni per scegliere il bersaglio migliore da attaccare, curare, indebolire, sacrificare.

## 13. Meta-gioco (fuori dalla partita)

- **Collezione e mazzi**: inventario con limite, carte minime e massimo di copie per mazzo, dimensione massima legata al livello del leader, minimo di creature.
- **Fusione**: ricette che combinano carte in carte nuove.
- **Forzieri a pesi** (gacha): normale, oro, ossidiana, eventi; con chiavi.
- **Mappa delle missioni** a regioni: ogni missione costa stamina, ha un mazzo avversario, condizioni per le stelle (turni, PV persi, fazioni usate, abilità usate...) e drop.
- **Stamina** che si ricarica col tempo.
- **Missioni secondarie ed eventi a tempo**, dungeon a rotazione, tornei.
- **Regali giornalieri** e calendario di accesso.
- **Multigiocatore** con trofei, serie di vittorie e classifica.
- Valute: monete e gemme.

---

## Cosa manca e come recuperarlo

- **Numeri delle carte** (ATK, DEF, costi), **matrice delle fazioni**, parametri globali: sono sul server, non nell'APK.
- **Effetto preciso della difesa nel minigioco**: il codice prevede zone di difesa, ma non sono riuscito a ricostruire esattamente come riducono il danno.
