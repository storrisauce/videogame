extends SceneTree
## Test delle regole, senza grafica.
## godot --headless --path game --script res://tests/test_runner.gd   (uscita 1 se un test fallisce)

var passed := 0
var failed := 0
var db: CardDB

const TESTS := [
	"test_advantage_cycle", "test_caos_growth", "test_play_rules", "test_replace",
	"test_combat_advantage", "test_botta_atomica", "test_hero_damage", "test_first_turn_no_combat",
	"test_death_and_on_death", "test_scuoti", "test_structure_aura", "test_empty_deck",
	"test_level_scaling", "test_hand_limit", "test_hero_cooldown", "test_reduce_action_points",
	"test_return_to_hand", "test_clone_independent", "test_resurrect", "test_full_game",
]


func _initialize() -> void:
	db = CardDB.load_default()
	for t: String in TESTS:
		if call(t) != true:
			failed += 1
			push_error("FAIL %s: non è arrivato in fondo (errore a runtime?)" % t)
	print("Risultati: %d ok, %d falliti" % [passed, failed])
	quit(1 if failed > 0 else 0)


func check(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		passed += 1
	else:
		failed += 1
		push_error("FAIL %s: atteso %s, ottenuto %s" % [label, expected, actual])


## Partita di prova senza mescolare né pescare: giocatore 0 inizia.
func new_match(zones0: Array = ["porcile", "pollaio", "stagno", "patate"],
		zones1: Array = ["patate", "stagno", "pollaio", "porcile"]) -> Match:
	var m := Match.new(db)
	m.setup(1, [[], []], [zones0, zones1], ["nonna", "speaker"])
	m.first_player = 0
	m.current = 0
	m.turn_number = 1
	m.round_caos = 2
	for p in 2:
		m.players[p].caos = 10
	return m


func put(m: Match, p: int, lane: int, id: String, lvl: int = 1) -> CardInst:
	var c := CardInst.new(db.card(id), lvl, p)
	if c.type() == "creature":
		m.players[p].lanes[lane].creature = c
	else:
		m.players[p].lanes[lane].structure = c
	return c


func give(m: Match, p: int, id: String, lvl: int = 1) -> int:
	m.players[p].hand.append(CardInst.new(db.card(id), lvl, p))
	return m.players[p].hand.size() - 1


# ---------------------------------------------------------------------------

func test_advantage_cycle() -> bool:
	check(db.advantage("porcile", "patate"), 0.25, "porcile batte patate")
	check(db.advantage("patate", "porcile"), -0.25, "patate subisce porcile")
	check(db.advantage("discarica", "porcile"), 0.25, "il ciclo si chiude")
	check(db.advantage("porcile", "stagno"), 0.0, "non adiacenti nel ciclo = neutro")
	check(db.advantage("cratere", "porcile"), 0.0, "cratere neutro")
	return true


func test_caos_growth() -> bool:
	var m := Match.new(db)
	var deck := []
	for i in 30:
		deck.append("maialino_di_scorta")
	m.setup(7, [deck, deck.duplicate()], [["porcile", "porcile", "porcile", "porcile"], ["porcile", "porcile", "porcile", "porcile"]], ["nonna", "nonna"])
	m.start()
	var f := m.first_player
	var s := 1 - f
	check(m.players[f].caos, 2, "Caos iniziale del primo")
	check(m.players[s].caos, 2 + db.rule_i("caos_bonus_secondo"), "Caos iniziale del secondo (+ bonus)")
	check(db.rule_i("caos_bonus_secondo"), 1, "bonus del secondo = 1 (D-012)")
	m.end_turn(f)
	check(m.players[f].caos, 3, "primo: +1 dopo il suo turno")
	m.end_turn(s)
	check(m.players[s].caos, 3, "secondo: stesso Caos del primo")
	for i in 20:
		m.end_turn(m.current)
	check(m.players[f].caos, db.rule_i("caos_max"), "Caos fermo al massimo")
	return true


func test_play_rules() -> bool:
	var m := new_match()
	m.players[0].caos = 3
	var h := give(m, 0, "scrofa_carrarmato")   # porcile, costo 4
	check(m.play_card(0, h, 0), false, "Caos insufficiente")
	m.players[0].caos = 5
	check(m.play_card(0, h, 1), false, "zona sbagliata (pollaio)")
	check(m.play_card(0, h, 0), true, "porcile nel porcile")
	check(m.players[0].caos, 1, "Caos speso")
	var r := give(m, 0, "mucca_laser")
	m.players[0].caos = 10
	check(m.play_card(0, r, 2), true, "cratere va ovunque")
	m.players[0].lanes[3].disabled = true
	var p := give(m, 0, "patata_depressa")
	check(m.play_card(0, p, 3), false, "recinto disabilitato")
	return true


func test_replace() -> bool:
	var m := new_match()
	put(m, 0, 0, "maialino_di_scorta")
	var h := give(m, 0, "maiale_in_lamiera")
	check(m.play_card(0, h, 0), true, "sostituzione permessa all'umano")
	check(m.players[0].discard.size(), 1, "la vecchia va nel Letamaio")
	m.allow_replace[0] = false
	var h2 := give(m, 0, "verro_spugna")
	check(m.play_card(0, h2, 0), false, "IA: niente sostituzioni")
	return true


func test_combat_advantage() -> bool:
	var m := new_match()
	m.players[0].turns_taken = 1
	put(m, 0, 0, "tacchino_furioso")              # pollaio, ATK 6
	var d := put(m, 1, 0, "zucca_lievitata")      # patate, DEF 9
	m.combat(0)
	check(d.damage, 6, "pollaio contro patate: neutro")
	var m2 := new_match()
	m2.players[0].turns_taken = 1
	put(m2, 0, 0, "scrofa_carrarmato")             # porcile, ATK 3
	var d2 := put(m2, 1, 0, "zucca_lievitata")
	m2.combat(0)
	check(d2.damage, 3, "porcile contro patate: 3 + 0,75 troncato = 3")
	var m3 := new_match()
	m3.players[0].turns_taken = 1
	put(m3, 0, 0, "scrofa_carrarmato", 2)          # ATK 6
	var d3 := put(m3, 1, 0, "zucca_lievitata", 2)  # DEF 18
	m3.combat(0)
	check(d3.damage, 7, "porcile contro patate: 6 + 1,5 = 7")
	var m4 := new_match()
	m4.players[0].turns_taken = 1
	put(m4, 0, 0, "zucca_lievitata")               # patate ATK 4 contro porcile
	var d4 := put(m4, 1, 0, "scrofa_carrarmato")
	m4.combat(0)
	check(d4.damage, 3, "patate contro porcile: 4 - 1 = 3")
	return true


func test_botta_atomica() -> bool:
	var m := new_match()
	m.players[0].turns_taken = 1
	put(m, 0, 0, "tacchino_furioso")
	var d := put(m, 1, 0, "zucca_lievitata")
	m.combat(0, [true, false, false, false])
	check(d.damage, 9, "Botta Atomica: 6 × 1,5")
	return true


func test_hero_damage() -> bool:
	var m := new_match()
	m.players[0].turns_taken = 1
	put(m, 0, 1, "pulcino_mitragliere")    # ATK 3, recinto vuoto di fronte
	var hp := m.players[1].hp
	m.combat(0)
	check(m.players[1].hp, hp - 3, "danno pieno alla Pazienza")
	m.players[0].atk_penalty = 1
	m.combat(0, [false, true])
	check(m.players[1].hp, hp - 3 - 3, "penalità 1, poi Botta: (3-1)×1,5 = 3")
	var d := put(m, 1, 1, "rapa_rancorosa")
	d.helpless = true
	var hp2 := m.players[1].hp
	m.players[0].atk_penalty = 0
	m.combat(0)
	check(m.players[1].hp, hp2 - 3, "creatura inerme: il colpo va alla Pazienza")
	check(d.damage, 0, "la creatura inerme non viene colpita")
	return true


func test_first_turn_no_combat() -> bool:
	var m := new_match()
	put(m, 0, 0, "tacchino_furioso")
	var hp := m.players[1].hp
	m.combat(0)
	check(m.players[1].hp, hp, "il primo giocatore non attacca al primo turno")
	m.players[0].turns_taken = 1
	m.combat(0)
	check(m.players[1].hp, hp - 6, "dal turno dopo sì")
	return true


func test_death_and_on_death() -> bool:
	var m := new_match()
	m.players[0].turns_taken = 1
	put(m, 0, 1, "tacchino_furioso")                 # ATK 6 nel recinto 1
	put(m, 1, 1, "anatra_col_coltello")              # stagno DEF 3, recinto 1 avversario (stagno)
	put(m, 1, 1, "silos_instabile")                  # quando muore: 3 alla Pazienza del giocatore 0
	var hp0 := m.players[0].hp
	m.combat(0)
	check(m.players[1].lanes[1].creature, null, "la creatura muore")
	check(m.players[1].discard.size(), 1, "finisce nel Letamaio")
	check(m.players[0].hp, hp0 - 3, "il Silos esplode sulla Pazienza avversaria")
	return true


func test_scuoti() -> bool:
	var m := new_match()
	var s := put(m, 0, 0, "scrofa_carrarmato")     # +3 DEF, costo 1
	m.players[0].caos = 2
	check(m.scuoti(0, 0), true, "prima scossa")
	check(m.def_of(s), 13, "DEF 10 + 3")
	check(m.players[0].caos, 1, "costo pagato")
	check(m.scuoti(0, 0), false, "una sola volta per turno")
	m.begin_turn(0)
	check(m.def_of(s), 13, "il bonus resta")
	check(m.can_scuoti(0, 0), true, "di nuovo disponibile al turno dopo")
	put(m, 0, 3, "patata_depressa")
	check(m.can_scuoti(0, 3), false, "nessuna adiacente ferita: non si può curare")
	return true


func test_structure_aura() -> bool:
	var m := new_match()
	var c := put(m, 0, 2, "anatra_col_coltello")   # ATK 4 nello stagno
	put(m, 0, 2, "pontile_dei_predoni")            # +2 ATK
	check(m.atk_of(c), 6, "aura della struttura")
	m.players[0].lanes[2].structure = null
	check(m.atk_of(c), 4, "senza struttura torna normale")
	return true


func test_empty_deck() -> bool:
	var m := new_match()
	m.players[0].hero_level = 3
	var hp := m.players[0].hp
	m.begin_turn(0)
	check(m.players[0].hp, hp - 3, "umano: perde Pazienza pari al livello")
	m.begin_turn(0)
	check(m.players[0].hp, hp - 6, "e di nuovo al turno dopo")
	m.players[1].empty_deck_rule = "reshuffle"
	for i in 3:
		m.players[1].discard.append(CardInst.new(db.card("rapa_rancorosa"), 1, 1))
	m.players[1].hand.append(CardInst.new(db.card("rapa_rancorosa"), 1, 1))
	var hp1 := m.players[1].hp
	m.begin_turn(1)
	check(m.players[1].hp, hp1, "IA: nessuna perdita")
	check(m.players[1].hand.size(), 4, "IA: rimescola mano e Letamaio e ripesca")
	return true


func test_level_scaling() -> bool:
	var m := new_match()
	var c := put(m, 0, 0, "scrofa_carrarmato", 3)
	check(m.atk_of(c), 9, "ATK × livello")
	check(m.def_of(c), 30, "DEF × livello")
	check(c.val(), 9, "valore abilità × livello")
	return true


func test_hand_limit() -> bool:
	var m := new_match()
	for i in 7:
		give(m, 0, "rapa_rancorosa")
	m.players[0].deck.append(CardInst.new(db.card("gallo_sentinella"), 1, 0))
	m.draw(0)
	check(m.players[0].hand.size(), 7, "mano piena: non cresce")
	check(m.players[0].discard.size(), 1, "la pescata va persa")
	return true


func test_hero_cooldown() -> bool:
	var m := new_match()
	var e := put(m, 1, 0, "rapa_rancorosa")    # DEF 5
	check(m.use_hero(0, {"p": 1, "lane": 0}), true, "Nonna: spara")
	check(e.damage, int(db.heroes["nonna"]["v1"]), "danni pari al valore della Nonna")
	check(m.can_use_hero(0), false, "in ricarica")
	for i in 3:
		m.end_turn(m.current)
		m.end_turn(m.current)
	check(m.can_use_hero(0), true, "ricarica finita dopo 3 dei suoi turni")
	return true


func test_reduce_action_points() -> bool:
	var m := new_match(["stagno", "stagno", "stagno", "stagno"])
	var h := give(m, 0, "razionamento")
	check(m.play_card(0, h, -1), true, "evento giocato")
	m.end_turn(0)
	m.end_turn(1)
	check(m.players[1].caos, 1, "avversario: 3 - 2 = 1 Caos")
	return true


func test_return_to_hand() -> bool:
	var m := new_match()
	put(m, 0, 2, "oca_esattrice")
	put(m, 1, 2, "tacchino_furioso")
	check(m.scuoti(0, 2), true, "l'Oca riscuote")
	check(m.players[1].lanes[2].creature, null, "il recinto si svuota")
	check(m.players[1].hand.size(), 1, "la creatura torna in mano")
	return true


func test_clone_independent() -> bool:
	var m := new_match()
	var c := put(m, 0, 0, "scrofa_carrarmato")
	var k := m.clone()
	k.players[0].lanes[0].creature.damage = 5
	k.players[0].caos = 0
	check(c.damage, 0, "il clone non tocca l'originale")
	check(m.players[0].caos, 10, "Caos originale intatto")
	return true


func test_resurrect() -> bool:
	var m := new_match()
	for i in 6:
		m.players[0].deck.append(CardInst.new(db.card("rapa_rancorosa"), 1, 0))
	m.players[0].hand.append(CardInst.new(db.card("gallo_sentinella"), 1, 0))
	m.players[0].discard.append(CardInst.new(db.card("gallo_sentinella"), 1, 0))
	put(m, 0, 0, "maialino_di_scorta")
	check(m.can_resurrect(0), false, "non si rialza chi non ha perso")
	m.damage_hero(0, 999)
	check(m.winner, 1, "il giocatore 0 ha perso")
	check(m.resurrect(0), true, "si rialza")
	check(m.winner, -1, "la partita continua")
	check(m.players[0].hp, m.players[0].max_hp, "Pazienza al massimo")
	check(m.players[0].hand.size(), 5, "ripesca 5 carte")
	check(m.players[0].deck.size() + m.players[0].hand.size(), 8, "mano e Letamaio tornati nel mazzo")
	check(m.players[0].lanes[0].creature != null, true, "le carte in campo restano")
	m.damage_hero(0, 999)
	check(m.resurrect(0), false, "una sola volta per partita")
	return true


func test_full_game() -> bool:
	var deck0 := []
	var deck1 := []
	for id in ["scrofa_carrarmato", "maiale_in_lamiera", "maialino_di_scorta", "verro_spugna", "bunker_di_lamiera",
			"pulcino_mitragliere", "gallina_uova_bomba", "gallo_sentinella", "tacchino_furioso", "silos_instabile"]:
		for i in 3:
			deck0.append(id)
	for id in ["anatra_col_coltello", "oca_esattrice", "germano_di_vedetta", "cigno_col_remo", "pontile_dei_predoni",
			"patata_depressa", "carota_urlatrice", "rapa_rancorosa", "zucca_lievitata", "fienile_fumante"]:
		for i in 3:
			deck1.append(id)
	var m := Match.new(db)
	m.setup(42, [deck0, deck1], [["porcile", "porcile", "pollaio", "pollaio"], ["stagno", "stagno", "patate", "patate"]], ["nonna", "veterinario"])
	m.allow_replace = [false, false]
	m.players[0].empty_deck_rule = "reshuffle"
	m.players[1].empty_deck_rule = "reshuffle"
	var r := GameRunner.play(m)
	check(r["winner"] in [0, 1], true, "la partita IA contro IA ha un vincitore")
	check(r["turns"] < db.rule_i("max_turns"), true, "finisce prima del limite di turni")
	return true
