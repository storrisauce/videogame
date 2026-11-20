# Analisi approfondita delle meccaniche dell'APK "Card Wars"

**Fonte:** codice C# dell'APK (Unity, compilazione Mono, `Assembly-CSharp.dll`), letto disassemblando i metodi uno per uno.
**Limite:** le tabelle dei dati (statistiche delle singole carte, costi, matrice delle fazioni, parametri globali, ricompense)
**non sono nell'APK**. Il gioco le scarica dal server all'avvio (`db_Creatures.json`, `db_Spells.json`, `db_RPS.json`,
`db_Parameters.json`, ecc.). Qui ci sono quindi le **regole, le formule e la struttura**, non i numeri delle singole carte.

I nomi originali compaiono tra parentesi o in `codice` solo come riferimento. Per un gioco nostro vanno cambiati nomi, tema e grafica.

Documento collegato: [`catalogo-abilita-card-wars.md`](catalogo-abilita-card-wars.md), con tutte le 239 abilità una per una.

**Legenda della certezza:** ✅ letto direttamente nel codice · ⚠️ dedotto dal codice, con margine d'interpretazione · ❓ dipende da dati del server.

---

## 1. Il tavolo ✅

| Elemento | Valore |
|---|---|
| Giocatori | 2 |
| Corsie per giocatore | **4**, ognuna di fronte a una corsia avversaria |
| Tipi di terreno | **5** (`Corn`, `Plains`, `Swamp`, `Cotton`, `Sand`) |
| Carte pescate all'inizio | **5** |
| Mano massima | **7** (con la mano piena la pescata va persa) |
| Oggetti per corsia | **2**: una creatura davanti e un edificio dietro |
| Mazzi salvabili | 5 |

**Proprietà di ogni corsia:** terreno, indice (0–3), corsie adiacenti, corsia avversaria di fronte, più quattro stati:
- **disabilitata**: non ci si può giocare;
- **abilità bloccate**;
- **modificatore del costo delle abilità**, che vale per le creature in quella corsia;
- **cancello di rarità**: vieta carte più rare di una soglia (lo crea un edificio).

Le corsie esterne (0 e 3) hanno una sola corsia adiacente.

## 2. Le carte ✅

### 2.1 Dati di una carta
Ogni carta ha: ID, nome, tipo, **fazione**, **rarità**, qualità, **costo**, **costo dell'abilità**, ATK base, DEF base,
due parametri d'effetto (`Val1`, `Val2`), prezzo di vendita, possibilità di fusione e il nome dello script che ne implementa l'effetto.

### 2.2 Il livello moltiplica tutto ✅
Ogni copia di una carta ha un **livello**, che **moltiplica linearmente** le statistiche:
```
ATK = livello × ATK base
DEF = livello × DEF base
Val1 = livello × Val1 base       (stessa cosa per Val2)
Prezzo di vendita = livello × prezzo base
```
Una carta di livello 3 ha quindi il triplo di attacco, difesa e potenza dell'effetto.
Il livello **non cresce con l'uso**: viene fissato quando ottieni la carta (dal livello del drop della missione o della ricompensa).

