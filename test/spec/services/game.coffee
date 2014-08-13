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
    expect(game.diffMillis new Date 1000).toBe 0
    expect(game.diffSeconds new Date 1000).toBe 0
    expect(game.diffMillis new Date 2000).toBe 1000
    expect(game.diffSeconds new Date 2000).toBe 1
    expect(game.diffMillis new Date 3500).toBe 2500
    expect(game.diffSeconds new Date 3500).toBe 2.5

  mkgame = (unittypes) ->
    new Game {unittypes: unittypes}

  it 'calculates a single resource\'s value over time (meat:1)', ->
    game = mkgame {meat:1}
    expect(game.count 'meat', 0).toBe 1
    expect(game.count 'meat', 1).toBe 1
    expect(game.count 'meat', 9.5).toBe 1
  it 'calculates a single resource\'s value over time (drone:1)', ->
    game = mkgame {drone:1}
    expect(game.count 'meat', 0).toBe 0
    expect(game.count 'meat', 1).toBe 1
    expect(game.count 'meat', 9.5).toBe 9.5
  it 'calculates a single resource\'s value over time (meat:3,drone:2)', ->
    game = mkgame {meat:3, drone:2}
    expect(game.count 'meat', 0).toBe 3
    expect(game.count 'meat', 1).toBe 5
    expect(game.count 'meat', 9.5).toBe 22
  it 'calculates a single resource\'s value over time (queen:1)', ->
    game = mkgame {queen:1} # gen 2; a/2*t^2
    expect(game.count 'meat', 0).toBe 0
    expect(game.count 'meat', 1).toBe 0.5
    expect(game.count 'meat', 4).toBe 8
    expect(game.count 'meat', 10).toBe 50
    expect(game.count 'drone', 0).toBe 0
    expect(game.count 'drone', 1).toBe 1
    expect(game.count 'drone', 9.5).toBe 9.5
  it 'calculates a single resource\'s value over time (nest:1)', ->
    game = mkgame {nest:1} # gen 3; j/6*t^3
    expect(game.count 'meat', 0).toBe 0
    expect(game.count 'meat', 1).toBe 1/6
    expect(game.count 'meat', 4).toBe 64/6
    expect(game.count 'meat', 10).toBe 1000/6
  it 'calculates a single resource\'s value over time (nest:2,queen:3,drone:4,meat:5)', ->
    game = mkgame {nest:2,queen:3,drone:4,meat:5}
    expect(game.count 'meat', 0).toBe 5
    #expect(game.count 'meat', 1).toBe 1/6*2 + 1/2*3 + 1*4 + 5 #TODO: floating point error
    expect(game.count 'meat', 4).toBe 64/6*2 + 8*3 + 4*4 + 5
    expect(game.count 'meat', 10).toBe 1000/6*2 + 50*3 + 10*4 + 5

  it 'calculates costs', ->
    game = new Game {unittypes:{larva:100,meat:25},date:{reified:new Date(0)}}
    expect(game.unit('drone').maxCostMet()).toBe 2
    expect(game.unit('drone').isCostMet()).toBe true
    game = new Game {unittypes:{larva:100,meat:9.99},date:{reified:new Date(0)}}
    expect(game.unit('drone').maxCostMet()).toBe 0
    expect(game.unit('drone').isCostMet()).toBe false
