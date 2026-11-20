# Catalogo delle abilità

Generato dal codice dell'APK. Per ogni effetto: quando scatta, cosa tocca e quali parametri usa.
`Val1`/`Val2` sono i numeri della singola carta (scaricati dal server) e **si moltiplicano per il livello della carta**.
Le colonne "Effetto" sono ricavate in automatico dalle chiamate nel codice: indicano cosa la carta modifica, non l'ordine esatto delle operazioni.

## Creature (abilità attivabili) (140)

| Nome interno | Quando | Effetto | Parametri |
|---|---|---|---|
| `ATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 |
| `ATKBonusAdjacentEmpty` | attivazione (a pagamento) | modifica ATK, corsie adiacenti | Val1 |
| `ATKBonusAll` | attivazione (a pagamento) | modifica ATK | Val1 |
| `ATKBonusCreatureFaction` | attivazione (a pagamento) | modifica ATK, dipende da fazione | Val1 Val2 |
| `ATKBonusCreatureFactionNextBattle` | attivazione (a pagamento), inizio turno | modifica ATK, dipende da fazione | Val1 Val2 |
| `ATKBonusDamageAll` | attivazione (a pagamento) | modifica ATK, danno a creatura | Val1 Val2 |
| `ATKBonusDamageSelf` | attivazione (a pagamento) | modifica ATK, danno a creatura | Val1 Val2 |
| `ATKBonusFloopCount` | attivazione (a pagamento) | modifica ATK, conta attivazioni | — |
| `ATKBonusFloopTurn` | attivazione (a pagamento) | modifica ATK, conta attivazioni | Val1 |
| `ATKBonusForBuilding` | attivazione (a pagamento) | modifica ATK, bersaglio scelto | Val1 |
| `ATKBonusOpponentLandscapes` | attivazione (a pagamento) | modifica ATK | Val1 Val2 |
| `ATKDEFBonus` | attivazione (a pagamento) | modifica ATK, modifica DEF | Val1 Val2 |
| `ATKHealBonus` | attivazione (a pagamento) | modifica ATK, cura creatura | Val1 Val2 |
| `ATKPenaltyCreatures` | attivazione (a pagamento) | modifica ATK, corsia di fronte, penalità ATK al leader | Val1 |
| `ATKPenaltyFaction` | attivazione (a pagamento) | modifica ATK, dipende da fazione, penalità ATK al leader | Val1 Val2 |
| `ATKPenaltySacrifice` | attivazione (a pagamento) | modifica ATK, manda negli scarti, toglie dal campo, corsia di fronte, penalità ATK al leader | Val1 |
| `AdjacentATKBonus` | attivazione (a pagamento) | modifica ATK, corsie adiacenti | Val1 |
| `AdjacentDEFBonus` | attivazione (a pagamento) | modifica DEF, corsie adiacenti | Val1 |
| `BlockFloop` | attivazione (a pagamento) | blocca abilità, corsia di fronte | — |
| `BlockFloopTarget` | attivazione (a pagamento) | blocca abilità, bersaglio scelto, creature | — |
| `BlockSummon` | attivazione (a pagamento) | disabilita corsia, corsia di fronte, evocazione | — |
| `BonusATKTarget` | attivazione (a pagamento) | modifica ATK, bersaglio scelto | Val1 |
| `BonusDEFTarget` | attivazione (a pagamento) | modifica DEF, bersaglio scelto | Val1 |
| `CardsATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 |
| `CardsDEFBonus` | attivazione (a pagamento) | modifica DEF | Val1 |
| `ConvertOpponentAttToHP` | attivazione (a pagamento) | cura creatura, corsia di fronte | — |
| `CreatureATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 |
| `CreatureDEFBonus` | attivazione (a pagamento) | modifica DEF | Val1 |
| `CreatureFactionATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 Val2 |
| `CreatureFactionDEFBonus` | attivazione (a pagamento) | modifica DEF | Val1 Val2 |
| `DEFBonus` | attivazione (a pagamento) | modifica DEF | Val1 |
| `DEFBonusBuildings` | attivazione (a pagamento) | modifica DEF | Val1 |
| `DEFBonusCreatures` | attivazione (a pagamento) | modifica DEF | Val1 |
| `DEFBonusOpponentLandscapes` | attivazione (a pagamento) | modifica DEF | Val1 Val2 |
| `DEFBonusRandom` | attivazione (a pagamento) | modifica DEF | Val1 |
| `DEFPenaltyATKBonusAdjacent` | attivazione (a pagamento) | modifica ATK, modifica DEF, corsie adiacenti | Val1 Val2 |
| `DEFPenaltyDamageSelf` | attivazione (a pagamento) | modifica DEF, danno a creatura, corsia di fronte | Val1 Val2 |
| `DEFPenaltyFaction` | attivazione (a pagamento) | modifica DEF, dipende da fazione | Val1 Val2 |
| `DamageAll` | attivazione (a pagamento) | danno a creatura | Val1 |
| `DamageAllDamageOne` | attivazione (a pagamento) | danno a creatura | Val1 Val2 |
| `DamageAllHealAll` | attivazione (a pagamento) | danno a creatura, cura creatura | Val1 Val2 |
| `DamageAndDiscard` | attivazione (a pagamento) | danno a creatura, manda negli scarti, toglie dal campo, corsia di fronte | Val1 |
| `DamageAndTakeCard` | attivazione (a pagamento), una creatura muore | danno a creatura, recupera dagli scarti, corsia di fronte | Val1 |
| `DamageFaction` | attivazione (a pagamento) | danno a creatura, dipende da fazione | Val1 Val2 |
| `DamageHero` | attivazione (a pagamento) | PV leader (danno o cura) | Val1 |
| `DamageHeroCards` | attivazione (a pagamento) | PV leader (danno o cura) | Val1 |
| `DamageHeroFloop` | attivazione (a pagamento) | PV leader (danno o cura), conta attivazioni | Val1 |
| `DamageOneHealAll` | attivazione (a pagamento) | danno a creatura, cura creatura | Val1 Val2 |
| `DamageOpponent` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageOpponentAdjacents` | attivazione (a pagamento) | danno a creatura, corsie adiacenti, corsia di fronte | Val1 |
| `DamageOpponentAndHero` | attivazione (a pagamento) | danno a creatura, PV leader (danno o cura), corsia di fronte | Val1 |
| `DamageOpponentAndSelf` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 Val2 |
| `DamageOpponentCards` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageOpponentDEF` | attivazione (a pagamento) | danno a creatura, corsia di fronte | — |
| `DamageOpponentDamage` | attivazione (a pagamento) | danno a creatura, corsia di fronte | — |
| `DamageOpponentDiscardPile` | attivazione (a pagamento) | danno a creatura, corsia di fronte, usa gli scarti | Val1 Val2 |
| `DamageOpponentDiscardedCreatures` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageOpponentFloop` | attivazione (a pagamento) | danno a creatura, corsia di fronte, conta attivazioni | Val1 |
| `DamageOpponentHealSelf` | attivazione (a pagamento) | danno a creatura, cura creatura, corsia di fronte | Val1 Val2 |
| `DamageOpponentIfDamagedLastTurn` | attivazione (a pagamento) | danno a creatura, corsia di fronte (costante 100.0) | Val1 |
| `DamageOpponentLadscapes` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 Val2 |
| `DamageOpponentLandscapeVariety` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageOpponentLowerATK` | attivazione (a pagamento) | modifica ATK, danno a creatura, corsia di fronte | Val1 Val2 |
| `DamageOpponentMyBuildings` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageOpponentRarity` | attivazione (a pagamento) | danno a creatura, corsia di fronte, dipende da rarità | Val1 |
| `DamageOpponentTheirBuildings` | attivazione (a pagamento) | danno a creatura, corsia di fronte | Val1 |
| `DamageRandom` | attivazione (a pagamento) | danno a creatura | Val1 |
| `DamageTarget` | attivazione (a pagamento) | danno a creatura, bersaglio scelto | Val1 |
| `DamageTargetFaction` | attivazione (a pagamento) | danno a creatura, bersaglio scelto, dipende da fazione | Val1 Val2 |
| `DamageTargetHealSelf` | attivazione (a pagamento) | danno a creatura, cura creatura, bersaglio scelto | Val1 Val2 |
| `DestroyOpponentBuilding` | attivazione (a pagamento) | manda negli scarti, toglie dal campo, corsia di fronte | — |
| `DrainAdjacentDEFAddATKBonus` | attivazione (a pagamento) | modifica ATK, modifica DEF, corsie adiacenti | Val1 Val2 |
| `DrainOpponentATKLowerSelfDEF` | attivazione (a pagamento) | modifica ATK, modifica DEF, corsia di fronte | — |
| `DrawCards` | attivazione (a pagamento) | pesca | Val1 |
| `DrawCardsSacrifice` | attivazione (a pagamento) | pesca, manda negli scarti, toglie dal campo | Val1 |
| `DrawCardsTake` | attivazione (a pagamento) | pesca, toglie dal campo | Val1 |
| `EmptyLaneATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 |
| `EqualizeATK` | attivazione (a pagamento) | modifica ATK, corsia di fronte | — |
| `FloopAdjacent` | attivazione (a pagamento) | corsie adiacenti, bersaglio scelto | — |
| `GainActionPoints` | attivazione (a pagamento) | punti azione bonus (turno dopo) | Val1 |
| `HealAdjacent` | attivazione (a pagamento) | cura creatura, corsie adiacenti | Val1 |
| `HealAdjacentDEFAndDiscard` | attivazione (a pagamento) | cura creatura, manda negli scarti, toglie dal campo, corsie adiacenti | — |
| `HealAdjacentDamage` | attivazione (a pagamento) | cura creatura, corsie adiacenti | — |
| `HealAdjacentHPAndDiscard` | attivazione (a pagamento) | cura creatura, manda negli scarti, toglie dal campo, corsie adiacenti | Val1 |
| `HealAll` | attivazione (a pagamento) | cura creatura | Val1 |
| `HealAllOpponentLandscapes` | attivazione (a pagamento) | cura creatura | Val1 Val2 |
| `HealAllSacrifice` | attivazione (a pagamento) | cura creatura, manda negli scarti, toglie dal campo | — |
| `HealHero` | attivazione (a pagamento) | PV leader (danno o cura) | Val1 |
| `HealHeroATK` | attivazione (a pagamento) | PV leader (danno o cura) | — |
| `HealHeroCreatures` | attivazione (a pagamento) | PV leader (danno o cura) | Val1 |
| `HealHeroFloop` | attivazione (a pagamento) | PV leader (danno o cura), conta attivazioni | Val1 |
| `HealRandom` | attivazione (a pagamento) | cura creatura | Val1 |
| `HealSelf` | attivazione (a pagamento) | cura creatura | — |
| `HealSelfAndAdjacent` | attivazione (a pagamento) | cura creatura, corsie adiacenti | Val1 |
| `HealTarget` | attivazione (a pagamento) | cura creatura, bersaglio scelto | Val1 |
| `HealTargetAdjacent` | attivazione (a pagamento) | cura creatura, corsie adiacenti, bersaglio scelto | Val1 |
| `HealTargetAll` | attivazione (a pagamento) | cura creatura, bersaglio scelto | — |
| `HealTargetBuildings` | attivazione (a pagamento) | cura creatura, bersaglio scelto | Val1 |
| `HealTargetCards` | attivazione (a pagamento) | cura creatura, bersaglio scelto | Val1 |
| `HealTargetCreatures` | attivazione (a pagamento) | cura creatura, bersaglio scelto | Val1 |
| `HealTargetFloop` | attivazione (a pagamento) | cura creatura, bersaglio scelto, conta attivazioni | Val1 |
| `HealTargetLandscapes` | attivazione (a pagamento) | cura creatura, bersaglio scelto | Val1 |
| `HelplessOpponent` | attivazione (a pagamento) | rende inerme, corsia di fronte | — |
| `IncreaseCritArea` | attivazione (a pagamento) | allarga zona critico (costante 100.0) | Val1 |
| `IncreaseDefenseArea` | attivazione (a pagamento) | allarga zona difesa (costante 100.0) | Val1 |
| `IncreaseDefenseCritArea` | attivazione (a pagamento) | allarga critico difesa (costante 100.0) | Val1 |
| `IncreaseFloopCost` | attivazione (a pagamento) | costo abilità | Val1 |
| `IncreaseHitArea` | attivazione (a pagamento) | allarga zona colpo (costante 100.0) | Val1 |
| `LandscapeATKBonus` | attivazione (a pagamento) | modifica ATK | Val1 Val2 |
| `LandscapeDEFBonus` | attivazione (a pagamento) | modifica DEF | Val1 Val2 |
| `LowerATKAll` | attivazione (a pagamento) | modifica ATK | Val1 |
| `LowerATKBonusATK` | attivazione (a pagamento) | modifica ATK, corsia di fronte | Val1 Val2 |
| `LowerATKByATK` | attivazione (a pagamento) | modifica ATK, corsia di fronte | — |
| `LowerATKOpponent` | attivazione (a pagamento) | modifica ATK, corsia di fronte | Val1 |
| `LowerATKOpponentCards` | attivazione (a pagamento) | modifica ATK, corsia di fronte | Val1 |
| `LowerATKTarget` | attivazione (a pagamento) | modifica ATK, bersaglio scelto | Val1 |
| `LowerAllATKSacrifice` | attivazione (a pagamento) | modifica ATK, manda negli scarti, toglie dal campo | Val1 |
| `LowerDEFAll` | attivazione (a pagamento) | modifica DEF | Val1 |
| `LowerDEFByATK` | attivazione (a pagamento) | modifica DEF, corsia di fronte | — |
| `LowerDEFFloop` | attivazione (a pagamento) | modifica DEF, bersaglio scelto, conta attivazioni | Val1 |
| `LowerDEFOpponent` | attivazione (a pagamento) | modifica DEF, corsia di fronte | Val1 |
| `LowerDEFTarget` | attivazione (a pagamento) | modifica DEF, bersaglio scelto | Val1 |
| `LowerFloopCost` | attivazione (a pagamento) | costo abilità | Val1 |
| `LowerMP` | attivazione (a pagamento) | punti azione | Val1 |
| `ProtectTarget` | attivazione (a pagamento) | protegge, bersaglio scelto, creature | — |
| `Protection` | attivazione (a pagamento) | impedisce di attaccare, corsia di fronte | — |
| `RaiseDEFFloop` | attivazione (a pagamento) | modifica DEF, bersaglio scelto, conta attivazioni | Val1 |
| `RandomDEFBonus` | attivazione (a pagamento) | modifica DEF, casuale | Val1 Val2 |
| `RandomDiscardCard` | attivazione (a pagamento) | recupera dagli scarti, casuale, usa gli scarti | — |
| `ResetSelf` | attivazione (a pagamento) | modifica ATK, modifica DEF, cura creatura | — |
| `ResetTarget` | attivazione (a pagamento) | modifica ATK, modifica DEF, cura creatura, azzera modifiche, bersaglio scelto | — |
| `ReturnDiscardCard` | attivazione (a pagamento) | recupera dagli scarti, usa gli scarti | Val1 |
| `ReturnHandsDrawCardsAddMP` | attivazione (a pagamento), inizio turno | pesca, punti azione, usa la mano, rimescola | Val1 Val2 |
| `ReturnOppnentToHand` | attivazione (a pagamento) | manda negli scarti, toglie dal campo, corsia di fronte | Val1 |
| `ReturnTargetToHand` | attivazione (a pagamento) | manda negli scarti, toglie dal campo, bersaglio scelto | Val1 |
| `SacrificeForMP` | attivazione (a pagamento) | punti azione, manda negli scarti, toglie dal campo | Val1 |
| `SelfAndAdjacentATKBonus` | attivazione (a pagamento) | modifica ATK, corsie adiacenti | Val1 |
| `SelfAndAdjacentDEFBonus` | attivazione (a pagamento) | modifica DEF, corsie adiacenti | Val1 |
| `ShuffleHand` | attivazione (a pagamento) | pesca, usa la mano, rimescola | — |
| `TargetATKBonusATK` | attivazione (a pagamento) | modifica ATK, bersaglio scelto | Val1 Val2 |

