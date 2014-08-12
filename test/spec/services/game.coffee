'use strict'

describe 'Service: game', ->

  # load the service's module
  beforeEach module 'swarmApp'

  # instantiate service
  #game = {}
  Game = {}
  dt = {}
  unittypes = {}
  beforeEach inject (_game_, _Game_, _dt_, _unittypes_) ->
    #game = _game_
    Game = _Game_
    dt = _dt_
    unittypes = _unittypes_

  it 'should do something', ->
    expect(!!Game).toBe true

  it 'diffs ticks', ->
    game = new Game date: saved: new Date 1000
    expect(dt).toBe 1/10
    expect(game.diffMillis new Date 1000).toBe 0
    expect(game.diffTicks new Date 1000).toBe 0
    expect(game.diffMillis new Date 2000).toBe 1000
    expect(game.diffTicks new Date 2000).toBe 10

  # Gains should match pascal's triangle.
  # https://en.wikipedia.org/wiki/Pascal's_triangle
  # This post explains it: http://www.reddit.com/r/incremental_games/comments/2co88i/ive_been_playing_adventure_capitalist_for_the/cji9fmm
  it 'calculates single generation\'s gains (1)', ->
    game = new Game {}
    # gen1, 1st derivative. Linear gains.
    for val, tick in [0,1,2,3,4,5,6,7]
      expect(game.gainsOne tick, 1).toBe val
  it 'calculates single generation\'s gains (2)', ->
    game = new Game {}
    # gen2, 2nd derivative. We start seeing pascal's here. No gains at the beginning.
    for val, tick in [0,0,1,3,6,10,15,21]
      expect(game.gainsOne tick, 2).toBe val
  it 'calculates single generation\'s gains (3)', ->
    game = new Game {}
    # gen3, 3nd derivative
    for val, tick in [0,0,0,1,4,10,20,35]
      expect(tick).toBeLessThan 10 # "for value, index" keeps messing me up...
      expect(game.gainsOne tick, 3).toBe val

