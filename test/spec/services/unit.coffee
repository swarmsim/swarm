'use strict'

describe 'Service: unittypes', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  unittypes = {}
  UnitTypes = {}
  UnitType = {}
  beforeEach inject (_unittypes_, _UnitTypes_, _UnitType_) ->
    unittypes = _unittypes_
    UnitTypes = _UnitTypes_
    UnitType = _UnitType_

  sorted = (list) ->
    ret = _.clone list
    ret.sort()
    return ret
  it 'should do something', ->
    expect(!!unittypes).toBe true

  # TODO: since writing this test, the list of drone-ancestors has exploded to
  # at least 10 tiers. This test would now be too unwieldy; need to rewrite it
  # to use a non-production unit spreadsheet.
  xit 'should build a production-graph', ->
    expect(sorted _.keys unittypes.byName.meat.producerPath).toEqual sorted ['drone', 'queen', 'nest', 'hive']
    expect(unittypes.byName.meat.producerNames().hive).toEqual [['hive', 'nest', 'queen', 'drone']]
    expect(unittypes.byName.meat.producerNames()).toEqual
      hive: [['hive', 'nest', 'queen', 'drone']]
      nest: [['nest', 'queen', 'drone']]
      queen: [['queen', 'drone']]
      drone: [['drone']]
    expect(unittypes.byName.drone.producerNames()).toEqual
      hive: [['hive', 'nest', 'queen']]
      nest: [['nest', 'queen']]
      queen: [['queen']]
    expect(unittypes.byName.queen.producerNames()).toEqual
      hive: [['hive', 'nest']]
      nest: [['nest']]
    expect(unittypes.byName.nest.producerNames()).toEqual
      hive: [['hive']]
    expect(unittypes.byName.hive.producerNames()).toEqual {}

  it 'should build a production-graph (minimal)', ->
    for ancestor in ['hive', 'nest', 'queen', 'drone']
      expect(unittypes.byName.meat.producerPath[ancestor]).not.toBeUndefined()
    expect(unittypes.byName.meat.producerPath.territory).toBeUndefined()

