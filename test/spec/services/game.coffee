'use strict'

describe 'Service: game', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  #game = {}
  Game = {}
  unittypes = {}
  beforeEach inject (_Game_, _unittypes_) ->
    #game = _game_
    Game = _Game_
    unittypes = _unittypes_
  mkgame = (unittypes, reified=new Date 0) ->
    game = new Game {state:{unittypes: unittypes, upgrades:{}, date:{reified:reified,started:reified,restarted:reified}}, save:->}
    game.now = new Date 0
    return game

  it 'should do something', ->
    expect(!!Game).toBe true

  it 'diffs seconds', ->
    game = new Game state: date: reified: new Date 1000
    game.now = new Date 0
    game.tick new Date 1000
    expect(game.diffMillis()).toBe 0
    expect(game.diffSeconds()).toBe 0
    game.tick new Date 2000
    expect(game.diffMillis()).toBe 1000
    expect(game.diffSeconds()).toBe 1
    game.tick new Date 3500
    expect(game.diffMillis()).toBe 2500
    expect(game.diffSeconds()).toBe 2.5

  it 'recovers NaN saves', ->
    game = mkgame {larva:NaN,meat:9999999,drone:99999}
    expect(game.unit('larva').count().toNumber()).toBe 0

describe 'Service: game achievements', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  Game = {}
  unittypes = {}
  statistics = {}
  scope = {}
  beforeEach inject (_Game_, _unittypes_, _statistics_, $rootScope) ->
    Game = _Game_
    unittypes = _unittypes_
    statistics = _statistics_
    scope = $rootScope.$new()
  mkgame = (unittypes, reified=new Date 0) ->
    game = new Game {state:{unittypes: unittypes, upgrades:{}, date:{reified:reified,started:reified,restarted:reified}}, save:->}
    game.now = new Date 0
    return game

  it 'just emits', (done) ->
    scope.$on 'hihi', ->
      done()
    scope.$emit 'hihi'

  # TODO commands and scope.emit is required
  xit 'grants unit-based achievements', ->
    game = mkgame {meat:999999999999999999999999, larva:9999999999999999999}
    drone = game.unit 'drone'
    expect(drone.count()).toBe 0
    expect(game.achievement('drone1').isEarned()).toBe false
    expect(game.achievement('drone2').isEarned()).toBe false
    expect(game.achievement('queen1').isEarned()).toBe false
    expect(game.achievementPoints()).toBe 0
    drone.buy 1
    expect(drone.count()).toBe 1
    expect(game.achievement('drone1').isEarned()).toBe true
    expect(game.achievement('drone2').isEarned()).toBe false
    expect(game.achievement('queen1').isEarned()).toBe false
    expect(game.achievementPoints()).toBe 10
    
  xit 'doesn\'t count queen-produced drones toward achievevements', ->
    game = mkgame {meat: 99999999999, queen:999999, larva:999999999}
    drone = game.unit 'drone'
    expect(game.achievement('drone2').isEarned()).toBe false
    expect(drone.statistics().twinnum).toBe 0
    expect(ct 'drone', 10).toBeGreaterThan 500
    # buying one doesn't count the others either
    drone.buy 1
    expect(game.achievement('drone2').isEarned()).toBe false
    expect(drone.statistics().twinnum).toBe 1

  xit 'grants upgrade-based achievements', ->
    game = mkgame {territory:99999999999999999999999999}
    upgrade = game.upgrade 'expansion'
    expect(game.achievement('expansion1').isEarned()).toBe false
    expect(game.achievement('expansion2').isEarned()).toBe false
    expect(game.achievementPoints()).toBe 0
    upgrade.buy()
    expect(game.achievement('expansion1').isEarned()).toBe true
    expect(game.achievement('expansion2').isEarned()).toBe false
    expect(game.achievementPoints()).toBe 10
    
  it 'respecs mutagen', ->
    game = mkgame {mutagen:100000, ascension:1,nexus:'1e999',energy:'1e999'}
    mutagen = game.unit 'mutagen'
    mutant = game.unit 'mutanthatchery'
    mutant2 = game.unit 'mutantbat'
    expect(mutant.count().toNumber()).toBe 0
    expect(mutant2.count().toNumber()).toBe 0
    game.upgrade('mutatehatchery').buy()
    game.upgrade('mutatebat').buy()
    expect(mutant.count().toNumber()).toBe 1
    expect(mutant2.count().toNumber()).toBe 1
    mutant.buy 39998
    mutant2.buy 40000
    expect(mutant.count().toNumber()).toBe 39999
    expect(mutant2.count().toNumber()).toBe 40001
    expect(mutagen.count().toNumber()).toBe 4376 # upgrades cost 1 + 15625 - 2 free upgrade-units = 15624
    expect(game.respecSpent().toNumber()).toBe 95624
    game.respec()
    expect(mutant.count().toNumber()).toBe 0
    expect(mutant2.count().toNumber()).toBe 0
    expect(mutagen.count().toNumber()).toBe 100000 # 100% refunded

  it 'has sane ascension costs', ->
    game = mkgame {nexus:1e100, energy:1e100}
    ascends = game.unit 'ascension'
    warps = game.upgrade 'swarmwarp'
    mutants = game.unit 'mutantnexus'
    expect(game.ascendEnergySpent().toNumber()).toBe 0
    expect(game.ascendCost().toNumber()).toBe 5000000
    ascends._setCount 1
    expect(game.ascendCost().toNumber()).toBe 5600000
    ascends._setCount 2
    expect(game.ascendCost().toNumber()).toBe 6272000
    ascends._setCount 0
    warps._setCount 25
    expect(game.ascendEnergySpent().toNumber()).toBe 50000
    expect(game.ascendCost().toNumber()).toBe 2500000
    warps._setCount 50
    expect(game.ascendEnergySpent().toNumber()).toBe 100000
    expect(game.ascendCost().toNumber()).toBe 1250000
    warps._setCount 75
    expect(game.ascendEnergySpent().toNumber()).toBe 150000
    expect(game.ascendCost().toNumber()).toBe 625000
    ascends._setCount 1
    expect(game.ascendEnergySpent().toNumber()).toBe 150000
    expect(game.ascendCost().toNumber()).toBe 700000
    # mutant lepidoptera increase ascension cost (compensating for increased energy gains)
    mutants._setCount 1000
    expect(game.ascendEnergySpent().toNumber()).toBe 150000
    expect(game.ascendCost().toNumber()).toBe 989950
    # free-respec doesn't reset spent energy
    game.unit('freeRespec')._setCount game.unit('freeRespec').unittype.init #backfill covers this for existing folks
    expect(game.unit('freeRespec').count().toNumber()).toBe 4
    game.respecFree()
    expect(mutants.count().toNumber()).toBe 0
    expect(game.unit('freeRespec').count().toNumber()).toBe 3
    expect(game.ascendCost().toNumber()).toBe 700000
    # respecing resets spent energy
    mutants._setCount 1000
    warps._setCount 400
    expect(game.respecCost().toNumber()).toBe 163
    game.respec()
    expect(mutants.count().toNumber()).toBe 0
    expect(game.ascendEnergySpent().toNumber()).toBe 163
    expect(game.ascendCost().toNumber()).toBe 5587361

  it "ascends", ->
    game = mkgame {drone:100, premutagen:100}
    expect(game.unit('ascension').count().toNumber()).toBe 0
    expect(game.unit('drone').count().toNumber()).toBe 100
    expect(game.unit('premutagen').count().toNumber()).toBe 100
    expect(game.unit('mutagen').count().toNumber()).toBe 0
    expect(game.unit('nexus').count().toNumber()).toBe 0
    expect(game.unit('energy').count().toNumber()).toBe 0
    expect(game.session.state.date.restarted.getTime()).toBe 0
    game.now = new Date 1
    expect(-> game.ascend()).toThrow()
    expect(game.unit('drone').count().toNumber()).toBe 100
    game.unit('nexus')._setCount 9e999
    game.unit('energy')._setCount 9e999
    game.ascend()
    expect(game.unit('ascension').count().toNumber()).toBe 1
    expect(game.unit('drone').count().toNumber()).toBe 0
    expect(game.unit('premutagen').count().toNumber()).toBe 0
    expect(game.unit('mutagen').count().toNumber()).toBe 100
    expect(game.unit('nexus').count().toNumber()).toBe 0
    expect(game.unit('energy').count().toNumber()).toBe 0
    expect(game.session.state.date.restarted.getTime()).toBe 1

