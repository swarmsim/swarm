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
    game = new Game {unittypes: unittypes, upgrades:{}, date:{reified:reified}, save:->}
    game.now = new Date 0
    return game

  # TODO why is this of all things disconnecting the test
  # ...because units have a cycle, and jasmine loops forever trying to print test failures with a cycle. D'oh.
  it 'buys upgrades', ->
    game = mkgame {territory:999999999}
    expect(upgrade = game.upgrade 'expansion').toBe game.unit('invisiblehatchery').upgrades.byName['expansion']
    expect(upgrade.count()).toBe 0
    upgrade.buy()
    expect(upgrade.count()).toBe 1

  it 'blocks expensive upgrades', ->
    game = mkgame {territory:1}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.count()).toBe 0
    expect(-> upgrade.buy()).toThrow()
    expect(upgrade.count()).toBe 0

  it 'calcs upgrade stats, no unit', ->
    game = mkgame {drone:99999999999999}
    upgrade = game.upgrade 'droneprod'
    upgrade2 = game.upgrade 'queenprod'
    stats = {}
    schema = {}
    upgrade.stats(stats, schema)
    expect(stats.prod).toBe 1
    stats2 = {}
    upgrade2.stats(stats2, schema)
    expect(stats2.prod).toBe 1

    upgrade.buy()
    stats = {}
    upgrade.stats(stats, schema)
    expect(stats.prod).toBeGreaterThan 1
    stats2 = {}
    upgrade2.stats(stats2, schema)
    expect(stats2.prod).toBe 1

  it 'buys/calcs max upgrades', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.maxCostMet()).toBe 0
    game.unit('territory')._setCount 10
    expect(upgrade.maxCostMet()).toBe 1
    game.unit('territory')._setCount 50
    expect(upgrade.maxCostMet()).toBe 2
    game.unit('territory')._setCount 1000
    expect(upgrade.maxCostMet()).toBe 5
    upgrade.buyMax()
    expect(upgrade.maxCostMet()).toBe 0
    expect(upgrade.count()).toBe 5

  it 'clones larvae', ->
    game = mkgame {energy:9999999999999999999, larva:1000, invisiblehatchery:1, nexus:999}
    upgrade = game.upgrade 'clonelarvae'
    unit = game.unit 'larva'
    expect(upgrade.effect[0].bank()).toBe 1000
    expect(upgrade.effect[0].output()).toBe 1000
    upgrade.buy 3
    expect(upgrade.count()).toBe 3
    expect(unit.count()).toBe 8000
    expect(upgrade.effect[0].bank()).toBe 8000
    expect(upgrade.effect[0].output()).toBe 8000

  it 'buy more than max', ->
    game = mkgame {territory:10}
    upgrade = game.upgrade 'expansion'
    expect(upgrade.maxCostMet()).toBe 1
    expect(upgrade.count()).toBe 0
    upgrade.buy 10
    expect(upgrade.maxCostMet()).toBe 0
    expect(upgrade.count()).toBe 1

  it 'clones cocoons', ->
    game = mkgame {energy:1000000000000000000000000000000000000000, cocoon: 100, larva: 10, invisiblehatchery:1, nexus:999}
    cocoon = game.unit 'cocoon'
    larva = game.unit 'larva'
    upgrade = game.upgrade 'clonelarvae'
    expect(cocoon.count()).toBe 100
    expect(larva.count()).toBe 10
    expect(upgrade.effect[0].bank()).toBe 110
    expect(upgrade.effect[0].cap()).toBe 100000
    expect(upgrade.effect[0].output()).toBe 110
    upgrade.buy()
    expect(cocoon.count()).toBe 100 # no change
    expect(larva.count()).toBe 120 # 0 base larvae + 100 cloned cocoons + 10 cloned larvae + 10 starting larvae

  it 'caps clones', ->
    game = mkgame {energy:1000000000000000000000000000000000000000, cocoon: 60000, larva: 70000, invisiblehatchery:1, nexus:999}
    cocoon = game.unit 'cocoon'
    larva = game.unit 'larva'
    upgrade = game.upgrade 'clonelarvae'
    expect(cocoon.count()).toBe 60000
    expect(larva.count()).toBe 70000
    expect(upgrade.effect[0].bank()).toBe 130000
    expect(upgrade.effect[0].cap()).toBe 100000
    expect(upgrade.effect[0].output()).toBe 100000
    upgrade.buy()
    expect(cocoon.count()).toBe 60000 # no change
    expect(larva.count()).toBe 170000 # 70k base larvae + 100k cloned capped bank
    # cap is unchanged after clone
    expect(upgrade.effect[0].bank()).toBe 230000
    expect(upgrade.effect[0].cap()).toBe 100000
    expect(upgrade.effect[0].output()).toBe 100000

  it 'sums costs', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(_.map upgrade.sumCost(1), (cost) -> [cost.unit.name, cost.val]).toEqual [['territory',10]]
    expect(_.map upgrade.sumCost(3), (cost) -> [cost.unit.name, cost.val]).toEqual [['territory',94.525]]

  it 'notices newly available upgrades', ->
    game = mkgame {territory:9}
    upgrade = game.upgrade 'expansion'
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    # we now have money for an upgrade
    game.unit('territory')._addCount 1
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe true
    # upon seeing the upgrade with viewNewUpgrades(), remove the indicator
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toEqual 1
    expect(upgrade.isNewlyUpgradable()).toBe false
    # stays removed when upgrade bought
    upgrade.buy()
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe false
    # we now have money for another upgrade, which disappears when viewNewUpgradesed
    game.unit('territory')._addCount 50
    expect(upgrade._lastUpgradeSeen).toEqual 0
    expect(upgrade.isNewlyUpgradable()).toBe true
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toEqual 1
    expect(upgrade.isNewlyUpgradable()).toBe false
    # money for a third upgrade does not make the indicator reappear, since we didn't buy upgrade #2
    game.unit('territory')._addCount 150
    upgrade.viewNewUpgrades()
    expect(upgrade._lastUpgradeSeen).toEqual 2
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
    expect(upgrade.effect[0].output()).toBe 1 * 7200
    expect(upgrade.effect[1].output()).toBe 100000000000
    upgrade.buy 1
    expect(upgrade.count()).toBe 1
    expect(unit.count()).toBe 100000007200
    expect(upgrade.effect[0].output()).toBe 1 * 7200
    expect(upgrade.effect[1].output()).toBe 100000000000

  it 'rushes territory', ->
    game = mkgame {energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1}
    upgrade = game.upgrade 'territoryrush'
    unit = game.unit 'territory'
    expect(upgrade.effect[0].output()).toBe 0.07 * 7200
    expect(upgrade.effect[1].output()).toBe 1000000000
    upgrade.buy 1
    expect(upgrade.count()).toBe 1
    expect(unit.count()).toBe 1000000000 + 0.07 * 7200
    expect(upgrade.effect[0].output()).toBe 0.07 * 7200
    expect(upgrade.effect[1].output()).toBe 1000000000

  it 'rushes larvae', ->
    game = mkgame {energy:9999999999999999999, nexus:999, invisiblehatchery:1, drone:1, swarmling:1}
    upgrade = game.upgrade 'larvarush'
    unit = game.unit 'larva'
    expect(upgrade.effect[0].output()).toBe 2400
    expect(upgrade.effect[1].output()).toBe 100000
    upgrade.buy 1
    expect(upgrade.count()).toBe 1
    expect(unit.count()).toBe 102400
    expect(upgrade.effect[0].output()).toBe 2400
    expect(upgrade.effect[1].output()).toBe 100000
