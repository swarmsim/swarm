'use strict'

describe 'Service: upgradetype', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  upgradetypes = {}
  beforeEach inject (_upgradetypes_) ->
    upgradetypes = _upgradetypes_

  it 'should parse the spreadsheet', ->
    expect(!!upgradetypes).toBe true
    expect(!!upgradetypes.list).toBe true
    expect(upgradetypes.list.length).toBeGreaterThan 4

describe 'Service: upgrade', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Game = {}
  unittypes = {}
  beforeEach inject (_Game_, _unittypes_) ->
    Game = _Game_
    unittypes = _unittypes_
  mkgame = (unittypes, reified=new Date 0) ->
    game = new Game {unittypes: unittypes, upgrades:{}, date:{reified:reified,started:reified,restarted:reified}, save:->}
    game.now = new Date 0
    return game

  # TODO why is this of all things disconnecting the test
  # ...because units have a cycle, and jasmine loops forever trying to print test failures with a cycle. D'oh.
  it 'buys upgrades', ->
    game = mkgame {territory:999999999}
    expect(upgrade = game.upgrade 'expansion').toBe game.unit('invisiblehatchery').upgrades.byName['expansion']
    expect(upgrade.count().toNumber()).toBe 0
    upgrade.buy()
    expect(upgrade.count().toNumber()).toBe 1

  it 'blocks expensive upgrades', ->
    game = mkgame {territory:1}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.count().toNumber()).toBe 0
    expect(-> upgrade.buy()).toThrow()
    expect(upgrade.count().toNumber()).toBe 0

  it 'calcs upgrade stats, no unit', ->
    game = mkgame {drone:99999999999999}
    upgrade = game.upgrade 'droneprod'
    upgrade2 = game.upgrade 'queenprod'
    stats = {}
    schema = {}
    upgrade.calcStats stats, schema
    expect(stats.prod.toNumber()).toBe 1
    stats2 = {}
    upgrade2.calcStats stats2, schema
    expect(stats2.prod.toNumber()).toBe 1

    upgrade.buy()
    stats = {}
    upgrade.calcStats stats, schema
    expect(stats.prod.toNumber()).toBeGreaterThan 1
    stats2 = {}
    upgrade2.calcStats stats2, schema
    expect(stats2.prod.toNumber()).toBe 1

  it 'buys/calcs max upgrades', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.maxCostMet().toNumber()).toBe 0
    game.unit('territory')._setCount 10
    expect(upgrade.maxCostMet().toNumber()).toBe 1
    game.unit('territory')._setCount 50
    expect(upgrade.maxCostMet().toNumber()).toBe 2
    game.unit('territory')._setCount 1000
    expect(upgrade.maxCostMet().toNumber()).toBe 5
    upgrade.buyMax()
    expect(upgrade.maxCostMet().toNumber()).toBe 0
    expect(upgrade.count().toNumber()).toBe 5

  it 'clones larvae', ->
    game = mkgame {energy:9999999999999999999, larva:1000, invisiblehatchery:1, nexus:999}
    upgrade = game.upgrade 'clonelarvae'
    unit = game.unit 'larva'
    expect(upgrade.effect[0].bank().toNumber()).toBe 1000
    expect(upgrade.effect[0].output().toNumber()).toBe 1000
    upgrade.buy 3
    expect(upgrade.count().toNumber()).toBe 3
    expect(unit.count().toNumber()).toBe 8000
    expect(upgrade.effect[0].bank().toNumber()).toBe 8000
    expect(upgrade.effect[0].output().toNumber()).toBe 8000

  it 'buy more than max', ->
    game = mkgame {territory:10}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.maxCostMet().toNumber()).toBe 1
    expect(upgrade.count().toNumber()).toBe 0
    upgrade.buy 10
    expect(upgrade.maxCostMet().toNumber()).toBe 0
    expect(upgrade.count().toNumber()).toBe 1

  it 'clones cocoons', ->
    game = mkgame {energy:1000000000000000000000000000000000000000, cocoon: 100, larva: 10, invisiblehatchery:1, nexus:999}
    cocoon = game.unit 'cocoon'
    larva = game.unit 'larva'
    upgrade = game.upgrade 'clonelarvae'
    expect(cocoon.count().toNumber()).toBe 100
    expect(larva.count().toNumber()).toBe 10
    expect(upgrade.effect[0].bank().toNumber()).toBe 110
    expect(upgrade.effect[0].cap().toNumber()).toBe 100000
    expect(upgrade.effect[0].output().toNumber()).toBe 110
    upgrade.buy()
    expect(cocoon.count().toNumber()).toBe 100 # no change
    expect(larva.count().toNumber()).toBe 120 # 0 base larvae + 100 cloned cocoons + 10 cloned larvae + 10 starting larvae

  it 'caps clones', ->
    game = mkgame {energy:1000000000000000000000000000000000000000, cocoon: 60000, larva: 70000, invisiblehatchery:1, nexus:999}
    cocoon = game.unit 'cocoon'
    larva = game.unit 'larva'
    upgrade = game.upgrade 'clonelarvae'
    expect(cocoon.count().toNumber()).toBe 60000
    expect(larva.count().toNumber()).toBe 70000
    expect(upgrade.effect[0].bank().toNumber()).toBe 130000
    expect(upgrade.effect[0].cap().toNumber()).toBe 100000
    expect(upgrade.effect[0].output().toNumber()).toBe 100000
    upgrade.buy()
    expect(cocoon.count().toNumber()).toBe 60000 # no change
    expect(larva.count().toNumber()).toBe 170000 # 70k base larvae + 100k cloned capped bank
    # cap is unchanged after clone
    expect(upgrade.effect[0].bank().toNumber()).toBe 230000
    expect(upgrade.effect[0].cap().toNumber()).toBe 100000
    expect(upgrade.effect[0].output().toNumber()).toBe 100000

  it 'sums costs', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(_.map upgrade.sumCost(1), (cost) -> [cost.unit.name, cost.val.toNumber()]).toEqual [['territory',10]]
    expect(_.map upgrade.sumCost(3), (cost) -> [cost.unit.name, cost.val.toNumber()]).toEqual [['territory',94.525]]

  it 'notices newly available upgrades', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.isNewlyUpgradable()).toBe false
    upgrade.watch false
    expect(upgrade.isNewlyUpgradable()).toBe false
    upgrade.watch true
    expect(upgrade.isNewlyUpgradable()).toBe false
    # we now have money for an upgrade
    game.unit('territory')._addCount 1
    expect(upgrade.isNewlyUpgradable()).toBe true
    # upon disabling isWatched, remove the indicator
    upgrade.watch false
    expect(upgrade.isNewlyUpgradable()).toBe false
    upgrade.watch true
    expect(upgrade.isNewlyUpgradable()).toBe true
    # stays removed when upgrade bought
    upgrade.buy()
    expect(upgrade.isNewlyUpgradable()).toBe false
    # we now have money for another upgrade, which disappears when watch disabled
    game.unit('territory')._addCount 50
    expect(upgrade.isNewlyUpgradable()).toBe true
    upgrade.watch false
    expect(upgrade.isNewlyUpgradable()).toBe false
    # money for a third upgrade does not make the indicator reappear, since we didn't buy upgrade #2
    game.unit('territory')._addCount 150
    expect(upgrade.isNewlyUpgradable()).toBe false

  xit 'doesnt notice invisible upgrades, even if we can afford them. https://github.com/erosson/swarm/issues/94', ->
    # disabled - this case isn't possible anymore
    game = mkgame {nest:25000}
    upgrade = game.upgrade 'nesttwin'
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    expect(upgrade.isVisible()).toBe false
    expect(upgrade.isCostMet()).toBe true
    # even though we can afford it, cannot view invisible upgrades
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    expect(upgrade.isVisible()).toEqual false
    expect(upgrade.isCostMet()).toEqual true
    # we now have visibility, and the indicator!
    game.unit('greaterqueen')._addCount 1
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe true
    expect(upgrade.isVisible()).toEqual true
    expect(upgrade.isCostMet()).toEqual true
    # goes away normally when viewed
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toBeGreaterThan 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    expect(upgrade.isVisible()).toEqual true
    expect(upgrade.isCostMet()).toEqual true

  it 'rushes meat', ->
    game = mkgame {energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, stinger:1}
    upgrade = game.upgrade 'meatrush'
    unit = game.unit 'meat'
    expect(upgrade.effect[0].output().toNumber()).toBe 1 * 7200
    expect(upgrade.effect[1].output().toNumber()).toBe 100000000000
    upgrade.buy 1
    expect(upgrade.count().toNumber()).toBe 1
    expect(unit.count().toNumber()).toBe 100000007200
    expect(upgrade.effect[0].output().toNumber()).toBe 1 * 7200
    expect(upgrade.effect[1].output().toNumber()).toBe 100000000000

  it 'rushes territory', ->
    game = mkgame {energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1}
    upgrade = game.upgrade 'territoryrush'
    unit = game.unit 'territory'
    expect(504).toBe new Decimal(0.07).times(7200).toNumber() #stupid floating-point precision
    expect(upgrade.effect[0].output().toNumber()).toBe 504
    expect(upgrade.effect[1].output().toNumber()).toBe 1000000000
    upgrade.buy 1
    expect(upgrade.count().toNumber()).toBe 1
    expect(unit.count().toNumber()).toBe 1000000000 + 504
    expect(upgrade.effect[0].output().toNumber()).toBe 504
    expect(upgrade.effect[1].output().toNumber()).toBe 1000000000

  it 'rushes larvae', ->
    game = mkgame {energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1}
    upgrade = game.upgrade 'larvarush'
    unit = game.unit 'larva'
    expect(upgrade.effect[0].output().toNumber()).toBe 2400
    expect(upgrade.effect[1].output().toNumber()).toBe 100000
    upgrade.buy 1
    expect(upgrade.count().toNumber()).toBe 1
    expect(unit.count().toNumber()).toBe 102400
    expect(upgrade.effect[0].output().toNumber()).toBe 2400
    expect(upgrade.effect[1].output().toNumber()).toBe 100000

  it 'randomly spawns premutagen when buying hatcheries', ->
    game = mkgame {meat:9e+100, premutagen:0}
    hatchery = game.upgrade 'hatchery'
    effect = hatchery.effect[1] # mutagen-spawner effect
    premutagen = game.unit 'premutagen'
    hatchery.buy 39
    expect(premutagen.count().toNumber()).toBe 0
    eff = hatchery.effect[1]
    # Random range, but consistent.
    expect(eff.type.name).toBe 'addUnitRand'
    spawned = eff.outputNext().qty.toNumber()
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    hatchery.buy 1
    # first spawn is guaranteed.
    expect(premutagen.count().toNumber()).toBe spawned
    expect(premutagen.count().toNumber()).not.toBeGreaterThan 10000
    expect(premutagen.count().toNumber()).not.toBeLessThan 7000

  it 'randomly spawns premutagen when buying expansions', ->
    game = mkgame {territory:9e+999, premutagen:0}
    hatchery = game.upgrade 'expansion'
    effect = hatchery.effect[1] # mutagen-spawner effect
    premutagen = game.unit 'premutagen'
    hatchery.buy 79
    expect(premutagen.count().toNumber()).toBe 0
    eff = hatchery.effect[1]
    # Random range, but consistent.
    expect(eff.type.name).toBe 'addUnitRand'
    spawned = eff.outputNext().qty.toNumber()
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    expect(eff.outputNext().qty.toNumber()).toBe spawned
    hatchery.buy 1
    # random range. first spawn is guaranteed.
    expect(premutagen.count().toNumber()).toBe spawned
    expect(premutagen.count().toNumber()).not.toBeGreaterThan 10000
    expect(premutagen.count().toNumber()).not.toBeLessThan 7000

  it 'rolls different mutagen values after ascending; mutagen spawns depend on date', ->
    game = mkgame {invisiblehatchery:1, meat:1e100}
    expect(game.session.date.restarted.getTime()).toBe 0
    premutagen = game.unit 'premutagen'
    game.upgrade('hatchery').buy 80
    precount = premutagen.count()
    expect(precount.isZero()).toBe false #sanity check

    # rolls change when date.restarted changes
    game.now = new Date 1
    game.ascend true
    expect(game.session.date.restarted.getTime()).toBe 1
    game.unit('meat')._setCount 1e100
    game.upgrade('hatchery').buy 80
    postcount = premutagen.count()
    expect(precount.toNumber()).not.toBe postcount.toNumber()

    # but change the date back, and mutagen rolls are identical
    game.ascend true
    game.session.date.restarted = new Date 0
    game.unit('meat')._setCount 1e100
    game.upgrade('hatchery').buy 80
    expect(precount.toNumber()).toBe premutagen.count().toNumber()

  it 'swarmwarps without changing energy', ->
    game = mkgame {energy:50000, nexus:999, invisiblehatchery:1, drone:1, meat:0}
    upgrade = game.upgrade 'swarmwarp'
    energy = game.unit 'energy'
    expect(energy.count().toNumber()).toBe 50000
    upgrade.buy 1
    expect(energy.count().toNumber()).toBe 48000
    upgrade.buy 1
    expect(energy.count().toNumber()).toBe 46000
  it "won't exceed maxlevel in count()", ->
    game = mkgame {}
    upgrade = game.upgrade 'achievementbonus'
    expect(upgrade.type.maxlevel).toBe 5
    expect(upgrade.count().toNumber()).toBe 0
    upgrade._setCount 999
    expect(upgrade.count().toNumber()).toBe 5

  it "won't buy more than maxlevel", ->
    game = mkgame {meat:1e300, territory:1e300}
    upgrade = game.upgrade 'achievementbonus'
    expect(upgrade.type.maxlevel).toBe 5

    expect(upgrade.count().toNumber()).toBe 0
    expect(upgrade.maxCostMet().toNumber()).toBe 5
    upgrade._setCount 1
    expect(upgrade.count().toNumber()).toBe 1
    expect(upgrade.maxCostMet().toNumber()).toBe 4
    upgrade._setCount 3
    expect(upgrade.count().toNumber()).toBe 3
    expect(upgrade.maxCostMet().toNumber()).toBe 2

  it "knows autobuyable upgrades depend on watched status", ->
    game = mkgame {}
    expect(game.upgrade('droneprod').isAutobuyable()).toBe true
    expect(game.upgrade('dronetwin').isAutobuyable()).toBe true
    expect(game.upgrade('swarmlingtwin').isAutobuyable()).toBe true
    expect(game.upgrade('mutatemeat').isAutobuyable()).toBe false
    game.upgrade('dronetwin').watch false
    expect(game.upgrade('dronetwin').isAutobuyable()).toBe false
    game.upgrade('dronetwin').watch true
    expect(game.upgrade('dronetwin').isAutobuyable()).toBe true

  it "calculates asymptotic stats multiplicatively, not additively. #264", ->
    game = mkgame {nexus:5, moth:1e1000, mutantnexus:1e1000}
    energyprod = game.unit('energy').velocity().toNumber()
    expect(energyprod).toBeGreaterThan 1.9
    expect(energyprod).toBeLessThan 2.1
