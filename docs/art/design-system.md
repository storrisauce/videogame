# Design system grafico — Fattoria Nucleare

Regole per disegnare **qualunque cosa** del gioco (creature, persone, strutture, tavolo, interfaccia) in modo che
sembri tutto fatto dalla stessa mano. Decisione D-013 (pixel art 2D in Godot). Ultimo aggiornamento: 2026-11-20.

## 1. Da dove viene lo stile
- Il riferimento è il pacchetto **Sunnyside World** (danieldiggle, https://danieldiggle.itch.io/sunnyside), usato
  **solo come ispirazione**: proporzioni, luce, contorni, colori. **Nessun suo elemento entra nel gioco**: niente case,
  scheletri, personaggi o tile copiati. Ogni sprite è disegnato da zero con queste regole.
- Il pacchetto sta solo sul computer dell'utente, in `art/reference/` (ignorata da git). Licenza: uso commerciale e
  modifiche permessi; vietato ridistribuirlo o rivenderlo e **vietato usarlo per addestrare un'AI**.
- Da Sunnyside prendiamo il *come*; il *cosa* viene dal [DNA tematico](../dna-tematico.md): fattoria post-nucleare
  demenziale, animali e ortaggi mutanti, sopravvissuti strani.

## 2. Palette (63 colori, una sola per tutto il gioco)
File: `art/palette/fattoria_nucleare.json` (fonte), `.gpl` (Aseprite/GIMP), `.hex`, `_campionario.png`.
Base: la palette pubblica **ENDESGA 32**, la stessa su cui poggia Sunnyside, più 24 toni misurati sul riferimento,
2 toni "radio" e 4 rosa per i maiali. Con questi 63 colori il riferimento viene riprodotto con un errore medio di
3,5 su 255: lo stile è dentro la palette.

| Rampa | Colori (dal più scuro) | Si usa per |
|---|---|---|
| neutri | inchiostro `#181425`, notte `#262b44`, ferro_1…ferro_6, bianco | contorno dei personaggi, ombre, lamiera, metallo, nuvole, occhi |
| legno | legno_0 `#3e2731` … legno_9 `#ead4aa` | recinti, casse, tetti di legno, cornici dell'interfaccia, paglia |
| ruggine | ruggine_1 `#944627` … ruggine_4 `#d77643` | ruggine, terra bruciata, mattoni |
| pelle | pelle_1 `#b86f50` … pelle_5 `#e8b796` | pelle delle persone, muso di mucca, pane, patate |
| arancio | arancio_1 `#e07317` … arancio_4 `#feae34` | zucche, becchi, fiamme, tetti arancioni |
| giallo | giallo_1 `#e4d572`, giallo_2 `#fee761` | pancia della rana, paperi, luci, centro del bagliore |
| verde | verde_0 `#193c3e` … verde_5 `#90bf5d`, salvia | erba, foglie, rane, folletti, verdure |
| **radio** | radio_1 `#a3e048`, radio_2 `#d4f25e` | **solo radiazioni**: macchie, bagliori, occhi mutanti, Caos |
| acqua | acqua_1 `#124e89` … acqua_6 `#2ce8f5` | stagno, acqua, vetro, schermi |
| rosso | rosso_1 `#a22633` … rosso_4 `#f6757a`, allarme `#ff0044` | creste, sangue cartoon, tetti rossi; `allarme` solo per l'interfaccia (danno, pericolo) |
| rosa | rosa_1 `#b74851` … rosa_4 `#ff979b` | maiali, nasi, guance |
| viola | prugna `#5d3b4a`, viola_1 `#68386c` … viola_4 `#b76baa` | Cratere, funghi strani, capelli scuri, magia |
| ombra | notte al **29%** di opacità (alpha 74) | l'unico colore semitrasparente: ombre a terra |

Regole:
- **Mai colori fuori palette.** Lo controlla `python3 art/tools/pixel.py check`.
- **Massimo 10–12 colori per sprite** (il riferimento ne usa 7–11 per animale).
- Una **rampa per materiale**: 3–4 toni (luce, base, ombra, contorno). Non mescolare rampe nello stesso materiale.
- Il verde **radio** è il segno del nucleare: al massimo ~10% dei pixel di uno sprite, e mai per l'erba normale.

## 3. Griglia e scala del mondo
- **1 tile = 16 px.** Tutto è disegnato alla stessa scala del mondo: **le misure dicono quanto è grande davvero**.
  Una mucca è più grande di una gallina, la Nonna è più alta di un bambino, un trattore occupa più di una mucca.
- Nella carta e nel tavolo ogni sprite si mostra con **lo stesso ingrandimento intero** (×2 o ×3, filtro *Nearest*),
  così le differenze di taglia restano visibili.
- Fotogrammi quadrati, in strisce orizzontali (`nome.png`, fotogrammi da sinistra a destra), con lo sprite **appoggiato
  in basso** e un po' di aria intorno, come nel riferimento.

| Taglia | Fotogramma | Corpo (larghezza × altezza, ombra esclusa) | Esempi |
|---|---|---|---|
| XS | 16×16 | ≤ 14 × 12 | pulcino, papera, ratto, ortaggio piccolo, uccellino |
| S | 32×32 | 14–20 × 14–20 | gallina, maiale, rana, patata, gallo, procione, gazza |
| M | 32×32 | 20–26 × 18–26 | mucca, pecora, capra, oca, cigno, tacchino |
| Persona | 32×32 | 11–14 × 16–22 | sopravvissuti: corpo da 12×17; la Nonna 13×20; il Veterinario il più alto |
| L | 48×48 | 26–40 × 26–40 | scrofa carrarmato, zucca lievitata, trattore, silos, bunker |
| XL | 64×64 | > 40 | creature leggendarie e strutture grandi (es. mucca laser) |

Le **persone** sono "chibi": testa grande quanto il corpo (circa 1:1), occhi di 1×2 px.

## 4. Vista, luce e forme
- **Vista dall'alto a 3/4**: si vedono il sopra e il davanti. Gli animali stanno di tre quarti o di fronte.
- **Luce dall'alto** (leggermente da sinistra): il tono chiaro sta sul bordo alto e a sinistra, lo scuro in basso e a destra.
- **Forme tonde e paffute**, contorni a scalini regolari (1-2-3 px), niente linee lunghe dritte su un corpo vivo.
- **Niente** anti-alias, sfumature, retini (dithering), pixel isolati "di rumore". Ogni blocco di colore ha un motivo.
- **Occhi**: 1 px inchiostro (2 px alti per persone e mostri). Se un mutante ha occhi grandi: bulbo bianco con
  pupilla di 1 px inchiostro, come la Rana a Due Teste. Le guance si possono segnare con 1–2 px rosa.

## 5. Contorni
- **Persone e umanoidi**: contorno di 1 px **inchiostro** tutto intorno.
- **Animali, piante, oggetti**: contorno **selettivo** di 1 px nel tono **più scuro della propria rampa**
  (maiale → rosa_1, rana → verde_1, pollo → rosso_1/legno_3, legno → legno_1, lamiera → ferro_1).
  Mucca, pecora e cose bianche/grigie usano **notte**.
- Mai nero puro, mai contorni di 2 px.

## 6. Ombra a terra
Ogni cosa appoggiata a terra ha un'ellisse di **ombra** (notte al 29%), larga quanto il corpo + 2–4 px, alta 2–3 righe,
che sbuca sotto i piedi. Le cose che volano hanno un'ombra più piccola e staccata.

## 7. Animazione
- **Idle: 4 fotogrammi** (testa o corpo che si abbassa di 1 px, un battito di ciglia), ~6 fotogrammi al secondo.
- Azioni (attacco, colpito, morte, Scuotere): 6–10 fotogrammi, movimenti di 1–2 px, schiacciamento e allungamento
  leggeri. Il "colpito" lampeggia col bianco per 1 fotogramma.
- Effetti (fumo, scintille, radiazioni): 4–8 fotogrammi, 2–3 colori.

## 8. Il tocco nucleare (come si "muta" una cosa normale)
Si parte dall'animale o dall'oggetto **normale e simpatico**, poi si aggiunge **una** mutazione leggibile da lontano:
- **parti in più** (due teste, tre occhi, quattro zampe di gallina), **parti di fattoria addosso** (lamiera, scolapasta,
  bulloni, copertoni), **macchie radio** che brillano (radio_1 con un pixel radio_2 al centro).
- Il nome della carta deve vedersi nello sprite: "Maiale in Lamiera" = maiale con piastre di ferro e bulloni.
- Niente sangue realistico o orrore: è demenziale, non macabro.

## 9. Bande → materiali e colori dominanti
| Banda | Rampe principali | Segni distintivi |
|---|---|---|
| Porcile | rosa + ferro | lamiera, bulloni, corazze fatte in casa |
| Pollaio | pelle/legno + rosso + arancio | creste rosse, bossoli, uova esplosive |
| Stagno | verde + acqua + bianco | piume bagnate, coltelli, remi, pozze |
| Patate | ruggine/legno + verde | ortaggi con facce tristi o urlanti, radici, terra |
| Discarica | ferro + ruggine + legno | rottami, scolapasta, copertoni, toppe |
| Cratere | viola + radio | creature strane, bagliori, cose sacre e inquietanti |

## 10. Ambientazione (tavolo e sfondi)
- Il tavolo è un **pezzo di fattoria visto dall'alto**, su tile da 16 px: erba (verde_4 con ciuffi verde_3/verde_5),
  sentieri di terra (legno_7/legno_8), acqua (acqua_4 con riflessi acqua_6 e bianco), bordi di scogliera (legno_4/legno_3).
- Versione nucleare: crateri, pozze che brillano (radio), bidoni, recinti di lamiera, alberi un po' storti,
  il fumo della centrale all'orizzonte. Sempre colori allegri: è un dopo-bomba **cartoon**.
- I 4 **recinti** di ogni giocatore sono recinti di legno sul terreno della loro banda (erba, fango, stagno, orto, discarica).

## 11. Interfaccia
- Riquadri a 9 fette in legno chiaro (legno_9 dentro, legno_3 bordo, legno_1 contorno), angoli a scalino.
- Icone 16×16 con le stesse regole (contorno, luce dall'alto). Barre: Pazienza in rosso, Caos in radio.
- Testi: carattere pixel leggibile (da scegliere con l'utente; deve avere accenti italiani).

## 12. Come si crea uno sprite nuovo
1. Scegli **taglia** (§3), **rampe** (§2, §9) e **la mutazione** (§8).
2. Scrivi `art/sprites/<id>.pxl` (formato in `art/tools/pixel.py`): ogni riga è una fila di pixel, la legenda usa i nomi
   della palette. Per forme tonde puoi generarlo da uno script e poi ritoccarlo a mano.
3. `python3 art/tools/pixel.py render art/sprites/<id>.pxl` → PNG in `game/assets/...`
4. `python3 art/tools/pixel.py check` → nessun colore fuori palette.
5. `python3 art/tools/pixel.py preview <png> <anteprima.png> 8` e **confrontalo affiancato** con gli sprite di
   riferimento della stessa taglia (in `art/reference/`, solo in locale): taglia, luce, contorno e ombra devono tornare.

Sprite fatti: `rana_a_due_teste` (S, 4 fotogrammi idle) — prima prova dello stile.