describe 'Service: game gains rates', ->
  # load the service's module
  beforeEach module 'swarmApp', ($provide) ->
    $provide.value 'dt', 1
    null

  # instantiate service
  Game = {}
  dt = {}
  unittypes = {}
  beforeEach inject (_Game_, _dt_, _unittypes_) ->
    Game = _Game_
    dt = _dt_
    unittypes = _unittypes_

  mkgame = (unittypes) ->
    new Game {unittypes: unittypes}
  it 'finds parentage trees', ->
    game = mkgame {meat:1,drone:1,queen:2, nest:2}
    expect(game.children unittypes.byName.meat).toEqual {}
    expect(game.children unittypes.byName.drone).toEqual {meat:{name:'meat',gen:1,rate:1}}
    expect(game.children unittypes.byName.queen).toEqual {meat:{name:'meat',gen:2,rate:1}, drone:{name:'drone',gen:1,rate:1}}
    expect(game.children unittypes.byName.nest).toEqual {meat:{name:'meat',gen:3,rate:1}, drone:{name:'drone',gen:2,rate:1}, queen:{name:'queen',gen:1,rate:1}}

  it 'finds single gains-rate trees (1s)', ->
    game = mkgame {meat:1, drone:1, queen:1, nest:1}
    expect(game.gainsTableOne unittypes.byName.meat, 1).toEqual {}
    expect(game.gainsTableOne unittypes.byName.meat, 10).toEqual {}
    expect(game.gainsTableOne unittypes.byName.drone, 1).toEqual {meat:1}
    expect(game.gainsTableOne unittypes.byName.drone, 10).toEqual {meat:10}
    expect(game.gainsTableOne unittypes.byName.queen, 1).toEqual {meat:0, drone:1}
    expect(game.gainsTableOne unittypes.byName.queen, 2).toEqual {meat:1, drone:2}
    expect(game.gainsTableOne unittypes.byName.queen, 3).toEqual {meat:3, drone:3}
    expect(game.gainsTableOne unittypes.byName.queen, 4).toEqual {meat:6, drone:4}
    expect(game.gainsTableOne unittypes.byName.nest, 1).toEqual {meat:0, drone:0, queen:1}
    expect(game.gainsTableOne unittypes.byName.nest, 2).toEqual {meat:0, drone:1, queen:2}
    expect(game.gainsTableOne unittypes.byName.nest, 3).toEqual {meat:1, drone:3, queen:3}
    expect(game.gainsTableOne unittypes.byName.nest, 4).toEqual {meat:4, drone:6, queen:4}
    expect(game.gainsTableOne unittypes.byName.nest, 5).toEqual {meat:10, drone:10, queen:5}

  it 'finds single gains-rate trees (2s)', ->
    game = mkgame {meat:1, drone:1, queen:2, nest:2}
    expect(game.gainsTableOne unittypes.byName.meat, 1).toEqual {}
    expect(game.gainsTableOne unittypes.byName.meat, 10).toEqual {}
    expect(game.gainsTableOne unittypes.byName.drone, 1).toEqual {meat:1}
    expect(game.gainsTableOne unittypes.byName.drone, 10).toEqual {meat:10}
    expect(game.gainsTableOne unittypes.byName.queen, 1).toEqual {meat:0, drone:2}
    expect(game.gainsTableOne unittypes.byName.queen, 2).toEqual {meat:2, drone:4}
    expect(game.gainsTableOne unittypes.byName.queen, 3).toEqual {meat:6, drone:6}
    expect(game.gainsTableOne unittypes.byName.queen, 4).toEqual {meat:12, drone:8}
    expect(game.gainsTableOne unittypes.byName.nest, 1).toEqual {meat:0, drone:0, queen:2}
    expect(game.gainsTableOne unittypes.byName.nest, 2).toEqual {meat:0, drone:2, queen:4}
    expect(game.gainsTableOne unittypes.byName.nest, 3).toEqual {meat:2, drone:6, queen:6}
    expect(game.gainsTableOne unittypes.byName.nest, 4).toEqual {meat:8, drone:12, queen:8}
    expect(game.gainsTableOne unittypes.byName.nest, 5).toEqual {meat:20, drone:20, queen:10}

  it 'finds single gains-rate trees (one nest)', ->
    game = mkgame {nest:1}
    expect(game.gainsTableOne unittypes.byName.meat, 1).toEqual {}
    expect(game.gainsTableOne unittypes.byName.meat, 10).toEqual {}
    expect(game.gainsTableOne unittypes.byName.drone, 1).toEqual {meat:0}
    expect(game.gainsTableOne unittypes.byName.drone, 10).toEqual {meat:0}
    expect(game.gainsTableOne unittypes.byName.queen, 1).toEqual {meat:0, drone:0}
    expect(game.gainsTableOne unittypes.byName.queen, 10).toEqual {meat:0, drone:0}
    expect(game.gainsTableOne unittypes.byName.nest, 1).toEqual {meat:0, drone:0, queen:1}
    expect(game.gainsTableOne unittypes.byName.nest, 2).toEqual {meat:0, drone:1, queen:2}
    expect(game.gainsTableOne unittypes.byName.nest, 3).toEqual {meat:1, drone:3, queen:3}
    expect(game.gainsTableOne unittypes.byName.nest, 4).toEqual {meat:4, drone:6, queen:4}
    expect(game.gainsTableOne unittypes.byName.nest, 5).toEqual {meat:10, drone:10, queen:5}

  it 'finds single gains-rate trees (two nest)', ->
    game = mkgame {nest:2}
    expect(game.gainsTableOne unittypes.byName.meat, 1).toEqual {}
    expect(game.gainsTableOne unittypes.byName.meat, 10).toEqual {}
    expect(game.gainsTableOne unittypes.byName.drone, 1).toEqual {meat:0}
    expect(game.gainsTableOne unittypes.byName.drone, 10).toEqual {meat:0}
    expect(game.gainsTableOne unittypes.byName.queen, 1).toEqual {meat:0, drone:0}
    expect(game.gainsTableOne unittypes.byName.queen, 10).toEqual {meat:0, drone:0}
    expect(game.gainsTableOne unittypes.byName.nest, 1).toEqual {meat:0, drone:0, queen:2}
    expect(game.gainsTableOne unittypes.byName.nest, 2).toEqual {meat:0, drone:2, queen:4}
    expect(game.gainsTableOne unittypes.byName.nest, 3).toEqual {meat:2, drone:6, queen:6}
    expect(game.gainsTableOne unittypes.byName.nest, 4).toEqual {meat:8, drone:12, queen:8}
    expect(game.gainsTableOne unittypes.byName.nest, 5).toEqual {meat:20, drone:20, queen:10}

  keys = ['meat','drone','queen','nest']
  it 'finds the whole gains table (meat1)', ->
    game = mkgame {meat:1}
    expect(_.pick game.gainsTable(1), keys).toEqual {meat:1, drone:0, queen:0, nest:0}
    expect(_.pick game.gainsTable(10), keys).toEqual {meat:1, drone:0, queen:0, nest:0}
  it 'finds the whole gains table (drone1)', ->
    game = mkgame {drone:1}
    expect(_.pick game.gainsTable(1), keys).toEqual {meat:1, drone:1, queen:0, nest:0}
    expect(_.pick game.gainsTable(10), keys).toEqual {meat:10, drone:1, queen:0, nest:0}
  it 'finds the whole gains table (queen1)', ->
    game = mkgame {queen:1}
    expect(_.pick game.gainsTable(1), keys).toEqual {meat:0, drone:1, queen:1, nest:0}
    expect(_.pick game.gainsTable(2), keys).toEqual {meat:1, drone:2, queen:1, nest:0}
    expect(_.pick game.gainsTable(3), keys).toEqual {meat:3, drone:3, queen:1, nest:0}
    expect(_.pick game.gainsTable(4), keys).toEqual {meat:6, drone:4, queen:1, nest:0}
  it 'finds the whole gains table (nest1)', ->
    game = mkgame {nest:1}
    expect(_.pick game.gainsTable(1), keys).toEqual {meat:0, drone:0, queen:1, nest:1}
    expect(_.pick game.gainsTable(2), keys).toEqual {meat:0, drone:1, queen:2, nest:1}
    expect(_.pick game.gainsTable(3), keys).toEqual {meat:1, drone:3, queen:3, nest:1}
    expect(_.pick game.gainsTable(4), keys).toEqual {meat:4, drone:6, queen:4, nest:1}
    expect(_.pick game.gainsTable(5), keys).toEqual {meat:10, drone:10, queen:5, nest:1}
  it 'finds the whole gains table (queen2nest1)', ->
    game = mkgame {queen:2,nest:1}
    expect(_.pick game.gainsTable(1), keys).toEqual {meat:0, drone:2, queen:3, nest:1}
    expect(_.pick game.gainsTable(2), keys).toEqual {meat:2, drone:5, queen:4, nest:1}
    expect(_.pick game.gainsTable(3), keys).toEqual {meat:7, drone:9, queen:5, nest:1}
    expect(_.pick game.gainsTable(4), keys).toEqual {meat:16, drone:14, queen:6, nest:1}
    expect(_.pick game.gainsTable(5), keys).toEqual {meat:30, drone:20, queen:7, nest:1}