### 2.3 Tipi
- **Creatura**: ATK, DEF e quasi sempre un'abilità attivabile.
- **Edificio**: va dietro la creatura e dà effetti continui o legati a eventi.
- **Incantesimo**: effetto immediato, poi va negli scarti.
- **Leader**: fuori dal mazzo. Ha i punti vita del giocatore e un'abilità con ricarica, implementata come un incantesimo gratuito.
- (Il tipo `Dweeb` corrisponde alla schermata di sconfitta, con l'offerta di resuscitare.)

**Fazioni:** i 5 terreni più `Universal`, che si gioca su qualsiasi terreno.

### 2.4 Il mazzo
Il mazzo contiene le carte **più i terreni** da disporre sulle corsie. Controlli di validità:
- numero minimo di carte (`Min_Cards_In_Deck`) ❓;
- numero massimo di carte = **dipende dal livello del leader** (`DeckMaxSize`) ❓;
- massimo di copie della stessa carta (`Max_Duplicates_In_Deck`) ❓.

## 3. Struttura della partita ✅

```
Freccia che sceglie chi inizia
  → Disposizione dei terreni
  → [Turno del giocatore che inizia] Preparazione → Combattimento
  → [Turno dell'altro]               Preparazione → Combattimento
  → ... finché un leader va a 0 PV
```

### 3.1 Inizio turno
1. Si azzerano i contatori del turno: incantesimi lanciati, creature evocate e rimosse.
2. Ogni carta in campo perde gli stati temporanei: *spostata*, *abilità già usata*, *inerme*, *protetta*, *appena evocata*, *usata*.
3. Scattano gli effetti "a inizio turno" delle tue carte e quelli persistenti dell'avversario.
4. **Peschi 1 carta.** Se il mazzo è vuoto si passa alla fase "carte finite" (§9).

### 3.2 Preparazione
Giochi carte, attivi abilità e usi l'abilità del leader finché hai punti azione.
Se non hai punti, o non hai mosse legali, la fase finisce da sola. Se ti restano mosse e provi a passare, ricevi un avviso.

### 3.3 Combattimento
Le tue creature attaccano **una corsia alla volta, da sinistra a destra** dal punto di vista di chi attacca (§6).
**Nel suo primo turno il giocatore che inizia salta il combattimento.**

### 3.4 Fine turno
- Bonus e sconti del turno si azzerano: punti bonus, sconti sui costi, modifiche al costo delle abilità, costo fisso delle abilità, penalità all'ATK.
- La **ricarica del leader scende di 1**.
- I punti azione crescono (§4).

## 4. Punti azione ✅

```
All'inizio:         punti del giro = Starting_Magic_Points                     ❓
A ogni giro:        punti del giro = min(punti del giro + 1, Max_Magic_Points)  ❓
Punti del turno:    punti del giro + punti bonus guadagnati nel turno prima
```
- Il "giro" cresce quando finisce il turno di chi ha iniziato, quindi entrambi i giocatori salgono allo stesso ritmo.
- I punti **non si accumulano**: a ogni turno vengono reimpostati.
- Alcune abilità danno **punti bonus per il turno successivo** (`AddBonusPoints`), altre punti immediati.

## 5. Giocare carte e abilità ✅

### 5.1 Una carta è giocabile in una corsia se...
1. in questo momento ti è permesso giocare quel tipo di carta (alcuni incantesimi bloccano all'avversario creature, edifici o incantesimi);
2. *(creature ed edifici)* la corsia **non è disabilitata** e la **rarità** della carta non supera il cancello di rarità della corsia;
3. la **fazione** della carta è uguale al **terreno** della corsia, oppure la carta è Universale;
4. **punti azione ≥ costo**, dove `costo = max(0, costo base − sconti)`.

Se la corsia è già occupata puoi **sostituire** la carta: la vecchia va negli scarti.

### 5.2 Abilità attivabili delle creature
Si possono attivare se:
- non sono già state usate in questo turno (una volta per turno);
- non sono disabilitate né bloccate da un effetto avversario;
- hai abbastanza punti azione;
- la condizione specifica dell'abilità è soddisfatta (per esempio esiste un bersaglio valido, o c'è una creatura adiacente).

```
costo abilità = max(0, costo base + modificatore del giocatore + modificatore della corsia)
se un effetto ha imposto un costo fisso (≥ 0), vale quello
```
Le modifiche di ATK e DEF date dalle abilità sono **permanenti** finché la creatura resta in campo, e si sommano tra loro.

## 6. Combattimento in dettaglio ✅

### 6.1 Ordine
Per ogni corsia, da sinistra a destra secondo chi attacca:
- corsia senza creatura attaccante → si salta;
- creatura con **ATK 0** → non attacca;
- creatura che **non può attaccare** (effetto avversario), o bersaglio **protetto** → nessun danno.

### 6.2 L'anello a tempo
- Sull'anello, un giro completo vale 1. Il leader definisce due ampiezze, *colpo* `H` e *critico* `C`, separate per attacco e difesa, più i modificatori della missione.
- Carte in campo possono allargarle: `H = H × (1 + modificatore)`, e lo stesso per C.
- Se `H + C > 1`, allora `H = 1 − C`.
- **Attacco contro una corsia vuota:** `H = 1 − C`, cioè tutto l'anello tranne il critico è "colpo". In pratica non si sbaglia.
- Posizione: `inizio colpo = casuale(0, 1 − H − C)`; la zona critico parte **subito dopo** la zona colpo.
- Tempo per un giro = `casuale(min, max)` del leader × fattore della missione. L'indicatore gira un numero limitato di volte, poi il tempo scade = **Mancato**.
- Mentre aspetta il tocco il gioco è in pausa (`timeScale = 0`).
- **Combattimento automatico** (opzione del giocatore): in attacco dà sempre "Colpo", in difesa sempre "Mancato". Niente critici.
- L'anello lo gioca **sempre e solo il giocatore umano**, in attacco e in difesa. L'IA non fa il minigioco.

### 6.3 Danno a una creatura
```
base     = ATK attaccante
danno    = max(0, base + base × Fattore[fazione attaccante][fazione difensore])
se Critico e il turno è tuo:    danno = danno × moltiplicatore critico del leader
ricevuto = max(0, (danno − riduzione danni) × fattore danni del difensore)
danni accumulati += ricevuto
```
- `Fattore` è la **matrice dei vantaggi fra fazioni** (`db_RPS.json` ❓): un valore positivo dà un bonus, uno negativo un malus.
- Se il difensore arriva a 0 vita e nella corsia dell'**attaccante** c'è un edificio, scatta l'effetto "alla vittoria" dell'edificio.
- La creatura che attacca **non subisce contrattacco**: in questo scontro solo il difensore riceve danni.

### 6.4 Danno al leader
Se di fronte non c'è una creatura, oppure è **inerme**:
```
danno al leader = ATK attaccante − penalità ATK del giocatore che attacca
se Critico: × moltiplicatore critico
```
I PV del leader restano fra un minimo e un massimo (`MinHealth`/`MaxHealth`), che alcuni effetti possono cambiare.

### 6.5 La difesa nell'anello non cambia il danno ⚠️
Il codice mostra "tocca per bloccare" e usa zone di difesa proprie, ma **nessuna formula di danno legge il risultato della difesa**:
- il bonus del critico si applica solo nel tuo turno di attacco;
- se l'avversario attacca una tua corsia vuota, l'anello non compare nemmeno e il danno è pieno.

In questa versione la difesa sembra quindi **solo scenica**. Per un nostro gioco conviene dargli un effetto vero (per esempio Colpo = −25% danno, Critico = −50%).

### 6.6 Statistiche effettive
```
ATK  = max(0, (ATK di livello + modificatori ATK) × fattore ATK)
DEF  = (DEF di livello + modificatori DEF) × fattore DEF
Vita = max(0, DEF − danni accumulati)
Cura: danni accumulati −= arrotonda(valore × fattore cure), senza scendere sotto 0
```
- Non esiste "vita oltre il massimo": una cura toglie solo danni già subiti.
- Per alzare la vita oltre la DEF iniziale bisogna aumentare la **DEF**.

## 7. Edifici ✅

Gli edifici reagiscono a questi eventi:
- **entra in gioco / esce di gioco** → aure continue di ATK o DEF, che si tolgono quando l'edificio sparisce;
- **una creatura usa l'abilità** → +ATK, +DEF o punti azione;
- **una creatura muore** → danno o cura al leader, rimanda carte in mano;
- **la creatura vince uno scontro** → cura;
- **inizio turno** → cura della creatura o delle creature.

Costanti trovate: un edificio dimezza i danni ricevuti (×0,5), un altro raddoppia le cure (×2).

## 8. Leader ✅

| Aspetto | Regola |
|---|---|
| Punti vita | `PV base + 5 × livello` |
| Livello | ricavato dall'esperienza secondo una tabella del leader (`LvUpScheme` ❓), con un'esperienza massima |
| Esperienza | quella della missione, assegnata a ogni vittoria |
| Effetti del livello | più PV, **mazzo più grande**, costo della ricerca PvP |
| Abilità | lanciata come incantesimo gratuito; poi la ricarica riparte da `Cooldown` e scende di 1 a ogni fine turno |
| Minigioco | zone colpo e critico (attacco e difesa), velocità min/max, moltiplicatore critico |
| Specializzazione | campi `forFaction` / `forLandscape` / `forCardType` per abilità legate a una fazione, un terreno o un tipo |

Le abilità dei leader sono incantesimi con il suffisso `Leader`: bonus ATK o DEF a tutti o a una fazione, cure, pesca,
punti azione, sconti per fazione o per tipo, recupero dagli scarti, edifici rimandati in mano, blocchi con distruzione di edifici.

## 9. Mazzo finito ✅

**Giocatore umano.** Se a inizio turno il mazzo è vuoto, appare un avviso e **il tuo leader perde PV pari al proprio livello**.
Gli scarti **non** tornano nel mazzo: la penalità si ripete **a ogni turno** finché la partita non finisce (un "dissanguamento").

**IA.** Se la missione lo permette (`AIReshuffle`), l'IA invece **rimescola**: la mano va negli scarti, gli scarti tornano nel mazzo,
il mazzo viene mescolato e l'IA pesca 5 carte. Non perde PV.

## 10. Fine partita ✅

- Perde chi arriva a 0 PV.
- In caso di sconfitta puoi **resuscitare pagando 1 gemma**:
  - PV del leader al massimo;
  - la mano va negli scarti, gli scarti tornano nel mazzo, il mazzo viene mescolato e peschi 5 carte;
  - le carte in campo restano dove sono, e tieni carte e monete raccolte.
- **Vittoria:**
  - esperienza al leader (quella della missione);
  - monete: un valore casuale fra minimo e massimo della missione, più quelle raccolte;
  - gemme raccolte;
  - carte raccolte, ognuna al proprio livello di drop;
  - alla prima vittoria in una missione: eventualmente un **nuovo leader** e **+1 alla stamina massima**.

## 11. Intelligenza artificiale ✅

L'IA è **greedy a una mossa**: a ogni azione prova tutte le mosse, valuta il tavolo che ne risulta e sceglie la migliore.
Se nessuna mossa migliora il tavolo, passa.

### Valutazione del tavolo
```
Punteggio(giocatore) = Σ punteggio delle 4 corsie
                     + PV "al sicuro"
                     + punti azione × 1
                     + carte in mano × 3

Corsia con una mia creatura:
   nessun nemico di fronte → ATK + Vita
   nemico di fronte        → ATK + max(0, Vita − ATK del nemico)
Corsia vuota con un nemico di fronte → −ATK del nemico

PV al sicuro = max(0, PV − Σ ATK delle creature nemiche senza nessuno davanti)

Valore finale = Punteggio(IA) − Punteggio(avversario)
```
- Gioca carte **solo in corsie vuote**: non sostituisce mai una creatura.
- Per bersagli, cure e sacrifici usa funzioni dedicate: "miglior candidato da attaccare / curare / indebolire / sacrificare".
- Costanti: `WEIGHT_SCALE = 100`, `DEF_FACTOR = 2`.

## 12. Catalogo delle abilità (239) ✅

Elenco completo, con il momento in cui scatta ogni effetto: [`catalogo-abilita-card-wars.md`](catalogo-abilita-card-wars.md). In sintesi:

- **140 abilità di creatura**: tutte si attivano pagando punti azione.
  - Bonus: ATK/DEF a sé, alle adiacenti, a tutte, alla fazione; in base a terreni, carte, corsie vuote, attivazioni del turno o della partita.
  - Malus: −ATK/−DEF a bersaglio, di fronte o a tutti; ATK pareggiato; vita dell'avversario convertita.
  - Danno: di fronte, bersaglio, adiacenti, tutti, leader; scalato su scarti, terreni diversi, rarità, edifici, danni subiti nel turno prima.
  - Cure: a sé, adiacenti, bersaglio, tutti, leader.
  - Controllo: proteggi, rendi inerme, impedisci l'attacco, blocca abilità o evocazioni, rimanda in mano, distruggi un edificio, resetta.
  - Economia: pesca, punti azione, sacrifica per punti o carte, recupera dagli scarti, rimescola la mano.
  - Anello: allarga la zona colpo, critico o difesa.
- **26 edifici**: vedi §7.
- **73 incantesimi e abilità dei leader**: attacco a una creatura (generico o per fazione), danno doppio, distruzione per rarità,
  disabilita corsia, blocca un tipo di carta, trasforma, scambia ATK/DEF, dimezza ATK o DEF (×0,5),
  ×1,5 a una fazione, sposta edifici, sconti, recupero, rimanda in mano, scarta, pesca, ruba PV.

## 13. Meta-gioco ✅

### 13.1 Collezione
- Inventario con limite (aumentabile); vendita delle carte (prezzo × livello).
- **Fusione**: ricetta = ingredienti (carta × quantità) + costo in monete + missione che la sblocca → carta nuova.

### 13.2 Forzieri (gacha)
- Più **colonne di pesi** (normale, oro, ossidiana, eventi). Ogni oggetto ha un peso in ciascuna colonna.
- Uno **schema** a calendario decide quali colonne sono attive e il costo in monete o gemme.
- **I leader già posseduti sono esclusi** dall'estrazione (niente leader doppi).
- "Party": eventi a tempo che cambiano i pesi.
- **Chiavi** (`KeyRing`) per forzieri speciali con carte dedicate.

### 13.3 Campagna
- Mappa a **regioni** che si sbloccano.
- Ogni missione ha: mazzo e leader avversario con il suo livello, **costo in stamina**, esperienza e monete min/max, profilo di drop, numero massimo di drop, drop fissi.
- La missione può imporre **leader o mazzo** al giocatore e modificare l'anello (zone, velocità).
- **Stelle / condizioni** della missione, combinabili:

  | Condizione | Significato |
  |---|---|
  | `AllowedTypes` | solo certi tipi di carta |
  | `AllowedFactions` | solo certe fazioni |
  | `MaxTurns` | vincere entro N turni |
  | `MinCreaturesDefeated` | sconfiggere almeno N creature |
  | `MaxActionPointsPerCard` | nessuna carta oltre un certo costo |
  | `MaxActionPointsTotal` | spesa totale massima |
  | `MaxHPLost` | perdere al massimo N PV |
  | `MaxNumCreaturesLost` | perdere al massimo N creature |
  | `MinLandscapesUsed` | usare almeno N terreni diversi |
  | `MaxDeckCost` | costo massimo del mazzo |
  | `MaxFloopsUsed` | massimo di abilità attivate |

### 13.4 Stamina
- Si consuma per entrare nelle missioni e si ricarica col tempo (`Stamina_Restoration_Rate` ❓).
- Massimo aumentabile con le prime vittorie nelle missioni.

### 13.5 Modalità ed eventi
- **Dungeon**: missioni disponibili solo **in certi giorni della settimana** o in periodi; si può entrare pagando gemme.
- **Sfidante casuale** (`ElFisto`): dopo un certo numero di battaglie compare con una probabilità; ha round crescenti e ricompense per round.
- **Missioni secondarie ed eventi a tempo**: oggetti da raccogliere nelle battaglie, ricompense, missioni da cui dipendono.
- **Regali giornalieri** (estratti a pesi) e **calendario** di accesso, con giorni persi recuperabili a pagamento.
- **Codici promozionali**.

### 13.6 Multigiocatore (asincrono)
- Il mazzo, i terreni e il leader del giocatore vengono salvati sul server. Gli altri ci giocano contro, **controllati dall'IA**.
- Ricerca dell'avversario a pagamento (monete o gemme, in base al livello del leader).
- Ogni sfida ha una **posta in trofei** per vittoria e sconfitta, una scadenza, **serie di vittorie** e un bonus per la serie.
- **Tornei** con classifica, data di fine e premi per posizione.

### 13.7 Valute
- **Monete**: dalle partite; servono per fusioni, forzieri e ricerche PvP.
- **Gemme**: valuta premium; servono per forzieri, resurrezioni, dungeon e recuperi.

---

## 14. Note per progettare un gioco originale ispirato a queste meccaniche

Cose che funzionano e conviene tenere:
- corsie con terreni e carte legate al terreno: costringono a scegliere il mazzo e la disposizione;
- punti azione crescenti e non accumulabili;
- abilità attivabili una volta per turno;
- l'anello a tempo come momento di abilità del giocatore.

Punti deboli dell'originale da sistemare:
1. **Difesa solo scenica** (§6.5): darle un effetto vero.
2. **IA a una mossa che non sostituisce mai le creature**: si batte facilmente. Si può aggiungere una seconda mossa di previsione e la sostituzione.
3. **Mazzo finito con regole diverse**: l'umano perde PV a ogni turno, mentre l'IA può rimescolare gratis. Meglio una regola uguale per tutti.
4. **Livello come moltiplicatore lineare**: le carte di livello alto schiacciano tutto. Meglio una crescita più dolce (per esempio +20% a livello).
5. **Nessun contrattacco**: valutare se il difensore debba rispondere, per rendere il combattimento più tattico.

Numeri da inventare da zero, perché non sono nell'APK: statistiche e costi delle carte, matrice delle fazioni, punti azione iniziali e massimi, PV base dei leader, curve di esperienza, pesi dei forzieri.