describe 'Service: unit', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  game = {}
  Game = {}
  unittypes = {}
  util = {}
  beforeEach inject (_Game_, _unittypes_, _util_) ->
    #game = _game_
    Game = _Game_
    unittypes = _unittypes_
    util = _util_
  mkgame = (unittypes, reified=new Date 0) ->
    game = new Game {unittypes: unittypes, upgrades:{}, date:{reified:reified}, save:->}
    game.now = new Date 0
    return game

  ct = (name, dt) ->
    game.tick new Date dt*1000
    return game.unit(name).count().toNumber()
  withNoTick = (game, fn) ->
    now = game.now
    try
      return fn()
    finally
      game.now = now
  it 'calculates a single resource\'s value over time (meat:1)', ->
    game = mkgame {meat:1}
    expect(ct 'meat', 0).toBe 1
    expect(ct 'meat', 1).toBe 1
    expect(ct 'meat', 9.5).toBe 1
  it 'calculates a single resource\'s value over time (drone:1)', ->
    game = mkgame {drone:1}
    expect(ct 'meat', 0).toBe 0
    expect(ct 'meat', 1).toBe 1
    expect(ct 'meat', 9.5).toBe 9.5
  it 'calculates a single resource\'s velocity (drone:1)', ->
    game = mkgame {drone:1}
    expect(game.unit('meat').velocity().toNumber()).toBe 1
    expect(game.unit('drone').velocity().toNumber()).toBe 0
  it 'calculates a single resource\'s value over time (meat:3,drone:2)', ->
    game = mkgame {meat:3, drone:2}
    expect(ct 'meat', 0).toBe 3
    expect(ct 'meat', 1).toBe 5
    expect(ct 'meat', 9.5).toBe 22
  it 'calculates a single resource\'s value over time (queen:1)', ->
    game = mkgame {queen:1} # gen 2; a/2*t^2
    # TODO looking up production-values sucks. Can we make a test-specific
    # unittype spreadsheet? We're testing the engine here, not specific values.
    c = unittypes.byName.queen.prod[0].val
    expect(ct 'meat', 0).toBe 0
    expect(ct 'meat', 1).toBe 0.5 * c
    expect(ct 'meat', 4).toBe 8 * c
    expect(ct 'meat', 10).toBe 50 * c
    game.now = new Date 0
    expect(ct 'drone', 0).toBe 0
    expect(ct 'drone', 1).toBe 1 * c
    expect(ct 'drone', 9.5).toBe 9.5 * c
  it 'calculates a single resource\'s value over time (nest:1)', ->
    game = mkgame {nest:1} # gen 3; j/6*t^3
    c = unittypes.byName.queen.prod[0].val * unittypes.byName.nest.prod[0].val
    expect(ct 'meat', 0).toBe 0
    expect(ct 'meat', 1).toBe 1/6 * c
    expect(ct 'meat', 4).toBe 64/6 * c
    expect(ct 'meat', 10).toBe 1000/6 * c
  it 'calculates a single resource\'s value over time (nest:2,queen:3,drone:4,meat:5)', ->
    game = mkgame {nest:2,queen:3,drone:4,meat:5}
    qc = unittypes.byName.queen.prod[0].val
    nc = qc * unittypes.byName.nest.prod[0].val
    expect(ct 'meat', 0).toBe 5
    expect(ct 'meat', 1).toBe 1/6*2*nc + 1/2*3*qc + 1*4 + 5
    expect(ct 'meat', 4).toBe 64/6*2*nc + 8*3*qc + 4*4 + 5
    expect(ct 'meat', 10).toBe 1000/6*2*nc + 50*3*qc + 10*4 + 5

  it 'calculates costs', ->
    game = mkgame {larva:100,meat:25}
    expect(game.unit('drone').maxCostMet().toNumber()).toBe 2
    expect(game.unit('drone').isCostMet()).toBe true
    game = mkgame {larva:100,meat:9.99}
    expect(game.unit('drone').maxCostMet().toNumber()).toBe 0
    expect(game.unit('drone').isCostMet()).toBe false

  it 'hides advanced units', ->
    game = mkgame {larva:100,meat:1}
    expect(game.unit('drone').isVisible()).toBe true
    expect(game.unit('queen').isVisible()).toBe false
    game.unit('drone')._addCount 9
    expect(game.unit('drone').isVisible()).toBe true
    expect(game.unit('queen').isVisible()).toBe false
    game.unit('drone')._addCount 1
    expect(game.unit('drone').isVisible()).toBe true
    expect(game.unit('queen').isVisible()).toBe true
    game.unit('drone')._subtractCount 1
    expect(game.unit('drone').isVisible()).toBe true
    expect(game.unit('queen').isVisible()).toBe true # we saw it once before

  it 'calcs unit stats', ->
    game = mkgame {drone:99999999999999}
    unit = game.unit 'drone'
    unit2 = game.unit 'queen'
    upgrade = game.upgrade 'droneprod'
    expect(unit.stats().prod.toNumber()).toBe 1
    expect(unit2.stats().prod.toNumber()).toBe 1
    expect(unit.stats()).toBe unit.stats()
    upgrade.buy()
    expect(unit.stats().prod.toNumber()).toBeGreaterThan 1
    expect(unit2.stats().prod.toNumber()).toBe 1

  it 'pukes for nonexistent stats', ->
    game = mkgame {}
    unit = game.unit 'drone'
    expect(-> unit.stat 'jflksdfjdslkfhdljkhfdksjh').toThrow()

  it 'buys multiplicative twin units (meat)', ->
    game = mkgame {larva:9999999,meat:9999999,drone:99999999999999, queen:9999999999999}
    unit = game.unit 'drone'
    upgrade = game.upgrade 'dronetwin'
    expect(unit.twinMult().toNumber()).toBe 1
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 1

    withNoTick game, -> upgrade.buy()
    expect(unit.twinMult().toNumber()).toBe 2
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 2
    withNoTick game, -> unit.buy 5
    expect(unit.count().toNumber()).toBe count + 12

    withNoTick game, -> upgrade.buy()
    expect(unit.twinMult().toNumber()).toBe 4
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 4
    withNoTick game, -> unit.buy 5
    expect(unit.count().toNumber()).toBe count + 24

  it 'buys multiplicative twin units (military)', ->
    game = mkgame {larva:9999999,meat:9999999,swarmling:0, queen:5}
    unit = game.unit 'swarmling'
    upgrade = game.upgrade 'swarmlingtwin'
    expect(unit.twinMult().toNumber()).toBe 1
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 1

    withNoTick game, -> upgrade.buy()
    expect(unit.twinMult().toNumber()).toBe 2
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 2
    withNoTick game, -> unit.buy 5
    expect(unit.count().toNumber()).toBe count + 12

    withNoTick game, -> upgrade.buy()
    expect(unit.twinMult().toNumber()).toBe 4
    count = unit.count().toNumber()
    withNoTick game, -> unit.buy 1
    expect(unit.count().toNumber()).toBe count + 4
    withNoTick game, -> unit.buy 5
    expect(unit.count().toNumber()).toBe count + 24

  it 'multiplies production', ->
    drone0 = 1000000
    game = mkgame {larva:9999999,meat:9999999,drone:drone0}
    unit = game.unit 'drone'
    upgrade = game.upgrade 'droneprod'
    expect(unit.stat('prod').toNumber()).toBe 1
    game.tick new Date 1000
    prod0 = withNoTick game, -> unit.totalProduction()
    game.now = new Date 0

    upgrade._addCount 1
    expect(unit.stat('prod').toNumber()).toBeGreaterThan 1
    game.tick new Date 1000
    prod1 = withNoTick game, -> unit.totalProduction()
    expect(prod0.meat.times(unit.stat 'prod').toNumber()).toBe prod1.meat.toNumber()

  it 'parses unit requirements', ->
    game = mkgame {meat:1000000000000000000000000000000000000000, nexus:4}
    unit = game.unit 'cocoon'
    larva = game.unit 'larva'
    upgrade = game.upgrade 'cocooning'
    expect(unit.requires.length).toBeGreaterThan 0
    expect(unit.requires[0].unit).toBeUndefined()
    expect(unit.requires[0].upgrade.name).toBe upgrade.name
    expect(unit.requires[0].resource.name).toBe upgrade.name
    expect(upgrade.count().toNumber()).toBe 0
    expect(unit.isVisible()).toBe false
    expect(upgrade.isVisible()).toBe true
    expect(larva.isBuyButtonVisible()).toBe false
    expect(upgrade.maxCostMet().toNumber()).toBe 1 #because...
    expect(upgrade.type.maxlevel).toBe 1
    upgrade.buy()
    expect(upgrade.count().toNumber()).toBe 1
    expect(unit.isVisible()).toBe true
    expect(larva.isBuyButtonVisible()).toBe true
    expect(upgrade.isVisible()).toBe false #because...
    expect(upgrade.count().toNumber()).toBe upgrade.type.maxlevel

  it 'parses OR unit requirements', ->
    game = mkgame {mutagen:1}
    expect(game.unit('mutagen').isVisible()).toBe true
    expect(game.unit('premutagen').isVisible()).toBe true
    game = mkgame {premutagen:1}
    expect(game.unit('mutagen').isVisible()).toBe true
    expect(game.unit('premutagen').isVisible()).toBe true
    game = mkgame {ascension:1}
    expect(game.unit('mutagen').isVisible()).toBe true
    expect(game.unit('premutagen').isVisible()).toBe true
    game = mkgame {}
    expect(game.unit('mutagen').isVisible()).toBe false
    expect(game.unit('premutagen').isVisible()).toBe false

  it 'caps energy', ->
    game = mkgame {energy:1000000000000000000000000000000000000000, nexus:5}
    unit = game.unit 'energy'
    expect(unit.capValue().toNumber()).toBe 50000
    expect(unit.count().toNumber()).toBe 50000
    expect(unit.capPercent().toNumber()).toBe 1
    expect(unit.capDurationSeconds()).toBe 0
    unit._setCount 50
    expect(unit.capValue().toNumber()).toBe 50000
    expect(unit.count().toNumber()).toBe 50
    expect(unit.capPercent().toNumber()).toBe 0.001
    expect(unit.capDurationSeconds()).toBe 99900
    expect(unit.capDurationMoment().humanize(true)).toBe 'in a day'
  it 'doesnt cap meat', ->
    game = mkgame {meat:1000000000000000000000000000000000000000}
    unit = game.unit 'meat'
    expect(unit.capValue()).toBeUndefined()
    expect(unit.count().toNumber()).toBe 1000000000000000000000000000000000000000
    expect(unit.capPercent()).toBeUndefined()
    expect(unit.capDurationSeconds()).toBeUndefined()

  it 'increases cost of empowered military units', ->
    game = mkgame {meat:1e40, larva: 1e40, queen:5}
    ling = game.unit 'swarmling'
    meat = game.unit 'meat'
    meatcount = meat.count().toNumber()
    empower = game.upgrade 'swarmlingempower'
    expect(ling.count().toNumber()).toBe 0

    lingmax = ling.maxCostMet()
    cost1 = _.indexBy ling.eachCost(), (c) -> c.unit.name
    ling.buy(10)
    expect(ling.count().toNumber()).toBe 10
    expect(meat.count().toNumber()).not.toBeLessThan meatcount - 750000000
    expect(ling.suffix).toBe ''

    empower.buy()
    meat._setCount(meatcount)
    ling.stats() # kick stats so the suffix works
    expect(ling.suffix).toBe 'II' # empowering sets a suffix
    expect(ling.count().toNumber()).toBe 0  # empowering destroys all units
    # empowering increases cost
    cost2 = _.indexBy ling.eachCost(), (c) -> c.unit.name
    expect(cost1.meat.val.toNumber()).toBeLessThan cost2.meat.val.toNumber()
    expect(cost1.larva.val.toNumber()).toEqual cost2.larva.val.toNumber()
    expect(ling.maxCostMet().toNumber()).toBeLessThan lingmax
    ling.buy(10)
    expect(ling.count().toNumber()).toBe 10
    expect(meat.count().toNumber()).toBeLessThan meatcount - 750000000 # really does cost more than unempowered

  it 'calculates stats from unit-effects', ->
    game = mkgame {energy:0, nexus: 1, nightbug:0}
    [energy, nexus, nightbug] = _.map ['energy', 'nexus', 'nightbug'], (name) -> game.unit name
    expect(energy._getCap().toNumber()).toBe 10000
    nexus._setCount 2
    expect(energy._getCap().toNumber()).toBe 20000
    nightbug._setCount 250
    expect(energy._getCap().toNumber()).toBe 40000

  it 'calculates resources spent for units', ->
    game = mkgame {meat:0, drone:3}
    meat = game.unit 'meat'
    expect(meat.spent().toNumber()).toBe 30

  it 'calculates resources spent for upgrades', ->
    game = mkgame {meat:0, drone:3}
    game.upgrade('hatchery')._setCount 1
    meat = game.unit 'meat'
    expect(meat.spent().toNumber()).toBe 330
    game.upgrade('hatchery')._setCount 3
    expect(meat.spent().toNumber()).toBe 33330

  it 'caps units globally and exceeds the JS max', ->
    game = mkgame {meat:'1e9999999'}
    expect(game.unit('meat').count()+'').toBe '1e+100000'

  it 'finds max production polynomial', ->
    game = mkgame {hive:'1'}
    expect(game.unit('hive')._producerPath.getMaxDegree()).toBe 0
    expect(game.unit('hivequeen')._producerPath.getMaxDegree()).toBe 0
    expect(game.unit('energy')._producerPath.getMaxDegree()).toBe 0
    expect(game.unit('greaterqueen')._producerPath.getMaxDegree()).toBe 1
    expect(game.unit('nest')._producerPath.getMaxDegree()).toBe 2
    expect(game.unit('queen')._producerPath.getMaxDegree()).toBe 3
    expect(game.unit('drone')._producerPath.getMaxDegree()).toBe 4
    expect(game.unit('meat')._producerPath.getMaxDegree()).toBe 5

  it 'estimates production', ->
    game = mkgame {hive:'1'}
    # 100 = 5 * t^1/1! ; t = 20
    unit = game.unit('greaterqueen')
    expect(unit._producerPath.getMaxDegree()).toBe 1
    expect(JSON.stringify unit._producerPath.getCoefficients()).toEqual JSON.stringify ['0','5']
    expect(unit.isEstimateCacheable()).toBe true
    expect(unit.isEstimateExact()).toBe true
    expect(unit.estimateSecsUntilEarned(100).toNumber()).toBe 20
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 100
    # 4000 = 5*4 * t^2/2! ; t^2 = 4000 * 2 / 20 = 400 ; t = 20
    unit = game.unit('nest')
    expect(unit._producerPath.getMaxDegree()).toBe 2
    expect(JSON.stringify unit._producerPath.getCoefficients()).toEqual JSON.stringify ['0','0','20']
    expect(unit.isEstimateCacheable()).toBe true
    expect(unit.isEstimateExact()).toBe true
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toBe 20
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000
    # 80000 = 5*4*3 * t^3/3!
    # estimtes stop being exact at degree 3, but let's at least do better than linear
    unit = game.unit('queen')
    expect(unit._producerPath.getMaxDegree()).toBe 3
    expect(JSON.stringify unit._producerPath.getCoefficients()).toEqual JSON.stringify ['0','0','0','60']
    expect(unit.isEstimateCacheable()).toBe true
    #expect(unit.isEstimateExact()).toBe false
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).not.toBeLessThan 19.8
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).not.toBeGreaterThan 30
    # 10000 = 5*4*3*2 * t^4/4!
    unit = game.unit('drone')
    expect(unit._producerPath.getMaxDegree()).toBe 4
    expect(JSON.stringify unit._producerPath.getCoefficients()).toEqual JSON.stringify ['0','0','0','0','120']
    expect(unit.isEstimateCacheable()).toBe true
    #expect(unit.isEstimateExact()).toBe false
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 800000
    expect(unit.estimateSecsUntilEarned(800000).toNumber()).not.toBeLessThan 19.8
    expect(unit.estimateSecsUntilEarned(800000).toNumber()).not.toBeGreaterThan 30
    # 10000 = 5*4*3*2*1 * t^5/5!
    unit = game.unit('meat')
    expect(unit._producerPath.getMaxDegree()).toBe 5
    expect(JSON.stringify unit._producerPath.getCoefficients()).toEqual JSON.stringify ['0','0','0','0','0','120']
    expect(unit.isEstimateCacheable()).toBe true
    #expect(unit.isEstimateExact()).toBe false
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 3200000
    expect(unit.estimateSecsUntilEarned(3200000).toNumber()).not.toBeLessThan 19.8
    expect(unit.estimateSecsUntilEarned(3200000).toNumber()).not.toBeGreaterThan 30

  fuzzyEquals = (threshold=0.2) ->
    return (one, two) ->
      if typeof(one)==typeof(two)=="number"
        return Math.abs(one - two) <= threshold
  it 'makes smooth quadratic predictions', ->
    jasmine.addCustomEqualityTester fuzzyEquals(0.2)
    game = mkgame {hive:'1'}
    unit = game.unit('nest')
    expect(unit._producerPath.getMaxDegree()).toBe 2
    expect(unit.isEstimateCacheable()).toBe true
    #expect(unit.isEstimateExact()).toBe true
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toEqual 20
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toEqual 15
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toEqual 10
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toEqual 5
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000
    game.tick new Date(game.now.getTime() + 3000)
    expect(unit.estimateSecsUntilEarned(4000).toNumber()).toEqual 2
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 4000

  it 'makes smooth cubic predictions', ->
    jasmine.addCustomEqualityTester fuzzyEquals(0.2)
    game = mkgame {hive:'1'}
    unit = game.unit('queen')
    expect(unit._producerPath.getMaxDegree()).toBe 3
    expect(unit.isEstimateCacheable()).toBe true
    #expect(unit.isEstimateExact()).toBe false
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).toEqual 20
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).toEqual 15
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).toEqual 10
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000
    game.tick new Date(game.now.getTime() + 5000)
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).toEqual 5
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000
    game.tick new Date(game.now.getTime() + 3000)
    expect(unit.estimateSecsUntilEarned(80000).toNumber()).toEqual 2
    expect(unit._countInSecsFromReified(20).toNumber()).toBe 80000

  it 'ignores fractional unit production', ->
    game = mkgame {queen:'0.99'}
    queen = game.unit('queen')
    drone = game.unit('drone')
    expect(drone.velocity().toNumber()).toBe 0
    expect(queen.totalProduction().drone.toNumber()).toBe 0
    game.unit('queen')._setCount '1.99'
    expect(drone.velocity().toNumber()).toBe 2
    expect(queen.totalProduction().drone.toNumber()).toBe 2
    game.unit('queen')._setCount '2'
    expect(drone.velocity().toNumber()).toBe 4
    expect(queen.totalProduction().drone.toNumber()).toBe 4