## Edifici (26)

| Nome interno | Quando | Effetto | Parametri |
|---|---|---|---|
| `ATKBonusBuilding` | entra in gioco, esce di gioco | aura continua ATK | Val1 |
| `ATKBonusCards` | entra in gioco, esce di gioco | aura continua ATK | Val1 |
| `ATKBonusCreatures` | entra in gioco, esce di gioco | aura continua ATK | Val1 |
| `ATKBonusLandscapes` | entra in gioco, esce di gioco | aura continua ATK | Val1 |
| `ATKDEFBonusBuilding` | entra in gioco, esce di gioco | aura continua ATK, aura continua DEF | Val1 Val2 |
| `ATKDEFBonusEmptyLanes` | entra in gioco, esce di gioco | aura continua ATK, aura continua DEF | Val1 Val2 |
| `ATKOnFloop` | una creatura usa l'abilità | aura continua ATK | Val1 |
| `ActionOnFloop` | una creatura usa l'abilità | punti azione | Val1 |
| `CreatureDamageOnEntry` | entra in gioco | danno a creatura, corsia di fronte | Val1 |
| `DEFBonusBuilding` | entra in gioco, esce di gioco | aura continua DEF | Val1 |
| `DEFBonusCards` | entra in gioco, esce di gioco | aura continua DEF | Val1 |
| `DEFBonusCreaturesBuilding` | entra in gioco, esce di gioco | aura continua DEF | Val1 |
| `DEFOnFloop` | una creatura usa l'abilità | aura continua DEF | Val1 |
| `DamageFactor` | entra in gioco, esce di gioco | moltiplicatore danni (costante 0.5) | — |
| `DamageHeroOnDeath` | una creatura muore | PV leader (danno o cura) | Val1 |
| `DamageReduction` | entra in gioco, esce di gioco | riduzione danni | Val1 |
| `FloopCostMod` | entra in gioco, esce di gioco, una creatura usa l'abilità | costo abilità | Val1 |
| `HealHeroOnDeath` | una creatura muore | PV leader (danno o cura) | Val1 |
| `HealOnVictory` | la creatura vince uno scontro | cura creatura | Val1 |
| `HealingFactor` | entra in gioco, esce di gioco | moltiplicatore cure (costante 2.0) | — |
| `HeroDamageOnEntry` | entra in gioco | PV leader (danno o cura) | Val1 |
| `RarityGate` | entra in gioco, esce di gioco | limite di rarità, corsia di fronte | Val1 |
| `ReturnToHandSacrifice` | una creatura muore | manda negli scarti, recupera dagli scarti, toglie dal campo | — |
| `StartTurnHealCreature` | inizio turno | cura creatura | Val1 |
| `StartTurnHealCreatures` | inizio turno | cura creatura | Val1 |
| `SwapATKDEFBuilding` | entra in gioco, esce di gioco | modifica ATK, modifica DEF | — |

