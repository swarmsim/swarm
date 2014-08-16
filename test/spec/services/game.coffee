'use strict'

describe 'Service: game', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  #game = {}
  Game = {}
  unittypes = {}
  beforeEach inject (_game_, _Game_, _unittypes_) ->
    #game = _game_
    Game = _Game_
    unittypes = _unittypes_

  it 'should do something', ->
    expect(!!Game).toBe true

  it 'diffs seconds', ->
    game = new Game date: reified: new Date 1000
    game.tick new Date 1000
    expect(game.diffMillis()).toBe 0
    expect(game.diffSeconds()).toBe 0
    game.tick new Date 2000
    expect(game.diffMillis()).toBe 1000
    expect(game.diffSeconds()).toBe 1
    game.tick new Date 3500
    expect(game.diffMillis()).toBe 2500
    expect(game.diffSeconds()).toBe 2.5

  game = {}
  mkgame = (unittypes, reified=new Date 0) ->
    new Game {unittypes: unittypes, date:{reified:reified}}

  ct = (name, dt) ->
    game.tick new Date dt*1000
    return game.unit(name).count()
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
    expect(game.unit('drone').maxCostMet()).toBe 2
    expect(game.unit('drone').isCostMet()).toBe true
    game = mkgame {larva:100,meat:9.99}
    expect(game.unit('drone').maxCostMet()).toBe 0
    expect(game.unit('drone').isCostMet()).toBe false

  it 'hides advanced units', ->
    game = mkgame {larva:100,meat:1}
    expect(game.unit('drone').isVisible()).toBe false
    expect(game.unit('queen').isVisible()).toBe false
    game.unit('meat')._addCount 8
    expect(game.unit('drone').isVisible()).toBe true
    expect(game.unit('queen').isVisible()).toBe false
    game.unit('meat')._subtractCount 8
    expect(game.unit('drone').isVisible()).toBe true # we saw it once before
    expect(game.unit('queen').isVisible()).toBe false