## Incantesimi e abilità dei leader (73)

| Nome interno | Quando | Effetto | Parametri |
|---|---|---|---|
| `ATKBonusAllCreaturesLeader` | attivazione, lancio | modifica ATK | Val1 |
| `ATKBonusFactionCreaturesLeader` | attivazione, lancio | modifica ATK, dipende da fazione | Val1 |
| `ATKDEFBonusFactionCreaturesLeader` | attivazione, lancio | modifica ATK, modifica DEF, dipende da fazione | Val1 Val2 |
| `ATKDEFFaction` | attivazione, lancio | moltiplica ATK, moltiplica DEF, corsia di fronte, dipende da fazione (costante 1.5) | Val1 |
| `ActionPointCreatures` | attivazione, lancio | punti azione | — |
| `ActionPointLandscapes` | attivazione, lancio | punti azione | — |
| `AttackCreature` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackCreatureCorn` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackCreatureCotton` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackCreaturePlains` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackCreatureSand` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackCreatureSwamp` | attivazione, lancio | danno a creatura, corsia di fronte, bersaglio scelto, dipende da fazione | Val1 |
| `AttackSelf` | attivazione, lancio | danno a creatura, bersaglio scelto | — |
| `BlockCardBuilding` | — | — | — |
| `BlockCardBuildingDestroyBuildingsLeader` | — | — | — |
| `BlockCardCreature` | — | — | — |
| `BlockCardCreatureDestroyBuildingsLeader` | — | — | — |
| `BlockCardSpell` | — | — | — |
| `BlockCardSpellDestroyBuildingsLeader` | — | — | — |
| `BlockCardType` | attivazione, lancio | — | Val1 |
| `BlockCardTypeDestroyBuildingsLeader` | attivazione, lancio | manda negli scarti, toglie dal campo, usa la mano | — |
| `BlockTargetFloop` | attivazione, lancio | blocca abilità, bersaglio scelto, creature | — |
| `DEFBonusAllCreaturesLeader` | attivazione, lancio | modifica DEF | Val1 |
| `DEFBonusFactionCreaturesLeader` | attivazione, lancio | modifica DEF, dipende da fazione | Val1 |
| `DamageToATK` | attivazione, lancio | modifica ATK, bersaglio scelto | — |
| `DestroyBuilding` | attivazione, lancio | manda negli scarti, toglie dal campo, bersaglio scelto, sacrificio | — |
| `DestroyBuildingLane` | attivazione, lancio | manda negli scarti, toglie dal campo, corsia di fronte, bersaglio scelto, sacrificio | — |
| `DestroyBuildings` | attivazione, lancio | manda negli scarti, toglie dal campo, corsia di fronte | — |
| `DestroyEntityForAction` | attivazione, lancio | punti azione, manda negli scarti, toglie dal campo, bersaglio scelto, sacrificio | Val1 |
| `DestroyEntityForCards` | attivazione, lancio | pesca, manda negli scarti, toglie dal campo, bersaglio scelto, sacrificio | Val1 Val2 |
| `DestroyHighRarityTarget` | attivazione, lancio | danno a creatura, bersaglio scelto, dipende da rarità | Val1 |
| `DestroyHigherRarity` | attivazione, lancio | danno a creatura, dipende da rarità | Val1 |
| `DestroyLowerRarity` | attivazione, lancio | danno a creatura, dipende da rarità | Val1 |
| `DisableLane` | lancio | disabilita corsia, bersaglio scelto | — |
| `DiscardForPoints` | attivazione, lancio | punti azione, manda negli scarti, usa la mano | Val1 |
| `DiscardTarget` | attivazione, lancio | manda negli scarti, toglie dal campo | — |
| `DoubleDamage` | attivazione, lancio | danno a creatura, bersaglio scelto | — |
| `DrainOpponentHealth` | attivazione, lancio | PV leader (danno o cura) | Val1 |
| `DrawCardsLeader` | attivazione, lancio | pesca | Val1 |
| `DrawCardsSpell` | attivazione, lancio | pesca | Val1 |
| `EmptyLaneCards` | attivazione, lancio | pesca | — |
| `FlatFloopCost` | attivazione, lancio | costo abilità fisso | Val1 |
| `GainActionPointsLeader` | attivazione, lancio | punti azione | Val1 |
| `HealAllCreatures` | attivazione, lancio | cura creatura (costante 0.5) | — |
| `HealAllCreaturesLeader` | attivazione, lancio | cura creatura | — |
| `HealAllFactionCreaturesLeader` | attivazione, lancio | cura creatura, dipende da fazione | — |
| `HealCreature` | attivazione, lancio | cura creatura, bersaglio scelto | — |
| `HealCreatureLeader` | attivazione, lancio | cura creatura, bersaglio scelto | — |
| `HealCreatures` | attivazione, lancio | cura creatura | — |
| `HealSelfATK` | attivazione, lancio | cura creatura, bersaglio scelto | — |
| `KillLoneOpponent` | attivazione, lancio | danno a creatura | — |
| `LeaderScript` | — | ricarica | — |
| `MoveBuildingOpponent` | attivazione, lancio | bersaglio scelto, edifici | — |
| `MoveBuildingSelf` | attivazione, lancio | bersaglio scelto, edifici | — |
| `Polymorph` | attivazione, lancio | modifica ATK, modifica DEF, bersaglio scelto, trasforma | — |
| `RandomCard` | attivazione, lancio | recupera dagli scarti | Val1 |
| `ReduceATK` | attivazione, lancio | moltiplica ATK, corsia di fronte (costante 0.5) | — |
| `ReduceActionPoints` | attivazione, lancio | punti azione | — |
| `ReduceCost` | attivazione, lancio | sconto | — |
| `ReduceCostLeader` | attivazione, lancio | sconto | — |
| `ReduceDEF` | attivazione, lancio | moltiplica DEF, corsia di fronte (costante 0.5) | — |
| `ReduceFactionCreatureCostLeader` | attivazione, lancio | sconto, usa la mano | Val1 Val2 |
| `ReduceTypeCostLeader` | attivazione, lancio | sconto, usa la mano | Val1 |
| `ReturnBuildingsLeader` | attivazione, lancio | manda negli scarti, toglie dal campo | — |
| `ReturnCard` | attivazione, lancio | recupera dagli scarti, usa gli scarti | Val1 |
| `ReturnCardLeader` | attivazione, lancio | recupera dagli scarti, usa gli scarti | — |
| `ReturnCardTypeLeader` | attivazione, lancio | recupera dagli scarti, usa gli scarti | — |
| `ReturnCreature` | attivazione, lancio | toglie dal campo, bersaglio scelto | — |
| `ReturnCreatures` | attivazione, lancio | manda negli scarti, toglie dal campo | — |
| `ReturnOpponentCreature` | attivazione, lancio | manda negli scarti, toglie dal campo, bersaglio scelto | — |
| `ShuffleAndDraw` | attivazione, lancio | pesca, usa la mano, rimescola | — |
| `SwapATKDEFOpponent` | attivazione, lancio | modifica ATK, modifica DEF, bersaglio scelto | — |
| `SwapATKDEFSelf` | attivazione, lancio | modifica ATK, modifica DEF, bersaglio scelto | — |

